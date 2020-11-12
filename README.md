# AsmQL

Simple plugin to display the assembly code of the function being currently edited in vim.

# Installation

The easiest way to install this plugin is by cloning this repository in
`~/.vim/pack/dist/start/`

## Getting started
Use `:Asm` inside the scope of a function in c to get it's assembly code in a new vertical pane. Note that you'll need the `.o` file in the same folder.

## Bugs
Executing the command outside of a function make it hang forever, you may use ctrl+c to cancel it.
