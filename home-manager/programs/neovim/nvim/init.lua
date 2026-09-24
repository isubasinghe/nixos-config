vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- vim.opt.number = true
vim.opt.termguicolors=true
vim.opt.expandtab=true
vim.opt.tabstop=2
vim.opt.smartindent=false
vim.opt.shiftwidth=2
vim.opt.softtabstop=2
vim.opt.background='dark'
vim.opt.mouse = 'a'
vim.opt.completeopt='menuone,noselect'
vim.opt.syntax='on'
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.signcolumn = "yes:1"
vim.opt.numberwidth = 4

require("lazy").setup({
  { 'rose-pine/neovim', name='rose-pine' },
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
  { 'nvim-treesitter/nvim-treesitter', branch="main", build=":TSUpdate" },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/vim-vsnip' },
  { 'kyazdani42/nvim-web-devicons' },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
    },
    config = true
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {"ellisonleao/glow.nvim", config = true, cmd = "Glow"},
  { 'sbdchd/neoformat' },
  { 'b3nj5m1n/kommentary' },
  { 'herringtondarkholme/yats.vim' },
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
    'mrcjkb/haskell-tools.nvim',
    version = '^3', -- Recommended
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  { 'fatih/vim-go' },
  { 'lervag/vimtex' },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {'kyazdani42/nvim-web-devicons', opt = true}
  },
  { "lukas-reineke/indent-blankline.nvim" },
  { 'FabijanZulj/blame.nvim', opts= { virtual_style = "float" }, },
  {'junegunn/fzf' },
  {  'junegunn/fzf.vim' },
  { 'nvim-focus/focus.nvim', version = '*' },
  { 'ThePrimeagen/harpoon', dependencies = 'nvim-lua/plenary.nvim' },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      local function open_dapui()
        dapui.open()
      end

      local function close_dapui()
        dapui.close()
      end

      dap.listeners.after.event_initialized["dapui_config"] = open_dapui
      dap.listeners.before.event_terminated["dapui_config"] = close_dapui
      dap.listeners.before.event_exited["dapui_config"] = close_dapui

      dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
          detached = true,
        },
        options = {
          initialize_timeout_sec = 20,
        },
      }

      dap.adapters.rust = {
        type = "executable",
        command = "rust-gdb",
        args = { "--interpreter=dap" },
      }

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug file",
          request = "launch",
          program = "${file}",
        },
        {
          type = "go",
          name = "Debug package",
          request = "launch",
          program = "${workspaceFolder}",
        },
        {
          type = "go",
          name = "Debug test",
          request = "launch",
          mode = "test",
          program = "${file}",
        },
      }

      local function rust_program()
        return vim.fn.input(
          "Path to Rust executable: ",
          vim.fn.getcwd() .. "/target/debug/",
          "file"
        )
      end

      dap.configurations.rust = {
        {
          type = "rust",
          name = "Debug executable",
          request = "launch",
          program = rust_program,
          cwd = "${workspaceFolder}",
        },
        {
          type = "rust",
          name = "Debug test binary",
          request = "launch",
          program = rust_program,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
  { 'tpope/vim-fugitive' },
  { 'airblade/vim-gitgutter' },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },

  { 'kvrohit/rasmus.nvim' },
  {
      url = "https://codeberg.org/andyg/leap.nvim",
  },
  { 'Everblush/everblush.nvim', name = 'everblush' },
  { 'Julian/lean.nvim' },
  {'ShinKage/idris2-nvim', dependencies = {'neovim/nvim-lspconfig', 'MunifTanjim/nui.nvim'}},
  { 'arkav/lualine-lsp-progress' },
  { 'kartikp10/noctis.nvim', dependencies = { 'rktjmp/lush.nvim' } },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
      dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { 'RRethy/vim-illuminate' },
  {
   "m4xshen/hardtime.nvim",
   dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
   opts = {}
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
  },
  {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    }
  },
  { "mfussenegger/nvim-lint" },
  {
    "susliko/tla.nvim",
    config = function ()
      require("tla").setup()
    end
  },
  {'florentc/vim-tla'},
  {
    'scalameta/nvim-metals',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = { 'scala', 'sbt', 'java' },
  },
  --[[ {
    'cordx56/rustowl',
    version = '*', -- Latest stable version
    build = 'cargo install rustowl',
    lazy = false, -- This plugin is already lazy
    opts = {
      auto_enable = true,
    },
  } ]]
})

require('lint').linters_by_ft = {
  go = {'revive'},
  sql = {'sqlfluff'},
  yaml = {'yamllint'},
  json = {'jsonlint'}
}


local telescope = require('telescope')
telescope.setup{
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

-- Full virtual_lines can leave stale rows in split redraws during fast scrolls.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
})

vim.g.go_highlight_functions=1
vim.g.go_highlight_function_calls=1

require'lualine'.setup{
  sections = {
		lualine_c = {
			'lsp_progress'
		}
	}
}

vim.cmd[[colorscheme rose-pine]]
vim.cmd[[highlight LineNr ctermfg=Grey guifg=Grey]]

-- Parsers are installed via :TSInstall or the build step in the lazy spec.
-- Run :TSInstall tlaplus go haskell rust javascript typescript agda bash bibtex capnp css devicetree llvm latex ledger lua make nix proto
-- to install any missing parsers.


local other_on_attach = function(_, bufnr)
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

local cmp = require'cmp'

cmp.setup({
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-c>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = function(fallback)
        if cmp.visible() then 
          cmp.select_next_item()
        else 
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then 
          cmp.select_prev_item()
        else 
          fallback()
        end
      end,
    },
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'orgmode' },

      -- For vsnip user.
      -- { name = 'vsnip' },

      -- For luasnip user.
      -- { name = 'luasnip' },

      -- For ultisnips user.
      -- { name = 'ultisnips' },

      { name = 'buffer' },
    }
})


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = {'ocamllsp', 'ts_ls', 'pyright', 'texlab', 'gopls', 'terraformls', 'zls', 'verible', 'nixd', 'ccls', 'rust_analyzer', 'idris2_lsp', 'leanls'}

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = other_on_attach,
    capabilities = capabilities,
  }
  if lsp == 'gopls' then
    config.settings = {
      gopls = {
        buildFlags = { "-tags=integration" }
      }
    }
  end
  vim.lsp.config(lsp, config)
end

vim.lsp.enable(servers)

local metals_config = require("metals").bare_config()
metals_config.capabilities = capabilities
metals_config.on_attach = other_on_attach
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function() require("metals").initialize_or_attach(metals_config) end,
})


-- Idris2 
require('idris2').setup({})

require('lean').setup{
  abbreviations = { builtin = true },
  mappings = true,
}


vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

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

require('kommentary.config').use_extended_mappings()

local map_opts = { silent = true, noremap = true }
local function normal_map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', map_opts, { desc = desc }))
end

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

local dap = require('dap')
local dapui = require('dapui')
normal_map('<leader>db', dap.toggle_breakpoint, 'Toggle breakpoint')
normal_map('<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, 'Set conditional breakpoint')
normal_map('<leader>dc', dap.continue, 'Continue debugging')
normal_map('<leader>di', dap.step_into, 'Step into')
normal_map('<leader>do', dap.step_over, 'Step over')
normal_map('<leader>dO', dap.step_out, 'Step out')
normal_map('<leader>dp', dap.pause, 'Pause debugging')
normal_map('<leader>dr', dap.restart, 'Restart debugging')
normal_map('<leader>dt', dap.terminate, 'Terminate debugging')
normal_map('<leader>du', dapui.toggle, 'Toggle debugger UI')
normal_map('<leader>dd', dapui.toggle, 'Toggle debugger UI')
vim.keymap.set('x', '<leader>de', dapui.eval, vim.tbl_extend('force', map_opts, {
  desc = 'Evaluate selection',
}))
normal_map('<leader>de', dapui.eval, 'Evaluate expression')

-- Keep the original debugger shortcuts as aliases.
normal_map('<leader>br', dap.toggle_breakpoint, 'Toggle breakpoint')
normal_map('<leader>cn', dap.continue, 'Continue debugging')
normal_map('<leader>so', dap.step_over, 'Step over')
normal_map('<leader>si', dap.step_into, 'Step into')

normal_map('<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Diagnostics (Trouble)')
normal_map('<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', 'Workspace diagnostics (Trouble)')
normal_map('<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Buffer diagnostics (Trouble)')
normal_map('<leader>xl', '<cmd>Trouble loclist toggle<cr>', 'Location list (Trouble)')
normal_map('<leader>xq', '<cmd>Trouble qflist toggle<cr>', 'Quickfix list (Trouble)')
normal_map('gR', '<cmd>Trouble lsp_references toggle<cr>', 'References (Trouble)')



vim.api.nvim_exec([[autocmd FileType haskell nnoremap <buffer> <space>fm :Neoformat! haskell ormolu<cr>]], false)
vim.api.nvim_exec([[autocmd FileType go nnoremap <buffer> <space>fm :Neoformat! go gofumpt<cr>]], false)
vim.api.nvim_exec([[autocmd FileType c nnoremap <buffer> <space>fm :Neoformat! c clang-format<cr>]], false)
vim.api.nvim_exec([[autocmd FileType rust nnoremap <buffer> <space>fm :Neoformat! rust rustfmt<cr>]], false)
vim.api.nvim_exec([[au BufRead,BufNewFile *.cwl setfiletype yaml]], false)
vim.api.nvim_exec([[au BufWritePost * lua require('lint').try_lint()]], false)
