vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
})

vim.diagnostic.config({
    virtual_text = {current_line = true},
    severity_sort = true,
})

-- LSP keymaps (buffer-local)
local lsp_group = vim.api.nvim_create_augroup("LspKeymaps", {
    clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_group,
    callback = function(args)
        local bufnr = args.buf

        local map = function(key, action, description)
            vim.keymap.set("n", key, action, {
                buffer = bufnr,
                desc = description,
            })
        end

        -- Navigation
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("grr", vim.lsp.buf.references, "Find references")
        map("gri", vim.lsp.buf.implementation, "Go to implementation")
        map("grt", vim.lsp.buf.type_definition, "Go to type definition")

        -- Code actions
        map("grn", vim.lsp.buf.rename, "Rename symbol")
        map("gra", vim.lsp.buf.code_action, "Code action")

        -- Formatting
        map("<leader>F", function()
            vim.lsp.buf.format({ async = true, bufnr = bufnr })
        end, "Format buffer")
    end,
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },

            diagnostics = {
                globals = {"vim"},
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                },
                checkThirdParty = false,
            },
        },
    },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("clangd")
