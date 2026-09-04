---
title: "we have a year to fix security everywhere"
date: 2026-09-04
description: "consumer-grade hardware can run an LLM that hacks the planet. we can stop it, but we don't have much time."
taxonomies:
 tags: [llms, security]
extra:
  toc: 2
---

GLM 5.3-flash [released last week](https://z.ai/blog/glm-5.3-flash), and that means [Project Glasswing] and [Daybreak] are running out of time.
Cheap models capable of dangerous hacking are now available to anyone, without the normal safeguards for refusing malicious actions.
We need to fix vulnerabilities across the industry so that we aren't caught unawares.
And for one of the first times in computing history, we have the ability to!
We can use frontier LLMs that move faster than a human to find and fix these issues in the time we have left.

This probably sounds like nonsense words or hysterical overreacting to most people, so here's what that means:
- "GLM" is a kind of LLM (AI). The GLM family is *open-weight*, which means anyone can download and run the models.
- "flash" means that it is *cheap* and *fast* to run, compared to most "frontier" models. "cheap" is relative, but think around 5-15k USD in hardware to run it locally.
- "frontier" here means that the LLM is "close to the frontier of what AI is currently able to achieve".
- Project Glasswing and Daybreak are initiatives to use LLMs to fix security issues across the tech industry.
- "malicious actions" includes things like hacking infrastructure and telling people how to build pipe bombs.

The rest of this post is about what makes me so sure this is an imminent threat, and what we can do in response.

## GLM

GLM 5.3-flash can be downloaded and modified by anyone in the world.

The GLM ("General Language Model") family is developed by Z.ai Co. (formerly Zhipu AI), which is a Chinese AI lab.
When the model is hosted by Z.ai, it comes with restrictions required by law:

![GLM 5.3-flash refuses to tell me how to build a pipe bomb](/assets/pipebomb.png)

Z.ai releases its models [publicly on the internet](https://huggingface.co/zai-org/GLM-5.3-Flash/) ("open-weight" models).
Once it does so, organizations such as [DeAlignAI](https://dealign.ai/)
release ["abliterated" models](https://huggingface.co/dealignai/GLM-5.3-Flash-ABLITERATED-NVFP4) with their task refusals surgically removed.
DealignAI says the abliterated model scores 0% on [Harmbench-320][Harmbench],
which tests whether models refuse to complete tasks about disinformation, cybercrime, biological weapons, and other illegal acts such as building a pipe bomb.

In other words, this model is willing to do basically anything.

[Harmbench]: https://www.harmbench.org/

## Flash

GLM 5.3-flash is possible to run locally on stock consumer hardware.

"Flash" is mostly an advertising term—it's relative to other models, not a specific technical approach.
Various people online have run benchmarks of GLM 5.3-flash locally.
Here's [one example][hiroshi-benchmark] showing around 20 tokens/second on a ~6k USD NVIDIA GPU.

[hiroshi-benchmark]: https://dev.classmethod.jp/en/articles/dgx-spark-glm-5-3-flash-first-touch/

On September 22, Apple is releasing the M5 Mac Studio with 256 GB of unified memory.
"Unified memory" means it can be shared between the host operating system and the GPU.
That's more than enough to run 5.3-flash, and it will probably get around 30 tokens/second once it releases.
For 256 GB, the price starts at around $9,500.

Further improvements in user-space software can get half-again the throughput
through [changes to the model decoder](https://arxiv.org/abs/2607.00501).
If we extrapolate that to the M5, that would put the total throughput at around 45 tokens/second.

45 tokens/second is enough to write this snippet of code in 3 seconds:

<details><summary>⚠️  LLM generated code</summary>

```python
from pathlib import Path
import hashlib

def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as file:
        while chunk := file.read(1024 * 1024):
            hasher.update(chunk)
    return hasher.hexdigest()

def main() -> None:
    import sys

    if len(sys.argv) < 2:
        raise SystemExit("usage: hash.py FILE...")

    for name in sys.argv[1:]:
        path = Path(name)
        try:
            print(f"{digest(path)}  {path}")
        except OSError as error:
            print(f"{path}: {error}", file=sys.stderr)

if __name__ == "__main__":
    main()
```

</details>

In other words, it's not just possible to run this model locally, it's possible to do so from an ordinary individual's savings, and use it round-the-clock at high speeds.

## Frontier

GLM 5.3-flash is very close to the abilities of the best AIs we have made.
The AIs we've made are already finding and exploiting real security vulnerabilities in the wild.
The AIs we make in the future are going to get more and more capable.

GLM 5.3 [scores][cybersec benches] 84.5% on CyberGym and 54.4% on ExploitBench.
We don't have data for 5.3-flash directly, but it will probably be around the same or a bit lower.
Abliterated models will be slightly lower again.

[cybersec benches]: https://docs.z.ai/guides/llm/glm-5.3#emergent-cyber-capability

CyberGym measures *real world vulnerabilities* that have been found and patched by open source projects in the past.
In other words, 84.5% of vulnerabilities in this representative sample would have been reproduced by GLM 5.3 just by looking at publicly available source code and a CVE description.

ExploitBench measures whether the model can actually use vulnerabilities to cause harm.
It scores on a sliding scale that gives partial points for partial exploits, with the final step being arbitrary code execution.

For comparison, the leading ("frontier") model on ExploitBench is GPT-6 Astra (100%), with GPT-5.6 Sol as the runner-up with 78.5% [^1].
The leading model on CyberGym is ... GLM-5.3.
The runner-up is GPT-5.6 Sol with 83.6%.
OpenAI hasn't released numbers for Astra on CyberGym yet, but once they do it'll likely beat GLM 5.3.

![cybersecurity evals visualizing the above stats](/assets/cybersec-eval.png)

You might think these are just synthetic benchmarks,
but security experts are reporting that they [can no longer be competitive in security challenges][ctfs-ai] without the assistance of an LLM.

[ctfs-ai]: https://blog.includesecurity.com/2026/04/ctfs-in-the-ai-era/

We don't have many standard benchmarks for remote-code and reverse-engineering exploits,
but we do have evidence of GPT 5.6-Sol [exploiting infrastructure in the real world][Huggingface], without human involvement.

[Huggingface]: https://openai.com/index/hugging-face-incident-and-the-road-ahead/

I think it is quite likely that people will be able to point GLM 5.3-flash at the open internet—real services, running real infrastructure—and it will be able and willing to find and exploit vulnerabilities.

## This Is Bad

Together, this means:
- Just about anyone can run GLM 5.3-flash if they have a bit of savings, continuously, day and night.
- Just about anyone can use GLM 5.3-flash for just about any task, including to malicious ends.
- GLM 5.3-flash is so good at those tasks that human involvement in those tasks can be negligible.

As a result, [we are now in a world where cybersecurity attacks can be run in a `for` loop][manish-post].

[manish-post]: https://manishearth.github.io/blog/2026/06/17/the-future-of-the-con-is-already-here/

Now, the frontier US labs have been aware of this coming for a while and have been working on getting security patches out.
[Project Glasswing] and [Daybreak] have been working with companies, foundations, governments, and NGOs across the tech industry to find and fix vulnerabilities using frontier models before this capability was open-sourced.
They've done a lot of good, and I'm very glad that this was funded.
Both have been sold as products after the initial funding, which feels a little bit sketchy at best, but they're at least giving out free credits to security organizations.

[Project Glasswing]: https://www.anthropic.com/glasswing
[Daybreak]: https://openai.com/index/daybreak-for-frontline-defenders/

However, we are running out of time.
And despite the good that Daybreak and Glasswing have done, the hard part is *deployment*, not fixing the bugs themselves.
Critical systems often require physical access or carefully planned staged rollouts to avoid downtime, both of which delay deploying patches.
It doesn't help to have a patched Linux kernel if your power grid is running Windows Server 2012.

There are some caveats: the 1.5 speedup might not be so high on GLM 5.3-flash; abliterated models might be worse on malicious tasks they weren't trained on; it might be hard to go from "break this" to an exploit without extensive human involvement.
But those things are temporary and models keep getting better.
Historically, GLM has lagged around 3-6 months behind OpenAI and Anthropic, and I think it's likely we'll see an Astra-level GLM model by this time next year.
And when that happens, there's going to be a high risk of successful cybersecurity attacks on public or private infrastructure.
We may be getting a lesson on [brownouts] sooner than we'd like.

In general, attackers are getting more capable faster than defenders are improving their posture.
Even if models stop scaling so fast (which they currently show no sign of doing),
it's only a matter of time before they get capable enough to start exploiting these vulns.
We need to act now, the sooner the better.

[brownouts]: https://jyn.dev/brownouts-reveal-system-boundaries/

## What do we do?

Things are getting weird, and scary, very quickly.
We need to act with urgency, not panic.
Some things we can do:

### Governments and regulation agencies

Scanning with frontier models is relatively cheap and does not need major incentives.
What does need incentives is *deployment*, and requiring organizations to look at their security practices in the first place.

If you're in a position to make policy, the following would be very effective:
Fund security engineering, either through token subsidies or raw money that can be used for hiring.
Create mandates and incentives for improving security.
Greatly reward people and organizations who do this research.
Penalize *not* deploying and revising security posture regularly, with increased penalties if a hack happens as a result.
Both carrot and stick.

Some specific things that are worth looking into:

- Be especially sure to fund local governments and hospitals, which are unlikely to get this funding through other channels.
- For banks, extend [DORA] in the EU
  and [FFIEC cyber resilience banking regulations][FFIEC] in the US to require frontier LLM scanning as part of routine penetration testing.
- For power companies, extend [NERC Critical Infrastructure Protection][NERC-CIP] in the US to apply to local utilities and municipalities, not just large systems.
  Extend NERC-CIP and the EU's [Electronic Communications Code][ECC] to require *and fund* frontier LLM scanning; power companies don't have the sorts of margins that banks do.
- Telecoms in the US are currently high risk and have no mandatory cybersecurity risk standards.
  Create one and enforce it, using existing regulations for banks and power companies as a starting point.

[DORA]: https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora
[FFIEC]: https://ithandbook.ffiec.gov/it-booklets/business-continuity-management/iv-business-continuity-strategies/iva-resilience/iva2-cyber-resilience/
[NERC-CIP]: https://www.nerc.com/standards/reliability-standards/cip?utm_source=chatgpt.com
[ECC]: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R1366-20250914

Banning GLM 5.3-flash weights from being hosted anywhere in the US or Europe will be hardly any use in the short term,
and no use at all in the long term.
In the short-term, it will just pop up again on file-sharing sites; you'll have no more luck killing it than killing piracy.
In the long-term, some other lab will release another model that's just as capable.

Banning access to Mythos or Astra will actively make things worse; it will remove defenders' most powerful tool at exactly the moment they need it most.

Banning the sale/export of new GPUs or large unified memory will extend the year-long window for a bit but won't help long-term.
It can't do anything about existing hardware, and it will be massively unpopular.
Memory in particular is hard to regulate because *everything* uses it, not just specialized AI systems.

### Companies and open source foundations

Take advantage of the (literal) billions of dollars that are flooding the industry to improve safety across the board.
Hire as many security engineers as you can.
Use Astra, Mythos, and other frontier models for good, to find the risks before attackers do.
Pay attention to developments in frontier and open weight models.

Even if you don't think the threat described here is real,
you're getting a once-in-a-lifetime opportunity to improve security for your projects and communities.
Please take it.

## Summary

We are living in interesting times.
We can't hide our heads in the sand.
We should act now, while there's still time.

<small>Thank you to Manish Goregaokar and several others for their feedback on this post. Thank you to everyone who is working tirelessly to make Glasswing and Daybreak a reality. And a big fuck you to DeAlignAI, Z.ai, and everyone else who's been participating in this race to the bottom.</small>

[^1]: depending who you ask, Z.ai and OpenAI disagree on exact numbers.
