vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n","<leader><leader>",function()
	vim.cmd("source")
end, { desc = "Source current file" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left and keep selection" })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right and keep selection" })
vim.keymap.set("x", "<leader>p", [["_dP]], { noremap = true, silent = true, desc = "Paste without overwriting register" })
vim.keymap.set("v", "p", '"_dp', { noremap = true, silent = true, desc = "Paste over selection without overwriting register" })
vim.keymap.set({"n","v"}, "<leader>y", [["+y]], { noremap = true, silent = true, desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true, desc = "Delete without overwriting register" })
vim.keymap.set("n", "<C-c>", ":nohl<CR>", 
        { desc = "Clear search hl", silent = true })
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true, desc = "Delete character without overwriting register" })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], 
        { desc = "Replace word cursor is on globally" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", 
        { silent = true, desc = "makes file executable" })

-- Split Windows
vim.keymap.set("n", "<leader>wv", "<C-w>v",
        { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wh", "<C-w>s",
        { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>we", "<C-w>=",
        { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>wx", "<cmd>close<CR>",
        { desc = "Close current split" })

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })


-- Diagnostics navigation
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

-- Show diagnostic details
vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float({
        scope = "line",
        border = "rounded",
    })
end, { desc = "Show line diagnostics" })
