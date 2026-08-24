---
title: "distributed identity"
date: 2026-08-24
draft: true
description: "Git makes it stupidly hard to change or hide your identity"
#taxonomies:
#  tags: []
#  computer-of-the-future: ["0"]
extra:
  draft: true
#  category: "tools"
#  audience: "everyone"
#  toc: 2
#  unlisted: true
#  stub: true
---

## What problem are we solving?

Say that you have a big 'ol git repo.
Thousands of commits, hundreds of issues, dozens of PRs.
And now let's say one of your contributors—not a maintainer, mind you, just someone who helps out once in a while—is named Andrea P. Researcher <andrea@conglomerate.example.com>.

Andrea gets a new job at Greenfield & Co and changes her email.
She come to you with a request: actually, i didn't like my old job very much, could you update the commit history to the new email?

Now you have a small problem: Git is a [merkle tree] that preserves all past commits in amber.
You can't change any past commit without "force-pushing" to the default branch, invalidating every single commit hash, distributed checkout, and open PR.

[merkle tree]: https://wyag.thb.lt/#merkle-dags

Not to worry, you say!
The authors of git predicted this.
You have the perfect tool: [git mailmap](https://git-scm.com/docs/gitmailmap).
Andrea says perfect, perfect, and adds an entry:
```mailmap
Andrea P. Researcher <andrea@greenfield.example.com> <andrea@conglomerate.example.com>
```

---

Now, Andrea gets married and changes her maiden name to Locksmith.
She's still working at Greenfield & Co, though, so she has the same email.
<!-- , and she accidentally made a few commits before she remembered to update her last name. -->
She comes back and asks: can you change the commits since I got married to Andrea Locksmith, but keep the old ones as Andrea Researcher?
And you say, no, mailmap doesn't really work that way ... git identifies you by your (name, email) tuple, it doesn't have any concept of a date.
She grumbles a bit, but well, it's not such a big deal.
She uses mailmap to change her commits to consistently use Andrea Locksmith for all the `<andrea@greenfield.example.com>` changes (it's close enough) and leaves the `conglomerate` ones be.

---

Andrea meets some friends and goes to some movies and shows and reads some books and has a few revelations about himself.
He comes back and says, hey i have some news about myself, um, my new name is Bobby.
Can you update all my commits?
And you point him to mailmap and he says no no, that keeps my deadname around right at the top of the repo.
Can't you change the *actual data* somehow?
Look, man, this is important to me. [^1]

And you apologize, and you really do feel bad;
but you look at the 300 open PRs, and the hard-coded commits in [`.git-blame-ignore-revs`][ignore-revs], and the merge tooling you wrote that can't handle force-pushes, and you just ... you just don't want to think about how much effort it would be to fix all those.
And Bobby gets it, he does, and he makes a mailmap entry instead.
But all the same, he contributes a bit less now.

[ignore-revs]: https://docs.github.com/en/repositories/working-with-files/using-files/viewing-and-understanding-files#ignore-commits-in-the-blame-view

---

Bobby moves to Germany and learns they have this neat thing called [GDPR].
And one of his friends tells him, look man, you have a right to be called the name you chose, you know?
An honest-to-god, enshrined-in-law legal right.
And now Bobby comes back to you and say "I want you rip my name out of the repository because it's personal data of an individual."

Well, you're not *quite* sure that's how GDPR works (maybe you have a "legitimate interest"? are we really sure you were offering a "product or service" to Bobby?).
But all the same, lawyers are expensive, and you'd rather not go through the hassle, especially since, well, Bobby really does have a good reason here.
And anyway, it would be bad PR, and *this* isn't the thing you want to lose contributors over.

So you figure out how to use [`git-filter-repo`]
and update `.git-blame-ignore-revs`
and force-push to `main`
and write a blog post telling everyone how to rebase their PRs
and realize you hard-coded commit hashes in your docs so you go back and fix those too,
and realize you hard-coded them even in some blog posts so now you have to update *those*
and ugh. ok. that's probably most of it now.

And Bobby is happy and you're happy he's happy and you put on a half-hearted smile.
And then his mate Charlie comes by and says actually that was neat, can you do that for me too?

[GDPR]: https://www.edpb.europa.eu/sme/learn-the-basics/data-protection-basics_en#does-the-gdpr-apply-to-your-organisation
[`git-filter-repo`]: https://github.com/newren/git-filter-repo

---

## How have people tried to solve this?

Git is making your life a right-old pain here!
If this happens two or three more times, you might even be willing to switch to a different tool, one that supports this better.
And—what's this?—there's something called [`hg censor`]!
It says this:
> The censor command instructs Mercurial to erase all content of a file at a given revision without updating the changeset hash. This allows existing history to remain valid while preventing future clones/pulls from receiving the erased data.
> Typical uses for censor are due to security or legal requirements, including:
> * Passwords, private keys, cryptographic material
> * Licensed data/code/libraries for which the license has expired
> * Personally Identifiable Information or other private data

Perfect, perfect, except *wait* that said **content of a file**.
The author of a commit is actually *not* the content of a file.
It's metadata attached to the commit itself.

Damn. So close.

[`hg censor`]: https://www.selenic.com/mercurial/hg.1.html#censor

## How can we solve it?

Well, how does `hg censor` work anyway?

> Censored nodes can interrupt mercurial's typical operation whenever the excised data needs to be materialized. Some commands, like hg cat/hg revert, simply fail when asked to produce censored data. Others, like hg verify and hg update, must be capable of tolerating censored data to continue to function in a meaningful way. Such commands only tolerate censored file revisions if they are allowed by the "censor.policy=ignore" config option.

Oh. Uh. They're destroying the "cryptographic hashes" part of the merkle tree.
That's fine? Probably? We don't *really* need [`hg verify`] to work.
[For complicated reasons related to "filelogs"][revlogs], this doesn't let us get up to much mischief anyway; we can corrupt `hg log --follow` but not much more.
If we extended this same scheme to metadata though, things would get worse, we might be able to corrupt `hg log` itself to point to a malicious history.

[`hg verify`]: https://mercurial-scm.org/repository-corruption
[revlogs]: https://aosabook.org/en/v1/mercurial.html#:~:text=the%20three%20revlogs

Does it *need* to work that way?
Let's consider the properties we want by comparing to how changes usually work online:
1. People can rename themselves and change their emails.
2. People can delete their accounts. This usually shows up as a post by a `[deleted]` user, or a `@ghost` username.
3. People can (usually) delete the contents of their posts; sometimes admins retain edit history.
4. People can (rarely) delete the post itself, in such a way that you can't distinguish "used to be a post here" from "never was a post here".

`mailmap` gets us 1, kinda. It's still traceable pretty easily.
`hg censor` gets us 3.
Nothing currently out there gets us 2 or 4.

4 is probably not something we care about too much here.
"Delete all traces of this commit, even the fact it existed" doesn't seem particularly necessary.
But better support for 1 and 2 would be very nice.

## Now she's back in the ATmosphere

I have good news for you: there is already an online identity service that does this!
(No, it's not OpenID Connect.)
It's called [ATProto](https://atproto.com/)
and it's the protocol powering [Bluesky](https://bsky.app/).

Exactly how ATProto works is a bit out of scope for this post (for more on that see [The Hitchhiker's Guide to the Atmosphere][what-is-atproto]),
but what is relevant is how ATProto handles *identity*.
It does this with a [**decentralized identifier** (DID)][did].
For example, my Bluesky handle is `@jyn.dev`, but my ATProto DID is
[`did:plc:h2okxbr76w5522tailkxmidq`][atproto-explorer].
Because the two are different, that allowed me to change my handle from `@jyn.bsky.social` to `@jyn.dev` when I first joined Bluesky.

What's interesting about this is it allows *you* to control where your data lives.
ATProto has a concept of a [**Personal Data Server** (PDS)][pds]:
by default, when you join Bluesky, your data lives on their servers,
but you can migrate your PDS and self-host your own data.
This means, for example, that Bluesky can't ban you [^2].

Ok, so, let's put this together and use it in our Git identity alternative.
We now have portability, modification, revocability, and—oh? what's that? [a primary source?][did-plc]

> The full history of DID operations and updates, including timestamps, is permanently publicly accessible. This is true even after DID deactivation. It is important to recognize (and communicate to account holders) that any personally identifiable information (PII) encoded in alsoKnownAs URIs will be publicly visible even after DID deactivation, and can not be redacted or purged.
> In the context of atproto, this includes the full history of handle updates and PDS locations (URLs) over time. To be explicit, it does not include any other account metadata such as email addresses or IP addresses. Handle history could potentially de-anonymize account holders if they switch handles between a known identity and an anonymous or pseudonymous identity.

aww.....

Does it *need* to work this way?

This is talking specifically about *bluesky handles*.
But ATProto has a bunch of other [kinds of data][lexicon].
We could just. You know. Build our own. With blackjack, and hookers.

[Here's][chess-record] an example of a custom ATPRoto record:
```
{
  "uri": "at://did:plc:h2okxbr76w5522tailkxmidq/blue.checkmate.game/3msn57l2vrt2x",
  "cid": "bafyreiab3suqph7m5xw2weronkts7ekp224rfrkltwiafluqjff7wtjlsi",
  "value": {
    "pgn": "[Event \"checkmate.blue\"]\n[Site \"https://checkmate.blue\"]\n[Date \"2026.08.09\"]\n[Round \"-\"]\n[White \"did:plc:7oyzfpde4xg23u447zkp3b2i\"]\n[Black \"did:plc:h2okxbr76w5522tailkxmidq\"]\n[Result \"1-0\"]\n\n1. e4 e5 2. f4 Nc6 3. Nf3 d6 4. Bc4 Nf6 5. O-O Nxe4 6. Bxf7+ Kxf7 7. Ng5+ Nxg5 8. fxg5+ Kg8 9. Qf3 Nd4 10. Qf7# 1-0",
    "$type": "blue.checkmate.game",
    "black": "did:plc:h2okxbr76w5522tailkxmidq",
    "white": "did:plc:7oyzfpde4xg23u447zkp3b2i",
    "result": "1-0",
    "status": "completed",
    "createdAt": "2026-08-09T08:12:04.842Z",
    "lastMoveAt": "2026-08-09T08:15:49.540Z",
    "drawOffered": false,
    "resultReason": "checkmate",
    "parentGameUri": "at://did:plc:7oyzfpde4xg23u447zkp3b2i/blue.checkmate.game/3msn4vikzvy2i"
  }
}
```

This is a chess game played between me and `@notjack.space`,
on [checkmate.blue](https://notes.hadsie.com/3mlbknk2cu22z),
a multiplayer chess app built fully-client side on top of ATProto.

Unlike `did:plc` records, normal ATProto records have no permanent history and can be deleted.

[what-is-atproto]: https://marvins-guide.leaflet.pub/3lyqxqbbqkc2p
[atproto-explorer]: https://atproto.at/uri/at://did:plc:h2okxbr76w5522tailkxmidq
[did]: https://atproto.wiki/en/wiki/reference/identifiers/did
[pds]: https://atproto.wiki/en/wiki/reference/core-architecture/pds
[lexicon]: https://atproto.wiki/en/wiki/reference/lexicons
[did-plc]: https://github.com/did-method-plc/did-method-plc/blob/main/website/spec/v0.1/did-plc.md

## Tying it all together

So, one way we could fix Bobby's problem is something like this:
1. Just build a new VCS data model from scratch. Look, if we make it a [jj] backend, it can't be *that* much work, right?
2. When you create a commit, instead of having a name/email pair in metadata, embed an opaque id that's *mumble mumble [fancy crypto secrets][digital-credentials] generated from your DID + per-repo salt*.
3. Create a new `org.jyns-awesome-vcs.identity` ATProto schema that has a list of claimed opaque ids, current name and email, optional past emails, optional github link using OAuth, etc.
4. When you run `jj log`, it fetches your identity from ATProto. [^3]

[digital-credentials]: https://www.w3.org/TR/digital-credentials/

This gets us all the properties we want!
- You can edit any identity after the fact.
- You can delete your identity by removing the claimed opaque ID from your ATProto record.
- The [*mumble mumble crypto secrets*][digital-credentials] make sure that only you can claim that DID. Probably. I'm not a cryptographer.

[jj]: https://docs.jj-vcs.dev/latest/

[^1]: if this doesn't sound important to you, imagine that idk, Bobby is going into a witness protection program or something, or getting a divorce from an abusive ex. but also, get the hell off my site.

[^2]: they can ban you from Bluesky, but not from ATProto as a whole. see [here][rudy-post] for more information about this.

[rudy-post]: https://bsky.app/profile/rude1.blacksky.team/post/3mcozwdhjos2b
[chess-record]: https://atproto.at/uri/at://did:plc:h2okxbr76w5522tailkxmidq/blue.checkmate.game/3msn57l2vrt2x

[^3]: Live fetches would be expensive, but you can make them cheaper with an [appview], which you can think of as a giant cache with structured database-like queries.
     This is similar to the idea behind [trustfall].

[appview]: https://atproto.wiki/en/wiki/reference/core-architecture/appview
[trustfall]: https://github.com/obi1kenobi/trustfall
