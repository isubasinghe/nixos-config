require("lazy").setup({
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'nvim-treesitter/nvim-treesitter', branch = "main", build = ":TSUpdate" },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/vim-vsnip' },
  { 'kyazdani42/nvim-web-devicons' },
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
  { 'sbdchd/neoformat' },
  { 'b3nj5m1n/kommentary' },
  { 'herringtondarkholme/yats.vim' },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
      }
    end,
  },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  { 'fatih/vim-go' },
  { 'lervag/vimtex' },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons', opt = true },
  },
  { "lukas-reineke/indent-blankline.nvim" },
  { 'FabijanZulj/blame.nvim', opts = { virtual_style = "float" } },
  { 'junegunn/fzf' },
  { 'junegunn/fzf.vim' },
  { 'nvim-focus/focus.nvim', version = '*' },
  { 'ThePrimeagen/harpoon', dependencies = 'nvim-lua/plenary.nvim' },
  { 'mfussenegger/nvim-dap' },
  { 'tpope/vim-fugitive' },
  { 'airblade/vim-gitgutter' },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  { 'kvrohit/rasmus.nvim' },
  { url = "https://codeberg.org/andyg/leap.nvim" },
  { 'Everblush/everblush.nvim', name = 'everblush' },
  { 'Julian/lean.nvim' },
  { 'ShinKage/idris2-nvim', dependencies = { 'neovim/nvim-lspconfig', 'MunifTanjim/nui.nvim' } },
  { 'arkav/lualine-lsp-progress' },
  { 'kartikp10/noctis.nvim', dependencies = { 'rktjmp/lush.nvim' } },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  { 'RRethy/vim-illuminate' },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
  },
  {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },
  { "mfussenegger/nvim-lint" },
  {
    "susliko/tla.nvim",
    config = function()
      require("tla").setup()
    end,
  },
  { 'florentc/vim-tla' },
})
