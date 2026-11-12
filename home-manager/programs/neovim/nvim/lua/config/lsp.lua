-- Shared LSP setup: the on_attach function and the client capabilities.
-- Used by lua/plugins/lsp.lua for all servers, and for metals.
local M = {}

function M.on_attach(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  local function lsp_map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, {
      buffer = bufnr,
      noremap = true,
      silent = true,
      desc = desc,
    })
  end

  lsp_map('gD', vim.lsp.buf.declaration, 'Go to declaration')
  lsp_map('gd', vim.lsp.buf.definition, 'Go to definition')
  lsp_map('K', vim.lsp.buf.hover, 'Show hover documentation')
  lsp_map('<C-space>', vim.lsp.buf.hover, 'Show hover documentation')
  lsp_map('gi', vim.lsp.buf.implementation, 'Go to implementation')
  lsp_map('<C-k>', vim.lsp.buf.signature_help, 'Show signature help')
  lsp_map('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
  lsp_map('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
  lsp_map('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'List workspace folders')
  lsp_map('<leader>D', vim.lsp.buf.type_definition, 'Go to type definition')
  lsp_map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  lsp_map('gr', vim.lsp.buf.references, 'List references')
  lsp_map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
  lsp_map('<leader>a', vim.lsp.buf.code_action, 'Code action')
  lsp_map('<leader>e', vim.diagnostic.open_float, 'Show line diagnostics')
  lsp_map('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
  lsp_map(']d', vim.diagnostic.goto_next, 'Next diagnostic')
  lsp_map('<leader>q', vim.diagnostic.setloclist, 'Diagnostics to location list')
  lsp_map('<leader>sy', function()
    require('telescope.builtin').lsp_document_symbols()
  end, 'Search document symbols')
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format({ async = true })
  end, { desc = 'Format current buffer with LSP' })
end

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  return require('cmp_nvim_lsp').default_capabilities(capabilities)
end

return M
