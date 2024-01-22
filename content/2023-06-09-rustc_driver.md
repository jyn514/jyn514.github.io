---
title:	"rustc_driver"
date:	2023-06-09
audience: developers
description:
draft: true
---

# Cargo and Rustc

## Rustup toolchain proxies

```
Running `/home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc --crate-name example --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=61 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=426bbcd91ed050d9 -C extra-filename=-426bbcd91ed050d9 --out-dir /home/jyn/src/example/target/debug/deps -C incremental=/home/jyn/src/example/target/debug/incremental -L dependency=/home/jyn/src/example/target/debug/deps --extern tracing=/home/jyn/src/example/target/debug/deps/libtracing-ce746726526ad3ba.rmeta`
```

```
; /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc +nightly
error: couldn't read +nightly: No such file or directory (os error 2)
; rustc +nightly
Usage: rustc [OPTIONS] INPUT
```

```
; ls -i /home/jyn/.local/lib/cargo/bin/rustup
32294517 /home/jyn/.local/lib/cargo/bin/rustup
(bash@pop-os) ~/src/example [05:16:29]
; ls -i /home/jyn/.local/lib/cargo/bin/rustc
32294517 /home/jyn/.local/lib/cargo/bin/rustc
```

```
; ls -l /home/jyn/.local/lib/cargo/bin/rustc
-rwxr-xr-x 14 jyn 14293176 Apr 25 07:54 /home/jyn/.local/lib/cargo/bin/rustc
; ls -l /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc
-rwxr-xr-x 1 jyn 2821496 May 17 22:24 /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc
```

```
; ls -lh /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu//lib
total 301M
-rw-r--r-- 1 jyn 170M May 17 22:24 libLLVM-16-rust-1.71.0-nightly.so
-rw-r--r-- 1 jyn 119M May 17 22:24 librustc_driver-d15267f2dccc2ab2.so
-rw-r--r-- 1 jyn  11M May 17 22:24 libstd-edb03adabf0b22c8.so
-rw-r--r-- 1 jyn 3.1M May 17 22:24 libtest-842d91ac2eda7883.so
drwxrwxr-x 8 jyn 4.0K May 17 22:24 rustlib
```

###  Custom proxies

```
; ls -i /home/jyn/.local/lib/cargo/bin/clippy-driver
32294517 /home/jyn/.local/lib/cargo/bin/clippy-driver
```

```
#![feature(rustc_private)]
extern crate rustc_driver;

fn main() -> ! {
    rustc_driver::main();
}
```

```
error[E0463]: can't find crate for `rustc_driver`
 --> src/main.rs:2:1
  |
2 | extern crate rustc_driver;
  | ^^^^^^^^^^^^^^^^^^^^^^^^^^ can't find crate
  |
  = help: maybe you need to install the missing components with: `rustup component add rust-src rustc-dev llvm-tools-preview`
```

```
; ls /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib
libLLVM-16-rust-1.71.0-nightly.so    libstd-edb03adabf0b22c8.so   rustlib
librustc_driver-d15267f2dccc2ab2.so  libtest-842d91ac2eda7883.so
; ls /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib
libaddr2line-c459f8b0a64f04e1.rlib
libadler-6deb8c633abe47e3.rlib
liballoc-c2c050aec00eb6da.rlib
libcfg_if-0b7d1529f62927c0.rlib
libcompiler_builtins-35b8a4bd2de4e62e.rlib
libcore-05898138a596088a.rlib
libgetopts-6bd43da0843f6a65.rlib
libgimli-c2d64f918d4b26ad.rlib
libhashbrown-2a372fbb5b41c14b.rlib
liblibc-69a45ab5967387b5.rlib
libLLVM-16-rust-1.71.0-nightly.so
libmemchr-c0ff7ddb2987d8da.rlib
libminiz_oxide-6b9410c3805b4c08.rlib
libobject-fd705a60736c3357.rlib
libpanic_abort-37ca8267dc328bb1.rlib
libpanic_unwind-56c2a42cc2d7381f.rlib
libproc_macro-2acefb5e6c908418.rlib
libprofiler_builtins-3c89b73fb0267e84.rlib
librustc_demangle-d22c51811a78dc80.rlib
librustc-nightly_rt.asan.a
librustc-nightly_rt.lsan.a
librustc-nightly_rt.msan.a
librustc-nightly_rt.tsan.a
librustc_std_workspace_alloc-45ff23c614a38f1d.rlib
librustc_std_workspace_core-522518611024dce5.rlib
librustc_std_workspace_std-8e879027941aa9d3.rlib
libstd_detect-d8ba7f24f3cb57da.rlib
libstd-edb03adabf0b22c8.rlib
libstd-edb03adabf0b22c8.so
libsysroot-48acea5d838646c5.rlib
libtest-842d91ac2eda7883.rlib
libtest-842d91ac2eda7883.so
libunicode_width-2a97125fb483284e.rlib
libunwind-57df4eca7d5785df.rlib
; ls /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib | grep driver
```

```
; rustup component add rust-src rustc-dev llvm-tools-preview
info: component 'rust-src' is up to date
info: downloading component 'rustc-dev'
info: installing component 'rustc-dev'
 98.4 MiB /  98.4 MiB (100 %)  26.9 MiB/s in  3s ETA:  0s
info: component 'llvm-tools' for target 'x86_64-unknown-linux-gnu' is up to date
; ls /home/jyn/.local/lib/rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib | grep driver
librustc_driver-d15267f2dccc2ab2.so
librustc_driver_impl-80a55b9458715443.rmeta
```

```
#!/bin/sh

case "$1" in
    +*) RUSTUP_TOOLCHAIN=$(echo "$1" | cut -c 1-); shift;;
    *) RUSTUP_TOOLCHAIN=$(rustup default | cut -d ' ' -f 1)
esac

set -x
exec rustup run "$RUSTUP_TOOLCHAIN" "$(basename $0)" "$@"
exit 1 # unreachable
```

### rustc_driver

```
{
    "rust-analyzer.rustc.source": "discover"
}
```

```
impl rustc_driver::Callbacks for UbrustcCallbacks {
    fn config(&mut self, config: &mut interface::Config) {
        config.override_queries = Some(override_queries);
    }
}

fn override_queries(_: &Session, providers: &mut Providers, _: &mut ExternProviders) {
    providers.mir_borrowck = not_a_borrowchecker;
}

fn not_a_borrowchecker(cx: TyCtxt<'_>, _: LocalDefId) -> &'_ BorrowCheckResult<'_> {
    cx.arena.alloc(BorrowCheckResult {
        concrete_opaque_types: Default::default(),
        closure_requirements: None,
        used_mut_upvars: Default::default(),
        tainted_by_errors: None,
    })
}
```

```
; cp target/debug/ubrustc $(rustc --print sysroot)/bin
```

```
fn foo(s: &str) -> &'static str {
    s
}

fn main() {
    let s = foo(&String::from("oops!"));
    println!("{}", s);
}
```


```
; RUSTC=ubrustc cargo +nightly run
    Finished dev [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/example`
�pV
```