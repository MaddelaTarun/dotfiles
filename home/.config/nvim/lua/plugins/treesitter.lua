vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter").install({
    "bash",
    "c",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
    "yaml",
})

-- Enable treesitter highlighting for every filetype that has a parser
local ts_group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = ts_group,
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
