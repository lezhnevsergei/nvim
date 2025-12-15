return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("aerial").setup({
            -- Priority list of preferred backends for aerial
            backends = { "treesitter", "lsp", "markdown", "man" },
            layout = {
                -- These control the width of the aerial window.
                -- They can be integers (fixed width) or a float (fraction of the editor width)
                max_width = { 40, 0.2 },
                width = nil,
                min_width = 10,

                -- key-value pairs of window-local options for aerial window (e.g. winhl)
                win_opts = {},

                -- Determin the default direction to open the aerial window. The 'prefer'
                -- options will open the window in the other direction concurrently if there
                -- is already a window in that direction.
                default_direction = "prefer_right",

                -- Put the aerial window on the far right or left of the screen
                placement = "window",
            },
            -- Automatically close the aerial window after selecting an item
            close_on_select = true,
        })

        vim.keymap.set("n", "<leader>cs", "<cmd>AerialToggle!<CR>", { desc = "Aerial: Toggle code structure" })
    end
}
