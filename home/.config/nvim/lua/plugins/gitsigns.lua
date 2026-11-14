-- Install Gitsigns
vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

-- Configure Gitsigns
require("gitsigns").setup({
    signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },

    signcolumn = true,
    current_line_blame = false,

    -- Keybindings
    on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
                buffer = bufnr,
                desc = desc,
            })
        end

        -- Navigation
        map("n", "]h", function()
            gs.nav_hunk("next")
        end, "Next hunk")

        map("n", "[h", function()
            gs.nav_hunk("prev")
        end, "Previous hunk")

        -- Stage and reset hunks
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")

        -- Stage and reset selected lines
        map("v", "<leader>gs", function()
            gs.stage_hunk({
                vim.fn.line("."),
                vim.fn.line("v"),
            })
        end, "Stage selected lines")

        map("v", "<leader>gr", function()
            gs.reset_hunk({
                vim.fn.line("."),
                vim.fn.line("v"),
            })
        end, "Reset selected lines")

        -- Entire buffer
        map("n", "<leader>gS", gs.stage_buffer, "Stage entire file")
        map("n", "<leader>gR", gs.reset_buffer_index, "Unstage entire file")

        -- Preview
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")

        -- Git blame
        map("n", "<leader>gbl", function()
            gs.blame_line({ full = true })
        end, "Git blame line")

        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")

        -- Diff
        map("n", "<leader>gd", gs.diffthis, "Diff current file")

        map("n", "<leader>gD", function()
            gs.diffthis("~1")
        end, "Diff against previous commit")

        -- Hunk text object
        map({ "o", "x" }, "ih", gs.select_hunk, "Select Git hunk")
    end,
})
