---
title: "callgraph analysis (full)"
date: 2026-05-03
draft: true
#description: ""
#taxonomies:
#  tags: []
#  computer-of-the-future: ["0"]
extra:
  draft: true
  toc: 2
#  category: "tools"
#  audience: "everyone"
#  unlisted: true
#  stub: true
---

# Approaches

Say you have a region of a program where users [Want Static Verification](https://faultlore.com/blah/linear-rust/#:~:text=Rust%20users%20Want%20Static%20Verification) that some function is never called. For simplicity, let's say you want to make sure you never call `panic!` so your program doesn't crash.

In this post we talk about:

* Different approaches you could take to implementing this requirement
* The approach we chose for Ferrocene and what made it the right choice for us
* Special requirements of `core` and of certification
* How we implemented callgraph analysis as a custom compiler driver
* How you can try it out yourself.

Now, onwards! There are a few different approaches you could take to implementing this analysis.

## The simple approach: Clippy lints

The first thing you could try is getting [clippy](https://doc.rust-lang.org/clippy/) to catch it:

```rust
#![deny(
  // explicit panics
  clippy::panic,
  clippy::unwrap_used,
  clippy::expect_used,
  clippy::unreachable,
  clippy::unimplemented,

  // panics on language types
  clippy::indexing_slicing,
  clippy::arithmetic_side_effects,

  // panics on library types
  clippy::string_slice,
  clippy::unchecked_time_subtraction,
  clippy::invalid_regex,
)]
```

This has a few issues:

* It doesn't apply recursively to your dependencies, which are still free to panic.
* Relatedly, it can't possibly catch all library types. Clippy has hard-coded lints for `Duration` and `Regex`, but it can't lint everything in the ecosystem.
* This doesn't apply to anything other than panics. Say that your property is "this function never makes a network call" or "this function never allocates memory". Clippy can't catch this; its lints are designed around the *idea* of panicking, not around actual calls to the panic runtime. It doesn't look "inside" of functions, so it's not applicable to any ideas it doesn't recognize.

## The language approach: effect (type-)systems

In this approach, we build the idea of side-effects directly into the language. We annotate the type of each function with the possible side effects it can have, and don't allow it to call functions that could cause a side effect that wasn't annotated[^1]. The most well-known example of this is checked exceptions in Java:

~~~java
static void createFile(String name) {
    new File(name).createNewFile();
    //~^ ERROR unreported exception IOException
}
~~~

In order for this program to compile, we must annotate the exception:

~~~java
static void createFile(String name) throws IOException {
  new File(name).createNewFile(); // ok
}
~~~

This can be extended to other things like I/O, memory allocation, etc. For an example of such a language, see [Koka](https://koka-lang.github.io/koka/doc/book.html#why-effects):

~~~koka
fun hello() : () { println("hi, you!") }
//~^ ERROR type error: effects do not match
            inferred effect: console|_e
            expected effect: total

fun hello2() : console () { println("hi, you!") } // ok
~~~

In Koka, "total" means "this function has no effects". Since `hello` prints to the console, it's inferred to have the `console` effect, which is a type error.

This seems like a neat direction for further research, but retrofitting it into Rust would effectively (🥁) require creating a new language, so I won't talk too much more about it here.

## The toolchain approach: linker errors

It's possible to [give a linker error if you try to call `panic`](https://github.com/dtolnay/no-panic):

~~~rust
fn foo() {
    struct NoPanic;
    unsafe extern "C" {
        #[link_name =
          "\n\nERROR[no-panic]: detected panic in function `main`\n"]
        fn trigger() -> !;
    }
    impl core::ops::Drop for NoPanic {
        fn drop(&mut self) { unsafe { trigger(); } }
    }
    let guard = NoPanic;
    let result = (move || -> () {})();
    core::mem::forget(guard);
    result
}
~~~

The way this works is like so:


1. Define a new `NoPanic` struct that implements `Drop`.
2. In its `Drop` impl, call an undefined C function *whose name is the error message*.
3. Create an instance of `NoPanic`.
4. Run the main part of the function, then `forget` that instance. This means the `Drop` impl will run if—and only if—the function panics.
5. Compile the program with optimizations and then link it.

If the compiler detects that the function never panics, then it can completely optimize out the `NoPanic` object, along with its `Drop` impl. That means it will never try to link the undefined C function, and will compile successfully. If, however, it can't confirm the function never panics (either because it really does panic, or just because the function is complicated), it will give an error while trying to link against the C function. [^4]

This is a neat hack to retrofit this easily into the existing language! It doesn't require any changes to the compiler or tooling, and can be added easily with an attribute macro: `#[no_panic] fn foo() {}`

It has a few downsides:

* This still only works for panics. It's very tied to the idea of unwinding; if your property is "don't allocate memory" it can't help.[^2] It also doesn't work when you set `panic = "abort"`, as is required in `#![no_std]` embedded targets.
* It doesn't support `async` functions.
* It's highly dependent on implementation details. It won't work for non-optimizing compilers, or for interpreters. It would likely be hard to adapt to other languages than Rust.
* It depends on the optimization level, and how "smart" the compiler is, which means that it's prone to breakage and doesn't fall under Rust's stability guarantee.
* Checks don't happen until link time, so it's extremely ill-advised to use this in library crates; it only really works for applications.

## The hacky approach: `cfg`s

You *could* Simply [fork the standard library and slap `cfg`\`s on all the panic machinery](https://github.com/ferrocene/ferrocene/blob/b8c9f370dd8e1e68a1dbf4be3e31041bda58da99/library/core/src/panicking.rs#L71-L86). I wouldn't *recommend* this. But you *could*.

The downside of this approach is that it affects everyone using core, not just the people who care about certification. To avoid breaking changes, we actually ended up introducing a whole new `aarch64-unknown-none.subset` target. This had other downsides, such as build scripts failing to parse the target name. It also doesn't allow compiling with `libtest` on that target, since it uses parts of core that have been `cfg`'d out. In practice, we told people to run `cargo check --target aarch64-unknown-none.subset` but not to use it for full builds, which was a very poor user experience.

## The static analysis approach: a custom compiler driver

We want an approach that "feels like" part of the Rust language, without needing massive changes to the language, compiler, standard library, or build tooling. So, what we can do is introduce a new custom lint that uses annotations that are already valid in the language today:

~~~rust
#![feature(register_tool)]
#![register_tool(verify_no_panic)]
#![deny(verify_no_panic::panics)]

#[verify_no_panic::no_panic]
fn foo() { println!("xyz"); }
//~^ ERROR `std::io::_print` calls `std::io::stdio::print_to`, which may panic
~~~

This has several parts:

1. Use the [`register_tool`](https://github.com/rust-lang/rfcs/pull/3808) attribute to mark that we have a [custom compiler driver](/rustc-driver/).
2. Tell our custom driver that we want to prevent panics, first at the crate-level with `deny` and then for the individual function with `no_panic`.
3. Run our custom tool with something like `cargo verify-no-panic`.

This is quite similar to extending clippy, except without needing to touch clippy itself.

The reason we need to say `#[no_panic]` a second time is in case there *are* some places where panicking is ok, such as in tests or compile-time evaluated code. The extra attribute lets the tool only check the places we care about.

# Implementing callgraphs in Ferrocene
## `core`

This post is not hypothetical. In Ferrocene, the property we wanted to verify was "no certified function in `core` calls an uncertified one". For some background about this, let's talk a bit about certification standards.

### Certification

In our case, we were certifying `core` to [IEC 61508 (SIL-2)](https://www.tuvsud.com/en-us/services/functional-safety/iec-61508) ([original text](https://share.ansi.org/Shared%20Documents/News%20and%20Publications/Other%20Documents/IEC%2061508%20Commented%20Version.pdf)), with a special focus towards use in robotics, as requested by our customers [^5]. We thank [Sonair](https://ferrous-systems.com/pdf/sonair-case-study-2026-03.pdf) and [Kiteshield](https://ferrous-systems.com/pdf/kiteshield-case-study-2026-03.pdf) for their support during the early days of certification.

 IEC 61508 has many different requirements, such as documenting the testing, design, and review process, but the one that scales with the size of the codebase is Annex A.9, "Software verification". We use methods 3 and 4 ("Static analysis" and "dynamic analysis"). The spec gives us a fair bit of freedom in how we actually do our tests; the [approach we document](https://public-docs.ferrocene.dev/main/certification/core/safety-plan/testing-plan.html) is to run our tests on every target platform with a certified `core` and collect code coverage that verifies that every function has been tested.

This of course means that the more code we have, the more tests we have to write. To avoid having to do several years of work before having a product at all, we chose to verify a subset of `core`: we mark these functions as validated, run tests and collect coverage for each of them, and tell our customers to only use those validated functions.

### Core is special

Now this has an issue: how can they actually tell which parts of core they're using? Core is quite strange: it's not a normal library, but actually contains extensive integrations between the compiler and language, as discussed in [my 2022 Rustconf talk about bootstrapping](https://youtu.be/oUIjG-y4zaA?si=HlYu6k5EUZyOFvhT&t=69). That means that when you write something innocuous, like `do_io()?`, it actually [emits a call to `core::ops::try_trait::Try::branch`](https://godbolt.org/z/PzGcEf5xK). As a result, you really do need proper compiler integration to be able to tell which functions call which.

For the 2 previous Ferrocene releases, we had been using the `cfg` approach. In Ferrocene 26.05 we are switching to the compiler driver approach, which integrates much better with existing code, and also allows you to `allow`/`deny` the lint both globally and at individual call-sites.

Here's a small example of what it looks like:

~~~rust
#![crate_type = "lib"]
#![deny(ferrocene::unvalidated)]

fn normal_def() {
    normal_def2(); // ok
}

fn normal_def2() {}

#[ferrocene::prevalidated]
fn validated() {
    normal_def(); //~ ERROR unvalidated
}
~~~

and a screenshot of the diagnostic you get when running Ferrocene on this code:

 ![](/assets/callgraph-analysis/8d069c72-656b-44a9-aa3f-67f31337d873.png " =670x290")

In Ferrocene, we take the liberty of injecting `#![register_tool(ferrocene)]` into your code so that you don't have to use nightly features. You still have the option to write it yourself if you want upstream compatibility with rustup-managed toolchains.

### Requirements

We can rephrase the problem we're solving like so:

> The set of validated functions in `core` must be closed under the function call operator.

"Closed" here is a [term from mathematics](https://en.wikipedia.org/wiki/Closure_(mathematics)) that means "any operation you do to elements of this set outputs another element within the set". In other words, any time we see a function call in a validated function, the function *being* called must also be validated.

Note that this doesn't say anything about unvalidated functions. It's perfectly fine for `core::async_iter::from_iter` (which is unvalidated) to call a validated function like `usize::checked_add`. We only care about keeping validated functions validated.

We have a few baseline requirements here.

* This should work through function calls, macro expansions, and "builtin" syntax expansions, like `?`.
* This should prefer false positives to false negatives. In other words, it's better to accidentally deny valid code than to allow invalid code to be certified.
* This should be backwards-compatible with all existing Rust code; it should only require validated functions to be annotated, without needing changes to unvalidated functions.

## How it works

We wrote a [callgraph analysis](https://en.wikipedia.org/wiki/Call_graph) that verifies that our set of validated functions is closed.

The approach we implemented has several parts.
First, we have a ["pre-mono"](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html) pass that works on [THIR](https://rustc-dev-guide.rust-lang.org/thir.html).
This gives fast feedback while running `cargo check`, and runs late enough that it can "desugar" calls to built-in syntax:

~~~rust
#![deny(ferrocene::unvalidated)]
#![crate_type = "lib"]

#[ferrocene::prevalidated]
fn ops() -> Result<(), &'static str> {
    let x = Err("something went wrong");
    x?;
    Ok(())
}
~~~

 ![](/assets/callgraph-analysis/13431cf8-94aa-4853-a44e-e21a3839d19d.png " =719x356")

It can even catch issues through multiple layers of indirection, such as when you pass an unvalidated function pointer to a validated function:

~~~rust
#![deny(ferrocene::unvalidated)]

use std::panic::{PanicHookInfo, set_hook};

fn unvalidated_panic_hook(_: &PanicHookInfo) {}
fn main() {
    set_hook(Box::new(unvalidated_panic_hook)); //~ ERROR unvalidated
}
~~~

 ![](/assets/callgraph-analysis/811c451c-94a2-4ea1-a280-a51cb35f4820.png " =779x401")

This works by looking for "unsizing casts" from a function type [^3] to a function pointer.

Finally, it can catch casts to dynamic trait objects, which would allow you to call an unvalidated function behind a layer of indirection:

~~~rust
#![deny(ferrocene::unvalidated)]
#![crate_type = "lib"]

struct Unvalidated;
impl ToString for Unvalidated {
    fn to_string(&self) -> String {
        String::new()
    }
}

#[ferrocene::prevalidated]
fn foo() {
    let stringy: &dyn ToString = &Unvalidated; //~ ERROR unvalidated
}
~~~

 ![](/assets/callgraph-analysis/b08c3e68-550a-40fd-8d99-8977d89ee111.png " =830x305")This works by looking for [unsizing casts](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_middle/ty/adjustment/enum.PointerCoercion.html#variant.Unsize) to a trait object, and has to account for things like supertraits and dyn-to-dyn coercions.

However, the pre-mono THIR pass isn't foolproof. Consider the following code:

~~~rust
#![deny(ferrocene::unvalidated)]
#![crate_type = "lib"]

struct Unvalidated;
impl Clone for Unvalidated {
    fn clone(&self) -> Self { Unvalidated }
}

#[ferrocene::prevalidated]
fn uninstantiated_generic<T: Clone>(x: T) {
    x.clone(); //~ ERROR unvalidated
}

#[ferrocene::prevalidated]
pub fn instantiation_reachable() {
    uninstantiated_generic(Unvalidated); //~ NOTE instantiated
}
~~~

Here, we don't know the type of `x` on line 11 until we substitute (or in compiler terms, "instantiate") the generic parameter `T` for the concrete argument `Unvalidated`. Only then do we see that `Unvalidated::clone` hasn't been validated.

To catch this, we implemented a "[post-mono](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html)" pass that works on [MIR](https://rustc-dev-guide.rust-lang.org/mir/index.html). This is reliable and is what we depend on for our certification, but doesn't run on `cargo check`. You'll only see its diagnostics when you run `cargo build` (and sometimes even later, if you have a library with public generic functions). It works by starting at the [monomorphized roots](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_monomorphize/collector/index.html#general-algorithm) of the program, and then working its way in along the callgraph, instantiating types as it goes. This allows us to reliably catch all function calls, no matter how deeply nested they are in generic types, even across crate boundaries:

 ![](/assets/callgraph-analysis/c05318d1-b2ab-420c-8f8b-96bff40be81c.png " =904x324")

## Documentation

Previously, we had generated documentation of which parts of `core` were validated by running rustdoc with special `--cfg` flags set. This generated two sets of documentation, one with all of `core` and one with only the items available in a certified core.

Our new approach is to reuse rustdoc's `doc(cfg(…))` feature to note which items are validated and which aren't. This allows us to show both in [the same document](https://public-docs.ferrocene.dev/main/certification/api-docs/core/index.html):

 ![](/assets/callgraph-analysis/c0d5ada4-bdb0-4a34-baa9-14d92d8f081e.png " =1135x626")

## Future work

The same approach we use for detecting calls to unvalidated functions should also work for detecting calls which can panic. If requested by a customer [^5], we could extend this lint to catch panics within safety-critical code, or within a customer-specified region of code.

## Try it out yourself

### Install Ferrocene

If you are a Ferrocene customer, installing Ferrocene is as simple as writing a `criticalup.toml `and running `criticalup install`:

~~~toml
manifest-version = 1

[products.ferrocene]
release = "nightly-2026-03-20"
packages = [
    "cargo-${rustc-host}",
    "rustc-${rustc-host}",
    "rust-std-${rustc-host}",
    "rust-src",
]
~~~

For more information, see [the criticalup docs](https://criticalup.ferrocene.dev/). To become a customer, see [ferrocene.dev](https://ferrocene.dev/).

Ferrocene is open source, so even if you aren't a customer, you can [consult our public docs](https://public-docs.ferrocene.dev/main/qualification/internal-procedures/index.html) for how to build Ferrocene from source.

### Enable and run the lint

Consult our public [safety-docs](https://public-docs.ferrocene.dev/main/safety-manual/core/subset.html#compliance-with-subset).

## What have we learned?

* There are many existing approaches to callgraph analysis, but all of them are limited in one way or another.
* For Ferrocene, the most accurate approach was to write a custom rustc driver which uses a post-monomorphization pass to detect all resolved function calls.
* Callgraph analysis generalizes to things besides certification, such as detecting whether a given snippet of code panics.

[^1]: Effect languages also introduce the idea of an "effect handler", which is a runtime function that is called when an effect is used. You can think of this as similar to a `catch` block in a language with exceptions, or as Rust's `global_allocator` attribute. Effect handlers don't necessarily need to be paired with an effect system; for example, [`binding`](https://clojuredocs.org/clojure.core/*out*) in clojure and [`parameterize`](https://docs.racket-lang.org/guide/parameterize.html) in Racket allow achieving similar things.

[^2]: You could imagine a setup where you set `#[global_allocator]` to a struct that always returns an error, but this only works globally, not for specific regions of the program. Maybe once the `Allocator` trait is stabilized it will be possible to do this for individual functions. It still won't help with preventing I/O, though.

[^3]: Every function in Rust has its own unique function type, which is usually displayed in diagnostics as `fn() {function_name}`. This is one of the reasons that closures all have a unique type and can only be referred to with `impl Fn()`.

[^4]: Compilers try hard to be deterministic and often succeed. However, that doesn't mean they're *reliable*. Optimizations in particular are almost never guaranteed to occur, and will only happen if the code is "simple enough" for the compiler to figure out what's going on. [As Aria puts it](https://nitter.net/Gankra_/status/1518024855039492096):

    > here's your protip hack for understanding everything compilers do:

    > > hey if i can prove this about your program i can do an optimization

    > > that's hard but there's lots of cases where the answer is easy

    > > when the answer is hard, just *don't do the optimization*

[^5]: Ferrocene has a contract-driven development model, which means that you can pay us to focus on the features that are most important to your company. For more information, [reach out to sales.](https://ferrocene.dev/#pricing)
