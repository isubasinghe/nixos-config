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

require("lazy").setup({
  { 'rose-pine/neovim', name='rose-pine' },
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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
    },
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
  { 'mfussenegger/nvim-dap' },
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

vim.g.mapleader =';'
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


other_on_attach = function(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-space>', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
  -- vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>sy', function()
    require('telescope.builtin').lsp_document_symbols()
  end, opts)
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
      ['<S-Tab'] = function(fallback)
        if cmp.visible() then 
          cmp.select_next_item()
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

vim.api.nvim_set_keymap('', '<space>ff', ':NvimTreeToggle<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>gg', ':Neogit<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>mk', ':Neomake!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>dd', ':lua require("dapui").toggle()<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>rl', ':s/', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>rg', ':%s/', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>bp', ':bp<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<space>bn', ':bn<cr>', { silent = true, noremap = true })

vim.api.nvim_set_keymap('', '<leader>br', ':lua require("dap").toggle_breakpoint()<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<leader>cn', ':lua require("dap").continue()<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<leader>so', ':lua require("dap").step_over()<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('', '<leader>si', ':lua require("dap").step_into()<cr>', { silent = true, noremap = true })

vim.api.nvim_set_keymap("", "<space>xx", "<cmd>Trouble<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("", "<space>xw", "<cmd>Trouble lsp_workspace_diagnostics<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("", "<space>xd", "<cmd>Trouble lsp_document_diagnostics<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("", "<space>xl", "<cmd>Trouble loclist<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("", "<space>xq", "<cmd>Trouble quickfix<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("", "gR", "<cmd>Trouble lsp_references<cr>",
  {silent = true, noremap = true}
)

vim.api.nvim_set_keymap("", '<space>bk', ':lua require("harpoon.mark").add_file()<cr>',
  {silent = true, noremap = true}
)

vim.api.nvim_set_keymap("", '<space>bkc', ':lua require("harpoon.mark").clear_all()<cr>',
  {silent = true, noremap = true}
)

vim.api.nvim_set_keymap("", '<space>bm', ':lua require("harpoon.ui").toggle_quick_menu()<cr>',
  {silent = true, noremap = true}
)

vim.api.nvim_set_keymap("", '<space>fd', ':FZF<cr>',
  {silent = true, noremap = true}
)



vim.api.nvim_exec([[autocmd FileType haskell nnoremap <buffer> <space>fm :Neoformat! haskell ormolu<cr>]], false)
vim.api.nvim_exec([[autocmd FileType go nnoremap <buffer> <space>fm :Neoformat! go gofumpt<cr>]], false)
vim.api.nvim_exec([[autocmd FileType c nnoremap <buffer> <space>fm :Neoformat! c clang-format<cr>]], false)
vim.api.nvim_exec([[autocmd FileType rust nnoremap <buffer> <space>fm :Neoformat! rust rustfmt<cr>]], false)
vim.api.nvim_exec([[au BufRead,BufNewFile *.cwl setfiletype yaml]], false)
vim.api.nvim_exec([[au BufWritePost * lua require('lint').try_lint()]], false)
