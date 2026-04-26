vim.cmd.colorscheme('rose-pine')
vim.cmd([[highlight LineNr ctermfg=Grey guifg=Grey]])

-- Run :TSInstall tlaplus go haskell rust javascript typescript agda bash bibtex
-- capnp css devicetree llvm latex ledger lua make nix proto
-- to install treesitter parsers.

local format_on = function(filetype, formatter)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetype,
    callback = function()
      vim.keymap.set('n', '<space>fm', ':Neoformat! ' .. filetype .. ' ' .. formatter .. '<cr>',
        { buffer = true })
    end,
  })
end

format_on('haskell', 'ormolu')
format_on('go', 'gofumpt')
format_on('c', 'clang-format')
format_on('rust', 'rustfmt')

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.cwl',
  callback = function() vim.bo.filetype = 'yaml' end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function() require('lint').try_lint() end,
})
