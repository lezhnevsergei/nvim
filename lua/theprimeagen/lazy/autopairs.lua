return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        -- Enable automatic closing of brackets, quotes, etc.
        require("nvim-autopairs").setup({
            check_ts = true,
            fast_wrap = {},
        })
    end,
}
