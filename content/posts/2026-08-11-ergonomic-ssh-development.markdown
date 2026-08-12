---
date: "2026-08-11T09:00:00Z"
tags: programming
title: Ergonomic SSH development
---

I've been setting up a `dev` machine on my home server and doing all of my
personal projects remotely over `SSH`. I've fiddled quite a bit with the system
to make it ergonomic, so here are some of the things I'm quite happy with.


## Tmux autocompletions

Of course, `tmux` is a t-must! One of the cool things about `tmux` is that you
can programmatically read the contents of a pane via `tmux capture-pane -S- -pt
$PANE_ID`, which means you can plug this data into autocomplete engines.

<video width=100% controls autoplay loop>
    <source src="/assets/zsh-tmux-autocomplete.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**zsh tmux autocomplete config**" >}}

```zsh
# Complete the current word from words in all tmux pane.
_tmux_pane_words() {
  [[ -n $TMUX ]] || return 1
  local pane text
  for pane in ${(f)"$(tmux list-panes -a -F '#{pane_id}')"}; do
    text+="$(tmux capture-pane -p -J -S - -t $pane)"$'\n'
  done
  local -a words
  words=(${(u)=${text//[^[:alnum:]_.@\/-]/ }})  # tokenize + dedup
  words=(${words:#$PREFIX})   # exclude the currently typed word
  compadd -a words
}
zmodload zsh/complist
zle -C tmux-complete menu-select _tmux_pane_words
bindkey '^N' tmux-complete
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history
```

{{< /details >}}

I got this working using a `zsh` custom completion function, along with
`vim`-style `^N` and `^P` to cycle between completions.


But why should `zsh` have all the fun? `neovim` has autocomplete too!

<video width=100% controls autoplay loop>
    <source src="/assets/nvim-tmux-autocomplete.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**neovim tmux autocomplete config**" >}}

```lua
-- Complete words from all other tmux panes.
function _G.tmux_complete(findstart, base)
  if findstart == 1 then                         -- locate start of the keyword
    local line, col = vim.fn.getline("."), vim.fn.col(".") - 1
    local s = col
    while s > 0 and line:sub(s, s):match("%S") do s = s - 1 end
    return s
  end
  if not vim.env.TMUX then return {} end
  local words, seen = {}, {}
  local self = vim.env.TMUX_PANE                  -- skip nvim's own pane
  for _, pane in ipairs(vim.fn.systemlist({ "tmux", "list-panes", "-a", "-F", "#{pane_id}" })) do
    if pane ~= self then
      local text = vim.fn.system({ "tmux", "capture-pane", "-p", "-J", "-S", "-", "-t", pane })
      for w in text:gmatch("%S+") do
        if #w > 2 and not seen[w]
           and (base == "" or w:sub(1, #base):lower() == base:lower()) then
          seen[w] = true
          words[#words + 1] = { word = w, menu = "[tmux]", dup = 0 }
        end
      end
    end
  end
  return words
end

vim.o.completefunc = "v:lua.tmux_complete"
vim.opt.complete:append("F")   -- F = use 'completefunc' as a <C-n> source
```

{{< /details >}}

Since I do pretty much all of my work in `tmux`, `nvim`, and `zsh`, these make
it really easy to autocomplete anything I'm looking at.


## OSC-52

But the real unsung hero of any workflow is the humble copy-and-paste. The 'ol
`<C-c> <C-v>`. It turns out there's a thing called OSC-52 that enables copy and
paste over `SSH`. Most terminals support this, so it's a matter of enabling it
everywhere (`tmux`, `nvim`, and `zsh`).

I accomplished this via custom `yank` and `put` scripts (defined at the end,
for dramatic effect).

<video width=100% controls autoplay loop>
    <source src="/assets/tmux-copy.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**tmux yank config**" >}}

This configures `tmux` to use a `yank` script that needs to exist on `$PATH`
(defined in the `zsh` section below).

```tmux
set -g allow-passthrough on
set -g set-clipboard on
set -as terminal-features '*:extkeys:clipboard'

bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'y' send -X copy-pipe "yank"
bind-key -T copy-mode-vi 'Enter' send -X copy-pipe-and-cancel "yank"
```
{{< /details >}}

<br>

<video width=100% controls autoplay loop>
    <source src="/assets/nvim-copy.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**neovim yank/put config**" >}}

Similarly, this relies on a `yank` and `put` script available on `$PATH`.

```lua
-- Custom clipboard commands.
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = 'OSC-52 + local clipboard',
  copy = {
    ["+"] = {'yank'},
    ["*"] = {'yank'},
  },
  paste = {
    ["+"] = {'put'},
    ["*"] = {'put'},
  },
  cache_enabled = true,
}
```
{{< /details >}}

<br>

<video width=100% controls autoplay loop>
    <source src="/assets/zsh-copy.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**zsh yank/put scripts**" >}}

And finally, the custom `yank` and `put` scripts. These scripts live on my
remote machine, which allows copying to my local machine over `SSH` and pasting
within the remote machine. OSC-52 supports pasting over `SSH` too, but the terminal
asks you every time, which I found annoying (especially in `nvim`).

```bash
# yank
#
# Script to save text to /tmp/clipboard and copy it via tmux or OSC-52. If args
# are passed, that takes precedence.

# If args are passed, copy those, otherwise, read stdin.
if [ $# -gt 0 ]; then
  content="$*"
else
  # Use process substitution to prevent command substitution from
  # stripping trailing newlines.
  IFS= read -rd "" content < <(cat)
fi
                                                                  
printf '%s' "$content" > /tmp/clipboard
if [ -n "$TMUX" ]; then
  tmux set-buffer -w -- "$content"
else
  printf "\033]52;c;%s\007" $(base64 -w0 <<< "$content")
fi
```

```bash
# put
#
# Script to paste text written to /tmp/clipboard.
cat /tmp/clipboard
```
{{< /details >}}

<br>


## Slime

[slime](https://github.com/slime/slime) is an `emacs` thing for REPL-driven
development, and [vim-slime](https://github.com/jpalardy/vim-slime) adds some
of those features to `vim`!

<video width=100% controls autoplay loop>
    <source src="/assets/nvim-slime.webm" type="video/webm">
    Your browser does not support the video tag.  
</video>

{{< details "**vim-slime config**" >}}

By default, `vim-slime` asks for a socket and target pane. I always use
`default` for the socket name, so I added an override to only ask for the
target pane.

```lua
-- Slime configuration.
vim.g.slime_target = "tmux"
vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
vim.keymap.set("x", "<Enter>", "<Plug>SlimeRegionSend", { remap = true })
vim.keymap.set("n", "<Leader>s", "<Plug>SlimeConfig", { remap = true })
-- Only ask for the target pane.
vim.cmd([[
  function! SlimeOverrideConfig()
    if !exists("b:slime_config")
      let b:slime_config = {"socket_name": "default", "target_pane": ""}
    endif
    let b:slime_config["socket_name"] = "default"
    let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"], "custom,slime#targets#tmux#pane_names")
  endfunction
]])
```

I also added this to my `tmux` config to make finding the target pane ID
easier. `{last}` uses the last pane you navigated from, but it evaluates every
time, so I like to use the constant pane ID.

```tmux
set -g pane-border-status top
set -g pane-border-format ' #{pane_id} '
```

{{< /details >}}

I find this to be quite useful combined with the `nvim`/`tmux` autocomplete
defined earlier in this post.


## Conclusion

I've always favored keyboard-driven development, and now that I'm leaning into
remote development over `SSH`, these configurations have really made it so much
easier to forget I'm not working locally. It's just a joy to have things work
seamlessly.
