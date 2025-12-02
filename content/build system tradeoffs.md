---
title: build system tradeoffs
date: 2025-11-02
extra:
  toc: 4
  fedi: https://tech.lgbt/@jyn/115480639582540712
  bsky: https://bsky.app/profile/jyn.dev/post/3m4nqq5nrf22k
taxonomies:
  tags:
    - build-systems
description: an overview of what builds for complicated projects have to think about
---
This post is part 1/4 of a series about build systems.
The next post is [negative build dependencies](/negative-build-dependencies/).

---
> If I am even TEMPTED to use `sed`, in my goddamn build system, you have lost.
> —[Qyriad](https://chaos.social/@Qyriad/111349762684384063)

I am currently employed to work on [the build system for the Rust compiler](https://rustc-dev-guide.rust-lang.org/building/bootstrapping/intro.html) (often called `x.py` or `bootstrap`). As a result, I think about a lot of build system weirdness that most people don't have to. This post aims to give an overview of what builds for complicated projects have to think about, as well as vaguely gesture in the direction of build system ideas that I like.

This post is generally designed to be accessible to the working programmer, but I have a lot of expert blindness in this area, and sometimes assume that ["of *course* people know what a feldspar is!"](https://xkcd.com/2501/). Apologies in advance if it's hard to follow.
## build concerns
What makes a project’s build complicated?
### running generated binaries
The first semi-complicated thing people usually want to do in their build is write an integration test. Here's a rust program which does so:
```rust
// tests/integration.rs
use std::process::Command;
fn assert_success(cmd: Command) {
    assert!(cmd.status().unwrap().success());
}
#[test]
fn test_my_program() {
    assert_success(Command::new("cargo").arg("build"));
    assert_success(Command::new("target/debug/my-program")
      .arg("assets/test-input.txt"));
}
```
This instructs [cargo](https://doc.rust-lang.org/cargo/) to, when you run `cargo test`, compile `tests/integration.rs` as a standalone program and run it, with `test_my_program` as the entrypoint.

We'll come back to this program several times in this post. For now, notice that we are invoking `cargo build` inside of `cargo test`. <!-- This isn't something cargo-specific—there's extensive literature about it under the name ["recursive make"](https://accu.org/journals/overload/14/71/miller_2004/).-->
### correct dependency tracking
I actually forgot this one in the first draft because Cargo solves this so well in the common case [^14]. In many hand-written builds (*cough* `make` *cough*), specifying dependencies by hand is very broken, `-j` for parallelism simply doesn't work, and running `make clean` on errors is common. Needless to say, this is a bad experience.
### cross-compiling
The next step up in complexity is to cross-compile code. At this point, we already start to get some idea of how involved things get:
```
$ cargo test --target aarch64-unknown-linux-gnu
   Compiling my-program v0.1.0 (/home/jyn/src/build-system-overview)
error[E0463]: can't find crate for `std`
  |
  = note: the `aarch64-unknown-linux-gnu` target may not be installed
  = help: consider downloading the target with `rustup target add aarch64-unknown-linux-gnu`
  = help: consider building the standard library from source with `cargo build -Zbuild-std`
```
How hard it is to cross-compile code depends greatly on not just the build system, but the language you're using and the exact platform you're targeting. The particular thing I want to point out is *your standard library has to come from somewhere*. In Rust, it's usually downloaded from the same place as the compiler. In bytecode and interpreted languages, like Java, JavaScript, and Python, there's no concept of cross-compilation because there is only one possible target. In C, you usually don't install the library itself, but only the headers that record the API [^1]. That brings us to our next topic:
#### libc
Generally, people refer to one of two things when they say "libc". Either they mean the C standard library, `libc.so`, or the C runtime, `crt1.o`.

Libc matters a lot for two reasons. Firstly, [C is no longer a language](https://faultlore.com/blah/c-isnt-a-language/), so generally the first step to porting *any* language to a new platform is to make sure you have a C [toolchain](https://stackoverflow.com/a/69006179) [^2]. Secondly, because libc is effectively the interface to a platform, [Windows](https://j00ru.vexillium.org/syscalls/nt/64/), [macOS](https://developer.apple.com/library/archive/qa/qa1118/_index.html), and [OpenBSD](https://marc.info/?l=openbsd-tech&m=169841790407370&w=2) have no stable syscall boundary—you are only allowed to talk to the kernel through their stable libraries (libc, and in the case of Windows several others too).

To talk about *why* they've done this, we have to talk about:
#### dynamic linking and platform maintainers
[Many](https://clojure.org/reference/vars) [languages](https://en.wikipedia.org/wiki/Dynamic_dispatch) have a concept of "[early binding](https://en.wikipedia.org/wiki/Name_binding)", where all variable and function references are resolved at compile time, and "[late binding](https://en.wikipedia.org/wiki/Late_binding)", where they are resolved at runtime. C has this concept too, but it calls it "linking" instead of "binding". "late binding" is called "dynamic linking"[^3]. References to late-bound variables are resolved by the ["dynamic loader"](https://linux.die.net/man/8/ld.so) at program startup. Further binding can be done at runtime using [`dlopen`](https://man7.org/linux/man-pages/man3/dlopen.3.html) and friends.

[Platform maintainers](https://wiki.debian.org/SoftwarePackaging#External_libraries) [really like dynamic linking](https://wiki.debian.org/StaticLinking#Downsides), for the same reason [they dislike vendoring](https://blogs.gentoo.org/mgorny/2021/02/19/the-modern-packagers-security-nightmare/): late-binding allows them to update a library for all applications on a system at once. This matters a lot for security disclosures, where there is a very short timeline between when a vulnerability is patched and announced and when attackers start exploiting it in the wild.

Application developers [dislike dynamic linking](https://vagabond.github.io/rants/2013/06/21/z_packagers-dont-know-best) for basically the same reason: it requires them to trust the platform maintainers to do a good job packaging all their dependencies, and it results in their application being deployed in scenarios that [they haven't considered or tested](https://blog.yossarian.net/2021/02/28/Weird-architectures-werent-supported-to-begin-with). For example, installing openssl on Windows is really quite hard. Actually, while I was writing this, a friend overheard me say "dynamically linking openssl" and said "oh god you're giving me nightmares".

Perhaps a good way to think about dynamically linking as commonly used is *a mechanism for devendoring libraries in a compiled program*. Dynamic linking has other use cases, but they are comparatively rare.

Whether a build system (or language) makes it easy or hard to dynamically link a program is one of the major things that distinguishes it. More about that later.
### toolchains
Ok. So. Back to cross-compiling.

To cross-compile a program, you need:
- A compiler for that target. If you're using clang or Rust, this is as simple as passing `--target`. If you're using gcc, you need a [whole-ass extra compiler installed](https://gcc.gnu.org/onlinedocs/gcc-15.2.0/gcc.pdf#Invoking%20GCC).
- A standard library for that target. This is very language-specific, but at a minimum requires a working C toolchain [^4].
- A linker for that target. This is usually shipped with the compiler, but I mention it specifically because it's usually the most platform specific part. For example, "not having the macOS linker" is *the* reason that [cross-compiling to macOS is hard](https://github.com/tpoechtrager/osxcross?tab=readme-ov-file#how-it-works).

Where does your toolchain come from? ...  
...  
...  
... It turns out [this is a hard problem](https://rustc-dev-guide.rust-lang.org/building/bootstrapping/what-bootstrapping-does.html#stages-of-bootstrapping). Most build systems sidestep it by "not worrying about it"; basically any Makefile you find is horribly broken if you update your compiler without running `make clean` afterwards. Cargo is a lot smarter—it caches output in `target/.rustc_info.json`, and rebuilds if `rustc --version --verbose` changes. "How do you deal with toolchain invalidations" is another important things that distinguishes a build system, as we'll see later.
### environments

toolchains are a special case of a more general problem: your build depends on your *whole build environment*, not just the files passed as inputs to your compiler. That means, for instance, that people can—and often do—download things off the internet, [embed previous build artifacts in later ones](https://rustc-dev-guide.rust-lang.org/rustdoc.html#multiple-runs-same-output-directory), and [run entire nested compiler invocations](https://docs.rs/openssl/latest/openssl/#vendored).
### reproducible builds
Once we get towards these higher levels of complexity, people want to start doing quite complicated things with caching. In order for caching to be sound, we need the same invocation of the compiler to emit the same output every time, which is called a **reproducible build**. This is much harder than it sounds! There are many things programs do that cause non-determinism that programmers often don’t think about (for example, iterating a hashmap or a directory listing).

At the very highest end, people want to conduct builds across multiple machines, and combine those artifacts. At this point, we can’t even allow reading absolute paths, since those will be different between machines. The common tool for this is a compiler flag called `--remap-path-prefix`, and allows the build system to map an absolute path to a relative one. `--remap-path-prefix` is also how rustc is able to print the sources of the standard library when emitting diagnostics, even when running on a different machine than where it was built.
## tradeoffs
At this point, we have enough information to start talking about the space of tradeoffs for a build system.
### configuration language
> Putting your config in a YAML file does not make it declarative! Limiting yourself to a Turing-incomplete language does not automatically make your code easier to read!
—[jyn](https://tech.lgbt/@jyn/112617315565817787)

The most common unforced error I see build systems making is forcing the build configuration to be written in a custom language[^6]. There are basically two reasons they do this:
- Programmers aren't used to treating build system code as code. This is a culture issue that's hard to change, but it's worthwhile to try anyway.
- There is some idea of making builds "declarative". (In fact, observant readers may observe that this corresponds to the idea of ["constrained languages"](https://jyn.dev/constrained-languages-are-easier-to-optimize/) I talk about in an earlier post.) This is not by itself a bad idea! The problem is it doesn't give them the properties you might want. For example, one property you might want is "another tool can reimplement the build algorithm". Unfortunately this quickly becomes [infeasible for complicated algorithms](https://docs.jade.fyi/gnu/make.html#Features-of-GNU-make). Another you might want is "what will rebuild next time a build occurs?". You can't get this from the configuration without—again—reimplementing the algorithm.

Right. So, given that making a build "declarative" is a lie, you may as well give programmers a real language. Some common choices are:
- [Starlark](https://starlark-lang.org/) [^7]
- [Groovy](https://groovy-lang.org/)
- “the same language that the build system was written in” (examples: [Clojure](https://boot-clj.github.io/), [Zig](https://ziglang.org/learn/build-system/), [JavaScript](https://gruntjs.com/sample-gruntfile))
### reflection
"But wait, jyn!", you may say. "Surely you aren't suggesting a build system where you have to run a whole program every time you figure out what to rebuild??"

I mean ... people are doing it. But just because they're doing it doesn't mean it's a good idea, so let's look at the alternative, which is to *serialize your build graph*. This is easier to see than explain, so let's look at an example using the [Ninja build system](https://ninja-build.org/) [^8]:
```ninja
rule svg2pdf
  command = inkscape $in --export-text-to-path --export-pdf=$out
  description = svg2pdf $in $out
  
build pdfs/variables.pdf: svg2pdf variables.svg
```
Ninjafiles give you the absolute bare minimum necessary to express your build dependencies: You get "rules", which explain *how* to build an output; "build edges", which state *when* to build; and "variables", which say *what* to build[^12]. That's basically it. There's some subtleties about "depfiles" which can be used to dynamically add build edges while running the build rule.

Because the features are so minimal, the files are intended to be generated, using a configure script written in one of the languages we talked about earlier. The most common generators are CMake and [GN](https://gn.googlesource.com/gn/#gn), but you can use any language you like because the format is so simple.

What's really cool about this is that it's trivial to parse, which means that it's very easy to write your own implementation of ninja if you want. It also means that you *can* get a lot of the properties we discussed before, i.e.:
- "Show me all commands that are run on a full build" (`ninja -t commands`)
- "Show me all commands that will be run the next time an incremental build is run" (`ninja -n -d explain`)
- "If this *particular* source file is changed, what will need to be rebuilt?" (`ninja -t query variables.svg`)

It turns out these properties are very useful.

{% note() %} "jyn, you're taking too long to get to the point!" look I’m getting there, I promise. {% end %}

The main downsides to this approach is that it has to be *possible* to serialize your build graph. In one sense, I see this as good, actually, because you have to think through everything your build does ahead of time. But on the other hand, if you have things like nested ninja invocations, or like our `cargo test` -> `cargo build` example [from earlier](#running-generated-binaries) [^9], all the tools to query the build graph don't include the information you expect.
### file watching
Re-stat'ing all files in a source directory is expensive. It would be much nicer if we could have a pull model instead of a push model, where the build tool gets notified of file changes and rebuilds exactly the necessary files. There are some tools with native integration for this, like [Tup](https://gittup.org/tup/manual.html#:~:text=monitor), [Ekam](https://github.com/capnproto/ekam/), [jj](https://jj-vcs.github.io/jj/latest/config/#filesystem-monitor), and [Buck2](https://engineering.fb.com/2023/04/06/open-source/buck2-open-source-large-scale-build-system/#:~:text=integrate%20with%20virtual%20file), but generally it's pretty rare.

That's ok if we have reflection, though! We can write our own file monitoring tool, ask the build system which files need to rebuilt for the changed inputs, and then tell it to rebuild only those files. That prevents it from having to recursively stat all files in the graph.

See [Tup's paper](https://gittup.org/tup/build_system_rules_and_algorithms.pdf) for more information about the big idea here.
### dependency tracking
Ok, let's assume we have some build system that uses some programming language to generate a build graph, and it rebuilds exactly the necessary outputs on changes to our inputs. What exactly are our inputs?

There are basically four major approaches to dependency tracking in the build space.
#### "not my problem, lol"
This kind of build system externalizes all concerns out to you, the programmer. When I say "externalizes all concerns", I mean that you are required to write in all your dependencies by hand, and the tool doesn't help you get them right. Some examples:
- `make`
- Github Actions [cache actions](https://github.com/actions/cache) (and in general, most CI caching I'm aware of requires you to manually write out the files your cache depends on)
- Ansible playbooks
- Basically most build systems, this is extremely common

A common problem with this category of build system is that people forget to mark *the build rule itself* as an input to the graph, resulting in dead artifacts left laying around, and as a result, [unsound](https://jacko.io/safety_and_soundness.html) builds.

In my humble opinion, this kind of tool is only useful as a serialization layer for a build graph, or if you have no other choice. Here's a nickel, kid, [get yourself a better build system](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/03/hadrian.pdf).
##### compiler support
Sometimes build systems (CMake, Cargo, maybe others I don't know) do a little better and use the compiler's built-in support for dependency tracking (e.g. [`gcc -M`](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html#index-M) or [`rustc --emit=dep-info`](https://doc.rust-lang.org/rustc/command-line-arguments.html#--emit-specifies-the-types-of-output-files-to-generate)), and automatically add dependencies on the build rules themselves. This is a lot better than nothing, and much more reliable than tracking dependencies by hand. But it still fundamentally trusts the compiler to be correct, and doesn't track environment dependencies.
#### ephemeral state
This kind of build system always does a full build, and lets you modify the environment in arbitrary ways as you do so. This is simple, always correct, and expensive. Some examples:
- `make clean && make` (kinda—assuming that `make clean` is reliable, which it often isn't.)
- Github Actions (`step:` rules)
- Docker containers (time between startup and shutdown)
- Initramfs (time between initial load and chroot into the full system)
- Systemd service startup rules
- Most compiler invocations (e.g. `cc file.c -o file`)

These are ok if you can afford them. But they are expensive! Most people using Github Actions are only doing so because GHA is a hyperscaler giving away free CI time like there's no tomorrow. I suspect we would see far less wasted CPU-hours if people had to consider the actual costs of using them.
#### hermetic builds
This is the kind of phrase that's well-known to people who work on build systems and basically unheard of outside it, alongside "monadic builds". "hermetic" means that *the only things in your environment are those you have explicitly put there*. This sometimes called "sandboxing", although that has unfortunate connotations about security that don't always apply here. Some examples of this:
- Dockerfiles (more generally, OCI images)
- nix
- Bazel / Buck2
- ["Bazel Remote Execution Protocol"](https://github.com/bazelbuild/remote-apis) (not actually tied to Bazel), which lets you run an arbitrary set of build commands on a remote worker

This has a lot of benefits! It statically guarantees that you *cannot* forget any of your inputs; it is 100% reliable, assuming no issues with the network or with the implementing tool 🙃; and it gives you very very granular insight into what your dependencies actually are. Some things you can *do* with a hermetic build system:
- On a change to some source code, rerun only the affected tests. You know statically which those are, because the build tool forced you to write out the dependency edges.
- Remote caching. If you have the same environment everywhere, you can upload your cache to the cloud, and download and reuse it again on another machine. You can do this in CI—but you can also do it locally! The time for a """full build""" can be almost instantaneous because when a new engineer gets onboarded they can immediately reuse everyone else's build cache.

The main downside is that you have to actually specify all those dependencies (if you don't, you get a hard error instead of an unsound build graph, which is the main difference between hermetic systems and "not my problem"). Bazel and Buck2 give you starlark, so you have a ~real[^10] language in which to do it, but it's still a ton of work. Both have an enormous "prelude" module that just defines where you get a compiler toolchain from[^13].

Nix can be thought of as taking this "prelude" idea all the way, by expanding the "prelude" (nixpkgs) to "everything that's ever been packaged for NixOS". When you write `import <nixpkgs>`, your nix build is logically in the same build graph as the nixpkgs monorepo; it just happens to have an enormous remote cache already pre-built. 

{% note() %}

Bazel and Buck2 don’t have anything like nixpkgs, which is the main reason that using them requires a full time dedicated build engineer: that engineer has to keep writing build rules from scratch any time you add an external dependency. They also have to package any language toolchains that aren’t in the prelude.

{% end %}

Nix has one more interesting property, which is that all its packages compose. You can install two different versions of the same package and that's fine because they use different [store](https://nix.dev/manual/nix/2.24/store/) paths. They fit together like lesbians' fingers interlock.

Compare this to docker, which does *not* compose[^11]. In docker, there is no way to say "Inherit the build environment from multiple different source images". The closest you can get is a "multi-stage build", where you explicitly copy over individual files from an earlier image to a later image. It can't blindly copy over all the files because some of them might want to end up at the same path, and touching fingers would be gay.
#### tracing
The last kind I'm aware of, and the rarest I've seen, is *tracing* build systems. These have the same goal as hermetic build systems: they still want 100% of your dependencies to be specified. But they go about it in a different way. Rather than sandboxing your code and only allowing access to the dependencies you specify, they *instrument* your code, tracing its file accesses, and record the dependencies of each build step. Some examples:
- [Tup](https://gittup.org/tup/ex_a_first_tupfile.html#:~:text=a%20program%20grows)
- [Bear](https://github.com/rizsotto/Bear)
- [Riker](https://github.com/curtsinger-lab/riker)
- [Ekam](https://github.com/capnproto/ekam/)
- [The rust compiler, actually](https://rustc-dev-guide.rust-lang.org/query.html)
- "A build system with orthogonal persistence" ([previously](https://jyn.dev/complected-and-orthogonal-persistence/#how-far-can-we-take-this); [previously](https://jade.fyi/blog/the-postmodern-build-system/#make-an-existing-architecture-and-os-deterministic); [previously](https://nlnet.nl/project/Ripple/))

The advantage of these is that you get all the benefits of a hermetic build system without any of the cost of having to write out your dependencies.

The first main disadvantage is that they require the kernel to support syscall tracing, which essentially means they only work on Linux. I have Ideas™ for how to get this working on macOS without disabling SIP, but they're still incomplete and not fully general; I may write a follow-up post about that. I don't yet have ideas for how this could work on Windows, but [it seems possible](https://stackoverflow.com/questions/864839/monitoring-certain-system-calls-done-by-a-process-in-windows).

The second main disadvantage is that not knowing the graph up front causes many issues for the build system. In particular:
- If you change the graph, it doesn't find out until the next time it reruns a build. This can lead to degenerate cases where the same rule has to be run multiple times until it doesn't access any new inputs.
- If you don't cache the graph, you have that problem on *every edge in the graph*. [This is the problem Ekam has](https://github.com/capnproto/ekam/issues/63), and makes it very slow to run full builds. Its solution is to run in "watch" mode, where it caches the graph in-memory instead of on-disk.
- If you do cache the graph, you can only do so for so long before it becomes prohibitively expensive to do that for all possible executions. For "normal" codebases this isn't a problem, but if you're Google or Facebook, this is actually a practical concern. I think it is still possible to do this with a tracing build system (by having your cache points look a lot more like many Bazel BUILD files than a single top-level Ninja file), but no one has ever tried it at that scale.
- If the same file can come from many possible places, due to multiple search paths (e.g. a `<system>` include header in C, or any import really in a JVM language), then you have a very rough time specifying what your dependencies actually are. The best ninja can do is say “depend on the whole directory containing that file”, which sucks because it rebuilds *whenever* that directory changes, not just when your new file is added. It’s possible to work around this with a (theoretical) serialization format other than Ninja, but regardless, you’re adding lots of file `stat()`s to your hot path.
- The build system does not know which dependencies are direct (specified by you, the owner of the module being compiled) and which are transient (specified by the modules you depend on). This makes error reporting worse, and generally lets you do fewer kinds of queries on the graph.
- My friend Alexis Hunt, a build system expert, says "there are deeper pathologies down that route of madness". So. That's concerning.

I have been convinced that tracing is useful as a tool to *generate* your build graph, but not as a tool actually used when executing it. Compare also [gazelle](https://github.com/bazel-contrib/bazel-gazelle), which is something like that for Bazel, but based on parsing source files rather than tracking syscalls.

Combining paradigms in this way also make it possible to verify your hermetic builds in ways that are hard to do with mere sandboxing. For example, a tracing build system can catch missing dependencies:
- emitting untracked *outputs*
- overwriting source files (!),
- using an input file that was registered for a different rule

and it can also detect non-reproducible builds:
- reading the current time, or absolute path to the current directory
- iterating all files in a directory (this is non-deterministic)
- machine and kernel-level sources of randomness.
## future work
There's more to talk about here—how build systems affect the dynamics between upstream maintainers and distro packagers; how .a files are [bad file formats](https://medium.com/@eyal.itkin/the-a-file-is-a-relic-why-static-archives-were-a-bad-idea-all-along-8cd1cf6310c5); how [mtime comparisons are generally bad](https://apenwarr.ca/log/20181113); how configuration options make the tradeoffs much more complicated; how FUSE can let a build system integrate with a VCS to avoid downloading unnecessary files into a shallow checkout; but this post is quite long enough already.
## takeaways
- Most build systems do not prioritize correctness.
- Prioritizing correctness comes with severe, hard to avoid tradeoffs.
- Tracing build systems show the potential to avoid some of those tradeoffs, but are highly platform specific and come with tradeoffs of their own at large enough scale. Combining a tracing build system with a hermetic build system seems like the best of both worlds.
- Writing build rules in a "normal" (but constrained) programming language, then serializing them to a build graph, has surprisingly few tradeoffs. I'm not sure why more build systems don't do this.
---

## bibliography
- [Alan Dipert, Micha Niskin, Joshua Smith, “Boot: build tooling for Clojure”](https://boot-clj.github.io/)
- [Alexis Hunt, Ola Rozenfield, and Adrian Ludwin, “bazelbuild/remote-apis: An API for caching and execution of actions on a remote system.”](https://github.com/bazelbuild/remote-apis)
- [Andrew Kelley, “zig cc: a Powerful Drop-In Replacement for GCC/Clang”](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html)
- [Andrew Thompson, “Packagers don’t know best”](https://vagabond.github.io/rants/2013/06/21/z_packagers-dont-know-best)
- [Andrey Mokhov et. al., “Non-recursive Make Considered Harmful”](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/03/hadrian.pdf)
- [apenwarr, “mtime comparison considered harmful”](https://apenwarr.ca/log/20181113)
- [Apple Inc., “Statically linked binaries on Mac OS X”](https://developer.apple.com/library/archive/qa/qa1118/_index.html)
- [Aria Desires, “C Isn’t A Language Anymore”](https://faultlore.com/blah/c-isnt-a-language/)
- [Charlie Curtsinger and Daniel W. Barowy, “curtsinger-lab/riker: Always-Correct and Fast Incremental Builds from Simple Specifications”](https://github.com/curtsinger-lab/riker)
- [Chris Hopman and Neil Mitchell, “Build faster with Buck2: Our open source build system”](https://engineering.fb.com/2023/04/06/open-source/buck2-open-source-large-scale-build-system/)
- [Debian, “Software Packaging”](https://wiki.debian.org/SoftwarePackaging)
- [Debian, “Static Linking”](https://wiki.debian.org/StaticLinking)
- [Dolstra, E., & The CppNix contributors., “Nix Store”](https://nix.dev/manual/nix/2.24/store/)
- [Eyal Itkin, “The .a File is a Relic: Why Static Archives Were a Bad Idea All Along”](https://medium.com/@eyal.itkin/the-a-file-is-a-relic-why-static-archives-were-a-bad-idea-all-along-8cd1cf6310c5)
- [Felix Klock and Mark Rousskov on behalf of the Rust compiler team, “Announcing Rust 1.52.1”](https://blog.rust-lang.org/2021/05/10/Rust-1.52.1/)
- [Free Software Foundation, Inc., “GNU make”](https://docs.jade.fyi/gnu/make.html)
- [GitHub, Inc., “actions/cache: Cache dependencies and build outputs in GitHub Actions”](https://github.com/actions/cache)
- [Google Inc., “bazel-contrib/bazel-gazelle: a Bazel build file generator for Bazel projects”](https://github.com/bazel-contrib/bazel-gazelle)
- [Google LLC, “Jujutsu docs”](https://jj-vcs.github.io/jj/latest/config/)
- [Jack Lloyd and Steven Fackler, “rust-openssl”](https://docs.rs/openssl/latest/openssl/)
- [Jack O’Connor, “Safety and Soundness in Rust”](https://jacko.io/safety_and_soundness.html)
- [Jade Lovelace, “The postmodern build system”](https://jade.fyi/blog/the-postmodern-build-system/)
- [Julia Evans, “ninja: a simple way to do builds”](https://jvns.ca/blog/2020/10/26/ninja--a-simple-way-to-do-builds/)
- [jyn, “Complected and Orthogonal Persistence”](https://jyn.dev/complected-and-orthogonal-persistence/)
- [jyn, “Constrained Languages are Easier to Optimize”](https://jyn.dev/constrained-languages-are-easier-to-optimize/)
- [jyn, “i think i have identified what i dislike about ansible”](https://tech.lgbt/@jyn/112617315565817787)
- [Kenton Varda, “Ekam Build System”](https://github.com/capnproto/ekam/)
- [László Nagy, “rizsotto/Bear: a tool that generates a compilation database for clang tooling”](https://github.com/rizsotto/Bear)
- [Laurent Le Brun, “Starlark Programming Language”](https://starlark-lang.org/)
- [Mateusz “j00ru” Jurczyk, “Windows X86-64 System Call Table (XP/2003/Vista/7/8/10/11 and Server)”](https://j00ru.vexillium.org/syscalls/nt/64/)
- [Michał Górny, “The modern packager’s security nightmare”](https://blogs.gentoo.org/mgorny/2021/02/19/the-modern-packagers-security-nightmare/)
- [Mike Shal, “A First Tupfile”](https://gittup.org/tup/ex_a_first_tupfile.html)
- [Mike Shal, “Build System Rules and Algorithms”](https://gittup.org/tup/build_system_rules_and_algorithms.pdf)
- [Mike Shal, “tup”](https://gittup.org/tup/manual.html)
- [Nico Weber, “Ninja, a small build system with a focus on speed”](https://ninja-build.org/)
- [NLnet, “Ripple”](https://nlnet.nl/project/Ripple/)
- [OpenJS Foundation, “Grunt: The JavaScript Task Runner”](https://gruntjs.com/sample-gruntfile)
- [“Preprocessor Options (Using the GNU Compiler Collection (GCC))”](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html)
- [Randall Munroe, “xkcd: Average Familiarity”](https://xkcd.com/2501/)
- [Richard M. Stallman and the GCC Developer Community, “Invoking GCC”](https://gcc.gnu.org/onlinedocs/gcc-15.2.0/gcc.pdf)
- [Rich Hickey, “Clojure - Vars and the Global Environment”](https://clojure.org/reference/vars)
- [Stack Exchange, “What are the advantages of requiring forward declaration of methods/fields like C/C++ does?”](https://langdev.stackexchange.com/questions/153/what-are-the-advantages-of-requiring-forward-declaration-of-methods-fields-like/)
- [Stack Overflow, “Monitoring certain system calls done by a process in Windows”](https://stackoverflow.com/questions/864839/monitoring-certain-system-calls-done-by-a-process-in-windows)
- [System Calls Manual, “dlopen(3)”](https://man7.org/linux/man-pages/man3/dlopen.3.html)
- [System Manager’s Manual, “ld.so(8)”](https://linux.die.net/man/8/ld.so)
- [The Apache Groovy project, “The Apache Groovy™ programming language”](https://groovy-lang.org/)
- [The Chromium Authors, “gn”](https://gn.googlesource.com/gn/)
- [Theo de Raadt, “Removing syscall(2) from libc and kernel”](https://marc.info/?l=openbsd-tech&m=169841790407370&w=2)
- [The Rust Project Contributors, “Bootstrapping the compiler”](https://rustc-dev-guide.rust-lang.org/building/bootstrapping/intro.html)
- [The Rust Project Contributors, “Link using the linker directly”](https://github.com/rust-lang/rust/issues/11937)
- [The Rust Project Contributors, “Rustdoc overview - Multiple runs, same output directory”](https://rustc-dev-guide.rust-lang.org/rustdoc.html)
- [The Rust Project Contributors, “The Cargo Book”](https://doc.rust-lang.org/cargo/)
- [The Rust Project Contributors, “Command-line Arguments - The rustc book”](https://doc.rust-lang.org/rustc/command-line-arguments.html)
- [The Rust Project Contributors, “Queries: demand-driven compilation”](https://rustc-dev-guide.rust-lang.org/query.html)
- [The Rust Project Contributors, “What Bootstrapping does”](https://rustc-dev-guide.rust-lang.org/building/bootstrapping/what-bootstrapping-does.html)
- [Thomas Pöchtrager, “MacOS Cross-Toolchain for Linux and *BSD”](https://github.com/tpoechtrager/osxcross?tab=readme-ov-file)
- [“What is a compiler toolchain? - Stack Overflow”](https://stackoverflow.com/a/69006179)
- [Wikipedia, “Dynamic dispatch”](https://en.wikipedia.org/wiki/Dynamic_dispatch)
- [Wikipedia, “Late binding”](https://en.wikipedia.org/wiki/Late_binding)
- [Wikipedia, “Name binding”](https://en.wikipedia.org/wiki/Name_binding)
- [william woodruff, “Weird architectures weren’t supported to begin with”](https://blog.yossarian.net/2021/02/28/Weird-architectures-werent-supported-to-begin-with)
- [Zig contributors, “Zig Build System“](https://ziglang.org/learn/build-system/)

[^1]: see [this stackexchange post](https://langdev.stackexchange.com/questions/153/what-are-the-advantages-of-requiring-forward-declaration-of-methods-fields-like/) for more discussion about the tradeoffs between forward declarations and requiring full access to the source.

[^2]: even [Rust depends on crt1.o when linking](https://github.com/rust-lang/rust/issues/11937)!

[^3]: early binding is called "static linking".

[^4]: actually, Zig solved this in [the funniest way possible](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html), by bundling a C toolchain with their Zig compiler. This is a legitimately quite impressive feat. If there's any Zig contributors reading—props to you, you did a great job.

[^6]: almost every build system does this, so I don't even feel compelled to name names.

[^7]: Starlark is *not* tied to hermetic build systems. The fact that the only common uses of it are in hermetic build systems is unfortunate.

[^8]: H.T. [Julia Evans](https://jvns.ca/blog/2020/10/26/ninja--a-simple-way-to-do-builds/)

[^9]: another example is  "rebuilding build.ninja when the build graph changes". it's more common than you think because the language is so limited that it's easier to rerun the configure script than to try and fit the dependency info into the graph.

[^10]: not actually turing-complete

[^11]: there's something *called* `docker compose`, but it composes containers, not images.

[^12]: actually variables are more general than this, but for $in and $out this is true.

[^13]: I have been informed that the open-source version of Bazel is not actually hermetic-by-default inside of its prelude, and just uses system libraries. This is quite unfortunate; with this method of using Bazel you are getting a lot of the downsides and little of the upside. Most people I know using it are doing so in the hermetic mode.

[^14]: the uncommon case mostly looks like [incremental bugs in rustc itself](https://blog.rust-lang.org/2021/05/10/Rust-1.52.1/), or issues around rerunning build scripts.
