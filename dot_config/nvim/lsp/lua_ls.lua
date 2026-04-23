--- @type vim.lsp.config
---@diagnostic disable: missing-fields
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    'lua',
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
  },
  settings = {
    Lua = {
      hint = { enable = true },
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      completion = { callSnippet = 'Replace' },
    },
  },
}
---@diagnostic enable: missing-fields
