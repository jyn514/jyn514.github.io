---
title: "simple is not small"
date: 2026-08-27
draft: true
description: "small programs hide complection"
taxonomies:
 tags: [ideas, software-architecture]
extra:
  draft: true
#  audience: "everyone"
#  toc: 2
#  unlisted: true
---

> **@notjack.space**: UIs with too many buttons confuse and alarm me  
> @**sixfold-origami.com**: ah, this is the unix thing!  
> **@notjack.space**: no, because I want cross device sync to actually work

Recently, I gave a talk titled ["Precise, consistent, and reliable code coverage"](https://www.youtube.com/watch?v=P9lmSc4oLFs&list=PL8Q1w7Ff68DBpmF38rcIAf8Z9Gj2TnlgM&index=27).
It's about a truly gnarly bug that took my company 9 months to debug.
At the end, my friend [Predrag](https://predr.ag/) asks:

> How would you recommend that we think about building tools such that these epic debugging stories aren't as necessary?

and I answer him:

> We need to prioritize simplicity.
> If you go back to my coverage pipeline, there are a *lot* of nodes in this diagram. \[...]
> The tooling's complicated.
> We need to rethink how our computing works.

I'm not satisfied with that answer.

<!--

In fact, I later got a comment from a different friend saying:

> The more I come back to \[the idea of vertical integration, the more] I feel like it's against principles of openess, unix philosophy, and prevents the diffusion of technology.
> I think one of the interesting things about computing is that people build their businesses off a handful of tools, often just gluing them together.
> And so we "stand on the shoulders of giants".

> Right now a bunch of people are writing/generating the code for the first time.
> I think maybe we are doing them a disservice when we as professionals decide to consolidate a bunch of stack layers into singlar systems that only do the "right" things.
> I think we might be pulling up the ladder that got us here.
> I don't really want software development to become a closed system.
> I am not sure we can keep it open and still vertically integrate everything.

I think this gets to the heart of why I'm dissatisfied: "simple" means different things to different people, and when I say that word I'm not saying it in the common usage.

-->

---

Consider three programs to calculate the word count of a file. First, a small unix pipeline:

```sh
tr < README.md --complement --squeeze-repeats '[:alpha:]' '\n' | tr A-Z a-z | sort | uniq --count | sort --reverse --numeric-sort
```

This says "read the README, translate each word boundary into a newline, collapsing multiple newlines, convert uppercase to lowercase, count the number of occurrences of each word, then show them in frequency order". 

I think this is what most people think of when they think of "simple": each program is small, they're designed to be joined together ad-hoc in this way, it's concise and somewhat easy to read.

Next, consider a Clojure program:
```clj
(->> (slurp "README.md")
     (re-seq #"[a-zA-Z]+")
     (map str/lower-case)
     frequencies
     (sort-by val >)
     (run! (fn [[word count]] (println count word))))
```

This does the same thing, with a few more names and higher-order functions thrown in.



; words = runs of letters; no split/empty-token bug
; count by equality — no sort needed to group
