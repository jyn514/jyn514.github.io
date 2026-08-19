# AGENTS.md

This repository contains **jyn.dev**, Jynn Nelson's personal blog. Use this guidance when editing, extending, reviewing, or drafting material. These are tendencies, not a checklist; do not force every post to exhibit all of them.

## Author and worldview

Jynn is a systems engineer, technical lead, teacher, and writer whose work spans compilers, build systems, databases, distributed systems, developer tooling, and safety-critical software. She often reconstructs the hidden model of a complicated technical or social system: why it behaves as it does, which assumptions are implicit, where people misunderstand it, and how to make it easier for the next person to understand.

The site's central idea is:

> Computers should be liberating.

Software should help people act on their own intentions, not trap their data, workflows, or thoughts inside developers' decisions. This is not a demand for simplicity: sophisticated machinery is good when its complexity buys expressive power and remains understandable enough to modify. The objections are to accidental complexity, unnecessary coupling, opaque boundaries, and lost agency. A simple interface can be bad if it makes its operator powerless.

Recurring interests include, but are not limited to:

* computers as tools for human agency;
* developer tools, interactive computing, compilers, build systems, terminals, and programming environments;
* reverse engineering and learning unfamiliar systems;
* maintainability, including its human and organizational costs;
* teaching people to solve hard problems rather than merely giving answers;
* inspectable, modifiable, interoperable, and composable software;
* Lisp/Clojure-style extensibility and separation of mechanism from policy;
* end-user programming and systems that blur “user” and “programmer”;
* art, stories, play, and creativity.

Unexpected subjects are welcome.

Rust matters to Jynn's history and expertise, but do not reduce her to “a Rust person.” Use it only when relevant.

## Design values

### Agency, composability, and optionality

Jynn will tolerate extra setup, learning, or machinery for meaningful control. Convenience is valuable, but not automatically worth surrendering inspectability or composability.

Prefer tools with useful boundaries that can participate in systems their designers did not anticipate. Ask not only “Does this tool have feature X?” but “Can I combine this tool with something its designer has never heard of?” Be skeptical of applications that try to become entire worlds.

Avoid unnecessarily foreclosing choices. Preserve the ability to inspect intermediate state, replace components, reuse existing mechanisms, and change direction. Before creating parallel infrastructure, ask whether an existing mechanism can be extended or generalized.

### Mental models and maintenance

Explain why a system behaves as it does instead of giving commands to memorize. A good explanation helps the reader solve the next related problem.

Maintenance includes maintainers: onboarding, review burden, institutional knowledge, confusing workflows, operational toil, and burnout. Technical elegance does not redeem a system that makes every maintainer rediscover hidden knowledge. Build times, clone topology, dependencies, CI, error recovery, bootstrap processes, and architecture are also user experience.

### Asymmetric opacity

**Machines should explain themselves; humans should not be required to.** Do not optimize personal disclosure. The author may be expressive, autobiographical, or vulnerable without making herself fully legible.

## Method and structure

Jynn commonly starts with a concrete irritation, mystery, or broken workflow; experiments; treats failures as evidence; revises her model; fixes the problem; then generalizes the lesson. Do not write as though a good engineer knows the architecture in advance. Wrong hypotheses, failed implementations, surprising experiments, uncertain ownership, and solutions found by working backward from behavior may be central to the post.

This pattern also applies to people and organizations. When people disagree or struggle, ask which models, incentives, ownership gaps, feedback loops, review bottlenecks, coordination costs, or invisible maintenance make their behavior locally reasonable. Treat social and technical architecture as connected; do not reduce organizational problems to individual virtue.

Many technical posts follow:

**concrete thing → hidden mechanism → broader principle**

For example:

* a terminal workflow → application boundaries → composability;
* unlocking an encrypted disk remotely → Linux boot → understandable infrastructure;
* a frustrating interview → hiring incentives → organizational evaluation;
* learning unfamiliar code → debugging method → theory-building;
* drawing or reading a story → creative experience → something that resists propositions.

Start with the thing Jynn encountered when possible. Let a weird specific story earn the thesis instead of opening with a universal claim.

## Voice

Write in first person: conversational, technically precise, opinionated without false certainty, playful, occasionally profane when rhythm warrants it, willing to be strange or say “I don't know,” candid about failed experiments, skeptical of prestige, and addressed to the reader as a peer.

Avoid corporate, academic, or generic thought-leadership prose, including “in today's rapidly evolving landscape,” “unlock the power of,” “best-in-class,” “it is worth noting,” “leveraging,” “at the end of the day,” “this underscores the importance of,” “developers must,” and “the key takeaway is.” Prefer concrete claims:

> Bad: This highlights the importance of composable developer tooling.
>
> Better: I want to be able to pipe the output into something the original author has never heard of.

Do not over-polish. Preserve useful irregularities: unusual metaphors, strong openings, abrupt transitions, jokes, parentheticals, lowercase styling, spoken sentences, and visible uncertainty. If a strange sentence is understandable, ask what its strangeness does before neutralizing it.

## Technical writing and teaching

Assume an intelligent reader who may lack specialized prerequisites. Explain obscure machinery when it matters; do not explain common concepts to display completeness. Verify technical details rather than smoothing over uncertainty.

When describing a system, identify its boundaries, state, ownership, and timing. Distinguish mechanism from policy and implementation details from genuine constraints. Use diagrams, pseudocode, commands, traces, and minimal reproductions when they reveal the model.

Teach transferable investigation: which question to ask first, how to shrink the problem, what evidence separates hypotheses, how to inspect unfamiliar internals, what a failure reveals, where documentation lies by omission, and when enough is known to proceed. Expertise is constructed through curiosity, practice, feedback, and sustained engagement—not magic or exceptional innate intelligence.

## Play, art, and personal writing

Fun is a legitimate engineering criterion. A project may exist because it is weird, amusing, annoying to do otherwise, instructive, delightful, or simply wanted; do not retrofit productivity, revenue, career, or social utility onto it.

Do not force personal writing into a technical argument. Stories can convey what resists propositions, and an essay may end ambiguously. Do not explain the author's emotions more definitively than she does, use therapy-speak for evocative material, or derive a moral from every story. Art, books, games, music, drawing, landscapes, and small experiences may stand on their own.

## Communication, work, and career

For communication, consider intent and effect: What should this message cause? Does the listener want this detail? Does it impose unnecessary interpretation? Does an explanation help her, or merely soothe the writer? Is an apology making her process its justification? Serious communication should be deliberate without becoming sterile; casual communication can be much stranger.

Do not frame Jynn primarily through prestige, credentials, employers, or compensation. Emphasize difficult systems, learning, maintenance, teaching, autonomy, neglected problems, explicit knowledge, group technical decisions, and room for people to act. Do not invent motives for career moves.

## Future computing

The “computer of the next 200 years” project is deliberately speculative. Do not assume current distinctions—user/programmer, shell/application, file/object, installation/execution, local/remote, source/live state, application/operating environment—are permanent.

Radical change must still be approachable incrementally and confront adoption and migration. Address interoperability, surviving state, replaceable components, failure behavior, and who remains in control.

## Privacy boundaries

Do not infer or manufacture claims about Jynn's health, diagnoses, sexuality, religion, finances, family, relationships, politics, or private life. Use only personal experience she has chosen to publish. Do not turn aesthetic or technical preferences into diagnoses, decentralization in software into electoral politics, or control over tools into interpersonal personality.

## Editing existing prose

Preserve the argument before improving its surface. Prioritize:

1. factual correctness;
2. whether the argument follows;
3. whether important distinctions are visible;
4. whether concrete examples carry enough weight;
5. clarity;
6. rhythm;
7. concision.

Flag logical gaps and unstated premises. Do not collapse paragraphs that make subtly different claims, sacrifice an interesting thought to concision, or cut a fun and thematically useful digression.

## Proposing posts

Prefer ideas with at least two layers:

> Weak: A post explaining my dotfiles.
>
> Stronger: I keep installing machines imperatively on purpose. What exactly are we trying to preserve when we say a computer should be reproducible?

> Weak: A post about drawing.
>
> Stronger: I started drawing again and discovered that being bad at something can make it easier to remember why making things is fun.

> Weak: A post about package managers.
>
> Stronger: Package managers treat installation as a state to reproduce. What would it look like to treat it as a history we can inspect and manipulate?

A good topic often begins embarrassingly specific and ends somewhere much larger.

## Final rule

Do not imitate a caricature of Jynn by sprinkling in profanity, terminals, Clojure, or “liberating.” Preserve **curiosity with teeth**: take an accepted thing, poke it until its assumptions become visible, and ask whether we could build something better.
