vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/stevearc/oil.nvim" },
})

-- Configure Oil
require("oil").setup({
    default_file_explorer = true,

    columns = {},

    keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-c>"] = false,
        ["<C-r>"] = { "actions.refresh", desc = "Refresh directory" },
        ["<M-h>"] = { "actions.select_split", desc = "Open in horizontal split" },
        ["q"] = { "actions.close", desc = "Close Oil" },
    },

    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,

    view_options = {
        show_hidden = true,
    },
})

-- Keybindings
vim.keymap.set("n", "-", "<CMD>Oil<CR>", {
    desc = "Open parent directory",
})

vim.keymap.set("n", "<leader>-", function()
    require("oil").toggle_float()
end, {
    desc = "Open Oil in floating window",
})

-- Highlight current line in Oil
local oil_group = vim.api.nvim_create_augroup("OilConfig", {
    clear = true,
})

vim.api.nvim_create_autocmd("FileType", {
    group = oil_group,
    pattern = "oil",
    callback = function()
        vim.opt_local.cursorline = true
    end,
})
