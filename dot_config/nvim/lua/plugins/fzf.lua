vim.pack.add { { src = 'https://github.com/ibhagwan/fzf-lua' } }
require('fzf-lua').setup { 'fzf-native' }
require('fzf-lua').register_ui_select()

local keymap = vim.keymap.set
keymap('n', '<leader>sf', function()
  local is_git_project = vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1] == true
  if is_git_project then
    require('fzf-lua').git_files()
  else
    require('fzf-lua').files()
  end
end)
keymap(
  'n',
  '<leader>sc',
  function() require('fzf-lua').files { cwd = vim.fn.stdpath 'config' } end,
  { desc = '[S]earch [C]onfig' }
)
keymap('n', '<leader><leader>', function() require('fzf-lua').history() end)

keymap(
  'n',
  '<leader>sw',
  function() require('fzf-lua').live_grep_native() end,
  { desc = '[S]earch [W]ord' }
)

keymap(
  'n',
  '<leader>ws',
  function() require('fzf-lua').lsp_live_workspace_symbols() end,
  { desc = '[W]orkspace [S]ymbols' }
)
keymap('n', '<leader>ut', function() require('fzf-lua').undotree() end, { desc = '[U]ndo [T]ree' })

keymap(
  'n',
  '<leader>ca',
  function() require('fzf-lua').lsp_code_actions() end,
  { desc = '[C]ode [A]ction' }
)

keymap(
  'n',
  '<leader>cr',
  function() require('fzf-lua').lsp_references() end,
  { desc = '[C]ode [R]eferences' }
)

keymap(
  'n',
  '<leader>cd',
  function() require('fzf-lua').lsp_references() end,
  { desc = '[C]ode [D]efinition' }
)

keymap(
  'n',
  '<leader>cD',
  function() require('fzf-lua').lsp_declarations() end,
  { desc = '[C]ode [D]eclaration' }
)

keymap(
  'n',
  '<leader>ci',
  function() require('fzf-lua').lsp_references() end,
  { desc = '[C]ode [I]mplementation' }
)
