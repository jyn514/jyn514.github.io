+++
title = "the terminal of the future"
date = 2025-11-11
description = "To redesign infrastructure, you have to allow incremental adoption, while simultaneously moving the whole design space at once."
taxonomies.tags = ["ideas", "terminal"]
taxonomies.computer-of-the-future = ["6"]
extra.toc = 3
extra.category = "tools"
extra.fedi = "https://social.jvns.ca/@b0rk/115534063787288626"
extra.bsky = "https://bsky.app/profile/jyn.dev/post/3m5ewy5lq3k2h"
+++
{% quote(author="Julia Evans", url="https://jvns.ca/blog/2025/06/24/new-zine--the-secret-rules-of-the-terminal/") %}

Terminal internals are a mess. A lot of it is just the way it is because someone made a decision in the 80s and now it’s impossible to change.

{% end %}

{% quote(author="Gary Bernhardt", url="https://www.destroyallsoftware.com/talks/a-whole-new-world") %}

This is what you have to do to redesign infrastructure. Rich [Hickey] didn't just pile some crap on top of Lisp [when building Clojure]. He took the entire Lisp and moved the whole design at once.

{% end %}
## a mental model of a terminal
At a very very high level, a terminal has four parts:
1. The "[terminal emulator](https://wizardzines.com/comics/meet-the-terminal-emulator/)", which is a program that renders a grid-like structure to your graphical display.
2. The "[pseudo-terminal](https://jvns.ca/blog/2022/07/20/pseudoterminals/)" (PTY), which is a connection between the terminal emulator and a "process group" which receives input. This is not a program. This is a piece of state in the kernel.
3. The "shell", which is a program that leads the "process group", reads and parses input, spawns processes, and generally acts as an event loop. Most environments use [bash](https://jvns.ca/blog/2017/03/26/bash-quirks/) as the default shell.
4. The programs spawned by your shell, which interact with all of the above in order to receive input and send output.

I lied a little bit above. "input" is not just text. It also includes [signals](https://man7.org/linux/man-pages/man7/signal.7.html) that can be sent to the running process. Converting keystrokes to signals is the job of the PTY.

Similar, "output" is not just text. It's a stream of [ANSI Escape Sequences](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797) that can be used by the terminal emulator to display rich formatting.
## what does a better terminal look like?
I do some [weird things](https://jyn.dev/how-i-use-my-terminal/) with terminals. However, the amount of hacks I can get up to are pretty limited, because terminals are pretty limited. I won't go into all the ways they're limited, because it's been rehashed [many](https://matklad.github.io/2019/11/16/a-better-shell.html) [times](https://github.com/withoutboats/notty) [before](https://jvns.ca/blog/2025/02/05/some-terminal-frustrations/). What I want to do instead is imagine what a better terminal can look like.
### a first try: Jupyter
The closest thing to a terminal analog that most people are familiar with is [Jupyter Notebook](https://docs.jupyter.org/en/latest/). This offers a lot of cool features that are not possible in a "traditional" VT100 emulator:
- high fidelity image rendering

	![screenshot of a JupyterLite notebook. It has some python code in a cell that generates a matplotlib chart. Beneath is the chart, rendered to raster graphics.](</assets/jupyter bubble plot.png>)
- a "rerun from start" button (or rerun the current command; or rerun only a single past command) that replaces past output instead of appending to it

	![](</assets/jupyter run cells.png>)
- "views" of source code and output that can be rewritten in place (e.g. markdown can be viewed either as source or as rendered HTML)

	![](</assets/jupyter markdown raw.png>) ![](</assets/jupyter markdown rendered.png>)
- a built-in editor with syntax highlighting, tabs, panes, mouse support, etc.

	![](</assets/jupyter window management.png>)
### some problems
Jupyter works by having a "kernel" (in this case, a python interpreter) and a "renderer" (in this case, a web application displayed by the browser). You could imagine using a Jupyter Notebook with a shell as the kernel, so that you get all the nice features of Jupyter when running shell commands. However, that quickly runs into some issues:
- Your shell gets the commands all at once, not character-by-character, so tab-complete, syntax highlighting, and autosuggestions don't work.
- What do you do about long-lived processes? By default, Jupyter runs a cell until completion; you can cancel it, but you can't suspend, resume, interact with, nor view a process while it's running. Don't even think about running `vi` or `top`.
- The "rerun cell" buttons do horrible things to the state of your computer (normal Jupyter kernels have this problem too, but "rerun all" works better when the commands don't usually include `rm -rf`).
- Undo/redo do *not* work. (They don't work in a normal terminal either, but people attempt to use them more when it looks like they should be able to.)

It turns out all these problems are solveable.
## how does that work?
### shell integration
There exists today a terminal called [Warp](https://www.warp.dev/). Warp has built native integration between the terminal and the shell, where the terminal understands where each command starts and stops, what it outputs, and what is your own input. As a result, it can render things very prettily:

![](</assets/warp terminal.png>)

It does this using (mostly) standard features built-in to the terminal and shell (a custom DCS): you can read their explanation [here](https://www.warp.dev/blog/how-warp-works#:~:text=the%20reason). It's possible to do this less invasively using [OSC 133 escape codes](https://iterm2.com/documentation-escape-codes.html#:~:text=shell%20integration/); I'm not sure why Warp didn't do this, but that's ok.

iTerm2 does a similar thing, and this allows it to enable [really quite a lot of features](https://iterm2.com/documentation-shell-integration.html#:~:text=enables%20numerous%20features): navigating between commands with a single hotkey; notifying you when a command finishes running, showing the current command as an "overlay" if the output goes off the screen.
### long-lived processes
This is really three different things. The first is *interacting* with a long-lived process. The second is *suspending* the process without killing it. The third is *disconnecting* from the process, in such a way that the process state is not disturbed and is still available if you want to reconnect.
#### interacting
To interact with a process, you need bidirectional communication, i.e. you need a "cell output" that is also an input. An example would be any TUI, like `top`, `gdb`, or `vim` [^1].  Fortunately, Jupyter is really good at this!  The whole design is around having [interactive outputs](https://ipywidgets.readthedocs.io/en/latest/) that you can change and update.

Additionally, I would expect my terminal to always have a "free input cell", as Matklad describes in [A Better Shell](https://matklad.github.io/2019/11/16/a-better-shell.html), where the interactive process runs in the top half of the window and an input cell is available in the bottom half. Jupyter can do this today, but "add a cell" is manual, not automatic.
#### suspending
"Suspending" a process is usually called "[job control](https://jvns.ca/blog/2024/07/03/reasons-to-use-job-control/)". There's not too much to talk about here, except that I would expect a "modern" terminal to show me all suspended and background processes as a de-emphasized persistent visual, kinda like how Intellij will show you "indexing ..." in the bottom taskbar.

![](</assets/intellij background tasks.png>)
#### disconnecting
There are roughly three existing approaches for disconnecting and reconnecting to a terminal session (Well, four if you count [reptyr](https://github.com/nelhage/reptyr)).
1. Tmux / Zellij / Screen

	These tools inject a whole extra terminal emulator between your terminal emulator and the program. They work by having a "server" which actually owns the PTY and renders the output, and a "client" that displays the output to your "real" terminal emulator. This model lets you detach clients, reattach them later, or even attach multiple clients at once. You can think of this as a "batteries-included" approach. It also has the benefit that you can [program](https://jyn.dev/how-i-use-my-terminal/) both the client and the server (although many modern terminals, like [Kitty](https://sw.kovidgoyal.net/kitty/) and [Wezterm](https://wezfurlong.org/wezterm/) are programmable now); that you can organize your tabs and windows in the terminal (although many modern desktop environments have tiling and thorough keyboard shortcuts); and that you get street cred for looking like Hackerman.
	
	![](</assets/hackerman.png>)
	
	The downside is that, well, now you have an extra terminal emulator running in your terminal, with [all the bugs that implies](https://sw.kovidgoyal.net/kitty/faq/#i-am-using-tmux-zellij-and-have-a-problem).

	iTerm actually avoids this by [bypassing the tmux client altogether and acting as its own client](https://iterm2.com/documentation-tmux-integration.html) that talks directly to the server. In this mode, "tmux tabs" are actually iTerm tabs, "tmux panes" are iTerm panes, and so on. This is a good model, and I would adopt it when writing a future terminal for integration with existing tmux setups.
2. [Mosh](https://mosh.org/)

	Mosh is a really interesting place in the design space. It is not a terminal emulator replacement; instead it is an *ssh* replacement. Its big draw is that it supports reconnecting to your terminal session after a network interruption. It does that by [running a state machine on the server and replaying an incremental diff of the viewport to the client](https://mosh.org/#:~:text=how%20mosh%20works). This is a similar model to tmux, except that it doesn't support the "multiplexing" part (it expects your terminal emulator to handle that), nor scrollback (ditto). Because it has its own renderer, it has [a similar class of bugs to tmux](https://github.com/mobile-shell/mosh/issues/234). One feature it *does* have, unlike tmux, is that the "client" is really running on your side of the network, so local line editing is instant.
3. [alden]/[shpool]/[dtach]/[abduco]/[diss]

	These all occupy a similar place in the design space: they *only* handle session detach/resume with a client/server, not networking or scrollback, and do not include their own terminal emulator. Compared to tmux and mosh, they are highly decoupled.

[shpool]: https://github.com/shell-pool/shpool
[dtach]: https://github.com/crigler/dtach
[abduco]: https://github.com/martanne/abduco
[diss]: https://github.com/yazgoo/diss
[alden]: https://ansuz.sooke.bc.ca/entry/389
### rerun and undo/redo
I'm going to treat these together because the solution is the same: dataflow tracking.

Take as an example [pluto.jl](https://plutojl.org/), which does this *today* by hooking into the Julia compiler.

![](</assets/pluto interactive ode.gif>)

Note that this updates cells live in response to previous cells that they depend on. Not pictured is that it *doesn't* update cells if their dependencies haven't changed. You can think of this as a spreadsheet-like Jupyter, where code is only rerun when necessary.

You may say this is hard to generalize. The trick here is [orthogonal persistence](https://jyn.dev/complected-and-orthogonal-persistence/#how-far-can-we-take-this). If you sandbox the processes, track all IO, and prevent things that are "too weird" unless they're talking to other processes in the sandbox (e.g. unix sockets and POST requests), you have really quite a lot of control over the process! This lets you treat it as a pure function of its inputs, where its inputs are "the whole file system, all environment variables, and all process attributes".
### derived features
Once you have these primitives—Jupyter notebook frontends, undo/redo, automatic rerun, persistence, and shell integration—you can build really quite a lot on top. And you can build it incrementally, piece-by-piece:
#### needs a Jupyter notebook frontend
- [Runbooks][atuin desktop] (actually, you can build these just with Jupyter and a PTY primitive).
- Terminal customization that uses normal CSS, no weird custom languages or ANSI color codes.
- Search for commands by output/timestamp. Currently, you can search across output in the current session, or you can search across all command input history, but you don't have any kind of smart filters, and the output doesn't persist across sessions.

[atuin desktop]: https://blog.atuin.sh/atuin-desktop-runbooks-that-run/
#### needs shell integration
- Timestamps and execution duration for each command.
- Local line-editing, even across a network boundary.
- [IntelliSense for shell commands](https://docs.warp.dev/terminal/command-completions/completions), without having to hit tab and with rendering that's integrated into the terminal.
#### needs sandboxed tracing
- "[All the features from sandboxed tracing](https://jyn.dev/complected-and-orthogonal-persistence/#but-why)": collaborative terminals, querying files modified by a command, "asciinema but you can edit it at runtime", tracing build systems.
- Extend the smart search above to also search by disk state at the time the command was run.
- Extending undo/redo to a git-like branching model (something like this is already support by [emacs undo-tree](https://elpa.gnu.org/packages/undo-tree.html#:~:text=undo%20systems)), where you have multiple "views" of the process tree.
- Given the undo-tree model, and since we have sandboxing, we can give an LLM access to your project, and run many of them in parallel at the same time without overwriting each others state, and in such a way that you can see what they're doing, edit it, and save it into a runbook for later use.
- A terminal in a prod environment that can't affect the state of the machine, only inspect the existing state.
## ok but how do you build this
jyn, you may say, [you can't build vertical integration in open source](https://becca.ooo/blog/vertical-integration/). [you can't make money off open source projects](https://tech.lgbt/@jyn/112187088917827279). [the switching costs are too high](https://jyn.dev/you-are-in-a-box/#switching-costs-and-growth).

All these things are true. To talk about how this is possible, we have to talk about incremental adoption.

if I were building this, I would do it in stages, such that at each stage the thing is an improvement over its alternatives. This is how `jj` works and it works extremely well: it doesn't require everyone on a team to switch at once because individual people can use `jj`, even for single commands, without a large impact on everyone else.
### stage 1: transactional semantics
When people think of redesigning the terminal, they always think of redesigning the terminal *emulator*. This is exactly the wrong place to start. People are attached to their emulators. They configure them, they make them look nice, they use their keybindings. There is a high switching cost to switching emulators because [everything affects everything else](https://jvns.ca/blog/2025/01/11/getting-a-modern-terminal-setup/#everything-affects-everything-else). It's not *so* terribly high, because it's still individual and not shared across a team, but still high.

What I would do instead is start at the CLI layer. CLI programs are great because they're easy to install and run and have very low switching costs: you can use them one-off without changing your whole workflow.

So, I would write a CLI that implements [transactional semantics for the terminal](https://jyn.dev/complected-and-orthogonal-persistence/#how-far-can-we-take-this). You can imagine an interface something like `transaction [start|rollback|commit]`, where everything run after `start` is undoable. There is a *lot* you can do with this alone, I think you could build a whole business off this.
### stage 2: persistent sessions
Once I had transactional semantics, I would try to decouple persistence from tmux and mosh. 

To get PTY persistence, you have to introduce a client/server model, because the kernel *really really* [expects](https://en.wikipedia.org/wiki/SIGHUP) both sides of a PTY to always be connected. Using commands like [alden], or a library like it (it's not *that* complicated), lets you do this simply, without affecting the terminal emulator nor the programs running inside the PTY session.

To get scrollback, the server could save input and output indefinitely and replay them when the client reconnects. This gets you "native" scrollback—the terminal emulator you're already using handles it exactly like any other output, because it looks exactly like any other output—while still being replayable and resumable from an arbitrary starting point. This requires some amount of parsing ANSI escape codes[^2], but it's doable with enough work.

To get network resumption like mosh, my custom server could use [Eternal TCP](https://eternalterminal.dev/howitworks/) (possibly built on top of QUIC for efficiency). Notably, the persistence for the PTY is separate from the persistence for the network connection. Eternal TCP here is strictly an optimization: you could build this on top of a bash script that runs `ssh host eternal-pty attach` in a loop, it's just not as nice an experience because of network delay and packet loss. Again, composable parts allow for incremental adoption.

At this point, you're already able to connect multiple clients to a single terminal session, like tmux, but window management is still done by your terminal emulator, not by the client/server. If you wanted to have window management integrated, the terminal emulator could speak the tmux -CC protocol, like iTerm.

All parts of this stage can be done independently and in parallel from the transactional semantics, but I don't think you can build a business off them, it's not enough of an improvement over the existing tools.
### stage 3: structured RPC
This bit depends on the client/server model. Once you have a server interposed between the terminal emulator and the client, you can start doing really funny things like tagging I/O with metadata. This lets all data be timestamped[^3] and lets you distinguish input from output. [xterm.js](https://jvns.ca/blog/2022/07/20/pseudoterminals/) works something like this. When combined with shell integration, this even lets you distinguish shell prompts from program output, at the *data* layer.

Now you can start doing really funny things, because you have a *structured log* of your terminal session. You can replay the log as a recording, like [asciinema][][^4]; you can transform the shell prompt without rerunning all the commands; you can import it into a Jupyter Notebook or [Atuin Desktop]; you can save the commands and rerun them later as a script. Your terminal is data.

[asciinema]: https://asciinema.org/
### stage 4: jupyter-like frontend
This is the very first time that we touch the terminal emulator, and it's intentionally the last step because it has the highest switching costs. This makes use of all the nice features we've built to give you a nice UI. You don't need our `transaction` CLI anymore unless you want nested transactions, because your whole terminal session starts in a transaction by default. You get all the features I mention [above](#derived-features), because we've put all the pieces together.
## jyn, what the fuck
This is bold and ambitious and I think building the whole thing would take about a decade. That's ok. I'm patient.

You can help me by spreading the word :) Perhaps this post will inspire someone to start building this themselves.

---
## bibliography

- [Gary Bernhardt, “A Whole New World”](https://www.destroyallsoftware.com/talks/a-whole-new-world)
- [Alex Kladov, “A Better Shell”](https://matklad.github.io/2019/11/16/a-better-shell.html)
- [jyn, “how i use my terminal”](https://jyn.dev/how-i-use-my-terminal/)
- [jyn, “Complected and Orthogonal Persistence”](https://jyn.dev/complected-and-orthogonal-persistence/)
- [jyn, “you are in a box”](https://jyn.dev/you-are-in-a-box/)
- [jyn, “there's two costs to making money off an open source project…”](https://tech.lgbt/@jyn/112187088917827279)
- [Rebecca Turner, “Vertical Integration is the Only Thing That Matters”](https://becca.ooo/blog/vertical-integration/)
- [Julia Evans, “New zine: The Secret Rules of the Terminal”](https://jvns.ca/blog/2025/06/24/new-zine--the-secret-rules-of-the-terminal/)
- [Julia Evans, “meet the terminal emulator”](https://wizardzines.com/comics/meet-the-terminal-emulator/)
- [Julia Evans, “What happens when you press a key in your terminal?”](https://jvns.ca/blog/2022/07/20/pseudoterminals/)
- [Julia Evans, “What's involved in getting a "modern" terminal setup?”](https://jvns.ca/blog/2025/01/11/getting-a-modern-terminal-setup/)
- [Julia Evans, “Bash scripting quirks & safety tips”](https://jvns.ca/blog/2017/03/26/bash-quirks/)
- [Julia Evans, “Some terminal frustrations”](https://jvns.ca/blog/2025/02/05/some-terminal-frustrations/)
- [Julia Evans, “Reasons to use your shell's job control”](https://jvns.ca/blog/2024/07/03/reasons-to-use-job-control/)
- [“signal(7) - Miscellaneous Information Manual”](https://man7.org/linux/man-pages/man7/signal.7.html)
- [Christian Petersen, “ANSI Escape Codes”](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797)
- [saoirse, “withoutboats/notty: A new kind of terminal”](https://github.com/withoutboats/notty)
- [Jupyter Team, “Project Jupyter Documentation”](https://docs.jupyter.org/en/latest/)
- [“Warp: The Agentic Development Environment”](https://www.warp.dev/)
- [“Warp: How Warp Works”](https://www.warp.dev/blog/how-warp-works)
- [“Warp: Completions”](https://docs.warp.dev/terminal/command-completions/completions)
- [George Nachman, “iTerm2: Proprietary Escape Codes”](https://iterm2.com/documentation-escape-codes.html)
- [George Nachman, “iTerm2: Shell Integration”](https://iterm2.com/documentation-shell-integration.html)
- [George Nachman, “iTerm2: tmux Integration”](https://iterm2.com/documentation-tmux-integration.html)
- [Project Jupyter, “Jupyter Widgets”](https://ipywidgets.readthedocs.io/en/latest/)
- [Nelson Elhage, “nelhage/reptyr: Reparent a running program to a new terminal”](https://github.com/nelhage/reptyr)
- [Kovid Goyal, “kitty”](https://sw.kovidgoyal.net/kitty/)
- [Kovid Goyal, “kitty - Frequently Asked Questions”](https://sw.kovidgoyal.net/kitty/faq/)
- [Wez Furlong, “Wezterm”](https://wezfurlong.org/wezterm/)
- [Keith Winstein, “Mosh: the mobile shell”](https://mosh.org/)
- [Keith Winstein, “Display errors with certain characters](https://github.com/mobile-shell/mosh/issues/234)
- [Matthew Skala, “alden: detachable terminal sessions without breaking scrollback”](https://ansuz.sooke.bc.ca/entry/389)
- [Ethan Pailes, “shell-pool/shpool: Think tmux, then aim... lower”](https://github.com/shell-pool/shpool)
- [Ned T. Crigler, “crigler/dtach: A simple program that emulates the detach feature of screen”](https://github.com/crigler/dtach)
- [Marc André Tanner, “martanne/abduco: abduco provides session management”](https://github.com/martanne/abduco)
- [yazgoo, “yazgoo/diss: dtach-like program / crate in rust”](https://github.com/yazgoo/diss)
- [Fons van der Plas, “Pluto.jl — interactive Julia programming environment”](https://plutojl.org/)
- [Ellie Huxtable, “Atuin Desktop: Runbooks that Run”](https://blog.atuin.sh/atuin-desktop-runbooks-that-run/)
- [Toby Cubitt, “undo-tree”](https://elpa.gnu.org/packages/undo-tree.html)
- [“SIGHUP - Wikipedia”](https://en.wikipedia.org/wiki/SIGHUP)
- [Jason Gauci, “How Eternal Terminal Works”](https://eternalterminal.dev/howitworks/)
- [Marcin Kulik, “Record and share your terminal sessions, the simple way - asciinema.org”](https://asciinema.org/)
- [“Alternate Screen | Ratatui”](https://ratatui.rs/concepts/backends/alternate-screen/)

<!--To talk about interacting with a process, we have to talk about [PTTYs](https://jvns.ca/blog/2022/07/20/pseudoterminals/).-->
<!--
My complaint about Warp is chiefly that they didn't think big enough. Warp built a very cool tool, and then wrapped it in a product that mostly exists to make it easier to use LLMs in the terminal. There are [*so many* things](https://iterm2.com/documentation-shell-integration.html#:~:text=enables%20numerous%20features) you could do with shell integration, and they don't seem to have done very many of them.
-->

[^1]: there are a *lot* of complications here around [alternate mode](https://ratatui.rs/concepts/backends/alternate-screen/), but I'm just going to skip over those for now. A simple way to handle alternate mode (that doesn't get you nice things) is just to embed a raw terminal in the output cell.

[^2]: otherwise you could start replaying output from inside an escape, which is [not good](https://mosh.org/#:~:text=evil%20escape%20sequences). I had a detailed email exchange about this with the alden author which I have not yet had time to write up into a blog post; most of the complication comes when you want to avoid replaying the *entire* history and only want to replay the visible viewport. 

[^3]: hey, this seems awfully like [asciinema]!

[^4]: oh, that's why it seemed like asciinema.
