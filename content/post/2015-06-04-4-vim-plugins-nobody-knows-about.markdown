---
categories: vim
comments: true
date: 2015-06-04T22:53:15Z
title: 4 Vim Plugins Nobody Knows About
slug: 4-vim-plugins-nobody-knows-about
---

I've been using these four plugins for a really long time. And they are
wonderful. But each time coming on Github and seeing the number of stars, I
think that few people actually know about them.

<!--more-->

## 1. AutoSave

AutoSave - automatically save changes to disk without having to use :w (or any
binding to it) every time a buffer has been modified.

Why on earth we need to type `:w` or hit some combo `<leader>-s` to save
changes to some file. We live in the 21st century, when [people are going to
Mars](http://www.mars-one.com/)! And yet, we're still repeatedly saving our
files. Stop doing this!

https://github.com/907th/vim-auto-save

I use it with these settings:

```vim
let g:auto_save = 1
let g:auto_save_in_insert_mode = 0
let g:auto_save_silent = 1
```

## 2. vim-bracketed-paste

vim-bracketed-paste enables transparent pasting into vim. (i.e. no more :set paste!)

Another great plugin that removes the pain when copying between Vim and OS. Time-saver.

https://github.com/ConradIrwin/vim-bracketed-paste

## 3. file-line

Plugin for vim to enable opening a file in a given line.

For example, if you have some of the RSpec tests failed:

```
Failed examples:

rspec ./spec/support/breadcrumbs.rb:6 # Breadcrumbs logged in as admin user Users behaves like a page with #index breadcrumbs shows the expected breadcrumbs
```

you may want to open a file with cursor on line 6:

```bash
$ vim ./spec/support/breadcrumbs.rb:6
```

And this plugin allows you to do exactly that.

https://github.com/bogado/file-line

## 4. vim-visual-star-search

Start a * or # search from a visual block.

Another plugin, which I constantly use. Quite often, there is a situation where
I want to see all the places where a certain variable is used. And having my
cursor on it, all I left to do is to press `*` to highlight all the
occurrences.

https://github.com/nelstrom/vim-visual-star-search

Example of using two last plugins (vim-visual-star-search and file-line):

[![asciicast](https://asciinema.org/a/5szdg2zqk0tjg1eb81vjpdmci.png)](https://asciinema.org/a/5szdg2zqk0tjg1eb81vjpdmci?autoplay=1)

Looking for more stuff? Check out [my dotfiles](https://github.com/akalyaev/dotfiles).
