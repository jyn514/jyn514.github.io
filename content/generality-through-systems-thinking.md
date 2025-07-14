---
title: "generality through systems thinking"
date: 2025-07-04
draft: true
description: "our programs have been stuck in a box for a long time. we can escape it."
taxonomies:
 tags: ["ideas"]
 computer-of-the-future: ["2"]
extra:
  category: principles
  stub: true
  draft: true
  toc: true

#  audience: "everyone"
#  unlisted: true
---
> **You are trapped in a box. You have been for a long time.**  
> —[*D. R. MacIver*](https://drmaciver.substack.com/i/145700143/you-are-in-a-box)

> **Every program attempts to expand until it can read mail. Those programs which cannot so expand are replaced by ones which can.**  
> —[_Zawinski's Law of Software Envelopment_](https://en.wikipedia.org/wiki/Jamie_Zawinski#Zawinski's_Law)
## switching costs and growth
most tools simultaneously think too small and too big. “i will let you do anything!”, they promise, “as long as you give up your other tools and switch to me!”

this is true of languages too. any new programming language makes an implicit claim that “using this language will give you an advantage over any other language”, at least for your current problem.

once you start using a tool for one purpose, due to switching costs, you want to keep using that tool. so you start using it for things that wasn’t designed for, and as a result, tools tend to grow and grow and grow until they [stagnate][tech-risk]. in a sense, we have replicated the business boom-and-bust cycle in our own tools.

[tech-risk]: /technical-debt-is-different-from-technical-risk/#what-to-do-about-risk
<!-- /technical-debt-is-different-from-technical-risk/#technical-risk-means-a-program-is-hard-to-modify -->
<!--## escaping the boom and bust cycle-->
## interoperability
there are two possible ways to escape this trap. the first is to [impose a limit on growth](https://graydon2.dreamwidth.org/263429.html), so that tools can’t grow until they bust. this makes a lot of people very unhappy and is generally regarded as a bad idea.

the second is to decrease switching costs. by making it easier to switch between tools, or to interoperate between multiple tools in the same system, there is not as much pressure to have “one big hammer” that gets used for every problem.
### back-compat
tools and languages can decrease switching costs by keeping backwards compatibility with older tools, or at least being close enough that they’re [easy to learn][Simple Made Easy] for people coming from those tools. for example, ripgrep has almost exactly the same syntax as GNU grep, and nearly every compiled language since C has kept the curly braces.

<!--note that you can think of different versions of a tool as having to interoperate with themselves, so you may see these techniques used even when the authors did not intend a clear interface boundary.-->

[Simple Made Easy]: https://youtu.be/SxdOUGdseq4?si=X9OZ975hwwzZOxpo&t=346
### standardization
tools can also collaborate on standards that make it easier to interoperate. this is the basis of nearly every network protocol, since there's no guarantee that the same tool will be on the other side of the connection. to some extent this also happens for languages (most notably for C), where a language specification allows multiple different compilers to work on the same code.

this has limitations, however, because the tool itself has to want (or be forced) to interoperate. for example, the binary format for CUDA (a framework for compiling programs to the GPU) is undocumented, so you're stuck with [reverse engineering](https://blog.vivekpanyam.com/parsing-an-undocumented-file-format) or [re-implementing](https://docs.vulkan.org/guide/latest/what_is_spirv.html) the toolchain if you want to modify it.
### FFI
the last "internal" way to talk to languages is through a "foreign function interface", where functions in the same process can call each other cheaply. this is hard because each language has to go [all the way down to the C ABI](https://faultlore.com/blah/c-isnt-a-language/) before there's something remotely resembling a standard, and because two languages may have incompatible runtime properties that make FFI [hard](https://pkg.go.dev/cmd/cgo#hdr-Passing_pointers) or [slow](https://words.filippo.io/rustgo/#why-not-cgo). languages that do encourage FFI often require you to write separate bindings for each program: for example, Rust requires you to write `extern "C"` blocks for each declaration, and python requires you to do that and also write wrappers that translate C types into python objects.

i won't talk too much more about this—the work i'm aware of in this area is mostly around [WASM](https://webassembly.org/) and [WASM Components](https://component-model.bytecodealliance.org/), and there are also some efforts to [raise the baseline for ABI](https://github.com/rust-lang/rfcs/pull/3470) above the C level.
<!-- IPC/RPC -->
<!--for instance, take the Go language. Go has many strengths—a performant green threads runtime, excellent devtools, static binaries. in exchange, you are locked into the Go ecosystem. unlike other languages (Python, Rust, JS), calls between Go and other languages are [hard](https://pkg.go.dev/cmd/cgo#hdr-Passing_pointers) and have a [high performance overhead](), which means that most libraries you might want to use have to be rewritten into Go. Compare this to, for example, Lua, which is intentionally designed to be easy to embed into larger applications due to its small language size and minimal runtime requirements.-->
### IPC
another approach is to compose tools. the traditional way to do this is to have a shell that allows you to freely compose programs with IPC. this does unlock a lot of freedom! IPC allows programs to communicate across different languages, different ABIs, and different user-facing APIs. it also unlocks 'ad-hoc' programs, which can be thought of as [situated software](https://gwern.net/doc/technology/2004-03-30-shirky-situatedsoftware.html) for developers themselves. consider for example the following shell pipeline:
```bash
git verify-pack -v $(git rev-parse --git-common-dir)/objects/pack/pack-*.idx | sort -k3 -n | cut -f1 -d' ' | while read i; do git ls-tree -r HEAD  | grep "$i"; done | tail
```
this [shows the 10 largest files in the git history for the current repository](https://askubuntu.com/questions/1259129/). let's set aside the readability issues for now. there are a lot of good ideas here! note that programs are interacting freely in many ways:
- the output of `git rev-parse` is passed as a CLI argument to `git verify-pack`
- the output of `git verify-pack` is passed as stdin to `sort`
- the output of `cut` is interpreted as a list and programmatically manipulated by `while read`. this kind of meta-programming is common in shell and has concise (i won't go as far as "simple") syntax.
- the output from the meta-programming loop is itself passed as stdin to the `tail` command

the equivalent in a programming language without spawning a subprocess would be very verbose; not only that, it would require a library for the git operations in each language, bringing back the FFI issues from before (not to mention the hard work designing "cut points" for the API interface[^1]). this shell program can be written, concisely, using only tools that already exist.

the downside of this approach is that the interface is completely unstructured; programs work on raw bytes, and there is no common interface. it also doesn't work if the program is interactive, unless the program deliberately exposes a way to query a running server (e.g. `tmux list-panes` or `nvim --remote`). let's talk about both of those.
<!--attempts to do this rely on IPC or RPC, but these are limited because they still require “cut points” to be determined by the program itself, which is a very hard problem and requires taste[^1] that many people don’t have.-->
#### structured IPC
[powershell](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-04?view=powershell-7.5), and more recently, [nushell](https://www.nushell.sh/book/types_of_data.html), extend traditional unix pipelines with structured data and a typesystem. they have mechanisms for parsing arbitrary text into native types, and helper functions for common data formats.

this is really good! i think it is the first major innovation we have seen in the shell language in many decades, and i'm glad it exists. but it does have some limitations:
- there is no interop between powershell and nushell.
- there is no protocol for programs to self-describe their output in a schema, so each program's output has to be special-cased by each shell.
	- powershell side-steps this by [building on the .NET runtime](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.5#scripting-language), and having native support for programs which emit .NET objects in their [output stream](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams?view=powershell-7.5). but this doesn't generalize to programs that don't run on the [CLR](https://learn.microsoft.com/en-us/dotnet/standard/clr).
and it is very hard to fix these limitations because there is no "out-of-band" communication channel that programs could use to emit a schema; the closest you could get is a "standardized file descriptor number", but that will lock out any program that happens to already be using that FD.
### RPC
## you are trapped in a box
all these [limitations](/operators-not-users-and-programmers#the-user-programmer-distinction) are because [programs are a prison](https://web.archive.org/web/20210121181531/https://djrobstep.com/posts/programs-are-a-prison). your data is trapped inside the box that is your program.

some programs try to make the box bigger—interop between Java, Kotlin, and Clojure is comparatively quite easy because they all run on the JVM. but at the end of the day the JVM is another box; getting a non-JVM language to talk to it is hard.

some programs try to make the box extensible—LISPs, and especially Racket, try to make it very easy to build new languages inside the box. but getting non-LISPs inside the box is hard.

some programs try to give you individual features—smalltalk gets you orthogonal persistence; pluto.jl gets you a “terminal of the future”; rustc gets you sub-process incremental builds. but all those features are inside a box.
### escaping the box
the approach i take in this series is to instead use runtime tracking at the lowest interfaces between the program and the outside world: syscalls, cpu instructions, and [ELF files][] [^2]; interactions that cannot possibly be faked and are required for all programs that run anywhere on the system. this loses portability between OS’s and static analysis. but in turn it gains **generality**: we do not need to establish a new coordination mechanism between any two processes, and our system does not need to special-case any program, because we use the same approach for all of them.

by doing so, we “escape the box”. by moving features outside the process, switching costs are greatly reduced: if we build things at the OS level, we don't have to rewrite them for each program, so the interface boundary is smaller. our systems work even for languages that have not yet been invented! in some sense, this series is an exploration of just how good we can make our tooling without first establishing a new coordination mechanism.

note that this isn’t “just another tool” because programs running in this system can interact freely with programs outside it. there is no kind of vendor lock in. i call this [**systems thinking**](https://en.m.wikipedia.org/wiki/Systems_thinking#Characteristics) because it works at the boundaries of the systems that already exist, in full detail, rather than at the level of the abstractions that are normally built on top. systems thinking is not limited to Unix processes; you can apply it to (e.g.) distributed systems, performance tracking, and debugging.
### does this actually work?
this systems-level approach is surprisingly powerful! here are some existing tools that work at this level:
- docker. this works by sandboxing all processes and interposing an [overlay filesystem] to track their file writes. this sandbox uses linux-specific mechanisms, which is why docker runs in a linux VM on macOS and Windows.
- SystemD [socket activation](https://0pointer.de/blog/projects/socket-activation.html), which decouples the socket file descriptor from the program listening to it, allowing services to be "lazy-activated" when the other side of the socket is written to
- syscall tracking using [strace]
- stack backtraces using [DWARF].
- debuggers (gdb, lldb, etc). these encode quite a lot of information about the language itself, but in theory work for any language with a C-compatible callstack.
- time-travel debuggers, like [rr]. these work by recording and replaying syscalls, so they can work no matter how many layers of FFI are going on in the program.
- dynamically loaded library metadata using [ldd] (and in general the dynamic loader has many surprising features most people don’t know about).

[DWARF]: https://dwarfstd.org
[ldd]: https://man7.org/linux/man-pages/man1/ldd.1.html
[strace]: https://strace.io
[rr]: https://rr-project.org/
[overlay filesystem]: https://docs.kernel.org/filesystems/overlayfs.html
### does this only work for “C-like” languages?
note that all of the above debugging tools are hamstrung by languages with an embedded interpreter; they show information that is accurate but contains far too much info about the runtime internals to be useful to a programmer in that language. in response, people build language specific tools such as [PDB](https://docs.python.org/3/library/pdb.html) and [Delve](https://github.com/go-delve/delve).

this limitation is specific to *mapping runtime info back to the source language*. if you do not attempt to map back to the source language—for examples, schemes 1 and 2 in [completed and orthogonal persistence](/complected-and-orthogonal-persistence/#but-why)—you do not need language specific tooling, and you can get systems that work in full generality for any language. for instance rr can *replay* any process even though it cannot let you debug a python process at the level you want to see.

i’ll discuss how to map back to the source language in [composable compilers](/computer-of-the-future#:~:text=composable%20compilers). for now, we’ll stick with features that don’t require mapping runtime info back to the source.
### this all sounds really cursed
<!--
> It is not so hard as we have supposed.
> —[_Jonathan Strange & Mr Norrell_](https://www.goodreads.com/book/show/14201.Jonathan_Strange_Mr_Norrell)
-->

![holy shit what the fuck is this. why is this a thing. also that sounds rather interesting.](/what-the-fuck-is-this.png)
this is cursed! it's true! working at this level stack exposes you to a whole new axis of bugs. you may discover that your program is broken only on [AMD Zen](https://hackmd.io/sH315lO2RuicY-SEt7ynGA?view#AMD-patented-time-travel-and-dubbed-it-SpecLockMapnbspnbspnbspnbspnbspnbspnbspnbspor-how-we-accidentally-unlocked-rr-on-AMD-Zen), or that it breaks when using [interruptible atomic accesses](https://github.com/rr-debugger/rr/issues/1373#issuecomment-152128412), or that it works 
<!--
thinking at a systems level is hard. but it is [possible to learn](https://jyn.dev/technical-debt-is-different-from-technical-risk/#bad-code-misses-the-point). you just have to learn not to flinch away from things you don’t know.
-->

[ELF files]: https://en.wikipedia.org/wiki/Executable_and_Linkable_Format?wprov=sfti1#Non-Unix_adoption

---
## bibliography

- [D. R. MacIver, "This is important"](https://drmaciver.substack.com/i/145700143/you-are-in-a-box)
- [Wikipedia, "Zawinski’s Law of Software Envelopment"](https://en.wikipedia.org/wiki/Jamie_Zawinski)
- [Graydon Hoare, "Rust 2019 and beyond: limits to (some) growth."](https://graydon2.dreamwidth.org/263429.html)
- [Rich Hickey, "Simple Made Easy"](https://youtu.be/SxdOUGdseq4?si=X9OZ975hwwzZOxpo&t=346)
- [Vivek Panyam, "Parsing an undocumented file format"](https://blog.vivekpanyam.com/parsing-an-undocumented-file-format)
- [The Khronos® Group Inc, "Vulcan Documentation: What is SPIR-V"](https://docs.vulkan.org/guide/latest/what_is_spirv.html)
- [Aria Desires, "C Isn't A Language Anymore"](https://faultlore.com/blah/c-isnt-a-language/)
- [Google LLC, "Standard library: cmd.cgo"](https://pkg.go.dev/cmd/cgo)
- [Filippo Valsorda, "rustgo: calling Rust from Go with near-zero overhead"](https://words.filippo.io/rustgo/)
- [WebAssembly Working Group, “WebAssembly”](https://webassembly.org/)
- [The Bytecode Alliance, "The WebAssembly Component Model"](https://component-model.bytecodealliance.org/)
- [Josh Triplett, "crABI v1"](https://github.com/rust-lang/rfcs/pull/3470)
- [Robert Lechte, “Programs are a prison: Rethinking the fundamental building blocks of computing interfaces”](https://web.archive.org/web/20210121181531/https://djrobstep.com/posts/programs-are-a-prison)
- [Wikipedia, “Executable and Linkable Format”](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format?wprov=sfti1)
- [DWARF Debugging Information Format Committee, “DWARF Debugging Standard”](https://dwarfstd.org)
- [Robert O’Callahan et al., “RR”](https://rr-project.org/)
- [“ldd(1)”](https://man7.org/linux/man-pages/man1/ldd.1.html)
- [The strace developers, “strace: linux syscall tracer](https://strace.io)
- [Python Software Foundation, “`pdb` — The Python Debugger“](https://docs.python.org/3/library/pdb.html)
- [Derek Parker, “Delve”](https://github.com/go-delve/delve)
- [Susanna Clark, *Jonathan Strange & Mr Norrell*](https://www.goodreads.com/book/show/14201.Jonathan_Strange_Mr_Norrell)

[^1]: blog post forthcoming
[^2]: ELF is the default executable format on nearly every modern OS besides MacOS and Windows.
