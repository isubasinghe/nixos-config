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

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = true,
})

vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1
