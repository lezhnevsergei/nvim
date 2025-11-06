vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

local function fallback_move(direction)
    if direction > 0 then
        vim.cmd("normal! ]]")
    else
        vim.cmd("normal! [[")
    end
end

local function move_between_blocks(direction)
    -- Try to use treesitter to find next/previous function-like node.
    local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
    if not ok_parsers then
        fallback_move(direction)
        return
    end

    local parser = parsers.get_parser(0)
    if not parser then
        fallback_move(direction)
        return
    end

    local tree = parser:parse()[1]
    if not tree then
        fallback_move(direction)
        return
    end

    local lang = parser:lang()
    local node_types = {
        ["*"] = {
            "function_declaration",
            "function_definition",
            "function_expression",
            "local_function",
            "method_definition",
            "method_declaration",
            "function_item",
            "impl_item",
            "struct_item",
            "trait_item",
            "class_declaration",
            "class_definition",
            "class_specifier",
            "class_body",
        },
        lua = { "function_declaration", "local_function", "function_definition" },
        go = { "function_declaration", "method_declaration" },
        javascript = {
            "function",
            "function_declaration",
            "generator_function_declaration",
            "method_definition",
            "class_declaration",
        },
        typescript = {
            "function_declaration",
            "method_definition",
            "method_signature",
            "class_declaration",
        },
        tsx = {
            "function_declaration",
            "method_definition",
            "method_signature",
            "class_declaration",
        },
        rust = {
            "function_item",
            "impl_item",
            "struct_item",
            "trait_item",
            "enum_item",
        },
        c = { "function_definition" },
        cpp = { "function_definition", "class_specifier", "class_definition" },
        python = { "function_definition", "class_definition" },
    }

    local function is_target(node)
        local t = node:type()
        local lang_nodes = node_types[lang]
        if lang_nodes then
            for _, v in ipairs(lang_nodes) do
                if v == t then
                    return true
                end
            end
        end
        for _, v in ipairs(node_types["*"]) do
            if v == t then
                return true
            end
        end
        return false
    end

    local root = tree:root()
    local positions = {}
    local function collect(node)
        if is_target(node) then
            local sr, sc = node:start()
            table.insert(positions, { row = sr, col = sc })
        end
        for child in node:iter_children() do
            collect(child)
        end
    end
    collect(root)

    if #positions == 0 then
        fallback_move(direction)
        return
    end

    table.sort(positions, function(a, b)
        if a.row == b.row then
            return a.col < b.col
        end
        return a.row < b.row
    end)

    local cursor = vim.api.nvim_win_get_cursor(0)
    local current = { row = cursor[1] - 1, col = cursor[2] }
    local target
    if direction > 0 then
        for _, pos in ipairs(positions) do
            if pos.row > current.row or (pos.row == current.row and pos.col > current.col) then
                target = pos
                break
            end
        end
    else
        for i = #positions, 1, -1 do
            local pos = positions[i]
            if pos.row < current.row or (pos.row == current.row and pos.col < current.col) then
                target = pos
                break
            end
        end
    end

    if target then
        vim.api.nvim_win_set_cursor(0, { target.row + 1, target.col })
    else
        fallback_move(direction)
    end
end

vim.keymap.set({ "n", "x", "o" }, "]]", function()
    move_between_blocks(1)
end, { desc = "Next code block" })

vim.keymap.set({ "n", "x", "o" }, "[[", function()
    move_between_blocks(-1)
end, { desc = "Previous code block" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set(
    "n",
    "<leader>ea",
    "oassert.NoError(err, \"\")<Esc>F\";a"
)

vim.keymap.set(
    "n",
    "<leader>ef",
    "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj"
)

vim.keymap.set(
    "n",
    "<leader>el",
    "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i"
)

vim.keymap.set("n", "<leader>ca", function()
    require("cellular-automaton").start_animation("make_it_rain")
end)

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)
