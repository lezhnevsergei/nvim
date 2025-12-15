return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.5",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({
            defaults = {
                layout_strategy = 'horizontal',
                layout_config = {
                    width = 0.95,
                    height = 0.95,
                    preview_width = 0.6,
                },
            },
            pickers = {
                lsp_references = {
                    show_line = false,
                },
                lsp_implementations = {
                    show_line = false,
                },
            },
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', function()
            builtin.git_files({
                file_ignore_patterns = { "vendor", "generated" }
            })
        end, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({
                search = vim.fn.input("Grep > "),
                additional_args = function()
                    return {
                        "--glob", "!**/vendor/**",
                        "--glob", "!**/generated/**",
                    }
                end,
            })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
}
