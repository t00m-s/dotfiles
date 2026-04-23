-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt
opt.guicursor = 'i:block' -- Use block cursor in insert mode
opt.colorcolumn = '80' -- Highlight column 80
opt.signcolumn = 'auto:2' -- Always show sign column
opt.termguicolors = true -- Enable true colors
opt.encoding = 'utf-8'
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true
opt.swapfile = false -- Disable swap files
opt.autoindent = true -- Enable auto indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Number of spaces for a tab
opt.softtabstop = 2 -- Number of spaces for a tab when editing
opt.shiftwidth = 2 -- Number of spaces for autoindent
opt.shiftround = true -- Round indent to multiple of shiftwidth
opt.list = true -- Show whitespace characters
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.numberwidth = 2 -- Width of the line number column
opt.wrap = false -- Disable line wrapping
opt.cursorline = true -- Highlight the current line
opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
opt.inccommand = 'nosplit' -- Shows the effects of a command incrementally in the buffer
opt.undodir = os.getenv 'HOME' .. '/.vim/undodir' -- Directory for undo files
opt.undofile = true -- Enable persistent undo
opt.completeopt = { 'menuone', 'popup', 'noinsert' } -- Options for completion menu
opt.winborder = 'rounded' -- Use rounded borders for windows
opt.hlsearch = false -- Disable highlighting of search results
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.termguicolors = true
vim.g.have_nerd_font = true
opt.breakindent = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.cmdheight = 0
opt.linebreak = true
opt.showmode = false
opt.hidden = true
opt.title = true
opt.titlestring = '%t'

vim.cmd.filetype 'plugin indent on' -- Enable filetype detection, plugins, and indentation
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
opt.runtimepath:append(vim.fn.stdpath 'data' .. '/site')
-- vim: ts=2 sts=2 sw=2 et
