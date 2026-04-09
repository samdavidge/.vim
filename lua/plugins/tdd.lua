return {
  "aaronlord/tdd.nvim",
  lazy = false,
  config = function()
    local tdd = require("tdd")

    tdd.setup({
      runners = {
        pest = {
          command = function(file, test_name)
            if test_name then
              return string.format('./vendor/bin/pest pest --stop-on-defect %s --filter "%s"', file, test_name)
            else
              return string.format("./vendor/bin/pest pest --stop-on-defect %s", file)
            end
          end,
        },
        vitest = {
          command = function(file, _, line_number)
            if line_number then
              return string.format("./vendor/bin/pest npm run test:run -- %s:%s", file, line_number)
            else
              return string.format("./vendor/bin/pest npm run test:run -- %s", file)
            end
          end,
        },
      },
    })

    vim.keymap.set("n", "<leader>tt", function()
      tdd.jump(true)
    end, { desc = "Jump to test or SUT" })

    vim.keymap.set("n", "<leader>tj", function()
      tdd.jump(false)
    end, { desc = "Goto the SUT or show all test options" })

    vim.keymap.set("n", "<leader>tr", function()
      tdd.run_test_file()
    end, { desc = "Run the current test file" })

    vim.keymap.set("n", "<leader><leader>tr", function()
      tdd.run_test()
    end, { desc = "Run the current test" })
  end,
}
