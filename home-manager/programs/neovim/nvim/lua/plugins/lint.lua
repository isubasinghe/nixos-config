-- Linters and formatters. The autocommands that run them are in
-- lua/config/autocmds.lua.
return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      require('lint').linters_by_ft = {
        go = {'revive'},
        sql = {'sqlfluff'},
        yaml = {'yamllint'},
        json = {'jsonlint'}
      }
    end,
  },
  { 'sbdchd/neoformat' },
}
