---
title: how i write blog posts
date: 2025-06-18
description: "the trick is to make it as easy as possible"
---

this isn’t about about blogging engines, don’t worry. there’s already plenty of writing about those. i use zola, i am mildly dissatisfied with it, i don’t care enough to switch.

no, this is how i actually write. i have an um. *eccentric* setup. in particular, i can write draft posts from any of my devices—desktop, laptop, phone—and have them show up live on a hidden subdomain of jyn.dev without any special work on my part.

how does this work? i’m glad you asked.
- on my desktop, i have Caddy running a reverse proxy back to a live zola server. Caddy gives me nice things like https, and makes me less worried about having public ports on the internet.
- on my desktop, i have the zola content/ directory sym-linked to a subdirectory of my obsidian notes folder.
- on all my devices, i run Obsidian Sync in the background, which automatically syncs my posts everywhere. it costs $5/month and doesn’t cause me trouble, which is a lot more than i can say for most technology.
- on laptop and mobile, i just write in obsidian, like i would for any other notes. i have a "blog post" template that inserts the zola header; otherwise i just write normal markdown.
- when i’m ready to publish, i commit the changes to git on desktop or laptop and push to github, which updates the public facing blog.

works great!

normally i write outlines and ideas down on mobile, and then clean them up into prose on desktop. when i edit on desktop, i sometimes use nvim (e.g. for posts like [how i use my terminal](@/how-i-use-my-terminal.md) that have complicated html fragments). unlike obsidian, nvim doesn't have autosave, so i [added it myself](https://github.com/jyn514/dotfiles/blob/45f6702de2608a972615cd877993a41521f76348/config/nvim.lua#L242-L268):
```lua
-- autosave on cursor hold
local timers = {}
function autosave_enable()
  local buf = vim.api.nvim_get_current_buf()
  if timers[buf] then return end

  local buf_name = vim.fn.expand '%'
  vim.notify("autosaving "..buf_name)
  timers[buf] = vim.api.nvim_create_autocmd("CursorHold", {
    desc = "Save "..buf_name.." on change",
    callback = function() vim.api.nvim_buf_call(buf,
      function() vim.cmd "silent update" end
    ) end })
end
vim.api.nvim_create_user_command('AutoSave', autosave_enable,
	{desc = "Start saving each second on change"})
```
the one downside of this is that i get very little visibility on mobile onto why things are not syncing to the desktop. to make up for this, my phone and desktop are on the same tailnet, which allows me to ssh in remotely to check up on the zola server (i’ve never had to check up on the Caddy server). i like Termius for this.
