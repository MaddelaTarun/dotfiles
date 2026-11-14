-- Highlight text after yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Restore last cursor position",
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')

        local line = mark[1]
        local col = mark[2]

        if line > 0 and line <= vim.api.nvim_buf_line_count(args.buf) then
            vim.api.nvim_win_set_cursor(0, { line, col })
        end
    end,
})

-- Automatically resize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
    desc = "Automatically resize splits",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})
