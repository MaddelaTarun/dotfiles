-- Install which-key
vim.pack.add({
    { src = "https://github.com/folke/which-key.nvim" },
})

-- Configure which-key
local wk = require("which-key")

wk.setup({
    delay = 200,
})

-- Keymap groups
wk.add({
    { "<leader>p", group = "Pickers" },
    { "<leader>g", group = "Git" },
    { "<leader>f", group = "File" },
    { "<leader>w", group = "Windows" },
})
