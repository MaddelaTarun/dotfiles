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
      -- vim.cmd([[colorscheme mellow]])
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    opts = {
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
        variables = { italic = false },
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    config = function()
      require("rose-pine").setup({
        styles = {
          italic = false,
        },
      })
    end,
  },
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
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "warmer",
        code_style = {
          comments = "none",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
      })
      require("onedark").load()
    end,
  },
}
