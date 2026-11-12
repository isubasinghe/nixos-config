-- Git.
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
    },
    config = true
  },
  { 'tpope/vim-fugitive' },
  { 'airblade/vim-gitgutter' },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  { 'FabijanZulj/blame.nvim', opts= { virtual_style = "float" }, },
}
