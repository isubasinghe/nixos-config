-- Autocommands.
vim.cmd([[autocmd FileType haskell nnoremap <buffer> <space>fm :Neoformat! haskell ormolu<cr>]])
vim.cmd([[autocmd FileType go nnoremap <buffer> <space>fm :Neoformat! go gofumpt<cr>]])
vim.cmd([[autocmd FileType c nnoremap <buffer> <space>fm :Neoformat! c clang-format<cr>]])
vim.cmd([[autocmd FileType rust nnoremap <buffer> <space>fm :Neoformat! rust rustfmt<cr>]])
vim.cmd([[au BufRead,BufNewFile *.cwl setfiletype yaml]])
vim.cmd([[au BufWritePost * lua require('lint').try_lint()]])
