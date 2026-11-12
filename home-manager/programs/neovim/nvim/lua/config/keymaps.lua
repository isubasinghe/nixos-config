-- General keymaps. Keymaps that need a plugin module are in the plugin file:
-- debugger keymaps in lua/plugins/dap.lua, LSP keymaps in lua/config/lsp.lua.
local map_opts = { silent = true, noremap = true }
local function normal_map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', map_opts, { desc = desc }))
end

vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

normal_map('<leader>ff', '<cmd>NvimTreeToggle<cr>', 'Toggle file tree')
normal_map('<leader>gg', '<cmd>Neogit<cr>', 'Open Git client')
normal_map('<leader>mk', function()
  require('lint').try_lint()
end, 'Run linter')
normal_map('<leader>rl', ':s/', 'Search and replace on line')
normal_map('<leader>rg', ':%s/', 'Search and replace in buffer')
normal_map('<leader>bp', '<cmd>bp<cr>', 'Previous buffer')
normal_map('<leader>bn', '<cmd>bn<cr>', 'Next buffer')
normal_map('<leader>bk', function()
  require('harpoon.mark').add_file()
end, 'Add file to Harpoon')
normal_map('<leader>bkc', function()
  require('harpoon.mark').clear_all()
end, 'Clear Harpoon marks')
normal_map('<leader>bm', function()
  require('harpoon.ui').toggle_quick_menu()
end, 'Open Harpoon menu')
normal_map('<leader>fd', '<cmd>FZF<cr>', 'Open FZF')

normal_map('<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Diagnostics (Trouble)')
normal_map('<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', 'Workspace diagnostics (Trouble)')
normal_map('<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Buffer diagnostics (Trouble)')
normal_map('<leader>xl', '<cmd>Trouble loclist toggle<cr>', 'Location list (Trouble)')
normal_map('<leader>xq', '<cmd>Trouble qflist toggle<cr>', 'Quickfix list (Trouble)')
normal_map('gR', '<cmd>Trouble lsp_references toggle<cr>', 'References (Trouble)')
