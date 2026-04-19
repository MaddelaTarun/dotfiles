-- Simple Comment. No use
return {
  {
    "mellow-theme/mellow.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.mellow_italic_functions = false
      vim.g.mellow_italic_comments = false
      vim.g.mellow_italic_keywords = false
      vim.g.mellow_italic_variables = false
      vim.cmd([[colorscheme mellow]])
    end,
  },
  { "craftzdog/solarized-osaka.nvim", lazy = false },
  { "rose-pine/neovim", name = "rose-pine", lazy = false },
  {
    "vague2k/vague.nvim",
    lazy = false,
    config = function()
      require("vague").setup({
        style = {
          boolean = "none",
          number = "none",
          float = "none",
          error = "none",
          comments = "none",
          conditionals = "none",
          functions = "none",
          headings = "none",
          identifiers = "none",
          keywords = "none",
          keyword_return = "none",
          keywords_loop = "none",
          keywords_label = "none",
          keywords_exception = "none",
          macros = "none",
          operators = "none",
          preproc = "none",
          regex = "none",
          strings = "none",
          tag = "none",
          type = "none",
          variables = "none",
        },
      })
    end,
  },
}
