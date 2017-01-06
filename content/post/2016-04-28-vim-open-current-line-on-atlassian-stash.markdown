---
tags:
- vim
comments: true
date: 2016-04-28T11:47:36Z
title: 'Vim: Open current line on Atlassian Stash (Bitbucket Server)'
slug: vim-open-current-line-on-atlassian-stash
---

This is based on Felix Geisendörfer [Vim Trick: Open current line on GitHub](http://felixge.de/2013/08/08/vim-trick-open-current-line-on-github.html).

<!--more-->

**Step 1. Create a git alias**

```
# ~/.gitconfig
[alias]
  url =! bash -c 'git config --get remote.origin.url | sed -E "s/.+\\.ru\\\\/\\(.+\\)\\\\/\\(.+\\)\\.git$/https:\\\\/\\\\/stash\\\\.yourcompanyname\\\\.com\\\\/projects\\\\/\\\\1\\\\/repos\\\\/\\\\2\\\\/browse/g"'
```

Change domain name from 'stash.yourcompanyname.com' to something real. Pay attention to '.' escaping.

**Step 2. Create a mapping in Vim**

```vim
; ~/.vimrc
nnoremap <leader>ou :!echo `git url`/%?at=`git rev-parse HEAD`\#<C-R>=line('.')<CR> \| xargs open<CR><CR>
```

**Step 3. Enjoy**

My dotfiles: https://github.com/akalyaev/dotfiles
