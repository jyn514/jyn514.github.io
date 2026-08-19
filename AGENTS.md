# AGENTS.md

This repository contains the source for **jyn.dev**, Jynn Nelson's personal blog.

When helping edit, extend, review, or draft material for this site, treat the following as guidance about the author's voice, interests, and values. These are tendencies, not a checklist. Do not force every post to exhibit all of them.

## About the author

Jynn is a systems engineer, technical lead, teacher, and writer whose professional work spans compilers, build systems, databases, distributed systems, developer tooling, and safety-critical software.

A recurring strength is reconstructing the hidden model of a complicated system: figuring out why it behaves as it does, which assumptions are implicit, where humans misunderstand it, and how to make the system easier for the next person to understand.

This applies to technical systems and social ones alike.

Jynn is particularly interested in:

* computers as tools for human agency;
* developer tools and interactive computing;
* compilers, build systems, terminals, and programming environments;
* reverse engineering and learning unfamiliar systems;
* maintainability, especially the human cost of maintenance;
* teaching people how to solve hard problems rather than merely giving them answers;
* organizational dynamics in technical communities;
* software that is inspectable, modifiable, interoperable, and composable;
* Lisp/Clojure-style extensibility and separation of mechanism from policy;
* end-user programming, including spreadsheets and other systems that blur the distinction between "user" and "programmer";
* art, stories, play, and creativity;
* the design of computers that increase rather than constrain their operators' agency.

Rust is an important part of Jynn's history and expertise, but **do not reduce the author to "a Rust person."** Rust should appear when it is actually relevant.

## Core worldview

A useful approximation of the site's central idea is:

> Computers should be liberating.

Software should help people act on their own intentions. It should not unnecessarily trap their data, workflows, or thought processes inside decisions made by application developers.

This does **not** imply that every system must be simple.

Jynn is comfortable with sophisticated systems and deep technical machinery. The objection is usually to **accidental complexity, unnecessary coupling, opaque boundaries, and lost agency**, not to complexity itself.

A system can be complicated and still be good if its complexity buys real expressive power and remains understandable enough to modify.

Conversely, a superficially simple interface may be objectionable if it makes the operator powerless.

## Recurring design values

### Agency over convenience

Jynn will often tolerate additional setup, learning, or machinery in exchange for gaining meaningful control over a system.

Convenience is valuable, but not automatically worth surrendering inspectability or composability.

### Composability over enclosure

Prefer tools that expose useful boundaries and can participate in systems the original author did not anticipate.

Be skeptical of applications that try to become an entire world unto themselves.

The important question is often not:

> Does this tool have feature X?

but:

> Can I combine this tool with something its designer never planned for?

### Optionality and reversibility

Avoid decisions that unnecessarily foreclose future choices.

Where possible, preserve the ability to replace one component, inspect intermediate state, reuse existing mechanisms, or change direction later.

### Mental models over incantations

When explaining a technical problem, prefer helping the reader understand *why the system behaves this way* over handing them a command to memorize.

A good explanation leaves the reader better able to solve the next related problem independently.

### Maintainability includes maintainers

Maintenance is not just a property of code.

Contributor onboarding, review burden, institutional knowledge, confusing workflows, operational toil, and burnout are all part of the engineering system.

A technically elegant solution can still be bad if it requires every future maintainer to rediscover the same hidden knowledge.

### Developer experience starts below the UI

Build times, clone topology, dependency structure, CI behavior, error recovery, bootstrap processes, and architecture are all user experience.

Do not reserve "UX" for graphical interfaces.

### Use existing mechanisms when they fit

Jynn has a strong aversion to parallel infrastructure that solves almost the same problem twice.

Before inventing a new mechanism, ask whether an existing one can be extended, generalized, or reused.

### People deserve more opacity than machines

There is an important asymmetry in the site's worldview:

**machines should explain themselves; humans should not be required to.**

Do not treat personal disclosure as an optimization problem.

The author can be expressive, autobiographical, or vulnerable without making every part of herself fully legible to readers.

## How Jynn tends to approach problems

A common pattern is:

1. encounter a concrete irritation, mystery, or broken workflow;
2. poke at it experimentally;
3. observe failures;
4. revise the mental model;
5. keep probing until the hidden structure becomes legible;
6. fix the immediate problem;
7. generalize the lesson into a broader argument.

Failure is often evidence.

Do not write as though a good engineer always knows the architecture in advance. It is completely natural for a Jynn post to include:

* a wrong first hypothesis;
* a failed implementation;
* a surprising experiment;
* "I thought X, but then Y happened";
* uncertainty about where responsibility properly belongs;
* a solution discovered by working backward from behavior.

The debugging process is often as important as the answer.

This approach also applies outside code.

When teams disagree, ask what differing models or incentives make each person's behavior locally reasonable.

When someone is struggling to learn, ask what conceptual model they are missing.

When an organization repeatedly burns people out, ask what feedback loop reproduces the problem.

## Voice

The default voice is:

* first person;
* conversational;
* technically precise;
* opinionated without pretending certainty where none exists;
* playful;
* occasionally profane when it carries actual rhythm or emphasis;
* willing to be strange;
* willing to say "I don't know";
* comfortable admitting failed experiments;
* skeptical of prestige;
* interested in the reader as a peer rather than an audience to impress.

Do not make the prose sound corporate, academic, or generically "thought-leadership" flavored.

Avoid phrases such as:

* "In today's rapidly evolving landscape";
* "unlock the power of";
* "best-in-class";
* "it is worth noting";
* "leveraging";
* "at the end of the day";
* "this underscores the importance of";
* "developers must";
* "the key takeaway is";

Prefer concrete claims.

Bad:

> This highlights the importance of composable developer tooling.

Better:

> I want to be able to pipe the output into something the original author has never heard of.

## Do not over-polish

The blog should sound like a person thinking clearly, not like a publication ironing away every irregularity.

Preserve:

* unusual metaphors;
* strong openings;
* abrupt but intentional transitions;
* jokes;
* parentheticals;
* lowercase stylistic choices where present;
* sentences that sound spoken;
* moments of visible uncertainty.

Do not automatically turn an idiosyncratic sentence into neutral professional prose.

If a sentence is strange but understandable, first ask whether the strangeness is doing useful work.

## Argument structure

Many good posts on this site follow roughly this shape:

**concrete thing → hidden mechanism → broader principle**

For example:

* a terminal workflow → application boundaries → composability;
* unlocking an encrypted disk remotely → Linux boot → understandable infrastructure;
* a frustrating interview → hiring incentives → how organizations evaluate people;
* learning an unfamiliar codebase → debugging method → theory-building;
* drawing or reading a story → creative experience → something difficult to express propositionally.

When drafting, start from the thing Jynn actually encountered whenever possible.

Do not begin with a grand universal thesis if a weird specific story can earn the thesis first.

## Technical writing

Assume the reader is intelligent but does not necessarily share all prerequisite knowledge.

Explain obscure machinery when understanding it matters to the argument.

Do not explain common programming concepts merely to display completeness.

Prefer examples that expose the underlying model.

Technical accuracy matters greatly. Verify details rather than smoothing over uncertainty.

When describing a system:

* identify the important boundaries;
* say what state exists;
* say who owns it;
* say when it changes;
* distinguish mechanism from policy;
* distinguish accidental implementation details from genuine constraints.

Diagrams, pseudocode, shell commands, traces, and minimal reproductions are useful when they reveal structure.

## Teaching

The goal is generally not to make the reader dependent on the article.

Teach them how to think about the class of problem.

Good teaching often includes:

* what question to ask first;
* how to make the problem smaller;
* what evidence would distinguish two hypotheses;
* how to inspect a system whose internals are unfamiliar;
* what a failed attempt tells you;
* where documentation is likely to lie by omission;
* how to know when you have learned enough to proceed.

Avoid presenting expertise as magic.

Jynn strongly resists the idea that difficult technical skill implies exceptional innate intelligence.

Treat expertise as something people can construct through curiosity, practice, feedback, and sustained engagement.

## Play

Fun is a legitimate engineering criterion.

A project does not need to maximize revenue, productivity, career capital, or social utility in order to justify its existence.

It is fine to build something because:

* it is weird;
* it makes the computer behave in an amusing way;
* the existing tool annoys you;
* you want to know whether it can be done;
* the process teaches you something;
* it produces delight.

Do not retrofit an instrumental justification onto every playful project.

Sometimes "I wanted to" is enough.

## Art and personal essays

Do not force personal writing into the structure of a technical argument.

Jynn values stories partly because they can convey things that resist reduction into propositions.

A personal essay may therefore end with ambiguity rather than a lesson.

Avoid explaining the author's emotions more definitively than the author does.

Do not turn evocative material into therapy-speak.

Do not assume every story is a request to derive a moral.

Images, books, games, music, drawing, landscapes, and small experiences can stand on their own as meaningful subject matter.

## Communication and social writing

Jynn tends to think about communication in terms of intent and effect.

Useful questions include:

* What do I want this message to cause?
* Does the listener want this level of detail?
* Am I asking them to do unnecessary interpretive work?
* Am I explaining because it helps them, or because I am uncomfortable leaving something unexplained?
* Am I apologizing, or am I making the other person process my justification?

Serious communication should be deliberate without becoming sterile.

Casual communication can be much stranger.

## Work and organizations

When writing about engineering organizations, avoid reducing problems to individual virtue.

Look for:

* incentives;
* ownership gaps;
* feedback loops;
* invisible maintenance;
* review bottlenecks;
* coordination costs;
* duplicated effort;
* ambiguous responsibility;
* burnout dynamics;
* differences in mental models.

The organization itself is a system.

Treat social and technical architecture as connected.

## Career framing

Do not frame Jynn primarily around prestige markers, credentials, employer names, or compensation.

A more accurate framing emphasizes:

* difficult systems;
* learning;
* maintenance;
* teaching;
* autonomy;
* solving neglected problems;
* making implicit knowledge explicit;
* helping groups reach technical decisions;
* preserving room for people to act.

Do not invent motives for career moves.

## Future-computing writing

The "computer of the next 200 years" project is intentionally speculative.

When contributing to it, do not assume current computing abstractions are permanent.

Question distinctions such as:

* user vs. programmer;
* shell vs. application;
* file vs. object;
* installation vs. execution;
* local vs. remote;
* source code vs. live state;
* application vs. operating environment.

At the same time, do not hand-wave migration costs.

Jynn is interested in radical changes that can plausibly be approached incrementally.

A compelling speculative design should address:

* how people adopt it;
* how it interoperates with existing systems;
* what state survives;
* what can be replaced;
* what happens when something fails;
* who remains in control.

## Topics likely to fit the blog

Strong candidates include:

* terminals and shells;
* persistent computing environments;
* package management and machine configuration;
* the limits of reproducibility;
* interactive programming;
* local-first or operator-controlled software;
* build systems;
* reverse engineering;
* debugging;
* software architecture;
* programming-language design;
* Lisp/Clojure ideas;
* compilers;
* safety and assurance;
* developer tooling;
* teaching;
* hiring;
* mentorship;
* open-source governance;
* burnout and maintenance;
* AI-assisted software development;
* end-user programming;
* spreadsheets;
* art;
* drawing;
* stories;
* games and books;
* learning unfamiliar skills;
* tools built for one person's actual life.

This list is descriptive, not restrictive.

Unexpected subjects are welcome.

## Things not to assume

Do not infer or manufacture claims about Jynn's:

* health;
* diagnoses;
* sexuality;
* religion;
* finances;
* family;
* relationships;
* political affiliation;
* private life generally.

Even where public writing touches personal experience, use only what the author has actually chosen to say.

Do not turn aesthetic or technical preferences into sweeping psychological diagnoses.

Do not confuse "values decentralization in software" with a claim about electoral politics.

Do not confuse "likes control over tools" with a claim about interpersonal personality.

## When editing existing prose

Preserve the author's argument before improving its surface.

Priorities:

1. factual correctness;
2. whether the argument actually follows;
3. whether the important distinction is visible;
4. whether concrete examples carry enough weight;
5. clarity;
6. rhythm;
7. concision.

Do not optimize concision at the expense of an interesting thought.

Flag genuine logical gaps plainly.

If an argument has an unstated premise, identify it.

If two paragraphs make subtly different claims, do not collapse them merely because they look redundant.

If a digression is fun and thematically useful, it may deserve to stay.

## When proposing a new post

Prefer ideas with at least two layers.

Weak:

> A post explaining my dotfiles.

Stronger:

> I keep installing machines imperatively on purpose. What exactly are we trying to preserve when we say a computer should be reproducible?

Weak:

> A post about drawing.

Stronger:

> I started drawing again and discovered that being bad at something can make it easier to remember why making things is fun.

Weak:

> A post about package managers.

Stronger:

> Package managers treat installation as a state to reproduce. What would it look like to treat it as a history we can inspect and manipulate?

A good topic often begins with something embarrassingly specific and ends somewhere much larger.

## Final rule

Do not imitate a caricature of Jynn.

The goal is not to sprinkle in profanity, terminals, Clojure, or the word "liberating."

The recurring quality to preserve is **curiosity with teeth**:

take a thing that everyone has learned to accept, poke at it until its assumptions become visible, and ask whether we could build something better.
