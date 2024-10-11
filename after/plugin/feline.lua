local feline = require('feline')
local vi_mode = require('feline.providers.vi_mode')
local file = require('feline.providers.file')

local baseSep = function(fg, bg)
    fg = fg or 'none'
    bg = bg or 'none'
    return {
        always_visible = true,
        str = ' ',
        hl = { fg = fg, bg = bg },
    }
end

local c = {
    -- left
    vim_mode = {
        provider = function()
            return string.format('%s', vi_mode.get_vim_mode())
        end,
        hl = function()
            return { fg = vi_mode.get_mode_color(), bg = 'none' }
        end,
        right_sep = baseSep(),
    },

    file_name = {
        provider = {
            name = 'file_info',
            opts = {
                colored_icon = false,
                type = 'relative',
            },
        },
        hl = { fg = '#5F63B4', bg = 'none' },
        right_sep = baseSep(),
    },

    git_branch = {
        provider = function()
            local git = require('feline.providers.git')
            local branch, icon = git.git_branch()
            local s
            if #branch > 0 then
                s = string.format('%s%s', icon, branch)
            else
                s = 'Untracked'
            end
            return s
        end,
        hl = { fg = '#AF9A91', bg = 'none' },
    },

    -- right
    macro = {
        provider = function ()
            local s
            local recording_register = vim.fn.reg_recording()
            if #recording_register == 0 then
                s = ''
            else
                s = string.format('Recording @%s', recording_register)
            end
            return s
        end,
        hl = { fg = '#D6B04E', bg = 'none' },
        right_sep = baseSep(),
    },

    search_count = {
        provider = 'search_count',
        hl = { fg = '#E2C2BB', bg = 'none' },
        right_sep = baseSep(),
    },

    cursor_position = {
        provider = {
            name = 'position',
            opts = { padding = true },
        },
        hl = { fg = '#F66813', bg = 'none' },
        right_sep = baseSep(),
    },

    scroll_bar = {
        provider = {
            name = 'scroll_bar',
            opts = { reverse = true },
        },
        hl = { fb = '#8086EF', bg = 'none' },
    }
}

local active = {
    { -- left
        c.vim_mode,
        c.file_name,
        c.git_branch,
        "",
    },
    { -- right
        c.macro,
        c.search_count,
        c.cursor_position,
        c.scroll_bar,
    }
}

local inactive = {
    {},
    {
        provider = function ()
            if vim.api.nvim_buf_get_name(0) == '' then
                return file.file_info({}, { colored_icon = false })
            else
                return file.file_type(
                    {},
                    { colored_icon = false, case = 'lowercase' }
                )
            end
        end,
    }
}

local opts = {
    components = {
        active = active,
        inactive = inactive,
    }
}

feline.setup(opts)
print("wtf")
