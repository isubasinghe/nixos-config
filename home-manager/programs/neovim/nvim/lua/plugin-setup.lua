require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
      },
    },
  },
})

require('lualine').setup({
  sections = {
    lualine_c = { 'lsp_progress' },
  },
})

require('nvim-web-devicons').setup({
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      name = "Zsh",
    },
  },
  default = true,
})

require('kommentary.config').use_extended_mappings()

require('lint').linters_by_ft = {
  go = { 'revive' },
  sql = { 'sqlfluff' },
  yaml = { 'yamllint' },
  json = { 'jsonlint' },
}
