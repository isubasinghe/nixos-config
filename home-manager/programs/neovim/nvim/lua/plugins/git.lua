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
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        local function navigate(direction, motion)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({ motion, bang = true })
            else
              gs.nav_hunk(direction)
            end
          end
        end

        map('n', ']c', navigate('next', ']c'), 'Next Git hunk')
        map('n', '[c', navigate('prev', '[c'), 'Previous Git hunk')
        map('n', '<leader>gs', gs.stage_hunk, 'Stage or unstage hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('x', '<leader>gs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage or unstage selected lines')
        map('x', '<leader>gr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset selected lines')
        map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>gb', gs.blame_line, 'Blame current line')
        map('n', '<leader>gB', gs.blame, 'Blame buffer')
        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select Git hunk')
      end,
    },
  },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
}
