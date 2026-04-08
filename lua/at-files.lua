-- blink.cmp source: completes file paths when typing @query
-- Activates only in markdown files and anonymous/scratch buffers.
local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
  return { "@" }
end

local function to_fuzzy_pattern(query)
  local chars = {}
  for i = 1, #query do
    -- Escape regex metacharacters in each character
    chars[i] = query:sub(i, i):gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
  end
  return table.concat(chars, ".*")
end

local function find_paths(query)
  if vim.fn.executable("fd") == 1 then
    local pattern = query ~= "" and vim.fn.shellescape(to_fuzzy_pattern(query)) or "."
    local flag = query ~= "" and "-i " or ""
    return vim.fn.systemlist("fd --max-results 5 " .. flag .. pattern)
  elseif vim.fn.executable("rg") == 1 then
    local filter = query ~= "" and (" | grep -iE " .. vim.fn.shellescape(to_fuzzy_pattern(query))) or ""
    return vim.fn.systemlist("rg --files 2>/dev/null" .. filter .. " | head -5")
  else
    local filter = query ~= "" and (" | grep -iE " .. vim.fn.shellescape(to_fuzzy_pattern(query))) or ""
    return vim.fn.systemlist("find . 2>/dev/null" .. filter .. " | head -5")
  end
end

function M:get_completions(ctx, callback)
  local bufnr = ctx.bufnr
  local ft = vim.bo[bufnr].filetype
  local name = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype

  local is_target = ft == "markdown" or name == "" or (buftype ~= "" and buftype ~= "terminal")
  if not is_target then
    return callback({ items = {}, is_incomplete_backward = false, is_incomplete_forward = false })
  end

  -- ctx.cursor is {row (1-indexed), col (0-indexed byte offset)}
  local line_before = ctx.line:sub(1, ctx.cursor[2])
  local query = line_before:match("@([^%s@]*)$")
  if query == nil then
    return callback({ items = {}, is_incomplete_backward = false, is_incomplete_forward = false })
  end

  -- @ sits at (cursor_col - #query - 1), 0-indexed
  local at_col = ctx.cursor[2] - #query - 1
  local cursor_row = ctx.cursor[1] - 1 -- LSP lines are 0-indexed
  local cursor_col = ctx.cursor[2]

  local paths = find_paths(query)

  local items = {}
  for _, path in ipairs(paths) do
    local abs = vim.fn.fnamemodify(path, ":p")
    local tail = vim.fn.fnamemodify(path, ":t")
    if tail == "" then goto continue end
    local dir = vim.fn.fnamemodify(path, ":~:.:h")
    local is_dir = vim.fn.isdirectory(abs) == 1

    table.insert(items, {
      label = tail,
      kind = is_dir and 19 or 17, -- 19 = Folder, 17 = File
      labelDetails = { description = dir ~= "." and dir or "" },
      filterText = "@" .. tail,
      textEdit = {
        newText = "@" .. abs,
        range = {
          start = { line = cursor_row, character = at_col },
          ["end"] = { line = cursor_row, character = cursor_col },
        },
      },
    })
    ::continue::
  end

  callback({
    items = items,
    is_incomplete_backward = false,
    is_incomplete_forward = true, -- re-query as user types more
  })
end

return M
