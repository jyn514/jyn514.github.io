---
title: negative build dependencies
date: 2025-12-03
description: A build system needs to know not just which files exist, but which shouldn't exist.
extra:
  bsky: https://bsky.app/profile/did:plc:h2okxbr76w5522tailkxmidq/post/3m7aotdmjos25
  fedi: https://tech.lgbt/@jyn/115667410263622000
taxonomies:
  tags:
    - build-systems
  four-posts-about-build-systems:
    - "2"
---
This post is part 2/4 of [a series about build systems](/four-posts-about-build-systems/).
The next post is [I want a better action graph serialization](/i-want-a-better-action-graph-serialization/).

---

This post is about a limitation of the dependencies you can express in a build file.
It uses Ninja just because it's simple and I'm very familiar with it, but the problem exists in most build systems.

Say you have a C project with two different include paths: `dependency/include` and `src`:
```
.
├── build.ninja
├── dependency
│   └── include
│       └── interface.h
└── src
    └── main.c
```
and the following build.ninja:[^depfiles]
```ninja
rule cc
  command = cc -I dependency/include -I src $in -o $out

build src/main: cc src/main.c | dependency/include/interface.h
```

{% note() %}

In ninja, `| file` means an “implicit dependency”, i.e. it causes a rebuild but does not get bound to `$in`.

{% end %}

and some small implementations, just so we can see that it actually works:
```c
// src/main.c
#include <stdio.h>
#include "interface.h"

int main(void) {
        printf("%d\n", interface_version);
}

// dependency/include/interface.h
const static short interface_version = 1;
```
This works ok on our first build, and when `dependency/include/interface.h` changes:
```
$ ninja
[1/1] cc -I dependency/include -I src src/main.c -o src/main
```
But say now that we add our own `src/interface.h` file:
```console
$ cat src/interface.h
const static char *version = "1.0";
$ ninja
ninja: no work to do.
```
Now we have a problem. If we remove our build artifacts, ninja *does* rerun, and shows us what that problem is:
```
[1/1] cc -I dependency/include -I src src/main.c -o src/main
FAILED: [code=1] src/main
cc -I dependency/include -I src src/main.c -o src/main
src/main.c: In function ‘main’:
src/main.c:5:24: error: ‘interface_version’ undeclared (first use in this function)
    5 |         printf("%d\n", interface_version);
      |                        ^~~~~~~~~~~~~~~~~
src/main.c:5:24: note: each undeclared identifier is reported only once for each function it appears in
ninja: build stopped: subcommand failed.
```
We switched out what `interface.h` resolved to, but ninja didn't know about the changed dependency.

What we want is a way to tell it to rebuild if the file `src/interface.h` is created. To my knowledge, ninja has no way of expressing this kind of negative dependency edge.

{% note() %}

One possibility is to depend on the *whole directory* of `src`. The semantics of this are that `src` gets marked dirty whenever a file is added, moved, or deleted. This has two problems:
- It rebuilds too often. We only want to rerun when `src/interface.h` is added, not for any other file creation.
- We don’t actually have a consistent way to find all directories that need to be marked in this way. Here we just hardcoded src, but in larger builds [we would use depfiles](#fn-depfiles), and depfiles do not contain any information about negative dependencies. This matters a lot when there are a dozen+ directories in the search path!

{% end %}

{% note() %}

Another way to avoid needing negative dependencies is to simply have a [hermetic build](https://jyn.dev/build-system-tradeoffs/#hermetic-builds), so that our `cc src/main.c | dependency/interface.h` rule never even makes the `src/interface.h` file available to the command. That works, but puts us firmly out of Ninja's design space; hermetic builds come with severe tradeoffs.

{% end %}

{% note() %}

Yet another idea is to introduce an early-cutoff point:
1. For each `.c` file, run `cc -M` to get a list of include files. Save that to disk.
2. Whenever a directory is changed, rerun `cc -M`. If our list has changed, rerun a full build for that file.

<style>var { font-family: monospace; font-style: inherit; }</style>

This has the problem that it's <var>O(n<sup>3</sup>)</var>: For each file, for each include, for each directory in the search path, the preprocessor will try to `stat` that file to see whether it exists.

One possible workaround is to calculate the list of include files *in the build system*:
Look at the order of the search paths, list each path recursively, ignore filenames that are overridden by an include earlier in the search path.
Save that to disk.
Next time a directory is modified, check if the list of include files has changed. If so, only then rerun `cc -M` for all files.

This requires the build system to have some quite deep knowledge of how the language works, but I do think it would work today without changes to Ninja.

Thanks to [Jade Lovelace](https://jade.fyi) for this suggestion.

{% end %}

Thanks to David Chisnall and Ben Boeckel (**@mathstuf**) for making me aware of this issue.

[^depfiles]: People familiar with ninja might say this looks odd and it should use a `depfile` with `cc -M` so dependencies are tracked automatically. That makes your files shorter and means you need to run the configure step less often, but it doesn't actually solve the problem of negative dependencies. Ninja still doesn't know when it needs to regenerate the depfile.
