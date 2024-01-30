My attempt at migrating to vim, wish me luck (Forked from LazyVim)

## Installation
```
$ cd ~
$ git clone https://github.com/samdavidge/.vim.git
$ rm -rf ~/.config/nvim
$ ln -s ~/.vim ~/.config/nvim
$ nvim
```

Be sure to run `:checkhealth` to identify any dependency issues (node, python, php, etc)

## Keymaps

| key             | Description                     |
|-----------------|---------------------------------|
| space + \       | Jump to Neeotree                |
| space + /       | Live Grep                       |
| space + space   | Files Search                    |
| space + s       | Git Status                      |
| alt + Left      | Previous Buffer                 |
| alt + Right     | Next Buffer                     |
| ctl + c         | Close Buffer                    |

## DAP Notes 

### xdebug

#### Initial setup - xdebug

I have only tested this with xdebug installed in docker. I won't cover the xdebug instalation here, but here is an example `xdebug.ini`:

```
[XDebug]
zend_extension = xdebug.so
xdebug.mode = develop,debug,coverage
xdebug.start_with_request = yes
xdebug.discover_client_host = true
xdebug.idekey = VIM
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
```

This setup assumes a path mapping of `/var/www/html` in your container, but you can add mappings in `plugins/dap.lua`.

#### Initial setup - vscode-php-debug

You'll need to install vscode-php-debug (https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#PHP) on your machine.

I opted to install it in `~/Dap`, if you want to put it somewhere else, you'll need to update `plugins/dap.lua` .

#### Debugging

In order to start your debugging session you will need to run `<leader>dc`.

To toggle a breakpoint, run `<leader>db`

Then simply execute your code and feel the joy!

You can see the full list of key binds here (see keys in the fullspec tab): https://www.lazyvim.org/extras/dap/core#nvim-dap


