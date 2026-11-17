-- Interface: keymap hints, status line, icons, indent guides, window focus,
-- floating terminals.

-- One ikhal terminal for the session. When ikhal stops (key: q), the next
-- toggle starts it again.
local ikhal_term
local function toggle_ikhal()
  if not ikhal_term then
    ikhal_term = require("toggleterm.terminal").Terminal:new({
      cmd = "ikhal",
      direction = "float",
      hidden = true,
      float_opts = { border = "rounded" },
    })
  end
  ikhal_term:toggle()
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {},
    keys = {
      { "<leader>k", toggle_ikhal, desc = "Toggle calendar (ikhal)" },
    },
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
        { "<leader>", mode = { "n", "v" } },
      },
      spec = {
        { "<leader>b", group = "Buffers" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Files" },
        { "<leader>g", group = "Git" },
        { "<leader>x", group = "Diagnostics" },
      },
    },
    keys = {
      {
        "<leader>?",
        "<cmd>WhichKey <Space><cr>",
        desc = "Show keymaps",
      },
    },
  },
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require'nvim-web-devicons'.setup {
        -- your personnal icons can go here (to override)
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            name = "Zsh"
          }
        };
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true;
      }
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      {'nvim-tree/nvim-web-devicons', opt = true},
      'arkav/lualine-lsp-progress',
    },
    config = function()
      require'lualine'.setup{
        sections = {
          lualine_c = {
            'lsp_progress'
          }
        }
      }
    end,
  },
  { "lukas-reineke/indent-blankline.nvim" },
  { 'nvim-focus/focus.nvim', version = '*' },
  { 'RRethy/vim-illuminate' },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {}
  },
}
