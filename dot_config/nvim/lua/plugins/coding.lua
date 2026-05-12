-- ~/.config/nvim/lua/plugins/coding.lua
-- LSP
vim.pack.add {
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/folke/trouble.nvim' },
  { src = 'https://github.com/folke/lazydev.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/stevearc/overseer.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' }, -- Optional, but saves work
  { src = 'https://github.com/folke/flash.nvim' },
  { src = 'https://github.com/lambdalisue/vim-suda' },
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
  { src = 'https://github.com/nvim-mini/mini.surround' },
}

require('mason').setup {}
require('trouble').setup {
  warn_no_results = false,
  modes = {
    lsp_base = {
      params = { include_current = true },
    },
  },
}

require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    sh = { 'shfmt' },
    go = { 'gofmt' },
    rust = { 'rustfmt' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = 'fallback',
  },
}

require('flash').setup {
  modes = {
    -- options used when flash is activated through
    -- `f`, `F`, `t`, `T`, `;` and `,` motions
    char = {
      enabled = true,
      -- show jump labels
      jump_labels = true,
    },
  },
}

require('harpoon'):setup()
require('lazydev').setup {
  library = {
    -- See the configuration section for more details
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

require('mini.surround').setup()
require('overseer').setup()

vim.lsp.enable {
  'lua_ls',
  'basedpyright',
  'ruff',
  'ts_ls',
  'clangd',
  'hyprls',
  'rust_analyzer',
}

vim.diagnostic.config {
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
}

local keymap = vim.keymap.set
keymap('n', '<leader>qf', '<cmd>Trouble diagnostics toggle<CR>')
keymap('n', '<leader>a', function() require('harpoon'):list():add() end)
keymap(
  'n',
  '<C-e>',
  function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end
)
keymap({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
keymap(
  { 'n', 'x', 'o' },
  'S',
  function() require('flash').treesitter() end,
  { desc = 'Flash Treesitter' }
)
keymap('o', 'r', function() require('flash').remote() end, { desc = 'Flash Remote' })
keymap(
  { 'x', 'o' },
  'R',
  function() require('flash').treesitter_search() end,
  { desc = 'Flash Treesitter Search' }
)

keymap('n', '<leader>cm', '<cmd>OverseerToggle<CR>', { desc = '[C]ompiler [M]enu' })
