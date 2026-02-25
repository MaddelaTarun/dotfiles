return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",         -- Autocomplete Engine
      "hrsh7th/cmp-nvim-lsp",     -- Bridge for LSP
      "hrsh7th/cmp-buffer",       -- Complete from current file
      "hrsh7th/cmp-path",         -- Complete file paths
      "L3MON4D3/LuaSnip",         -- Snippets (Required)
      "saadparwaiz1/cmp_luasnip", 
    },
    config = function()
      -- 1. Setup Mason
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- Ensure these are automatically installed
        ensure_installed = { "clangd", "jdtls", "lua_ls", "ts_ls" }, 
      })

      -- 2. Setup Autocompletion (CMP)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(), -- Trigger dropdown
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter to accept
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- 3. Define and Enable LSPs (The Neovim 0.11 Way)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configuration for JavaScript / TypeScript
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        -- Default filetypes for JS/TS
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })

      -- Configuration for Lua (Your Config)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } }
      })

      -- Configuration for C/C++
      vim.lsp.config("clangd", { capabilities = capabilities })

      -- ACTIVATE THE SERVERS
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("clangd")

      -- Recommended Global Keybinds
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "LSP Hover Documentation" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "LSP Go to Definition" })
    end,
  },
}
