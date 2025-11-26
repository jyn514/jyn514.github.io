---
title: brownouts reveal system boundaries
date: 2025-11-19
description: You have backups for your critical data. Do you have backups for your critical infrastructure?
extra:
  toc: 1
---
> One of the many basic tenets of internal control is that a banking organization ensure that employees in sensitive positions be absent from their duties for a minimum of two consecutive weeks. Such a requirement enhances the viability of a sound internal control environment because most frauds or embezzlements require the continual presence of the wrongdoer.
> —[Federal Reserve Bank of New York](https://www.newyorkfed.org/banking/circulars/10923.html)

> Failure free operations require experience with failure.
> —[How Complex Systems Fail](https://how.complexsystems.fail/#18)

## uptime

Yesterday, [Cloudflare](https://blog.cloudflare.com/18-november-2025-outage/)’s global edge network was down across the world. This post is not about why that happened or how to prevent it. It’s about the fact that this was inevitable. Infinite uptime [does not exist](https://how.complexsystems.fail/). If your business relies on it, sooner or later, you will get burned.

Cloudflare’s [last global edge outage](https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/) was on July 2, 2019. They were down yesterday for about 3 hours (with a long tail extending about another 2 and a half hours). That’s an uptime of 99.99995% over the last 6 years.

Hyperscalers like Cloudflare, AWS, and Google try very very hard to always be available, to never fail. This makes it easy to intertwine them in your architecture, so deeply you don’t even know where. This is great for their business. I used to work at Cloudflare, and being intertwined like this is one of their explicit goals.
## system boundaries
My company does consulting, and one of our SaaS tools is a time tracker. It was down yesterday because it relied on Cloudflare. I didn’t even know until it failed! Businesses certainly don’t publish their providers on their homepage. The downtime exposes dependencies that were previously hidden. 

This is especially bad for “cascading” dependencies, where a partner of a partner of a partner has a dependency on a hyperscaler you didn’t know about. Failures like this really happen in real life; [Matt Levine writes](https://www.bloomberg.com/opinion/articles/2024-11-25/synapse-still-can-t-find-its-money) about one such case where a spectacular failure in a fintech caused thousands of families to lose their life savings.

What I want to do here is make a case that cascading dependencies are bad for you, the business depending on them. Not just because you go down whenever everyone else goes down, but because depending on infinite uptime [hides error handling issues in your own architecture](https://danluu.com/postmortem-lessons). By making failures frequent enough to be normal, organizations are forced to design and practice their backup plans.
## backup plans
Backup plans don’t require running your own local cloud. My blog is proxied through cloudflare; my backup plan could be “failover DNS from cloudflare to github when cloudflare is down”. 

Backup plans don’t have to be complicated. A hospital ER could have a backup plan of “keep patient records for everyone currently in the hospital downloaded to an offline backup  sitting in a closet somewhere”, or even just “keep a printed copy next to the hospital bed”.

The important thing here is to have *a* backup plan, to not just blithely assume that “the internet” is a magic and reliable thing.
## testing your backups

One way to avoid uptime reliance is brownouts, where services are down or only partially available for a predetermined amount of time. Google intentionally brownouts their internal infrastructure so that nothing relies on another service being up 100% at the time[^1]. This forces errors to be constantly tested, and exposes dependency cycles.

Another way is Chaos Monkey, pioneered at Netflix, where random things just break and you don’t know which ahead of time. This requires a lot of confidence in your infrastructure, but reveals kinds of failures you didn’t even think were possible.

I would like to see a model like this for the Internet, where all service providers are required to have at least 24 hours of outages in a year. This is a bit less than 3 nines of uptime (about 5 minutes a day): enough that the service is usually up, but not so much that you can depend on it to always be up.
## it could happen here
In my experience, and [according to studies about failure reporting](https://ferd.ca/notes/paper-the-failure-gap.html), both people and organizations tend to chronically underestimate tail risks. Maybe you’re just a personal site and you don’t need 100% reliability. That’s ok. But if other people depend on you, and others depend on them, and again, eventually we end up with hospitals and fire stations and water treatment plants depending on the internet. The only way I see to prevent this is to make the internet *unreliable* enough that they need a backup plan.

People fail. Organizations fail. You can’t control them. What you can control is whether you make them a single point of failure.

You have backups for your critical data. Do you have backups for your critical infrastructure?

---

[^1]: Of course, they don't brown-out their external-facing infra. That would lose them customers.
