-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for CPP

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    optional = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'codelldb' })
      end
    end,
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        --'delve',
        'codelldb',
      },
    }
    if not dap.adapters['codelldb'] then
      require('dap').adapters['codelldb'] = {
        type = 'server',
        --host = 'localhost',
        port = '${port}',
        executable = {
          command = 'codelldb',
          args = {
            '--port',
            '${port}',
          },
        },
      }
    end
    for _, lang in ipairs { 'c', 'cpp' } do
      dap.configurations[lang] = {
        {
          type = 'codelldb',
          request = 'launch',
          name = 'Launch file',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'codelldb',
          request = 'launch',
          name = 'Launch file with args',
          args = function()
            local args_string = vim.fn.input 'Input arguments: '
            return vim.split(args_string, ' ')
          end,
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'codelldb',
          request = 'attach',
          name = 'Attach to process',

          -- Not sure why using process ID not working !!!
          --processId = require("dap.utils").pick_process,

          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
        },
      }
    end
    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {}
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    --icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    --controls = {
    --  icons = {
    --    pause = '⏸',
    --    play = '▶',
    --    step_into = '⏎',
    --    step_over = '⏭',
    --    step_out = '⏮',
    --    step_back = 'b',
    --    run_last = '▶▶',
    --    terminate = '⏹',
    --    disconnect = '⏏',
    --  },
    --},
    --}

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}

--{
--  'jay-babu/mason-nvim-dap.nvim',
--  dependencies = {
--    'williamboman/mason.nvim',
--    'mfussenegger/nvim-dap',
--  },
--  opts = {
--    handlers = {},
--  },
--},
