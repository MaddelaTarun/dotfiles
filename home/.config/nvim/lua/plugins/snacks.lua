-- Install Snacks.nvim
vim.pack.add({
    { src = "https://github.com/folke/snacks.nvim" },
})

-- Configure Snacks
local Snacks = require("snacks")

Snacks.setup({
    picker = {
        enabled = true,
    },
})

-- File search
vim.keymap.set("n", "<leader>pf", function()
    Snacks.picker.files()
end, { desc = "Find files" })

-- Search text in directory
vim.keymap.set("n", "<leader>ps", function()
    Snacks.picker.grep()
end, { desc = "Search text in project" })

-- Browse all keymaps
-- vim.keymap.set("n", "<leader>?", function()
--     Snacks.picker.keymaps()
-- end, { desc = "Search keymaps" })

-- Search Neovim configuration
vim.keymap.set("n", "<leader>pc", function()
    Snacks.picker.files({
        cwd = vim.fn.stdpath("config"),
    })
end, { desc = "Find Neovim config files" })

-- Find Git files
vim.keymap.set("n", "<leader>pg", function()
    Snacks.picker.git_files()
end, { desc = "Find Git files" })

-- Pick and switch Git branches
vim.keymap.set("n", "<leader>gb", function()
    Snacks.picker.git_branches()
end, { desc = "Git branches" })

-- Diagnostics picker
vim.keymap.set("n", "<leader>sD", function()
    Snacks.picker.diagnostics()
end, { desc = "Search project diagnostics" })

vim.keymap.set("n", "<leader>sd", function()
    Snacks.picker.diagnostics_buffer()
end, { desc = "Search buffer diagnostics" })
