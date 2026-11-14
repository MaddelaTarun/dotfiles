-- Install Blink.cmp and snippets
vim.pack.add({
    {
        src = "https://github.com/Saghen/blink.cmp",
        version = vim.version.range("1.*"),
    },
    {
        src = "https://github.com/rafamadriz/friendly-snippets",
    },
})

-- Configure Blink.cmp
require("blink.cmp").setup({

    -- Keybindings
    keymap = {
        preset = "default",

        -- Completion navigation
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },

        -- Disable old navigation and acceptance mappings
        ["<C-n>"] = false,
        ["<C-p>"] = false,
        ["<C-y>"] = false,

        -- Accept completion
        ["<C-CR>"] = { "select_and_accept", "fallback" },
    },
    -- Appearance
    appearance = {
        nerd_font_variant = "mono",
    },

    -- Completion documentation
    completion = {
        documentation = {
            auto_show = true,
        },
    },
    -- Completion sources
    sources = {
        default = {
            "lsp",
            "path",
            "snippets",
            "buffer",
        },
    },

    -- Fuzzy matching
    fuzzy = {
        implementation = "prefer_rust_with_warning",
    },
})
