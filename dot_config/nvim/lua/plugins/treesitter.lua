-- ~/.config/nvim/lua/plugins/treesitter.lua
vim.pack.add {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
}

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath 'data' .. '/site',
}
require('nvim-treesitter').install {
  'bash',
  'c',
  'diff',
  'html',
  'latex',
  'yaml',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'rust',
  'javascript',
  'python',
}
