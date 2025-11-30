---
title: I want a better action graph serialization
date: 2025-11-23
draft: true
description: We’ve learned a lot since Ninja was designed. Let’s build something better.
taxonomies:
  tags:
    - build-systems
    - ideas
extra:
  toc: 2
---
> As someone who ends up getting the ping on "my build is weird" _after_ it has gone through a round of "poke it with a stick", I would really appreciate the _mechanisms_ for \[correct dependency edges\] rolling out sooner rather than later.
> —[mathstuf](https://lobste.rs/s/uwyfpy/build_system_tradeoffs#c_ymm0ad)

> If I am even TEMPTED to use `sed`, in my goddamn build system, you have lost.
> —[Qyriad](https://chaos.social/@Qyriad/111349762684384063)
## what does "action graph" mean?
In [a previous post](https://jyn.dev/build-system-tradeoffs/), I talked about various approaches in the design space of build systems. In this post, I want to zero in on one particular area: action graphs.

First, let me define "action graph". If you've ever used CMake, you may know that there are two steps involved: A "configure" step (`cmake -B build-dir`) and a build step (`make` or `cmake --build`). What I am interested here is what `cmake -B` *generates*, the Makefiles it has created. As [the creator of ninja writes](https://neugierig.org/software/blog/2020/05/ninja.html#:~:text=Related%20work), this is a *serialization* of all build steps at a given moment in time, with the ability to regenerate the graph by rerunning the configure step.

This post explores that design space, with the goal of sketching a tool that improves on the current state while also enabling incremental adoption. When I say "design space", I mean a tool that:
- Is [non-hermetic](https://jyn.dev/build-system-tradeoffs/#hermetic-builds) (hermeticity is hard to adopt incrementally)
- Ingests machine-generated files, not hand-written files
- Has no persistent server
- Prioritizes performance
### who uses an action graph?
Not all build systems serialize their action graph. `bazel` and `buck2` run persistent servers that store it in memory and allow querying it, but never serialize it to disk. For large graphs, this requires a lot of memory; `blaze` has actually started [serializing parts of its graph to reduce memory usage and startup time](https://youtu.be/1A8LMZ21t6Y?si=FiQ6LGdBQ7Y-aQLY).

The nix evaluator doesn’t allow querying its graph at all; nix has a very strange model where it never rebuilds because each change to your source files is a new “[input-addressed derivation](https://nix.dev/manual/nix/2.32/store/derivation/index.html)” and therefore requires a reconfigure. This is the main reason it’s only used to package software, not as an “inner” build system, because that reconfigure can be very slow.

{% note() %}

I’ve talked to a couple Nix maintainers and they’ve considered caching parts of the *configure* step, without caching its outputs (because there are no outputs, other than derivation files!) in order to speed this up. This is much trickier because it requires serializing parts of the evaluator state.

{% end %}

Tools that *do* serialize their graph include CMake, Meson, and the Chrome build system ([GN](https://gn.googlesource.com/gn/)).

Generally, serializing the graph comes in handy when:
- You don’t have a persistent server to store it in memory. When you don’t have a server, serializing makes your startup times much faster, because you don’t have to rerun the configure step each time. [^9]
- You don’t have a remote build cache. When you have a remote cache, the rules for *loading* that cache can be rather complicated because they involve network queries [^10]. When you have a local cache, loading it doesn’t require special support because it’s just opening a file.
- You want to support querying, process spawning, and progress updates without rewriting the logic yourself for every OS.
### design goals
In the last post I talked about 4 things one might want from a build system:
1. a "real" language in the configuration step
2. reflection (querying the build graph)
3. file watching
4. support for discovering incorrect dependency edges. 

For a serialization, we have slightly different constraints. We still want 2-4. We care about incremental rebuild speed. And finally, we care about *minimizing reconfigurations*: we want to be able to express as many things as possible in the action graph so we don't have the pay the cost of rerunning the configure step. This tends to be at odds with incremental rebuild speed; adding features at this level of the stack is very expensive!

Throughout this post, I'll dive into detail on how these 5 overarching goals apply to the *serialization*, and how well various serializations achieve that goal.
#### querying
Note that “querying the build graph” is not a binary yes/no. Both bazel and ninja allow querying the build graph, but ninja's querying is much more restricted.

Compare bazel's syntax for querying why a dependency edge exists between a folder and an input:
```console
$ bazel query "somepath(//src/..., //third_party/zlib:zlibonly)"
//src:src
//third_party/py/MySQL:MySQL
//third_party/py/MySQL:_MySQL.so
//third_party/mysql:mysql
//third_party/zlib:zlibonly
```
to ninja's
```console
$ ninja -t targets | rg '^src/' | cut -d : -f 1 | xargs ninja -t inputs
mysql/sql/main.cc
src/a.c
zlib/deflate.c
```
Even this is massively understating the difference: ninja will show *all* dependencies of the `src/` directory, without filtering them to `zlib/`; won't show the path from `src/` to `zlib/`; and has no concept of packages, so it will show all source files instead of package names.
## existing serializations
The first one we'll look at, because it's the default for CMake, is `make`. Make is truly in the Unix spirit: simple to implement[^2], very complicated to use correctly.  Make does not have any of 2-4 and also fares pretty poorly on speed. It does do pretty well on minimizing reconfigurations, since it's quite flexible.

Ninja is the other generator supported by CMake. Ninja is explicitly intended to work on a serialized action graph; it's the only tool I'm aware of that is. It [solves a lot of the problems of Make](https://ninja-build.org/manual.html#_comparison_to_make): it's faster, it has reflection, and you can build file watching on top of the reflection.

Unfortunately, Ninja still has some limitations. It depends on [mtimes, which have many issues](https://apenwarr.ca/log/20181113), and has no support for checksums nor for file attributes other than mtime. It's possible to work around the checksum issue by using [`restat = true`](https://ninja-build.org/manual.html#:~:text=re-stat%20the%20command) and having a wrapper script that doesn't overwrite files unless they've changed, but that's a lot of extra work and is annoying to make portable between operating systems.

Ninja also has trouble expressing correct dependency edges. Let's look at a few examples, one by one. In each of these cases, we either have to reconfigure more often than we wish, or we have no way at all of expressing the dependency edge.
## dependency edge issues with ninja
### negative dependencies
See [my previous post](/negative-build-dependencies/) about negative dependencies. The short version is that build files need to specify not just the files they expect to exist, but also the files they expect *not* to exist.
### renamed files
Say that you have a C project with just a `main.c`. You rename it to `project.c` and ninja gives you an error that main.c no longer exists. Annoyed of editing ninja files by hand, you decide to write a generator[^4] :
```python
# build.py
import ninja_syntax
import os
import sys
from os.path import basename, splitext

writer = ninja_syntax.Writer(sys.stdout)
writer.rule("python", "python $in > $out")
writer.build("build.ninja", "python", "build.py", implicit=["."])

writer.rule("cc", "cc $in -o $out")
for path in os.listdir('.'):
    base, ext = splitext(path)
    if ext == '.c':
        writer.build(base, "cc", path)
```
Note this that this registers an implicit dependency on the current directory. This should automatically detect that you renamed your file and rebuild for you.
```
$ ninja
[1/1] python build.py > build.ninja
[1/2] python build.py > build.ninja
[1/3] python build.py > build.ninja
[1/4] python build.py > build.ninja
[1/5] python build.py > build.ninja
[1/6] python build.py > build.ninja
...
[1/100] python build.py > build.ninja
ninja: error: manifest 'build.ninja' still dirty after 100 tries, perhaps system time is not set
```
Oh. Right. Generating build.ninja also modifies the current directory, which creates an infinite loop.

It's possible to work around this by putting your C file in a source directory:
```python
# build.py
writer.build("build.ninja", "python", "build.py", implicit=["src"])
for path in os.listdir('src'):
    base, ext = splitext(path)
    if ext == '.c':
        writer.build('src/'+base, "cc", 'src/'+path)
```
```console
$ tree
.
├── build.ninja
├── build.py
├── main.c
├── ninja_syntax.py
└── src
    └── main.c
$ ninja
[1/1] python build.py > build.ninja
[1/2] cc src/main.c -o src/main
$ mv src/{main,project}.c
$ ninja
[1/1] python build.py > build.ninja
[1/2] cc src/project.c -o src/project
```
There's still a problem here, though—did you notice it?
```
$ ls src
main  project  project.c
```
Our old `main` target is still lying around. Ninja actually has enough information recorded to fix this: `ninja -t cleandead`. But it's not run automatically.

The other problem is that this approach rebuilds far too often. In this case, we wanted to support renames, so in Ninja's model we need to depend on the whole directory. But that's not what we really depended on—we only care about `.c` files. I would like to see a action graph tool that has an event-based system, where it says "this file was created, make any changes to the action graph necessary", and cuts the build short if the graph wasn't changed.

For [flower](https://flower.jyn.dev/overlay.html), I want to go further and support *deletions*: source files and targets that are optional, that should not fail the build if they aren't present, but should cause a rebuild if they are created, modified, or deleted. Ninja has no way of expressing this.

<!--
## deleted depfiles
Ninja has a feature called "depfiles", where dependency information is not fully known until after the first run of a build edge. It's intended for C header files, but can be used for other things. The idea is that the dependency graph might depend on which things you dynamically require inside your source file. To support this, C compilers support `-M` [^5] to emit a `make`-compatible dependency graph for that source file, which ninja will read on the next run.

This can get us into a lot of trouble.

Consider the following C project:

-->
## tracing
So far we’ve looked at particular dependency graphs that aren’t possible to express with ninja. Now I want to look at features that would require a new tool.

In my previous post, I talked about two main uses for a tracing build system: first, to automatically add dependency edges for you; and second, to verify at runtime that no dependency edges are missing. This especially shines when the action graph has a way to express negative dependencies, because the tracing system *sees* every attempted file access and can add them to the graph automatically.

For prior art, see the [Shake build system](https://shakebuild.com/). Shake is higher-level than ninja and doesn't work on an action graph, but it has [built-in support for file tracing](https://neilmitchell.blogspot.com/2020/05/file-tracing.html) in all three of these modes: warning about incorrect edges; adding new edges to the graph when they're detected at runtime; and finally, [fully inferring all edges from the nodes alone](https://blogs.ncl.ac.uk/andreymokhov/stroll/).

I would want my serialization to only support linting and hard errors for missing edges. Inferring a full action graph is scary and IMO belongs in a higher-level tool, and adding dependency edges automatically can be done by a tool that wraps ninja and parses the lints.

What's really cool about this linting system is that it allows you to gradually transition to a hermetic build over time, without frontloading all the work to when you switch to the tool.

{% note() %}

The main downside of tracing is that it's highly non-portable, and in particular is very limited on macOS.

One possible alternative I've thought of is to do a buck2-style unsandboxed hermetic builds, where you copy exactly the specified inputs into a tempdir and run the build from the tempdir. If that fails, rerun the build from the main source directory. This can't tell *which* dependency edges are missing, but it can tell you *a* dependency is missing without fully failing the build.

The downside to *that* is it assumes command spawning is a pure function, which of course it's not; anything that talks to a socket is trouble because it might be stateful.

{% end %}
## designing a new action graph
<!-- mention incremental switch, possible to mechanically translate ninja, not meant to be hand-edited -->

At this point, we have a list of constraints for our tool:
1. Reflection on the action graph
2. Negative dependencies
3. File rename dependencies
4. Optional file dependencies
5. Tracing (in both linting and hard error mode) to allow gradually transitioning to a hermetic build
6. Extended rebuild detection (file attributes other than `mtime` to reduce false negatives, optional checksums to reduce false positives)
7. "all the features of ninja" (depfiles, [monadic builds](https://www.microsoft.com/en-us/research/uploads/prod/2018/03/build-systems-final.pdf) through `dyndeps`, a `generator` statement, order-only dependencies, no persistent server)
8. "as fast as possible given all the above constraints"

I am not aware of any existing tool that meets these constraints. I'm considering building one on top of Shake. If anyone knows of prior art in this area, please [let me know](mailto:blog@jyn.dev) :)
## ronin
### language
This sketches out a new tool that could improve over Ninja, named `ronin`. It could look something like this:
- A very very small clojure subset (just `def`, `let`, [EDN](https://github.com/edn-format/edn), and function calls) for the text itself, no need to make parsing the graph harder than necessary [^6]. If people really want an equivalent of `include` or `subninja` I suppose this could learn support for `ns` and `require`, but it would have much simpler rules than Clojure's classpath. It would not have support for looping constructs, nor most of clojure's standard library.
- `redo`-inspired dependency edges: `ifwritten` (for changes in file attributes), `ifchanged` (for changes in the checksum), `ifcreate` (for optional dependencies), `always`; plus our new `ifdeleted` edge.
- A `dyndeps` input function that can be used anywhere a file path can (e.g. in calls to `ifwritten`) so that the kind of edge does not depend on whether the path is known in advance or not.
- Runtime functions that determine whether the configure step needs to be re-run based on file watch events[^7]. Whether there is actually a file watcher or the build system just calculates a diff on its next invocation is an implementation detail; ideally, one that's easy to slot in and out.
- “phony” targets would be replaced by a `group` statement. Groups are sets of targets. Groups cannot be used to avoid “input not found” errors; that niche is filled by `ifcreated`.

Here's a sample action graph in `ronin`:
```clojure
(rule cc
  :command ["cc" :in "-MD" "-MF" :depfile "-o" :out])
(build "main"
  :rule cc
  :inputs [(ifwritten "main.c")]
  :depfile "main.c.d")

(def tarfile (ifwritten "example.tar"))

(rule list-tar
  :command ["tar" "-tf" (first :in)]
  :stdout :out)
(build "example.tar.dd"
  :inputs [tarfile]
  :rule list-tar)

(def tar-outputs (dyndeps (ifchanged "example.tar.dd"))

(rule extract-tar
  :command ["tar" "-xf" (first :in)])
(build tar-outputs)
  :inputs [tarfile]
  :rule extract-tar)

(group all
  (concat ["main"] tar-outputs))

(defn should-rerun [event]
  (and (ends-with? (:path event) ".c")
       (not= :modified (:kind event)))
(rule configure
  :command ["python" "configure.py"])
(build "build.ronin"
  :rule configure
  :generator true
  :inputs [(watch "." should-rerun)])
```
Note some things about this language:
- Command spawning is specified as an array. No more dependency on shell quoting rules.
- Redirecting stdout no longer requires bash syntax, it's supported natively with the `:stdout` parameter of `rule`.
- Build parameters can be referred to in rules with `:keyword` syntax.
- `rule` is a wrapper around `def` that injects variables into the current scope. `:rule list-tar` is doing name resolution.
- `dyndeps` is a [thunk](https://wiki.haskell.org/Thunk); it only registers an intent to add edges in the future, it does not eagerly require `example.tar.dd` to exist.
- Our `watch` input edge is generalized and can apply to any rule, not just to the configure step. It executes when a file is modified (or if the tool doesn’t support file watching, on each file in the calculated diff in the next tool invocation).
- Our `watch` edge provides the file event type, but not the file contents. This allows ronin to automatically map `true` results to one of the three edge kinds: `ifwritten`, `ifcreated`, `ifdeleted`. `always` and `ifchanged` are not available through this API.
- Our `group` cannot actually be used in a `:inputs` parameter because it doesn’t specify the kind of edge (created/modified/deleted). Our mini-clojure provides other abstractions, like variables; arrays; and `map`, that render this unnecessary.
### interface
Like [Ekam](https://github.com/capnproto/ekam/), Ronin would have a `--watch` continuous rebuild mode. Like [Starlark](https://starlark-lang.org/), the language would be constrained so that action graphs can never touch the filesystem other than through the build/rule/watch/dyndeps built-ins. It would have runtime tracing, with all of `--tracing=never|warn|error` options. And it would have bazel-like querying, both through CLI arguments and through a programmatic API.

Finally, it would have pluggable backends for file watching, tracing, stat-ing, and checksums, so that it can take advantage of filesystems that have more features while still being reasonably fast on filesystems that don’t. For example, on Windows stats are slow, so it would cache stat info; but on Linux stats are fast so it would just directly make a syscall.
### architecture
Like ninja, ronin would keep a command log with a history of past versions of the action graph. It would reuse the “bipartite graph” structure, with one half being files and the other being commands. It would parse depfiles and dyndeps files just after they’re built, while the cache is still hot.

Like [`n2`](https://neugierig.org/software/blog/2022/03/n2.html), ronin would use a single-pass approach to support early cutoff. It would hash an "input manifest" to decide whether to rebuild. Unlike `n2`, it would store a mapping from that hash back to the original manifest so you can query why a rebuild happened.

Like Shake, the tracing would be built on top of [FSATrace](https://neilmitchell.blogspot.com/2020/05/file-tracing.html?m=1). I haven’t decided whether to use the Shake integration, which would require ronin to be written in Haskell, or the standalone shared library, which would let me do JNI to use it from Clojure.

Unlike other build systems I know, state (such as manifest hashes, content hashes, and removed outputs) would be stored in an SQLite database, not in flat files.
### "did you just reinvent [starlark](https://starlark-lang.org/)?"
Kinda. The language itself has a lot in common with starlark: it's deterministic, hermetic, immutable, and can be evaluated in parallel. But the APIs are very different, because Ronin files are a build *target*, not a build *input*. In particular they only describe dependencies between files and process executions; they cannot be used as libraries and do not have support for selecting between multiple configurations.

The main difference between the languages themselves is that clojure has `:keywords` (equivalent to sympy symbolic variables) and starlark doesn't. They could be rewritten to `var.keyword`, but I'm not sure how much benefit there is to literally using Starlark when these files are being generated by a configure step in any case.
## next steps
In this post, we have learned some downsides of Make and Ninja, sketched out how they could possibly be fixed, and designed a language that has those characteristics.

... I guess the next step is to build `ronin`.

---
[^1]: You might object and say that "a configuration language" is what CMake is for. Yes. But Make works *just* well enough that people are tempted to use it on its own, bypassing the configuration language.

[^2]: at least a basic version—although several of the features of GNU Make get rather complicated.

[^3]: People familiar with ninja might say this looks odd and it should use a `depfile` with `cc -M` so dependencies are tracked automatically. That makes your files shorter and means you need to run the configure step less often, but it doesn't actually solve the problem of negative dependencies. Ninja still doesn't know when it needs to regenerate the depfile.

[^4]: `ninja_syntax.py` is <https://github.com/ninja-build/ninja/blob/231db65ccf5427b16ff85b3a390a663f3c8a479f/misc/ninja_syntax.py>.

[^5]: and rustc support `--emit=dep-info`

[^6]: This goes all the way around [the configuration complexity clock](https://mikehadlow.blogspot.com/2012/05/configuration-complexity-clock.html) and skips the "DSL" phase to simply give you a real language.

[^7]: This is totally based and not at all a terrible idea.

[^9]: I've heard a clean start of Blaze at Google takes 14 hours (!)

[^10]: see e.g. [this description](https://github.com/facebook/buck2/issues/976#issuecomment-3007201092) of how it works in buck2
