-- ~/.config/nvim/lua/plugins/oil.lua
vim.pack.add { { src = 'https://github.com/stevearc/oil.nvim' } }
-- File manager
require('oil').setup {
  columns = {
    'icon',
    'permissions',
    'size',
  },
  watch_for_changes = true,
  use_default_keymaps = false,
  keymaps = {
    ['<CR>'] = 'actions.select',
  },
  view_options = { show_hidden = true },
  default_file_explorer = true,
  win_options = {
    signcolumn = 'yes:2',
  },
}
local keymap = vim.keymap.set
keymap('n', '<leader>pv', function() require('oil').toggle_float() end)
