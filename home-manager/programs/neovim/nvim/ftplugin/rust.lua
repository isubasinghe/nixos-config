-- Rust specific config 
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(param0, bufnr)
      other_on_attach(param0, bufnr)

      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
    capabilities = capabilities,
  },
})
