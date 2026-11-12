-- Colorschemes. base16-isotope is the active one. It matches the desktop
-- scheme (nix-colors "isotope") in home-manager/profiles/common.nix.
return {
  {
    'RRethy/base16-nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd[[colorscheme base16-isotope]]
      vim.cmd[[highlight LineNr ctermfg=Grey guifg=Grey]]
    end,
  },
  { 'rose-pine/neovim', name='rose-pine' },
  -- build = false: the plugin has a rockspec, and lazy.nvim fails to build it.
  { 'nyoom-engineering/oxocarbon.nvim', build = false },
  { 'kvrohit/rasmus.nvim' },
  { 'Everblush/everblush.nvim', name = 'everblush' },
  { 'kartikp10/noctis.nvim', dependencies = { 'rktjmp/lush.nvim' } },
}
