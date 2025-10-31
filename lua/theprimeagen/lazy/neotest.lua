return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-go",
    },
    config = function()
        local neotest = require("neotest")
        local neotest_go = require("neotest-go")
        local lib = require("neotest.lib")

        local match_go_root = lib.files.match_root_pattern("go.mod", "go.work", ".git")

        neotest.setup({
            level = vim.log.levels.DEBUG,
            discovery = { enabled = true },
            adapters = {
                neotest_go({
                    root = function(path)
                        return match_go_root(path) or vim.loop.cwd()
                    end,
                    recursive_run = true,
                    level = vim.log.levels.DEBUG,
                    experimental = { test_table = true },
                    args = { "-count=1", "-v" },
                }),
            },
        })

        local function run_nearest_or_file()
            local tree = neotest.run.get_tree_from_args(nil, false)
            if tree then
                neotest.run.run()
            else
                neotest.run.run(vim.fn.expand("%"))
            end
        end

        vim.keymap.set("n", "<leader>tr", run_nearest_or_file, { desc = "Test: run nearest (fallback file)" })
        vim.keymap.set("n", "<leader>td", function()
            local tree = neotest.run.get_tree_from_args(nil, false)
            if tree then
                neotest.run.run({ strategy = "dap" })
            else
                neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
            end
        end, { desc = "Test: debug nearest (fallback file)" })

        vim.keymap.set("n", "<leader>tf", function()
            neotest.run.run(vim.fn.expand("%"))
        end, { desc = "Test: run current file" })

        vim.keymap.set("n", "<leader>tF", function()
            neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
        end, { desc = "Test: debug current file" })

        vim.keymap.set("n", "<leader>ts", function()
            neotest.run.run(vim.fn.getcwd())
        end, { desc = "Test: run suite (cwd)" })

        vim.keymap.set("n", "<leader>tv", neotest.summary.toggle, { desc = "Test: toggle summary" })

        vim.keymap.set("n", "<leader>to", function()
            local position_id = neotest.run.get_last_run()
            if position_id then
                neotest.output.open({ enter = true, last_run = true })
            else
                neotest.output.open({ enter = true })
            end
        end, { desc = "Test: open last output" })
    end,
}
