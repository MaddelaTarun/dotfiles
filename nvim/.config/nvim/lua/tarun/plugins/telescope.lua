return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        pickers = {
          colorscheme = {
            enable_preview = true,
            ignore_builtins = true,
          },
        },
      })
      
      -- Force check built-in themes 
      -- Some versions of telescope require specific patterns
      vim.keymap.set("n", "<leader>cs", function()
        require("telescope.builtin").colorscheme({
          ignore_builtins = true,
          enable_preview = true,
        })
      end, { desc = "Telescope colorschemes" })
    end,
  },
}
