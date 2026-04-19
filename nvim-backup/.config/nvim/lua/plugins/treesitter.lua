return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'master',
  build = ":TSUpdate",
  lazy = false, 
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "html","java", "javascript", "typescript", "tsx", "markdown", "markdown_inline" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
