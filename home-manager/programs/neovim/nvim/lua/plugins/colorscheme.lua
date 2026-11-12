-- Colorschemes. rose-pine is the active one.
return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd[[colorscheme rose-pine]]
      vim.cmd[[highlight LineNr ctermfg=Grey guifg=Grey]]
    end,
  },
  { 'kvrohit/rasmus.nvim' },
  { 'Everblush/everblush.nvim', name = 'everblush' },
  { 'kartikp10/noctis.nvim', dependencies = { 'rktjmp/lush.nvim' } },
}
