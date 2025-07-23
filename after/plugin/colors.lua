function ColorMyPencils(color)
    if color ~= "" then
        color = color or "tokyonight-moon"
        vim.cmd.colorscheme(color)
    end

    vim.o.background = "dark"

	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils("vague")
