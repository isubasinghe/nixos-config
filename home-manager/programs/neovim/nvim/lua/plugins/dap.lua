-- Debugger (nvim-dap): adapters, launch configurations and keymaps.
return {
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

      -- GDB 14+ has a built-in DAP server. Used for C and C++.
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      -- debugpy comes from the Nix python3 environment (packages/dev-tools.nix).
      -- Prefer that interpreter, because a virtualenv python3 usually has no debugpy.
      local nix_python = vim.fn.expand("~/.nix-profile/bin/python3")
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.executable(nix_python) == 1 and nix_python or "python3",
        args = { "-m", "debugpy.adapter" },
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

      local function c_program()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end

      dap.configurations.c = {
        {
          type = "gdb",
          name = "Debug executable",
          request = "launch",
          program = c_program,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          type = "gdb",
          name = "Attach to process",
          request = "attach",
          pid = function()
            return require("dap.utils").pick_process()
          end,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = dap.configurations.c

      dap.configurations.python = {
        {
          type = "python",
          name = "Debug file",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          -- Run the program with the active virtualenv, if there is one.
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
              return venv .. "/bin/python"
            end
            return vim.fn.exepath("python3")
          end,
        },
      }

      -- The "scala" adapter is registered by metals.setup_dap() on attach.
      dap.configurations.scala = {
        {
          type = "scala",
          name = "Run or test file",
          request = "launch",
          metals = { runType = "runOrTestFile" },
        },
        {
          type = "scala",
          name = "Test target",
          request = "launch",
          metals = { runType = "testTarget" },
        },
      }

      local map_opts = { silent = true, noremap = true }
      local function normal_map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', map_opts, { desc = desc }))
      end

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
    end,
  },
}
