return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,

      window = {
        position = "left",
        width = 35,

        mappings = {
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
          ["l"] = "open",
          ["s"] = "open_vsplit",
          ["S"] = "open_split",
          ["t"] = "open_tabnew",

          ["<bs>"] = "navigate_up",
          ["."] = "set_root",

          ["a"] = "add",
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",

          ["R"] = "refresh",
          ["H"] = "toggle_hidden",

          ["/"] = "fuzzy_finder",
          ["f"] = "filter_on_submit",
          ["<c-x>"] = "clear_filter",

          ["P"] = { "toggle_preview", config = { use_float = true } },

          ["q"] = "close_window",
          ["?"] = "show_help",
        },
      },

      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
            "node_modules",
            "__pycache__",
          },
        },
      },
    })

    -- Keybindings
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "\\", ":Neotree reveal<CR>", { noremap = true, silent = true })
  end,
}
