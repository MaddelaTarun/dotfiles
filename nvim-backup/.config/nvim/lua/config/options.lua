vim.opt.number = true
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Disable italics globally
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local hl_groups = vim.api.nvim_get_hl(0, {})
    for name, hl in pairs(hl_groups) do
      if hl.italic then
        hl.italic = false
        vim.api.nvim_set_hl(0, name, hl)
      end
    end
  end,
})
