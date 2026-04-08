return {
  {
    dir = ".",
    name = "gh-copilot-integration",
    config = function()
      -- Target tmux pane/window. Change if needed (e.g. "1.2", ":.+" etc).
      local TMUX_TARGET = 3

      local LOG_FILE = vim.fn.stdpath("data") .. "/copilot-prompts.log"

      local function load_history()
        local prompts = {}
        local f = io.open(LOG_FILE, "r")
        if not f then return prompts end
        local current = {}
        local current_ts = ""
        for line in f:lines() do
          if line:match("^=== %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d ===$") then
            if #current > 0 then
              while #current > 0 and current[#current] == "" do
                table.remove(current)
              end
              table.insert(prompts, { ts = current_ts, text = table.concat(current, "\n") })
              current = {}
            end
            current_ts = line
          else
            table.insert(current, line)
          end
        end
        if #current > 0 then
          while #current > 0 and current[#current] == "" do
            table.remove(current)
          end
          table.insert(prompts, { ts = current_ts, text = table.concat(current, "\n") })
        end
        f:close()
        return prompts
      end

      local function log_prompt(prompt)
        local f = io.open(LOG_FILE, "a")
        if f then
          f:write("=== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n")
          f:write(prompt .. "\n\n")
          f:close()
        end
        -- Keep only the last 10 prompts
        local history = load_history()
        if #history > 10 then
          local trimmed = {}
          for i = #history - 9, #history do
            table.insert(trimmed, history[i])
          end
          local fw = io.open(LOG_FILE, "w")
          if fw then
            for _, p in ipairs(trimmed) do
              fw:write(p.ts .. "\n")
              fw:write(p.text .. "\n\n")
            end
            fw:close()
          end
        end
      end

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
        vim.wait(5000)

        -- Send prompt as if typed
        send_to_tmux(target, prompt, "prompt")
        vim.wait(250)
        vim.fn.system(string.format("tmux send-keys -t %q Enter", target))
      end

      -- Create a new buffer for prompt input, with file context pre-filled
      local function open_prompt_buffer(opts)
        opts = opts or {}
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
          local current_file_label = "(this is the current file)"
          if opts.start_line and opts.end_line then
            if opts.start_line == opts.end_line then
              current_file_label = "(this is the current file, line " .. opts.start_line .. " specifically)"
            else
              current_file_label = "(this is the current file, lines " .. opts.start_line .. "-" .. opts.end_line .. " specifically)"
            end
          end
          table.insert(lines, "- @" .. curfile .. "  <- " .. current_file_label)
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

        -- History cycling: <C-p> older, <C-n> newer
        local history = load_history()
        local hist_idx = 0 -- 0 = draft, 1 = most recent, 2 = second most recent, ...
        local draft_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

        local function set_buf_content(text)
          local new_lines = vim.split(text, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
          vim.api.nvim_set_option_value("modified", false, { buf = buf })
          vim.cmd("normal! gg")
        end

        vim.keymap.set("n", "<C-p>", function()
          if #history == 0 then return end
          if hist_idx == 0 then
            draft_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          end
          hist_idx = math.min(hist_idx + 1, #history)
          set_buf_content(history[#history - hist_idx + 1].text)
        end, { buffer = buf, noremap = true, desc = "Previous prompt from history" })

        vim.keymap.set("n", "<C-n>", function()
          if hist_idx == 0 then return end
          hist_idx = hist_idx - 1
          if hist_idx == 0 then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, draft_lines)
            vim.api.nvim_set_option_value("modified", false, { buf = buf })
            vim.cmd("normal! gg")
          else
            set_buf_content(history[#history - hist_idx + 1].text)
          end
        end, { buffer = buf, noremap = true, desc = "Next prompt from history" })

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

          log_prompt(prompt)
          vim.cmd("bdelete!")
        end, { buffer = buf, noremap = true, desc = "Submit prompt to copilot" })

        -- Position cursor at top for editing
        vim.cmd("normal! gg")
      end

      vim.keymap.set("n", "<leader>ai", open_prompt_buffer, { desc = "Open Copilot prompt buffer" })
      vim.keymap.set("v", "<leader>ai", function()
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end
        open_prompt_buffer({ start_line = start_line, end_line = end_line })
      end, { desc = "Open Copilot prompt buffer with selected lines" })
    end,
  },
}
