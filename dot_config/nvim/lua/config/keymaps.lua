-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set
local s = { silent = true }
local opts = { noremap = true, silent = true }

vim.g.mapleader = ' '

keymap('n', '<space>', '<Nop>')

keymap(
  'n',
  'j',
  function() return tonumber(vim.api.nvim_get_vvar 'count') > 0 and 'j' or 'gj' end,
  { expr = true, silent = true }
) -- Move down, but use 'gj' if no count is given
keymap(
  'n',
  'k',
  function() return tonumber(vim.api.nvim_get_vvar 'count') > 0 and 'k' or 'gk' end,
  { expr = true, silent = true }
) -- Move up, but use 'gk' if no count is given
keymap('n', '<C-d>', '<C-d>zz') -- Scroll down and center the cursor
keymap('n', '<C-u>', '<C-u>zz') -- Scroll up and center the cursor
keymap('n', '<Leader>|', '<cmd>vsplit<CR>', s) -- Split the window vertically
keymap('n', '<Leader>-', '<cmd>split<CR>', s) -- Split the window horizontally
keymap('x', 'y', [["+y]], s) -- Yank to the system clipboard in visual mode
keymap('n', 'x', [["_x]], s) -- Yank to the system clipboard in visual mode
keymap('n', 'p', 'p==', opts)
keymap('t', '<Esc>', '<C-\\><C-N>') -- Exit terminal mode
keymap('n', '<C-a>', 'ggVG', { desc = 'Select all' })
-- Center view when jumping between search results
keymap('n', 'n', 'nzzzv', s)
keymap('n', 'N', 'Nzzzv', s)
-- Keep cursor centered when joining lines
keymap('n', 'J', 'mzJ`z', s)

keymap('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })

-- Move lines up/down
keymap('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
keymap('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
keymap('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
keymap('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
keymap('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
keymap(
  'v',
  '<A-k>',
  ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = 'Move Up' }
)
