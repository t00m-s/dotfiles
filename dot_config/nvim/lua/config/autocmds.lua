-- ~/.config/nvim/lua/autocmds.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  pattern = '*',
  callback = function() vim.hl.on_yank { timeout = 150 } end,
  group = highlight_group,
})

-- LSP group
local lsp = augroup('Lsp', { clear = true })
-- Treesitter group for the autocmd
local treesitter = augroup('Treesitter', { clear = true })

-- Gets all installed parsers, so that treesitter does not start/crash on
-- unintended filetypes
local ok, _ = pcall(require, 'nvim-treesitter')
if ok then
  local treesitter_installed_parsers = require('nvim-treesitter').get_installed()
  autocmd('FileType', {
    group = treesitter,
    nested = false,
    pattern = treesitter_installed_parsers,
    callback = function()
      ok = pcall(vim.treesitter.start)
      if not ok then
        vim.notify('Failed to start treesitter.', vim.log.levels.ERROR)
        return
      end
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldlevel = 99
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

-- LSP specific keybinds
autocmd('LspAttach', {
  group = lsp,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

autocmd('PackChanged', {
  callback = function()
    ok = pcall(vim.treesitter.start)
    if not ok then
      return
    end
    require('nvim-treesitter').update()
  end,
})
