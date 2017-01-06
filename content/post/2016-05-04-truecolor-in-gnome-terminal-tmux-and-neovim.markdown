---
tags:
- tmux
- vim
- terminal
comments: true
date: 2016-05-04T11:41:10Z
title: TrueColor in Gnome Terminal, Tmux and Neovim
slug: truecolor-in-gnome-terminal-tmux-and-neovim
---

Here is where we are right now: https://gist.github.com/XVilka/8346728 . As you
can see, most of the editors and terminals now support TrueColor (16 million
colors).

**The result**

Difference between TrueColor (24bits - 16 million colors) and "256colors" (8bits - 256 colors):

<img class="img-rounded" src="/images/posts/2016-05-05-truecolor-in-gnome-terminal-tmux-and-neovim/diff1.png" alt="" width="100%" title=""/>

Original theme ([gruvbox](https://github.com/morhetz/gruvbox)):

<img class="img-rounded" src="/images/posts/2016-05-05-truecolor-in-gnome-terminal-tmux-and-neovim/orig.png" alt="" width="100%" title=""/>

TrueColor looks better and comfier for your eyes. So, there is no excuse not to use it.

<!--more-->

## Gnome Terminal

gnome-terminal has to be in version linked against `libvte >= 0.36`.

1) Check

```
ldd /usr/lib/gnome-terminal/gnome-terminal-server | grep libvte
```

2) Install

```
sudo add-apt-repository ppa:gnome3-team/gnome3-staging
sudo apt-get update
sudo apt-get install -y gnome-terminal
sudo add-apt-repository -r ppa:gnome3-team/gnome3-staging
```

3) Restart gnome-terminal-server (I've just rebooted my machine, but killing the corresponding process should also do the job).

Links:

- https://askubuntu.com/questions/512525/how-to-enable-24bit-true-color-support-in-gnome-terminal

## Tmux

tmux must be `>= 2.2`.

1) Check

```
tmux -V
```

2) Kill tmux (`tmux kill-server`) and (optionally) remove it

3) Install

On Ubuntu:

```
sudo apt-get install -y libevent-dev libncurses-dev build-essential
```

```
wget https://github.com/tmux/tmux/releases/download/2.2/tmux-2.2.tar.gz && \
  tar -xzvf tmux-2.2.tar.gz && \
  cd tmux-2.2 && \
  ./configure && \
  make && \
  sudo make install
```

4) Alias tmux or set $TERM env variable

```
alias tmux="env TERM=xterm-256color tmux"
```

5) Set option, which overrides default terminal

```
# .tmux.conf
set-option -ga terminal-overrides ",xterm-256color:Tc"
```

6) Check (inside tmux)

```
tmux info | grep Tc
```

If the command reports Tc: [missing], then support for 24-bit colors has not been enabled properly because the terminal-overrides option may have specified the outer terminal’s $TERM value incorrectly or because tmux may have been reattached to an entirely different outer terminal altogether.

Links:

- https://github.com/tmux/tmux
- https://sunaku.github.io/tmux-24bit-color.html#usage

## Neovim

1) Set env variable

```vim
" .nvimrc
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
```

2) Pick a theme, which does not force 256 colors `if !has('gui_running')` or checks for `neovim` ([discussion](https://github.com/neovim/neovim/issues/793)):

- [solarized fork](https://github.com/frankier/neovim-colors-solarized-truecolor-only)
- [gruvbox](https://github.com/morhetz/gruvbox)
- https://github.com/neovim/neovim/issues/793#issuecomment-59628883

Links:

- https://chris.chowie.net/2015/04/19/True-colour-with-neovim-tmux-and-iterm2/

My dotfiles: https://github.com/akalyaev/dotfiles
