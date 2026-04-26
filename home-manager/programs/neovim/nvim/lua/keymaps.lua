local map = function(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true })
end

-- Leap
map({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
map('n', 'S', '<Plug>(leap-from-window)')

-- File navigation
map('', '<space>ff', ':NvimTreeToggle<cr>')
map('', '<space>fd', ':FZF<cr>')

-- Git
map('', '<space>gg', ':Neogit<cr>')

-- Build
map('', '<space>mk', ':Neomake!<cr>')

-- Buffers
map('', '<space>bp', ':bp<cr>')
map('', '<space>bn', ':bn<cr>')

-- Search and replace
map('', '<space>rl', ':s/')
map('', '<space>rg', ':%s/')

-- DAP
map('', '<space>dd', ':lua require("dapui").toggle()<cr>')
map('', '<leader>br', ':lua require("dap").toggle_breakpoint()<cr>')
map('', '<leader>cn', ':lua require("dap").continue()<cr>')
map('', '<leader>so', ':lua require("dap").step_over()<cr>')
map('', '<leader>si', ':lua require("dap").step_into()<cr>')

-- Trouble
map('', '<space>xx', '<cmd>Trouble<cr>')
map('', '<space>xw', '<cmd>Trouble lsp_workspace_diagnostics<cr>')
map('', '<space>xd', '<cmd>Trouble lsp_document_diagnostics<cr>')
map('', '<space>xl', '<cmd>Trouble loclist<cr>')
map('', '<space>xq', '<cmd>Trouble quickfix<cr>')
map('', 'gR', '<cmd>Trouble lsp_references<cr>')

-- Harpoon
map('', '<space>bk', ':lua require("harpoon.mark").add_file()<cr>')
map('', '<space>bkc', ':lua require("harpoon.mark").clear_all()<cr>')
map('', '<space>bm', ':lua require("harpoon.ui").toggle_quick_menu()<cr>')
