return {
  {
    dir = ".",
    name = "gh-copilot-integration",
    config = function()
      -- Target tmux pane/window. Change if needed (e.g. "1.2", ":.+" etc).
      local TMUX_TARGET = 3

      -- Check tmux availability and that we are in a tmux session
      local function tmux_available()
        if vim.fn.executable("tmux") ~= 1 then
          vim.notify("tmux not found in PATH", vim.log.levels.ERROR)
          return false
        end
        if not os.getenv("TMUX") then
          vim.notify("Not inside a tmux session", vim.log.levels.ERROR)
          return false
        end
        return true
      end

      -- Send text to tmux target via temporary buffer (preserves whitespace)
      local function send_to_tmux(target, content, buffer_name)
        if not tmux_available() then
          return
        end
        if not content or content == "" then
          return
        end

        -- Focus the pane
        vim.fn.system(string.format("tmux select-window -t %q", target))
        vim.wait(100)

        -- Write to temporary file, load into tmux buffer, and paste
        local temp_file = "/tmp/copilot_" .. (buffer_name or "content") .. "_" .. os.time()
        local f = io.open(temp_file, "w")
        if f then
          f:write(content)
          f:close()

          local buf_name = "copilot_" .. (buffer_name or "content")
          vim.fn.system(string.format("tmux load-buffer -b %q %q", buf_name, temp_file))
          vim.fn.system(string.format("tmux paste-buffer -b %q -t %q", buf_name, target))
          os.remove(temp_file)
        end
      end

      -- Check if gh copilot is already running in target pane
      local function is_copilot_running(target)
        if not tmux_available() then
          return false
        end

        local pane_pid_cmd = string.format("tmux list-panes -t %q -F '#{pane_pid}'", target)
        local pane_pid = vim.fn.system(pane_pid_cmd):gsub("\n", "")

        if not pane_pid or pane_pid == "" then
          return false
        end

        local ps_cmd = string.format("pgrep -P %s -f 'gh copilot'", vim.fn.shellescape(pane_pid))
        local result = vim.fn.system(ps_cmd)

        return result ~= "" and result:find("%d+") ~= nil
      end

      -- Send prompt to existing copilot session via stdin
      local function send_to_existing_session(target, prompt)
        send_to_tmux(target, prompt, "prompt")
        vim.wait(250)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", target))
      end

      -- Launch new copilot session, wait, then send prompt as if typed
      local function send_to_new_session(target, prompt)
        if not tmux_available() then
          return
        end

        -- Launch copilot
        local cmd = "gh copilot"
        send_to_tmux(target, cmd, "cmd")
        vim.fn.system(string.format("tmux send-keys -t %q Enter", target))

        -- Wait for copilot to initialize
        vim.wait(3000)

        -- Send prompt as if typed
        send_to_tmux(target, prompt, "prompt")
        vim.wait(250)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", target))
      end

      -- Create a new buffer for prompt input, with file context pre-filled
      local function open_prompt_buffer()
        -- Create a new scratch buffer
        local buf = vim.api.nvim_create_buf(false, true)

        local function make_rel(path)
          if path == "" then
            return nil
          end
          local rel = vim.fn.fnamemodify(path, ":.")
          return rel == path and vim.fn.fnamemodify(path, ":p") or rel
        end

        -- Build file list with current file first
        local curfile = make_rel(vim.fn.expand("%:p"))
        local seen = { [curfile] = curfile ~= nil }
        local others = {}

        for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          if b.name and b.name ~= "" then
            local rel = make_rel(b.name)
            if rel and not seen[rel] then
              seen[rel] = true
              table.insert(others, rel)
            end
          end
        end

        -- Build initial content
        local lines = { "", "", "###### Files in Context:", "" }
        if curfile then
          table.insert(lines, "- @" .. curfile .. "  <- (this is the current file)")
        end
        for _, f in ipairs(others) do
          table.insert(lines, "- @" .. f)
        end

        table.insert(lines, "")

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        vim.cmd("split")
        vim.api.nvim_win_set_buf(0, buf)

        -- Configure buffer
        vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
        vim.api.nvim_set_option_value("modified", false, { buf = buf })
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

        -- Set up 'cc' keybinding to submit
        vim.keymap.set("n", "cc", function()
          local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
          if not prompt or prompt == "" then
            return
          end

          if is_copilot_running(TMUX_TARGET) then
            send_to_existing_session(TMUX_TARGET, prompt)
          else
            send_to_new_session(TMUX_TARGET, prompt)
          end

          vim.cmd("bdelete!")
        end, { buffer = buf, noremap = true, desc = "Submit prompt to copilot" })

        -- Position cursor at top for editing
        vim.cmd("normal! gg")
      end

      vim.keymap.set("n", "<leader>ai", open_prompt_buffer, { desc = "Open Copilot prompt buffer" })
    end,
  },
}
