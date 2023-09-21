{pkgs,...}: 
{
  programs.nixvim = {
    enable = true;
    colorschemes.rose-pine.enable = true;
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          ccls.enable = true;
          gopls.enable = true;
          hls.enable = true;
          pyright.enable = true;
          texlab.enable = true;
          tsserver.enable = true;
        };
      };
      gitgutter = {
        enable = true;
      };
      harpoon = {
        enable = true;
      };
      indent-blankline = {
        enable = true;
      };
      neo-tree = {
        enable = true;
      };
      neogit = {
        enable = true;
      };
      rust-tools = {
        enable = true;
      };
      treesitter = {
        enable = true;
      };
      lualine = {
        enable = true;
      };
    };
  };
}
