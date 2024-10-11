require("oil").setup({
              columns = { "icon" },
              keymaps = {
                  ["C-h"] = false,
                  ["C-s"] = false,
                  ["C-t"] = false,
                  ["<CR>"] = "actions.select",
                  ["<C-c>"] = "actions.close",
                  ["<C-l>"] = "actions.refresh",
                  ["`"] = "actions.cd",
                  ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
              },
              use_default_keymaps = false,
              view_options = {
                  show_hidden = true,
              },
})
