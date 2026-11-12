-- Interface: keymap hints, status line, icons, indent guides, window focus.
return {
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
