---
tags:
- editors
- vim
- productivity
comments: true
date: 2016-05-23T12:02:11Z
title: How to be productive with almost any text editor
slug: how-to-be-productive-with-almost-any-editor
---

<a href="/pdfs/posts/2016-05-23-how-to-be-productive-with-almost-any-editor/how_to_be_productive_with_almost_any_editor_ru_RU.pdf" title="Скачать PDF на русском">
  На русском
</a>

What makes us productive when working with code in the editor? Every day, there
is a new shining plugin, that allows us to do something useful by pressing only
2 keystrokes. Don't get me wrong, I'm not against plugins. Hell, I have at
least 40 of them (https://git.io/vrg64).

But, are all of them equally useful? I am certain that some tricks outperform
others in terms of productivity (**20% results in 80% boost**). These could be
features, built into the editor. You just don't know about them. Here, I've
tried to collect **the most important ones**, which don't require you to read a
pile of docs and much time to learn.

<!--more-->

There is no research (not to my knowledge) to backup the list below. If you
think I missed something, leave a comment or two.

In addition, I've compared the 5 most popular editors (vim, emacs, idea,
sublime text and atom). I hope it will be interesting for you to see how your
editor is doing relative to others.

<img class="img-rounded" src="/images/posts/2016-05-23-how-to-be-productive-with-almost-any-editor/trends.png" alt="" width="100%" title=""/>

Your humble servant is using Vim at his regular job, so you may notice a
certain predisposition. But I try to be open - the second attempt to master
Spacemacs? https://github.com/google/xi-editor ? Who knows..

## 1. Fast switching between the last two files

| Editor       | Mapping                                                 |
| ------------ | ------------------------------------------------------- |
| Vim          | `nnoremap <leader><leader> <C-^>`                       |
| ------------ | ------------------------------------------------------- |
| Emacs        | `(global-set-key (kbd "M-o")  'mode-line-other-buffer)` |
| ------------ | ------------------------------------------------------- |
| Idea         | Ctrl + Tab / Ctrl + Shift + Tab                         |
| ------------ | ------------------------------------------------------- |
| Sublime Text | Ctrl + Tab / Ctrl + Shift + Tab                         |
| ------------ | ------------------------------------------------------- |
| Atom         | Ctrl + Tab / Ctrl + Shift + Tab                         |


Emacs:

- https://www.emacswiki.org/emacs/SwitchingBuffers#toc5
- http://emacsredux.com/blog/2013/04/28/switch-to-previous-buffer/

Idea:

- http://blog.jetbrains.com/webide/2013/02/navigating-between-files-in-the-ide-best-practices/

## 2. Running tests without leaving the editor

| Editor       | The way                                                              |
| ------------ | -------------------------------------------------------------------- |
| Vim          | https://github.com/janko-m/vim-test                                  |
| ------------ | -------------------------------------------------------------------- |
| Emacs        | no uniform interface, but there are packages for different languages |
| ------------ | -------------------------------------------------------------------- |
| Idea         | through the UI plus Ctrl + R to restart                              |
| ------------ | -------------------------------------------------------------------- |
| Sublime Text | no uniform interface, but there are packages for different languages |
| ------------ | -------------------------------------------------------------------- |
| Atom         | no uniform interface, but there are packages for different languages |


Emacs:

- clojure - https://github.com/clojure-emacs/cider
- ruby - https://github.com/pezra/rspec-mode
- erlang - https://github.com/tjarvstrand/edts
- python - https://github.com/ionrock/pytest-el
- golang - https://github.com/nlamirault/gotest.el

Idea:

- for some languages, you'll need to configure Idea, e.g. golang - https://github.com/go-lang-plugin-org/go-lang-idea-plugin/wiki/Documentation
- https://www.jetbrains.com/help/idea/2016.1/rerunning-tests.html

Sublime Text:

- ruby - https://github.com/maltize/sublime-text-2-ruby-tests
- python - https://damnwidget.github.io/anaconda/tests_runner/
- scala - https://github.com/jarhart/SublimeSBT

Atom:

- ruby - https://github.com/moxley/atom-ruby-test
- elixir - https://github.com/indiejames/atom-iex
- (many) - https://atom.io/packages/script
- http://brendankemp.com/essays/atom-is-ready-to-be-your-editor/

## 3. Terminal emulator

| Editor                    | Terminal emulator                          |
| ------------------------- | ------------------------------------------ |
| Vim                       | no                                         |
| ------------------------- | ------------------------------------------ |
| Neovim                    | yes                                        |
| ------------------------- | ------------------------------------------ |
| Emacs                     | yes                                        |
| ------------------------- | ------------------------------------------ |
| Idea                      | yes                                        |
| ------------------------- | ------------------------------------------ |
| Sublime Text              | yes                                        |
| ------------------------- | ------------------------------------------ |
| Atom                      | yes                                        |


*Note on terminal text editors*

You can easily switch to the actual terminal using Ctrl + z (this will suspend
the editor) and get back by entering fg. However, I would say that it is not
the same as having a terminal emulator running in an editor's window below. The
reason is simple - context. Most often, **you'll want to look at the output of
some command and the code at the same time**. For example, seeing an error's
stack trace and the code at the same time is far better than performing these
actions in turn (you could easily forget the exact line number or some other
detail).

If you don't want to type fg, there is a hack:

zsh: https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh

fish:
```
bind \ck 'if test -z (commandline) ; fg %; else ; clear; commandline ""; end'
```

Another advantage of having a terminal emulator: copy-pasting between the
terminal emulator and your code is much easier, and you **get completion in the
code for things in the terminal** (thanks to
[somebodddy](https://www.reddit.com/user/somebodddy)).

Sublime Text: https://packagecontrol.io/packages/Terminal

Atom: https://atom.io/packages/term3

## 4. Go to definition

| Editor       | Mapping                                                 |
| ------------ | ------------------------------------------------------- |
| Vim          | Ctrl + ] / Ctrl - T using ctags                         |
| ------------ | ------------------------------------------------------- |
| Emacs        | M-. / M-* using ctags                                   |
| ------------ | ------------------------------------------------------- |
| Idea         | Ctrl + B or Ctrl + click / Ctrl + Tab                   |
| ------------ | ------------------------------------------------------- |
| Sublime Text | Ctrl + click / Ctrl + right click                       |
| ------------ | ------------------------------------------------------- |
| Atom         | Ctrl + Alt + down / Ctrl + Alt + up                     |


Emacs:

- https://www.emacswiki.org/emacs/EmacsTags
- https://github.com/jacktasia/dumb-jump (uses `ag`)

Sublime Text: https://gist.github.com/kendellfab/6135193#gistcomment-1768760

Atom: https://github.com/atom/symbols-view

Generating tags using git hooks: http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html

## 5. REPL (Advanced)

If you have a REPL alongside the editor - excellent! You can eval some code or
lookup some documentation (http://tonsky.me/blog/interactive-development/).

| Editor       | REPL                                                    |
| ------------ | ------------------------------------------------------- |
| Vim          | yes (few languages)                                     |
| ------------ | ------------------------------------------------------- |
| Neovim       | yes (many languages)                                    |
| ------------ | ------------------------------------------------------- |
| Emacs        | yes (many languages)                                    |
| ------------ | ------------------------------------------------------- |
| Idea         | yes (many languages)                                    |
| ------------ | ------------------------------------------------------- |
| Sublime Text | yes (many languages)                                    |
| ------------ | ------------------------------------------------------- |
| Atom         | yes (few languages)                                     |

Vim:

- clojure: https://github.com/tpope/vim-fireplace

If language has a command-line REPL, you can always execute: `:!<repl>` (e.g. `:!irb`).

Neovim: https://github.com/kassio/neoterm

Emacs:

- ruby - https://github.com/dgutov/robe
- scala - https://github.com/ensime/ensime-emacs
- clojure - https://github.com/clojure-emacs/cider

Idea:

- clojure - https://cursive-ide.com/

Sublime Text: https://packagecontrol.io/packages/SublimeREPL

Atom:

- clojure - https://atom.io/packages/proto-repl
- haskell - https://atom.io/packages/ide-haskell-repl

## The end list

1. Fast switching between the last two files
2. Running tests without leaving the editor
3. Terminal emulator
4. Go to definition
5. REPL (Advanced)

3 and 5 could be alternatively solved using a terminal multiplexer. For
example, my favorite https://tmux.github.io/ .

## Bonus

1) Do not repeat yourself ("." in Vim, macros [atom - https://atom.io/packages/atom-keyboard-macros])

2) Operate on objects: blocks, functions, etc., not individual characters (motions and text objects https://github.com/kana/vim-textobj-user/wiki in Vim)

3) Quickly navigate through code using AceJump-like plugins

- vim - https://github.com/easymotion/vim-easymotion
- idea - https://github.com/johnlindquist/AceJump
- emacs - https://github.com/abo-abo/avy
- sublime text - https://packagecontrol.io/packages/EasyMotion
- atom - https://atom.io/packages/jumpy

My current use of `vim-easymotion` reduced to only one https://git.io/vrzAE
mapping that allows me to jump to any location in the current file. Simple and
effective!

4) Use multiple selection/cursors

- vim - https://github.com/terryma/vim-multiple-cursors
- idea - F6 and the rest
- emacs - https://github.com/magnars/multiple-cursors.el
- sublime text - Ctrl + D
- atom - Ctrl + D

5) Open files using fuzzy search

- vim - https://github.com/junegunn/fzf.vim
- idea - Shift + Ctrl + O (https://www.jetbrains.com/help/idea/2016.1/navigating-to-class-file-or-symbol-by-name.html)
- emacs - https://github.com/bbatsov/projectile
- sublime text - Ctrl + P (http://docs.sublimetext.info/en/latest/file_management/file_management.html)
- atom - https://github.com/atom/fuzzy-finder

## Conclusion

As you can see, each of the editors does the job. Some slightly better, others
- a little worse.

Another finding: Vim is best suited for polyglot developers
(http://searchsoftwarequality.techtarget.com/definition/polyglot-programming)
because it provides plugins and unified interface for multiple languages. Emacs
offers more power, but you need to configure all the packages to make mappings
the same. It may be a good idea for Spacemacs, is it?

Useful links:

- https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
- https://danielmiessler.com/blog/enhancements-to-shell-and-vim-productivity/

Did I miss something? You can leave a comment or send me an email.
