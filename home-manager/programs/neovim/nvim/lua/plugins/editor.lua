-- Navigation and editing: file tree, finders, motions, text objects, search.
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
    'nvim-telescope/telescope.nvim', version = '*',
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
    'nvim-mini/mini.ai',
    opts = {},
  },
  {
    'nvim-mini/mini.surround',
    opts = {
      -- Keep s/S free for Leap in Normal mode.
      mappings = {
        add = 'ys',
        delete = 'ds',
        replace = 'cs',
        find = '',
        find_left = '',
        highlight = '',
      },
    },
    config = function(_, opts)
      require('mini.surround').setup(opts)
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], {
        silent = true,
        desc = 'Surround selection',
      })
      vim.keymap.set('n', 'yss', 'ys_', { remap = true, desc = 'Surround line' })
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
    "isubasinghe/scratchmacro",
    main = "scratchmacro",
    cmd = { "ScratchMacro", "ScratchMacros" },
    opts = {},
    keys = {
      { "<leader>sm", "<cmd>ScratchMacro<cr>", desc = "Macro scratchpad" },
      { "<leader>sM", "<cmd>ScratchMacros<cr>", desc = "Macro library" },
    },
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
    config = function(_, opts)
      require("splitasm").setup(opts)
      require("config.splitasm").setup()
    end,
  },
}
