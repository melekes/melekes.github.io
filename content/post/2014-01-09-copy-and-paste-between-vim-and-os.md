---
tags:
- tutorials
- vim
- os
- copy-and-paste
- vimrc
comments: true
date: 2014-01-09T00:00:00Z
title: Copy and paste between Vim and OS
slug: copy-and-paste-between-vim-and-os
---

When I first encountered this problem it slightly
puzzled me. "Why can not I press `ctrl-c` to copy the text and
`ctrl-v` to paste?"- I asked myself. Indeed, the majority of source code editors
able to do this. And yes, I got used to this dammit!

<!--more-->

Well, Vim is primarily a console text editor. Of course, there is a GUI version - GVim (or MacVim for MacOS), but most prefer to stay in the console, where we can use such wonderful tools as [tmux](http://en.wikipedia.org/wiki/Tmux) and [teamochil](https://github.com/remiprev/teamocil) \*.

### First attempt

The first more or less acceptable solution offered [Victor Gumayunov](https://twitter.com/gumayunov). Few people know, but if you press and hold `ctrl + alt`, you will be able to select a text block using the mouse and, by clicking its right button, copy it.

### Second attempt

And at first, it suited me. But it has lasted a short time and I started
looking for other ways out. The next approach was to use of custom bindings for tmux, which use xclip utility (pbcopy on MacOS) to copy the contents of the system's buffer into tmux's buffer and back.

For this you was have to write:

{% codeblock lang:bash %}
# move x clipboard into tmux paste buffer
bind C-p run "tmux set-buffer \"$(xclip -o)\"; tmux paste-buffer"
# move tmux copy buffer into x clipboard
bind C-y run "tmux save-buffer - | xclip -i"
{% endcodeblock %}

in your `.tmux.conf`.

But do not rush to do it :)

### Third attempt (the lucky one)

While getting to know Vim more tightly, I learned that it has support
for system buffer. To work with it, Vim has two registers `*` and `+`
(see `:h registers`). "Sounds great" - I thought.

One catch - Vim must be compiled with `+clipboard`. To check whether you have support for clipboard run:

{% codeblock lang:bash %}
$ vim --version | grep clipboard
{% endcodeblock %}

The easiest way to fix this **for most Linux'es** is to install GVim (but continue to use its console version).

{% codeblock lang:bash %}
$ sudo apt-get install vim-gnome
{% endcodeblock %}

**For MacOS** you can get Vim with `+clipboard` via Homebrew or download and install MacVim [here](http://code.google.com/p/macvim/downloads/list).

{% codeblock lang:bash %}
$ brew install vim
{% endcodeblock %}

Look inside /Applications/MacVim.app/Contents/MacOS, and you’ll see that the app provides two binaries: MacVim, which launches the GUI, and Vim, which runs in the Terminal with the same feature set. Both versions include the `+clipboard` feature.

The last thing left to do - something to get rid of the need to
to type `"*p` and `"*y` prefixes. I don't want copy and paste between Vim and OS was some special occasion, I want everything to be transparent to the user. It turned out, you just need to add this line to your `.vimrc`:

{% codeblock lang:vim %}
set clipboard=unnamed " or unnamedplus if you have X11
{% endcodeblock %}

Now all operations such as `yy`, `D`, and `p` work with the clipboard. No need to prefix them with `"*` or `"+`. Sounds like magic, right?!

Example:

<iframe width="560" height="315" src="//www.youtube.com/embed/x19YZF4YfLs" frameborder="0" allowfullscreen="true">       </iframe>

\* these utilities are among the best in my humble opinion and they are helping me every day
