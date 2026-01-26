return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",         -- The actual completion engine (THE MISSING PIECE)
      "hrsh7th/cmp-nvim-lsp",     -- The bridge between LSP and completion
      "L3MON4D3/LuaSnip",         -- Required snippet engine for the menu to work
    },
    config = function()
      -- 1. Setup Mason
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "jdtls", "lua_ls" },
      })

      -- 2. Setup Autocompletion (Fixes your 'cmp' not found error)
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        })
      })

      -- 3. Define LSP Settings (The Native 0.11+ Way)
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Lua
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } }
      })

      -- C/C++
      vim.lsp.config('clangd', { capabilities = capabilities })

      -- Java
      vim.lsp.config('jdtls', { capabilities = capabilities })

      -- 4. Enable the servers
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('clangd')
      vim.lsp.enable('jdtls')
    end,
  },
}
