-- Language servers. The shared on_attach function and the capabilities are in
-- lua/config/lsp.lua.
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local lsp = require('config.lsp')
      local capabilities = lsp.capabilities()

      local servers = {'ocamllsp', 'ts_ls', 'pyright', 'texlab', 'gopls', 'terraformls', 'zls', 'verible', 'nixd', 'ccls', 'rust_analyzer', 'idris2_lsp', 'leanls'}

      for _, server in ipairs(servers) do
        local config = {
          on_attach = lsp.on_attach,
          capabilities = capabilities,
        }
        if server == 'gopls' then
          config.settings = {
            gopls = {
              buildFlags = { "-tags=integration" }
            }
          }
        end
        vim.lsp.config(server, config)
      end

      vim.lsp.enable(servers)
    end,
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
  {
    'scalameta/nvim-metals',
    dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/cmp-nvim-lsp' },
    ft = { 'scala', 'sbt', 'java' },
    config = function()
      local lsp = require('config.lsp')
      local metals_config = require("metals").bare_config()
      metals_config.capabilities = lsp.capabilities()
      metals_config.on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)
        require("metals").setup_dap()
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function() require("metals").initialize_or_attach(metals_config) end,
      })
    end,
  },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3', -- Recommended
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  -- lean.nvim reads vim.g.lean_config, which is set in lua/config/options.lua.
  { 'Julian/lean.nvim' },
  {
    'ShinKage/idris2-nvim',
    dependencies = {'neovim/nvim-lspconfig', 'MunifTanjim/nui.nvim'},
    config = function()
      require('idris2').setup({})
    end,
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
}
