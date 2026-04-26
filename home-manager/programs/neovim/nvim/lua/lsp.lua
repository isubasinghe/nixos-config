local M = {}

M.on_attach = function(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-space>', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>sy', function()
    require('telescope.builtin').lsp_document_symbols()
  end, opts)
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format({ async = true })
  end, { desc = 'Format current buffer with LSP' })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = {
  'ocamllsp', 'ts_ls', 'pyright', 'texlab', 'gopls', 'terraformls',
  'zls', 'verible', 'nixd', 'ccls', 'rust_analyzer', 'idris2_lsp', 'leanls',
}

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = M.on_attach,
    capabilities = capabilities,
  }
  if lsp == 'gopls' then
    config.settings = {
      gopls = {
        buildFlags = { "-tags=integration" },
      },
    }
  end
  vim.lsp.config(lsp, config)
end

vim.lsp.enable(servers)

require('idris2').setup({})

require('lean').setup({
  abbreviations = { builtin = true },
  mappings = true,
})

return M
