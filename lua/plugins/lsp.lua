-- Defines the list of LSP servers and other tools to be installed by Mason
local servers = {
	clangd = {},
	gopls = {},
	ts_ls = {},

	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
				-- diagnostics = { disable = { 'missing-fields' } },
			},
		},
	},
}

-- A list of other tools to install
local ensure_installed_tools = {
	"stylua", -- Used to format Lua code
	"templ",
	"gopls",
}

-- Combine the server names and the tools list
local ensure_installed_list = vim.tbl_keys(servers)
for _, tool in ipairs(ensure_installed_tools) do
	if not vim.tbl_contains(ensure_installed_list, tool) then
		table.insert(ensure_installed_list, tool)
	end
end

return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Lsp
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
			"j-hui/fidget.nvim",

			"saghen/blink.cmp",
			{
				"supermaven-inc/supermaven-nvim",
				config = function()
					require("supermaven-nvim").setup({
						keymaps = {
							accept_suggestion = "<M-y>",
							clear_suggestion = "<C-]>",
							accept_word = "<C-j>",
						},
					})
					local sm = require("supermaven-nvim.api")
					vim.keymap.set("n", "<leader>sm", sm.toggle, { desc = "Toggle Supermaven" })
				end,
			},
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("csg-lsp-attach", { clear = true }),
				callback = function(event)
					local builtin = require("telescope.builtin")
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- LSP
					map("K", vim.lsp.buf.hover, "")
					map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("<C-h>", vim.lsp.buf.signature_help, "i")
					map("<leader>vd", vim.diagnostic.open_float, "Open diagnostics in float window")
					map("[d", vim.diagnostic.get_next, "Next diagnostic")
					map("]d", vim.diagnostic.get_prev, "Prev diagnostic")
					-- Telescope
					map("gr", builtin.lsp_references, "[G]oto [R]eferences")
					map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>vs", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbol")
					map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = " ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Enable the following language servers
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				-- clangd = {},
				gopls = {},
				ts_ls = {},
				-- rust_analyzer = {},
				-- pyright = {},

				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{
		-- Autoformatter
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return { timeout_ms = 500, lsp_format = "fallback" }
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},
}

-- {
-- 	-- Autocompletion plugin
-- 	"hrsh7th/nvim-cmp",
-- 	event = "InsertEnter",
-- 	dependencies = {
-- 		"hrsh7th/cmp-nvim-lsp",
-- 		"hrsh7th/cmp-buffer",
-- 		"hrsh7th/cmp-nvim-lsp-signature-help",
-- 		{
-- 			"L3MON4D3/LuaSnip",
-- 			build = (function()
-- 				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
-- 					return
-- 				end
-- 				return "make install_jsregexp"
-- 			end)(),
-- 		},
-- 		"saadparwaiz1/cmp_luasnip",
-- 	},
-- 	config = function()
-- 		local cmp = require("cmp")
-- 		local luasnip = require("luasnip")
-- 		luasnip.config.setup({})
--
-- 		cmp.setup({
-- 			snippet = {
-- 				expand = function(args)
-- 					luasnip.lsp_expand(args.body)
-- 				end,
-- 			},
-- 			completion = { completeopt = "menu,menuone,noinsert" },
-- 			mapping = cmp.mapping.preset.insert({
-- 				["<C-n>"] = cmp.mapping.select_next_item(),
-- 				["<C-p>"] = cmp.mapping.select_prev_item(),
-- 				["<C-b>"] = cmp.mapping.scroll_docs(-4),
-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
-- 				["<C-y>"] = cmp.mapping.confirm({ select = true }),
-- 				["<C-Space>"] = cmp.mapping.complete({}),
-- 				["<C-l>"] = cmp.mapping(function()
-- 					if luasnip.expand_or_locally_jumpable() then
-- 						luasnip.expand_or_jump()
-- 					end
-- 				end, { "i", "s" }),
-- 				["<C-h>"] = cmp.mapping(function()
-- 					if luasnip.locally_jumpable(-1) then
-- 						luasnip.jump(-1)
-- 					end
-- 				end, { "i", "s" }),
-- 			}),
-- 			sources = {
-- 				{ name = "lazydev", group_index = 0 },
-- 				{ name = "nvim_lsp" },
-- 				{ name = "luasnip" },
-- 				{ name = "path" },
-- 				{ name = "nvim_lsp_signature_help" },
-- 				{ name = "supermaven" },
-- 			},
-- 		})
-- 	end,
-- },
--
-- -- First, set up the base Mason plugin
-- {
-- 	"williamboman/mason.nvim",
-- 	opts = {}, -- `opts = {}` calls `require('mason').setup({})`
-- 	dependencies = {
-- 		"williamboman/mason-lspconfig.nvim",
-- 		"WhoIsSethDaniel/mason-tool-installer.nvim",
-- 	},
-- },
--
-- -- Then, configure the tool installer to depend on Mason
-- {
-- 	"WhoIsSethDaniel/mason-tool-installer.nvim",
-- 	dependencies = { "williamboman/mason.nvim" },
-- 	opts = {
-- 		ensure_installed = ensure_installed_list,
-- 	},
-- },
--
-- -- Finally, configure the main LSP plugin
-- {
-- 	"neovim/nvim-lspconfig",
-- 	dependencies = {
-- 		"hrsh7th/cmp-nvim-lsp",
-- 		{ "j-hui/fidget.nvim", opts = {} },
-- 		"williamboman/mason.nvim",
-- 	},
-- 	config = function()
--
-- 		vim.api.nvim_create_autocmd("LspAttach", {
-- 			group = vim.api.nvim_create_augroup("vwb-lsp-attach", { clear = true }),
-- 			callback = function(event)
-- 				local map = function(keys, func, desc, mode)
-- 					mode = mode or "n"
-- 					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
-- 				end
--
-- 				local function client_supports_method(client, method, bufnr)
-- 					if vim.fn.has("nvim-0.11") == 1 then
-- 						return client:supports_method(method, bufnr)
-- 					else
-- 						return client.supports_method(method, { bufnr = bufnr })
-- 					end
-- 				end
--
-- 		})
--
-- },
