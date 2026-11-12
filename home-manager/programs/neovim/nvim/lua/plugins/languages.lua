-- Language plugins that are not language servers.
return {
  { 'herringtondarkholme/yats.vim' },
  { 'fatih/vim-go' },
  { 'lervag/vimtex' },
  {
    "susliko/tla.nvim",
    config = function ()
      require("tla").setup {
        java_executable = vim.fn.exepath("java"),
      }
    end
  },
  {'florentc/vim-tla'},
}
