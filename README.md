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
| alt + /         | Jump to Neeotree                |
| alt + Left      | Previous Buffer                 |
| alt + Right     | Next Buffer                     |
| space + /       | Live Grep                       |
| space + space   | Files Search                    |
