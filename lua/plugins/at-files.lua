return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.providers = opts.sources.providers or {}

    opts.sources.providers["at-files"] = {
      name = "AtFiles",
      module = "at-files",
      score_offset = 100, -- surface above other sources when @ triggers
    }

    -- Always include at-files so its trigger character (@) is registered.
    -- The source module itself gates on buffer type, so it returns nothing
    -- in non-target buffers.
    local original_default = opts.sources.default
    opts.sources.default = function(ctx)
      local base
      if type(original_default) == "function" then
        base = original_default(ctx)
      elseif type(original_default) == "table" then
        base = vim.deepcopy(original_default)
      else
        base = { "lsp", "path", "snippets", "buffer" }
      end
      table.insert(base, 1, "at-files")
      return base
    end

    return opts
  end,
}
