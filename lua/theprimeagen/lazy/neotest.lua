return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            {
                "nvim-treesitter/nvim-treesitter", -- Optional, but recommended
                branch = "main",                   -- NOTE; not the master branch!
                build = function()
                    vim.cmd(":TSUpdate go")
                end,
            },
            {
                "fredrikaverpil/neotest-golang",
                version = "*",                                                              -- Optional, but recommended; track releases
                build = function()
                    vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
                end,
            },
        },
        config = function()
            local config = {
                runner = "gotestsum", -- Optional, but recommended
                dap_go_enabled = true,
                warn_test_name_dupes = false,
            }
            require("neotest").setup({
                output = { open_on_run = true },
                adapters = {
                    require("neotest-golang")(config),
                }
            })

            -- биндинги
            vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Test: run nearest" })
            vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,
                { desc = "Test: run file" })
            vim.keymap.set("n", "<leader>ts", function() require("neotest").run.run(vim.fn.getcwd()) end,
                { desc = "Test: run suite (cwd)" })
            vim.keymap.set("n", "<leader>tp", function() require("neotest").output_panel.toggle() end,
                { desc = "Test: output panel" })
            vim.keymap.set("n", "<leader>to", function()
                local nt = require("neotest"); local id = nt.run.get_last_run()
                nt.output.open({ enter = true, last_run = id ~= nil })
            end, { desc = "Test: open last output" })

            vim.keymap.set("n", "<leader>tv", function()
                require("neotest").summary.toggle()
            end, { desc = "Test: toggle summary" })

            vim.keymap.set("n", "<leader>td", function()
                require("neotest").run.run({ strategy = "dap" })
            end, { desc = "Test: debug nearest" })

            vim.api.nvim_create_user_command("NeoTestNearestDebug", function()
                local nt = require("neotest")
                local path = vim.fn.expand("%:p")
                local tree = nt.state.positions(path)
                if not tree then
                    print("no positions (treesitter didn't parse this file)")
                    return
                end
                local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-based
                local nearest

                for _, node in ipairs(tree:to_list()) do
                    -- интересуют только test / namespace (subtests и т.п.)
                    if node.type == "test" or node.type == "namespace" then
                        local r = node.range -- { start_row, start_col, end_row, end_col }
                        if r and r[1] <= row and row <= r[3] then
                            nearest = node
                            break
                        end
                    end
                end

                print(nearest and (nearest.id .. "  " .. nearest.type .. "  " .. nearest.name) or "nil")
            end, {})
        end,

    } }
