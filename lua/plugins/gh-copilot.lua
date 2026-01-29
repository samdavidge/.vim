return {
  {
    dir = ".",
    name = "gh-copilot-integration",
    config = function()
      vim.keymap.set("n", "<leader>ai", function()
        local filepath = vim.fn.expand("%:.")
        vim.fn.system("tmux send-keys -t ai @'" .. filepath .. "' ")
      end, { desc = "Send current file path to tmux pane 2" })

      vim.keymap.set("n", "<leader>aI", function()
        local buffers = vim.fn.getbufinfo({ buflisted = 1 })
        local files = {}
        for _, buf in ipairs(buffers) do
          if buf.name ~= "" then
            local relative_path = vim.fn.fnamemodify(buf.name, ":.")
            table.insert(files, '@"' .. relative_path .. '"')
          end
        end
        local files_str = table.concat(files, " ")
        vim.fn.system("tmux send-keys -t ai '" .. files_str .. "' ")
      end, { desc = "Send all open file paths to tmux pane 2" })

      vim.api.nvim_create_user_command("Prompt", function(opts)
        local text = opts.args
        if text ~= "" then
          -- Get current file
          local current_file = vim.fn.expand("%:.")
          local current_file_abs = vim.fn.expand("%:p")

          -- Get all open buffers
          local buffers = vim.fn.getbufinfo({ buflisted = 1 })
          local other_files = {}
          for _, buf in ipairs(buffers) do
            if buf.name ~= "" and buf.name ~= current_file_abs then
              local relative_path = vim.fn.fnamemodify(buf.name, ":.")
              table.insert(other_files, '@"' .. relative_path .. '"')
            end
          end

          -- Build the command parts
          local cmd_parts = { text }
          if current_file ~= "" then
            table.insert(cmd_parts, ' this is the file I am referring to: @"' .. current_file .. '"')
          end
          if #other_files > 0 then
            table.insert(cmd_parts, " these files will also be useful: " .. table.concat(other_files, " "))
          end

          local cmd = table.concat(cmd_parts, "")
          -- Escape single quotes for shell
          cmd = cmd:gsub("'", "'\\''")

          vim.fn.system("tmux send-keys -t ai '" .. cmd .. "'")
        end
      end, { nargs = "+", desc = "Send text to AI window" })
    end,
  },
}
