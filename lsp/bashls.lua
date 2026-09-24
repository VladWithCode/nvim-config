---@type vim.lsp.Config
return {
	cmd = { "bash-language-server", "start" },
	-- sh is included so the POSIX dotfiles (.path_fns, .profile) attach too.
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
}
