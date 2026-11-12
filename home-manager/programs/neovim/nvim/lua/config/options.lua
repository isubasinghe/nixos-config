-- Options and globals. These must be set before lazy.nvim loads the plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.lean_config = {
  abbreviations = { builtin = true },
  mappings = true,
}

vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1

-- vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.smartindent = false
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.background = 'dark'
vim.opt.mouse = 'a'
vim.opt.completeopt = 'menuone,noselect'
vim.opt.syntax = 'on'
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.signcolumn = "yes:1"
vim.opt.numberwidth = 4

-- Full virtual_lines can leave stale rows in split redraws during fast scrolls.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
})
