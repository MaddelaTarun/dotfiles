return {
  {
    "NvChad/nvim-colorizer.lua",
    -- This forces the plugin to load for any file you open
    event = { "BufReadPost", "BufNewFile" }, 
    config = function()
      require("colorizer").setup({
        filetypes = { "*" }, -- Target all files
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true, -- This handles "blue", "red", etc.
          mode = "background", -- "foreground", "background", or "virtualtext"
        },
      })
    end,
  },
  
  -- Keep your other plugins below
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", opts = {} },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
}
