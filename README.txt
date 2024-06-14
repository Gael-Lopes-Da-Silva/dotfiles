                          Linux dotfiles
     https://github.com/Gael-Lopes-Da-Silva/MyLinuxDotfiles

Description
------------------------------------------------------------------

This is my Arch Linux dotfiles. It containes all my configurations
for my window manager, my text editor, etc. They are configured
to work on my 2 computers (one fix and one portable) but it's
not guaranteed to work right away without configuring it for your
computer.


Requirements
------------------------------------------------------------------

The following requirements my be used if you want to use my
dotfiles as I do, but you can also just take what you want from
it.

Here a simple list of what I already configured:
- i3
- picom
- polybar
- rofi
- kitty
- neovim

To use my dotfiles the following apps are required:
- git
- stow


Installation
------------------------------------------------------------------

Use the following commands to get my dotfiles. This assume that
you don't already have configurations set on you computer.

git clone --recursive https:://github.com/gael-lopes-da-silva/MyLinuxDotfiles ~/.dotfiles
cd ~/.dotfiles
stow .
