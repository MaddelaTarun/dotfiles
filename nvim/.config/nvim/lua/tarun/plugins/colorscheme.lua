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
      vim.opt.background = "dark"
      require("onedark").load()
    end,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "oxocarbon",
        callback = function()
          local groups = {
            "Comment",
            "Keyword",
            "Statement",
            "Conditional",
            "Repeat",
            "Label",
            "Exception",
            "Operator",
            "Type",
            "StorageClass",
            "Structure",
            "Typedef",
            "Identifier",
            "Function",
            "@keyword",
            "@comment",
            "@type",
            "@function",
            "@variable",
            "@parameter",
            "@property",
            "@field",
            "@method",
            "@constant",
            "@string",
            "@namespace",
            "@label",
            "@operator",
            "@include",
            "@repeat",
            "@conditional",
            "@exception",
            "@storageclass",
            "@structure",
            "@typedef",
            "@punctuation.delimiter",
            "@punctuation.bracket",
            "@punctuation.special",
          }
          for _, group in ipairs(groups) do
            vim.api.nvim_set_hl(0, group, { italic = false })
          end
        end,
      })
    end,
  },
  {
    "ramojus/mellifluous.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mellifluous").setup({
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = { italic = false },
          strings = { italic = false },
          variables = { italic = false },
          constants = { italic = false },
          numbers = { italic = false },
          operators = { italic = false },
          types = { italic = false },
        },
      })
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("no-clown-fiesta").setup({
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = { italic = false },
          type = { italic = false },
          variables = { italic = false },
          lsp = { italic = false },
        },
      })
    end,
  },
  {
    "edeneast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          styles = {
            comments = "NONE",
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            keywords = "NONE",
            numbers = "NONE",
            operators = "NONE",
            preprocs = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
          },
        },
      })
    end,
  },
}
