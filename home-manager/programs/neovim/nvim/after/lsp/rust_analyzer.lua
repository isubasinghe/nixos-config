-- rust-analyzer can panic on didSave while its VFS is still loading:
-- FileSourceRootInput is missing for a newly opened file. Replay saves once
-- serverStatus reports that workspace loading has finished.
return {
  capabilities = { experimental = { serverStatusNotification = true } },
  on_init = function(client)
    local ready = false
    local pending = {}
    local notify = client.notify
    local status_handler = client.handlers['experimental/serverStatus']
      or vim.lsp.handlers['experimental/serverStatus']

    client.notify = function(self, method, params, bufnr)
      if method == 'textDocument/didSave' and not ready then
        pending[params.textDocument.uri] = { params = params, bufnr = bufnr }
        return true
      end
      if method == 'textDocument/didClose' then
        pending[params.textDocument.uri] = nil
      end
      return notify(self, method, params, bufnr)
    end

    client.handlers['experimental/serverStatus'] = function(err, result, ctx, config)
      if not err and result then
        ready = result.quiescent == true
        if ready then
          local saved = pending
          pending = {}
          for _, item in pairs(saved) do
            notify(client, 'textDocument/didSave', item.params, item.bufnr)
          end
        end
      end
      if status_handler then
        return status_handler(err, result, ctx, config)
      end
    end
  end,
}
