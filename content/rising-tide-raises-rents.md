---
title: "A rising tide raises all rents"
date: 2026-10-25
description: "If AI restructures the economy, who benefits?"
taxonomies:
 tags: [ai, economics, futurism]
extra:
  toc: 3
  audience: "everyone"
  fedi: https://tech.lgbt/@jyn/117503139873608046
  bsky: https://bsky.app/profile/jyn.dev/post/3mypw36kgzk2n
---

{% quote(url="https://x.com/VincentGeloso/status/1806109883647008946/", author="Michael from The Good Place (paraphrased)") %}

You're a rent seeker.
It's an economist insult. It's devastating. You're devastated right now.

{% end %}

Imagine, for a second, that AI really does become [too cheap to meter](../tokens-too-cheap-to-meter/).
What happens next?

I've heard hype that says there'll be a productivity boom to rival the internet, electricity, and spinning loom.
That *ideas* and *skill* and *taste* will become the new currency,
that 5 people can do the work of 500.
Maybe. I think this is directionally correct but a bit exaggerated.

But here's a more interesting question:
Who benefits from that productivity?

If software is no longer scarce, what still is?
Where are the bottlenecks?
How does that shape the world, and what emergent behaviors result?

I posit that it partly goes to the people building,
partly goes to incumbents,
mostly goes to landlords and other rent-seekers,
and hardly any of it goes to everyone else.

To avoid that situation, we need an equivalent of Land-Value-Tax that works for scarce resources other than land.
I propose some potential approaches towards the end of this post.

## Possible worlds

Consider five different scenarios.

![Flow chart depicting the alternatives below. Notably, "reinstatement failure" is a transition state, not a final scenario.](/assets/possible-worlds.svg)

### Status quo

In our baseline, AI doesn't do anything useful, or it works but it doesn't do *that* much.
Maybe it has about as much impact on the world as the invention of the mobile phone; culture changes around it, but the world is fundamentally the same place.
Let's call this a "status quo world".
I personally think the status quo is quite unlikely, but maybe you feel differently.
If so, and you hate AI, you can stop reading right here, the rest of the post will just make you mad.

### Messy transition

For this and all future worlds, let's assume AI really does work and really does result in greatly increased productivity that revolutionizes the economy.
Not only that, but also that we get at least a limited form of "recursive self-improvement" where improvements in AI get faster as AI itself gets better. [^6]
What next?

Will AI take our jobs?
We're [already seeing this][canaries] to some extent in markets that are "AI-exposed", such as programmers, translators, and people just entering the job market.
But that doesn't necessarily mean they can't get other jobs.
The National Bureau of Economic Research published [a paper][Acemoglu] about exactly this possibility in 2019:

[canaries]: https://digitaleconomy.stanford.edu/publication/canaries-in-the-coal-mine-six-facts-about-the-recent-employment-effects-of-artificial-intelligence/
[Acemoglu]: https://www.nber.org/papers/w25684

> […] the *displacement effect* of automation has been counterbalanced by technologies that create new tasks in which labor has a comparative advantage. Such new tasks generate not only a positive productivity effect, but also a *reinstatement effect*—they reinstate labor into a broader range of tasks and thus change the task content of production in favor of labor. The reinstatement effect is the polar opposite of the displacement effect and directly increases the labor share as well as labor demand.
>
> History is also replete with examples of the creation of new tasks and the reinstatement effect […]

In this world, there are a lot fewer programmers, but a lot more UI designers, sales engineers, and HCI researchers.
There is significant short- and mid-term displacement, but in 10 years things shake out mostly ok.
Labor has less influence over capital than today; wealth inequality gets worse; careers and jobs become more unstable.
Overall though, people can still make rent [^12].
Let's call this a "messy transition world".

### Reinstatement failure

What happens if the reinstatement effect fails?
What if jobs change faster than people can retrain, and long-term employment becomes more and more unstable?
What if nearly *all* jobs become automated?

Well, first we're going to see [labor lose out power against capital][growth-and-inequality].
As this spreads to other industries and demographics, we'll start seeing more and more unemployment.
People and organizations who were lucky enough to catch the automation wave start accumulating more and more wealth;
an ever-narrowing fraction goes to people who work for a living.
Eventually, a small plutocracy controls the majority of the world's wealth.

[growth-and-inequality]: https://www.imf.org/external/pubs/ft/fandd/2016/09/berg.htm

This is possible on an economic level, but also on a geopolitical level.
Not every country has its own GPU foundries; not every country is part of the global supply chain for those foundries.
We could see a post-modern version of colonialism, mediated through markets rather than force.

This plutocratic world is not stable.
It's the nature of plutocrats to try and accumulate more and more power, and to automate more and more of the labor that generates their income.
Unlike today, they will actually have the power to do so, and unemployment spreads like wildfire.
An increasing portion of the population is simply unable to find a job.
Eventually there's just no one left to buy the goods and services that are being produced, and the bottom falls out of our society.
Either there's not enough demand from governments and foreign countries that the [Magnificent Seven] can sustain themselves, and the economy collapses;
or there *is*, and we get an
["enclave"][why-we-build-the-wall] [of][Utopia-tawfik] [massively][Diamond Age] [rich][Beggars in Spain] [capitalists][Player Piano] [surrounded][Oryx and Crake] [by][snow-crash] [the][the-penultimate-truth] [unemployed][Altered Carbon].

Historically, humanity has always been coupled to its labor value.
Incomes, purchases, well-being, and freedom, has been tied to the usefulness of labor.
What happens if that *stops* being the case?

[Magnificent Seven]: https://en.wikipedia.org/wiki/Big_Tech#Magnificent_Seven
[why-we-build-the-wall]: https://www.youtube.com/watch?v=Q1VDxMe54Og
[Oryx and Crake]: https://en.wikipedia.org/wiki/Oryx_and_Crake
[Diamond Age]: https://en.wikipedia.org/wiki/The_Diamond_Age?utm_source=chatgpt.com
[Beggars in Spain]: https://en.wikipedia.org/wiki/Beggars_in_Spain
[Player Piano]: https://en.wikipedia.org/wiki/Player_Piano_(novel)
[Altered Carbon]: https://en.wikipedia.org/wiki/Altered_Carbon_(TV_series)
[Utopia-tawfik]: https://en.wikipedia.org/wiki/Utopia_(Tawfik_novel)
[snow-crash]: https://en.wikipedia.org/wiki/Snow_Crash
[the-penultimate-truth]: https://en.wikipedia.org/wiki/The_Penultimate_Truth

If this gets bad enough, I see one of three possible political reactions, in the sense of an action taken by a country's government.

### Stable equilibria

#### Butlerian Jihad

If a government takes no action at all in response to increasing unemployment, people get more and more desperate until there is violent revolution.
One possibility is that the revolution is crushed, and the country becomes a North Korea-like autocracy (hopefully we can all agree this is bad).
Another possibility is that the revolution succeeds.

Now, I have friends who think that [Revolution Is The Answer][Marx], and will usher in the [Fully-Automated Post-Scarcity Luxury Gay Space Communism][Culture] of the future.
I, unfortunately, am not so hopeful.
Looking at history, and at small-scale upheavals in my own communities, I just don't think this is going to happen.
You have to remember: someone who's been unemployed for years due to AI is *angry*.
They're not going to care whether you were using AI to build solar panels, to automate driving a truck, or to build military drones;
they're just going to see someone who has contributed to their helplessness.

[Marx]: https://blogs.kent.ac.uk/ageofrevolution/revolutionary-figures/karl-marx/
[Culture]: https://theculture.fandom.com/wiki/The_Culture

Instead, I think revolution would look more like Frank Herbert's [Butlerian Jihad], or Walter Miller's [A Canticle for Leibowitz]:
*Indiscriminate* destruction; mass pogroms; loss of human knowledge; book burnings.
It's much easier to destroy things than to rebuild them.

Revolution is not inherently liberatory!
If it doesn't completely destroy the institutions that maintain our society, the most likely outcome is "the same as always, with someone else in charge".
Even [Robespierre was in favor of property rights][declaration-of-rights-of-citizen].
At a bare minimum you need [a plan for self-correcting systems that react to changing events][cybersyn].

[Butlerian Jihad]: https://dune.fandom.com/wiki/Butlerian_Jihad
[A Canticle for Leibowitz]: https://en.wikipedia.org/wiki/A_Canticle_for_Leibowitz
[declaration-of-rights-of-citizen]: https://fr.wikisource.org/wiki/%C5%92uvres_de_Robespierre/Sur_la_propri%C3%A9t%C3%A9._Projet_de_d%C3%A9claration_des_droits_de_l%E2%80%99homme_et_du_citoyen
[cybersyn]: https://en.wikipedia.org/wiki/Project_Cybersyn

#### Bread and circuses

A government could react earlier.
The most likely reaction I foresee is to extend existing welfare and unemployment programs, in effect resulting in Universal Basic Income (UBI).

This is good! I am in favor of UBI!
However, UBI does not guarantee a good life for the people receiving it.
Eliezer Yudkowsky, as much as I hate to give it to him, has a good article about this called [Universal Basic Income and Poverty][big-yud]:

[big-yud]: https://www.lesswrong.com/posts/fPvssZk3AoDzXwfwJ/universal-basic-income-and-poverty

> it only takes a life lacking in one resource needed to survive, to produce some quality that I think ancient poor people would also recognize as 'poverty'.
>
> It's the quality of working yourself until you can't work any longer; of taking on jobs that are painful to do, and require groveling submission to bosses, because that's what it takes to get the few scraps to hang on.
> 
> […]
> somehow there is a Poverty Equilibrium which beat a 100-fold increase in productivity plus everything else that went right over the last thousand years.
> […]
> 
> I do not understand the Poverty Equilibrium.  So I expect that a Universal Basic Income would fail to eliminate poverty, for reasons I don't fully understand.

I think what Yud is missing here is very simple: rent-seeking and incumbent effects.
A world where everyone has, say, a guaranteed minimum of 50k annual income, is a world where rental housing costs about 25k a year and the rest goes to food, utilities, transport and healthcare.
Above a certain point, making food/utilities/transport/healthcare cheaper doesn't help in the long term, because it just results in housing swallowing an ever-increasing proportion of income.

Don't just take my word for it.
[Henry George][progress-and-poverty], [Enrico Moretti][local-labor-markets], and [Richard Hornbeck][benefits-from-productivity] all predict near-total capture of productivity increases by landlords and economic rent-collectors when housing supply is sufficiently limited.
Their findings are pretty bleak!

[progress-and-poverty]: https://www.econlib.org/library/YPDBooks/George/grgPP.html?chapter_num=23
[local-labor-markets]: https://eml.berkeley.edu/~moretti/handbook.pdf
[benefits-from-productivity]: https://eml.berkeley.edu/~moretti/tfp.pdf

This world is explored further in "[Manna]", a fictional dystopia where all service jobs are automated down to the minute by an AI "manager" that whispers tasks into everyone's ear.
The end result is a permanent underclass, half of whom work precarious jobs with extreme hours, and the other half of whom are permanently unemployed and live in government-sponsored housing.

[Manna]: https://web.archive.org/web/20260725174355/https://marshallbrain.com/manna1

Let's call this a "rentier world", for the plutocracy that makes their money through rent and capital, not through innovation.
Here, people can rent enough to survive, but scarcity is everywhere, and almost no one owns anything that would give them power.

#### Distributed ownership

["Manna"][australia-project] explores another world, one where automation improvements are captured by the whole population, not just plutocrats.
Scarcity is, essentially, a thing of the past.
There is no real-estate mogul extracting rent, because there is no land ownership.
There is no one working themselves to death, because everyone has plenty.
Instead, the land and production are split equally between everyone in the society.

[australia-project]: https://web.archive.org/web/20260515191335/https://marshallbrain.com/manna5

Now, I think Manna has a lot of funny ideas (constant surveillance sounds a lot like a dystopia to me), but its *ownership model* is quite interesting.
The catch, of course, is that we have to get there somehow.

Let's call this a "post-scarcity world", for the abundance that's present throughout the society.
This is the world I want to see.
This is the world I want to build together.

## Distribut*ing* ownership

How do we build a post-scarcity world?
How do we distribute the enormous amount of material wealth in our society to everyone within it?

Corporations are neither good nor bad but amoral.
Changing their actions is in a way very similar to AI alignment:
you have to change their *incentives*, not just the actions they have available.

### Tax rents, not capital

In economics, there is a concept called *[deadweight loss]*.
Most taxes are "inefficient" in a broad sense.
For example, when you tax food, you cause people to buy less food or cheaper food, with negative health outcomes.
This inefficiency is called "deadweight loss".
A tax is "efficient" if it does not introduce deadweight loss.

[deadweight loss]: https://en.wikipedia.org/wiki/Deadweight_loss

Lars Doucet, writing on Scott Alexander's blog, talks about [Georgism and Land Value Tax][acx-georgism]:
> George argues that poverty paradoxically advances alongside progress because, as material conditions improve, landowners can charge more rent for locational benefits they didn’t create.
> […]
>
> Henry George’s remedy is the *land value tax*, or LVT. In its ideal form, this tax would capture and redistribute the annual *rental* value of land; that is, the recurring value of the land *excluding* the value of any buildings or other improvements on top of it. In practice, this looks a lot like a conventional property tax paired with a “universal building exemption.” Notably, George isn’t simply in favor of a land value tax; he’s also *opposed* to taxes on both labor and capital.
>
> \[…[earlier](https://www.astralcodexten.com/p/your-book-review-progress-and-poverty)…\]
> Keep in mind also that the Georgist Land Value Tax is pair \[sic\] with a "Citizen's Dividend" or what we see as UBI, so that it's not the government claiming land rent, rather the land rent is taxed and split up equally for all men.

[acx-georgism]: https://www.astralcodexten.com/p/does-georgism-work-five-years-later

[Land-value tax is efficient][economics-of-lvt]!
I said above that UBI doesn't help much because demand-side interventions just raise housing costs.
Conversely, LVT *does* help because the supply of land is fixed:
landlords are *already* charging as much as their tenants can afford, so when taxes go up, landlords have no choice but to pay the tax out of pocket.

[economics-of-lvt]: https://bluerepublik.wordpress.com/2019/07/31/welfare-economics-of-the-land-value-tax/

Not only that, but I think this is conceptually the right model:
There's a difference between a landlord who owns the property and does nothing to work on it and a property-management company who's responsible for fixing issues.
The property-management company is doing useful work; the landlord is not.
We should pay people for the work they've done (improvements built on land, and maintenance of those improvements),
while not allowing them to capture value from the underlying shared resource (the land itself).

#### Measuring value

So how do we figure out the value of land?

LVT is generally measured using *[appraisals][land-valuation]* which distinguish "improvement value" from "land value".
You get the latter by looking at prices for properties with little improvement (parking lots, empty fields, etc.) and then comparing that to the price of buildings in nearby areas [^5].

[land-valuation]: https://boe.ca.gov/info/iav/lesson15.htm

We said earlier that LVT works because the supply of land is fixed.
There are other areas where supply is fixed: radio broadcast spectrums, IPv4 addresses, mineral and resource rights, utility contracts.

Land and IP addresses are in some ways the hard cases because they're private property.
For public property, like radio spectrums and resource rights, there's a much simpler solution, which is to force an auction for ownership of the right every so often.
If the incumbent wins, the auction acts as a tax; otherwise, the incoming owner pays the tax.
Either way, the owner pays fair market value.
The US government already [auctions off spectrum rights][fcc-auctions].

[fcc-auctions]: https://www.fcc.gov/about-auctions

Note that this is auctioning the *right to the scarce resource*, not the capital used to develop that resource.
For example, a radio broadcast company retains their broadcast towers if they lose an auction; they only lose the spectrum itself.

### Tax cash flow, not income

<small>Note 26 October: This section has been substantially rewritten for clarity based on user feedback.</small>

#### What is economic rent?

Another term in economics is *[economic rent]*.
This refers to income that is not necessary to incentivize valuable work or investment.
In other words, the "rentier" is collecting more income than justified (in the sense of "economically worthwhile") by their risk + investment + labor.
This often happens when the rentier controls a scarce good that no one else is able to create or buy.

[economic rent]: https://en.wikipedia.org/wiki/Economic_rent

Not all rentiers are landlords [^9].
I know someone who ran a ["Managed Service Provider"][MSP].
This is a kind of IT company where a business pays a fixed fee every quarter, in exchange for having all their computer problems repaired at no additional charge.
This particular company was a registered ["Authorized Service Provider"][ASP] for a [large computer manufacturer][OEM], which means that the MSP was authorized to conduct repairs on behalf of the manufacturer without voiding the hardware warranty.
This is quite relatively rare; most companies do not have this relationship.

[MSP]: https://en.wikipedia.org/wiki/Managed_services
[ASP]: https://en.wikipedia.org/wiki/Authorized_service_provider
[OEM]: https://en.wikipedia.org/wiki/Original_equipment_manufacturer

The owner sold most of the company many years ago, but kept one thing, which was the repair authorization.
They no longer do any work for the MSP at all, but employ a project manager, who takes contracts, delegates them to subcontractors, and coordinates between them and the manufacturer.
The owner takes some profit off the resulting fixes after paying the contractors and project manager.
This is also a form of economic rent:
The owner's income comes from controlling access to the authorization, not from labor, risk [^10], or investment.

#### Taxing rent doesn't require us to distinguish rent-seeking

How do we distinguish the rent extracted by this MSP from the valuable production?
With LVT, we can value the land separately from the improvements built on top,
but here the authorization is inextricably tied to the work being done in its name.
We want to share the rents that the MSP receives, without discouraging the real positive impact it has by fixing computers.

One possible solution is to not try to separate these in the first place.
"Rent-seeking" is when you try to build a company with high rents (in Silicon Valley terms, "build a moat").
But you don't have to intentionally build a moat in order to receive economic rent.
If you are, say, Larry Page in 1998, spend about $25 million on Google's first 5 years of business, and make back 500 million, you are still collecting economic rent!
You've built something useful, you're not exploiting people, but that half a billion is *far* beyond what you'd need in order for the time, effort, and risk to be worthwhile.

If we generalize our idea of rent to economic rent and not just moats, we have more options.
*Cash flow tax* is a generalization of LVT to other kinds of resources, keeping the same idea of taxing rents and deducting investments.

How is this different from a corporate profit tax?
Let's look at exactly what's charged in each case.
For cash-flow taxes, the government charges a percentage on `sales receipts - operating payments - investments in capital`. [^13]
For profit taxes, the government charges a percentage on `sales revenue - operating expenses - depreciation - interest`.

So there are three differences here:
- Tax receipts instead of revenue. The difference is that "revenue" is when you *provide* a good or service, but a "receipt" is when they actually pay you for it. Ditto for expenses and payments, from the other side.
- Deduct investments all-at-once up-front, rather than over-time through depreciation.
- Remove the deduction for interest repayment.  [^8]

There's also a fourth difference: the tax can be negative.
Profit taxes are "capped" at a minimum of $0; if you have no profit from which to deduct, you get no benefit from a deduction.
You need a future [^16] profitable year before you see any benefit from the deduction.
By contrast, cash-flow taxes will immediately *pay* businesses who lose money.

We could design the tax to initially be just a revenue-neutral tax-swap [^14].
What's useful about it is that, because it causes no economic distortion [^15], we can raise the tax much higher without disincentivizing useful work.

The UK's Institute for Fiscal Studies has [published a paper][full-expensing] on exactly this:

> The intuition is that the company is taxed immediately on all receipts but can immediately deduct all outgoings at the same rate: with a 25% tax rate, the government covers 25% of the investment cost and takes 25% of the return, essentially becoming a compulsory silent partner in the project. If the revenue is worth more than the cost, 75% of the revenue will be worth more than 75% of the cost, so any project that is worthwhile before tax will be worthwhile after tax. That is a good thing.

"Any project that is worthwhile before tax will be worthwhile after tax" is another way of saying this is an efficient tax that causes no deadweight loss. [^7]
"Compulsory silent partner" means that every citizen of the country is invested in every company, indirectly through the government.
Just like LVT would be the only tax on property, this would be the only tax on corporate profits, replacing existing taxes.
Norway [already does something like this][norway-resource-rent] for oil and hydropower.

We would apply deductions and refunds to wages, not just to capital investment, just like profit taxes today.
The government would pay a portion of every salary and independent contract, at the same rate as the rest of the cash-flow tax.

[norway-resource-rent]: https://www.regjeringen.no/en/documents/prop.-1-ls-20242025/id3057469/?ch=2#kap2-3-3

[full-expensing]: https://ifs.org.uk/publications/full-expensing-and-corporation-tax-base

### Distribute the funds

Using our tax income, we would redistribute it to everyone in our society as dividends.
This would be unconditional, without means-testing.
Our LVT and cash-flow taxes give everyone an economic stake in productivity improvements,
which means the money doesn't immediately evaporate into economic rent and corporate conglomerates [^11].
People still spend their income on housing, but most of the money goes back into the dividend pool through LVT.
Similarly, money spent on goods and services goes back into the pool, tying dividends to *the whole economy* rather than to the minimum necessary to live.

This is not new.
Both [Alaska] and [Norway] discovered enormous reserves of oil and put the profits into reserves that are saved and redistributed for the benefit of all citizens.
It really is politically feasible to make these changes when there's sufficient wealth floating around.

[Alaska]: https://apfc.org/about/history/
[Norway]: https://www.nbim.no/

With these funds, people would become much much less dependent on their employer for a stable source of income.
This is good, because as AI and automation develops, there will be fewer jobs.
By themselves, dividends don't give us post-scarcity, nor independence from work.
What they *do* give us is a way to ensure that benefits to a small segment of the population are shared between everyone.
If, in the future, we have enough productivity and resources to support everyone on dividends alone,
we have the governance processes in place to make sure we end up in a post-scarcity world rather than a rentier world.

This doesn't work automatically.
The taxes have to be high enough that the dividends make up for lost work hours during the transition period.
We'd need some way to avoid companies from simply relocating to somewhere with lower taxes.
But—if we somehow manage that—I really do think we'd have a bright future ahead of us.

## Transition plans

If you call your representative to ask them to increase taxes on landlords; homeowners; conglomerates; and banks; and then redistribute the money to everyone as dividends, they will laugh you out of the room.
These are some of the most powerful and influential groups in politics, in large part *due to* their giant rental incomes.
Just saying "hi could you dismantle the political machine please" will not work.
Instead, we need some sort of incremental transition that appeases existing interests.

### Homeowners

Let's start with homeowners.
The traditional problem here is people on fixed-income who cannot tolerate tax increases.
If you switch from property taxes to LVT, and this results in a net tax increase, they really do experience material hardship.

One possible solution is to [defer the increased tax][irish-revenue] until after the sale of the property, charging interest on the deferral.
Until then, the tax collected stays at previous values, avoiding a sudden "spike" in costs for people on fixed income.
This still results in an overall wealth transfer, just delayed by a few years;
and because it's tied to the sale, you're not punishing people for ownership: selling gives them the free cash they need to pay the tax.
This would be a *one-time* deferment; unlike [California's Prop 13][prop-13], it would go away after the first sale.

[prop-13]: https://en.wikipedia.org/wiki/1978_California_Proposition_13
[irish-revenue]: https://www.revenue.ie/en/property/local-property-tax/deferral-of-payment/index.aspx

Note that we *want* new houses to be built, we *want* them to sell at market price.
What we *don't* want is for people's life savings to be tied up in their home, and for landlords to make a giant profit even when they're not doing any maintenance.
[I do not believe that home ownership is intrinsically good][30-year-mortgage].

[30-year-mortgage]: https://byrnehobart.medium.com/the-30-year-mortgage-is-an-intrinsically-toxic-product-200c901746a

### Businesses

Businesses have a clear motivation here: our cash-flow tax gives them a discount for all investments.
Even raising the tax is not necessarily bad for the business, because it gives them more cash up-front, allowing them to take more risks and start more projects.
The strongest opposition would be from businesses who make few investments but collect a lot of profit, i.e. exactly the people we want to redistribute wealth away from.

If government budgets are a problem, we could "ease in" the tax over time for new projects, keeping current profit tax rates and adding investment deductions until the two rates match.
Only then would we raise the overall cash-flow tax rate.

## Conclusion

The goal of this proposal is not to take away profits from people who are earning 'too much', or to single out landlords as uniquely bad.
The goal is to *give everyone a stake in productivity improvements* in a way that still keeps the natural self-regulation of the free market,
and to make people economically secure without being dependent on their employer.
I *want* to live in Asimov's, Iain M. Bank's, Kim Stanley Robinson's post-scarcity worlds.
And I really do believe that we have a path to get there.
We just need to open our eyes and walk down it.

In other words:
Land is different from capital.
Economic rent is a curse.
Economic security is freedom.

To all a good night.

---

## Bibliography

- [“Canaries in the Coal Mine? Six Facts about the Recent Employment Effects of Artificial Intelligence”, Brynjolfsson et al.](https://digitaleconomy.stanford.edu/publication/canaries-in-the-coal-mine-six-facts-about-the-recent-employment-effects-of-artificial-intelligence/)
- [“Automation and New Tasks: How Technology Displaces and Reinstates Labor”, Acemoglu and Restrepo](https://www.nber.org/papers/w25684)
- [“Robots, Growth, and Inequality”, Berg et al.](https://www.imf.org/external/pubs/ft/fandd/2016/09/berg.htm)
- [“Big Tech — Magnificent Seven­”, Wikipedia](https://en.wikipedia.org/wiki/Big_Tech)
- [“Why We Build the Wall”, Hadestown Original Broadway Company](https://www.youtube.com/watch?v=Q1VDxMe54Og)
- [“Utopia (Tawfik novel)”, Wikipedia](https://en.wikipedia.org/wiki/Utopia_(Tawfik_novel))
- [“The Diamond Age”, Wikipedia](https://en.wikipedia.org/wiki/The_Diamond_Age?utm_source=chatgpt.com)
- [“Beggars in Spain”, Wikipedia](https://en.wikipedia.org/wiki/Beggars_in_Spain)
- [“Player Piano (novel)”, Wikipedia](https://en.wikipedia.org/wiki/Player_Piano_(novel))
- [“Oryx and Crake”, Wikipedia](https://en.wikipedia.org/wiki/Oryx_and_Crake)
- [“Snow Crash”, Wikipedia](https://en.wikipedia.org/wiki/Snow_Crash)
- [“The Penultimate Truth”, Wikipedia](https://en.wikipedia.org/wiki/The_Penultimate_Truth)
- [“Altered Carbon (TV series)”, Wikipedia](https://en.wikipedia.org/wiki/Altered_Carbon_(TV_series))
- [“Karl Marx”, Ben Macready](https://blogs.kent.ac.uk/ageofrevolution/revolutionary-figures/karl-marx/)
- [“The Culture”, Culture Wiki](https://theculture.fandom.com/wiki/The_Culture)
- [“Butlerian Jihad”, Dune Wiki](https://dune.fandom.com/wiki/Butlerian_Jihad)
- [“A Canticle for Leibowitz”, Wikipedia](https://en.wikipedia.org/wiki/A_Canticle_for_Leibowitz)
- [“Sur la propriété. Projet de déclaration des droits de l’homme et du citoyen”, Maximilien de Robespierre](https://fr.wikisource.org/wiki/%C5%92uvres_de_Robespierre/Sur_la_propri%C3%A9t%C3%A9._Projet_de_d%C3%A9claration_des_droits_de_l%E2%80%99homme_et_du_citoyen)
- [“Project Cybersyn”, Wikipedia](https://en.wikipedia.org/wiki/Project_Cybersyn)
- [“Universal Basic Income and Poverty”, Eliezer Yudkowsky](https://www.lesswrong.com/posts/fPvssZk3AoDzXwfwJ/universal-basic-income-and-poverty)
- [“Progress and Poverty”, Henry George](https://www.econlib.org/library/YPDBooks/George/grgPP.html?chapter_num=23)
- [“Local Labor Markets”, Enrico Moretti](https://eml.berkeley.edu/~moretti/handbook.pdf)
- [“Estimating who benefits from productivity growth”, Hornbeck and Moretti](https://eml.berkeley.edu/~moretti/tfp.pdf)
- [“Manna – Two Views of Humanity’s Future – Chapter 1”, Marshall Brain](https://web.archive.org/web/20260725174355/https://marshallbrain.com/manna1)
- [“Manna – Two Views of Humanity’s Future – Chapter 5”, Marshall Brain](https://web.archive.org/web/20260515191335/https://marshallbrain.com/manna5)
- [“Deadweight loss”, Wikipedia](https://en.wikipedia.org/wiki/Deadweight_loss)
- [“Does Georgism Work? Five Years Later”, Lars Doucet](https://www.astralcodexten.com/p/does-georgism-work-five-years-later)
- [“Your Book Review: Progress And Poverty”, Lars Doucet](https://www.astralcodexten.com/p/your-book-review-progress-and-poverty)
- [“Welfare Economics of the Land Value Tax”, @BlueRepublik](https://bluerepublik.wordpress.com/2019/07/31/welfare-economics-of-the-land-value-tax/)
- [“Land Valuation: Direct Land Capitalization (The Income Approach to Value)”, California State Board of Equalization](https://boe.ca.gov/info/iav/lesson15.htm)
- [“About Auctions”, United States Federal Communications Commission](https://www.fcc.gov/about-auctions)
- [“Economic rent”, Wikipedia](https://en.wikipedia.org/wiki/Economic_rent)
- [“Managed services”, Wikipedia](https://en.wikipedia.org/wiki/Managed_services)
- [“Authorized service provider - Wikipedia”](https://en.wikipedia.org/wiki/Authorized_service_provider)
- [“Original equipment manufacturer - Wikipedia”](https://en.wikipedia.org/wiki/Original_equipment_manufacturer)
- [“Full expensing and the corporation tax base: Green Budget 2023”, Adam and Miller](https://ifs.org.uk/publications/full-expensing-and-corporation-tax-base)
- [“Taxes 2025 For the 2025 Budget Year: Tax on resource rent industries”, Norway Ministry of Finance](https://www.regjeringen.no/en/documents/prop.-1-ls-20242025/id3057469/?ch=2)
- [“Our History”, Alaska Permanent Fund Corporation](https://apfc.org/about/history/)
- [“The fund”, Norges Bank Investment Management](https://www.nbim.no/)
- [“Deferral of Local Property Tax (LPT) payment”, Irish Tax and Customs](https://www.revenue.ie/en/property/local-property-tax/deferral-of-payment/index.aspx)
- [“1978 California Proposition 13”, Wikipedia](https://en.wikipedia.org/wiki/1978_California_Proposition_13)
- [“The 30-year Mortgage is an Intrinsically Toxic Product”, Byrne Hobart](https://byrnehobart.medium.com/the-30-year-mortgage-is-an-intrinsically-toxic-product-200c901746a)
- [“Moore’s Law for Everything”, Sam Altman](https://moores.samaltman.com/)
- [”Corporate Taxation in an International Context”, Adam et al.](https://ifs.org.uk/books/18-corporate-taxation-international-context)


[^5]: it's a lot more complicated than this in practice, but this is a reasonable mental model.

[^6]: I am explicitly *not* considering a "singularity" or "FOOM"-type situation. I don't think it's possible to make any useful predictions about singularity, and furthermore I don't think singularity is very plausible in the first place.

[^7]: Within a country. It can still incentivize companies to change their headquarters to another country.

[^8]: If we didn't remove the interest deduction, this would mean an investment can be "double-deducted": first the investment itself gets a tax deduction, then the interest repayment gets a deduction.
    In some cases this can result in the government losing money while the company gains.

[^9]: And landlords are not purely rentiers; they do *some* amount of work in the form of repairs and upkeep.

[^10]: They do accept some amount of risk, but not any more than their administrator does.

[^11]: Sam Altman, of all people, [wrote about this in 2021][moores].

[moores]: https://moores.samaltman.com/

[^12]: I try very hard to distinguish "housing costs" from "economic rent" in this article, but in this one place I've blurred it because I don't know a better common phrase for it. I mean housing costs specifically.

[^13]: IFS refers to this as an "R-base". It also discussed other bases, such as R+F-base.
      "in capital" means that this only applies to goods and services, not stocks.

[^14]: across the whole country. individual companies will still see a different tax bill.

[^15]: kinda, sorta, mostly. the IFS has a [section][ifs-returns-to-effort] on how investments of effort and skill aren't compensated in this scheme.

[ifs-returns-to-effort]: https://ifs.org.uk/books/18-corporate-taxation-international-context#18.1.3:~:text=Rents%2C%20and%20Location%2DSpecific%20Rents

[^16]: or, occasionally, past
