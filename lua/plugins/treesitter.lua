-- nvim-treesitter `main` branch: it only installs parsers/queries (needs the tree-sitter CLI).
-- Highlighting and indent are enabled per buffer with Neovim's built-in treesitter.
local ensure_installed = {
	"bash",
	"c",
	"diff",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
	"go",
	"typescript",
}

return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.install(ensure_installed)

			local function attach(buf, lang)
				vim.treesitter.start(buf, lang)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("csg-treesitter", { clear = true }),
				callback = function(args)
					local buf, lang = args.buf, vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end
					if vim.treesitter.language.add(lang) then
						attach(buf, lang)
					elseif vim.tbl_contains(ts.get_available(), lang) then
						-- Autoinstall languages that are not installed, then attach
						ts.install(lang):await(function()
							if vim.api.nvim_buf_is_valid(buf) then
								attach(buf, lang)
							end
						end)
					end
				end,
			})
		end,
	},
}
