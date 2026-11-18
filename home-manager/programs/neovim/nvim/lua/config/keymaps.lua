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
normal_map('<leader>ha', function()
  require('harpoon.mark').add_file()
end, 'Add file to Harpoon')
normal_map('<leader>hc', function()
  require('harpoon.mark').clear_all()
end, 'Clear Harpoon marks')
normal_map('<leader>hm', function()
  require('harpoon.ui').toggle_quick_menu()
end, 'Open Harpoon menu')
-- Programs in a terminal buffer. One buffer is kept for each program: the
-- keymap goes back to it if the program is in operation. When the program
-- stops, its buffer is deleted.
local term_bufs = {}
local function toggle_term_buf(cmd)
  local key = table.concat(cmd, ' ')
  local buf = term_bufs[key]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd.enew()
    buf = vim.api.nvim_get_current_buf()
    term_bufs[key] = buf
    vim.fn.jobstart(cmd, {
      term = true,
      on_exit = function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end,
    })
  end
  vim.cmd.startinsert()
end

-- "cha -V" opens the home page from the Chawan config.
normal_map('<leader>bw', function()
  toggle_term_buf({ 'cha', '-V' })
end, 'Open web browser (cha)')
-- neomutt reads the local Maildir. "hm-sync" in a shell gets new mail.
normal_map('<leader>be', function()
  toggle_term_buf({ 'neomutt' })
end, 'Open email (neomutt)')
-- newsboat opens links in cha, in the same terminal buffer.
normal_map('<leader>bf', function()
  toggle_term_buf({ 'newsboat' })
end, 'Open RSS feeds (newsboat)')
normal_map('<leader>bi', function()
  toggle_term_buf({ 'weechat' })
end, 'Open IRC (weechat)')

-- Short key to go from terminal mode to normal mode. The program in the
-- terminal continues. The default key is <C-\><C-n>.
vim.keymap.set('t', '<C-Space>', '<C-\\><C-n>', { silent = true, noremap = true, desc = 'Go to normal mode' })

normal_map('<leader>fd', '<cmd>FZF<cr>', 'Open FZF')

normal_map('<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Diagnostics (Trouble)')
normal_map('<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', 'Workspace diagnostics (Trouble)')
normal_map('<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Buffer diagnostics (Trouble)')
normal_map('<leader>xl', '<cmd>Trouble loclist toggle<cr>', 'Location list (Trouble)')
normal_map('<leader>xq', '<cmd>Trouble qflist toggle<cr>', 'Quickfix list (Trouble)')
normal_map('gR', '<cmd>Trouble lsp_references toggle<cr>', 'References (Trouble)')
