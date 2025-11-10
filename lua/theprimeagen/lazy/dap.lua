return {
    {
        "mfussenegger/nvim-dap",
        lazy = false,
        config = function()
            local dap = require("dap")

            dap.adapters.go = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }

            local function project_root()
                return vim.fs.root(0, { "go.mod", "go.work", ".git" }) or vim.loop.cwd()
            end

            dap.configurations.go = {
                {
                    type = "go",
                    name = "Launch package",
                    request = "launch",
                    program = function()
                        return project_root()
                    end,
                    cwd = function()
                        return project_root()
                    end,
                },
                {
                    type = "go",
                    name = "Launch file",
                    request = "launch",
                    program = function()
                        return vim.fn.expand("%:p")
                    end,
                    cwd = function()
                        return project_root()
                    end,
                },
            }

            table.insert(dap.configurations.go, {
                type = "go",
                name = "Debug test (nearest)",
                request = "launch",
                mode = "test",
                program = "${file}",
                cwd = function()
                    return project_root()
                end,
            })

            table.insert(dap.configurations.go, {
                type = "go",
                name = "Debug test (package)",
                request = "launch",
                mode = "test",
                program = "${fileDirname}",
                cwd = function()
                    return project_root()
                end,
            })

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
            vim.keymap.set("n", "<leader>B", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "DAP: Conditional breakpoint" })
        end,
    },

    {
        "leoluz/nvim-dap-go",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-go").setup()
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dapui = require("dapui")
            local dap = require("dap")

            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI: toggle" })
            vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "DAP UI: eval under cursor" })
        end,
    },
}
