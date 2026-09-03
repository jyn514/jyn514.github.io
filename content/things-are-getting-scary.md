---
title: "things are getting scary"
date: 2026-09-01
description: "consumer-grade hardware can run an LLM that hacks the planet. no one is ready."
taxonomies:
 tags: [llms]
extra:
  draft: true
  toc: 2
---

GLM 5.3-flash [released last week](https://z.ai/blog/glm-5.3-flash), and that means [Project Glasswing] is out of time.

This probably sounds like nonsense words to most people, so here's what that means:
- "GLM" is a kind of LLM (AI) built on a different architecture than GPT (as in ChatGPT). The GLM family is *open-weight*, which means anyone can download and run the models.
- "flash" means that it is *cheap* and *fast* to run, compared to most "frontier" models. "cheap" is relative, but think around 5-15k USD in hardware to run it locally.
- "frontier" here means that the LLM is "close to the frontier of what AI is currently able to achieve".
- Project Glasswing is an initiative by Anthropic and several other large US companies to use LLMs to fix security issues across the tech industry.

This is a *very very bad* combo.

## GLM

The GLM ("General Language Model") family of models is developed by Z.ai Co. (formerly Zhipu AI), which is a Chinese AI lab.
Because the model is Chinese, it comes with restrictions required by Chinese law:

![GLM-5.3-flash returns a "Content Security Warning" if you ask it the capital of Taiwan](/assets/taiwan.png)

Z.ai releases its models [publicly on the internet](https://huggingface.co/zai-org/GLM-5.3-Flash/).
Once it does so, organizations such as [dealignai](https://dealign.ai/)
release ["abliterated" models](https://huggingface.co/dealignai/GLM-5.3-Flash-ABLITERATED-NVFP4) with their task refusals surgically removed.
DealignAI says the abliterated model scores 0% on [Harmbench-320][Harmbench],
which tests whether models refuse to complete tasks about disinformation, cybercrime, biological weapons, and other illegal acts such as building a pipe bomb.
In other words, this model is willing to do basically anything.

[Harmbench]: https://www.harmbench.org/

## Flash

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

This is where things get really bad.

GLM 5.3 [scores][cybersec benches] 84.5% on CyberGym and 54.4% on ExploitBench.
We don't have data for 5.3-flash directly, but it will probably be around the same or a bit lower.
Abliterated models will be slightly lower again.

CyberGym measures *real world vulnerabilities* that have been found and patched by open source projects in the past.
In other words, 84.5% of vulnerabilities in this representative sample would have been found by GLM 5.3 just by looking at publicly available source code.

ExploitBench measures whether the model can actually use those vulnerabilities to cause harm.
In other words, 54.4% of vulnerabilities that GLM 5.3 finds can be used to gain code execution ignoring a security boundary.

For comparison, the leading ("frontier") model on ExploitBench is GPT-6 Astra (100%), with GPT-5.6 Sol as the runner-up with 78.5% [^1].
The leading model on CyberGym is ... GLM-5.3.
The runner-up is GPT-5.6 Sol with 83.6% [^2].

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
- GLM 5.3 is so good at those tasks that human involvement in those tasks can be negligible.

Now, the frontier US labs have been aware of this coming for a while and have been working on getting security patches out.
[Project Glasswing] and [Daybreak] have been working with companies across the tech industry to find and fix vulnerabilities using frontier models before this capability was open-sourced.
They've done a lot of good, and I'm very glad that this was funded.
Both have been sold as products after the initial funding, which feels a little bit sketchy at best, but they're at least giving out free credits to security organizations.

[Project Glasswing]: https://www.anthropic.com/glasswing
[Daybreak]: https://openai.com/daybreak/

However, we are out of time.
And despite the good that Glasswing has done, the hard part is *deployment*, not fixing the bugs themselves.
It doesn't help to have a patched Linux kernel if your power grid is running Windows Server 2012.
The critical systems running our society—energy, transport, hospitals, wastewater plants—are
often some of the most outdated and vulnerable, because [they can never be shut down for maintenance][brownouts].

This is very, very worrying.
There are some caveats: the 1.5 speedup might not be so high on GLM 5.3-flash; abliterated models might be worse on malicious tasks they weren't trained on; it might be hard to go from "break this" to an exploit without extensive human involvement.
But those things are temporary and models keep getting better.
Historically, GLM has lagged around 3-6 months behind OpenAI and Anthropic, and I think it's likely we'll see an Astra-level GLM model by this time next year.
And when that happens, we're going to start seeing widespread successful cybersecurity attacks on public or private infrastructure.

I don't know what to do here.
I do know that things are getting weird, and scary, very quickly.

[brownouts]: https://jyn.dev/brownouts-reveal-system-boundaries/

[cybersec benches]: https://docs.z.ai/guides/llm/glm-5.3#emergent-cyber-capability

[^1]: depending who you ask, Z.ai and OpenAI disagree on exact numbers.

[^2]: OpenAI hasn't released numbers for Astra on CyberGym yet. Once they do it'll likely beat GLM 5.3.
