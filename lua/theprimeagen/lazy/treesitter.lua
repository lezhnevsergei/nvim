return {
    {
        "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter.configs", -- Lazy сам сделает require(...)
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ensure_installed = { "go", "lua", "vim", "vimdoc", "query", "bash", "rust" },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true },
        },
    },
    -- опционально, если используешь context — но отключаем для Go
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" },
        opts = { enable = true, disable = { "go" } },
    },
}
