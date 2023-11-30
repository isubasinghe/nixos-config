require('lean').setup{
  abbreviations = { builtin = true },
  lsp = { on_attach = other_on_attach },
  lsp3 = { on_attach = other_on_attach },
  mappings = true,
}
