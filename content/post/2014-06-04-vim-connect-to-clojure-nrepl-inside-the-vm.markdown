---
categories:
- vim
- clojure
- virtualbox
- vm
comments: true
date: 2014-06-04T12:11:45Z
title: 'Vim: Connect to Clojure nREPL inside the VM'
slug: vim-connect-to-clojure-nrepl-inside-the-vm
---

For Vim to talk to nREPL we will be using fantastic
[fireplace.vim](https://github.com/tpope/vim-fireplace) plugin. If you have
Clojure installed locally, this plugin will connect to its nREPL automatically
based on `.nrepl-port`. But if you, like me, have Clojure inside the VM
(VirtualBox or VMWare, or something else), you need to connect to its nREPL
manually using `:Connect` function.

<!--more-->

This function has the following syntax:

```vim
:Connect {proto}://{host}:{port} {path}
```

Most of the options are self-explanatory, except to say that `proto` (protocol)
is always `nrepl` and `path` is your project's location.

I am using Vagrant to manage my VMs and this one, as the rest,
configured with private network.

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "private_network", ip: "192.168.50.4"
end
```

Now we need to start nREPL inside the guest machine.

```
$> lein repl :start :host 0.0.0.0 :port 4242
```

You could omit the `:port` option, in which case leiningen will use a
random port.

One thing remains is to connect to nREPL.

```vim
:Connect nrepl://192.168.50.4:4242
```

Now you should be able to run fireplace.vim commands. Try `:Doc get` for
example.

