-- Navigation and editing: file tree, finders, motions, comments, search.
return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        actions = {
          open_file = {
            quit_on_open = true
          }
        }
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup{
        defaults = {
          -- Default configuration for telescope goes here:
          -- config_key = value,
          mappings = {
            i = {
              -- map actions.which_key to <C-h> (default: <C-/>)
              -- actions.which_key shows the mappings for your picker,
              -- e.g. git_{create, delete, ...}_branch for the git_branches picker
              ["<C-h>"] = "which_key"
            }
          }
        },
        pickers = {
          -- Default configuration for builtin pickers goes here:
          -- picker_name = {
          --   picker_config_key = value,
          --   ...
          -- }
          -- Now the picker_config_key will be applied every time you call this
          -- builtin picker
        },
        extensions = {
          -- Your extension configuration goes here:
          -- extension_name = {
          --   extension_config_key = value,
          -- }
          -- please take a look at the readme of the extension you want to configure
        }
      }
    end,
  },
  {'junegunn/fzf' },
  {  'junegunn/fzf.vim' },
  { 'ThePrimeagen/harpoon', dependencies = 'nvim-lua/plenary.nvim' },
  -- The keymaps for leap are in lua/config/keymaps.lua.
  {
      url = "https://codeberg.org/andyg/leap.nvim",
  },
  {
    'b3nj5m1n/kommentary',
    config = function()
      require('kommentary.config').use_extended_mappings()
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {"ellisonleao/glow.nvim", config = true, cmd = "Glow"},
  {
    "NickTsaizer/splitasm.nvim",
    cmd = {
      "SplitAsm",
      "SplitAsmOpen",
      "SplitAsmSetup",
      "SplitAsmConfig",
      "SplitAsmToggleSync",
      "SplitAsmToggleLineNumbers",
      "SplitAsmToggleHideAddress",
    },
    keys = {
      { "<leader>A", "<cmd>SplitAsmOpen<cr>", desc = "Show assembly split" },
    },
    opts = {},
  },
}
