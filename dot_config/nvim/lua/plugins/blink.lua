-- ~/.config/nvim/lua/plugins/blink.lua
vim.pack.add {
  {
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range '^1',
  },
}

require('blink.cmp').setup {
  keymap = {
    preset = 'super-tab',
    ['<Tab>'] = {
      'select_next',
      'snippet_forward',
      'fallback',
    },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-1>'] = { function(cmp) cmp.accept { index = 1 } end },
    ['<C-2>'] = { function(cmp) cmp.accept { index = 2 } end },
    ['<C-3>'] = { function(cmp) cmp.accept { index = 3 } end },
    ['<C-4>'] = { function(cmp) cmp.accept { index = 4 } end },
    ['<C-5>'] = { function(cmp) cmp.accept { index = 5 } end },
    ['<C-6>'] = { function(cmp) cmp.accept { index = 6 } end },
    ['<C-7>'] = { function(cmp) cmp.accept { index = 7 } end },
    ['<C-8>'] = { function(cmp) cmp.accept { index = 8 } end },
    ['<C-9>'] = { function(cmp) cmp.accept { index = 9 } end },
    ['<C-0>'] = { function(cmp) cmp.accept { index = 10 } end },
  },
  signature = { enabled = true },
  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = false },
  },

  sources = {
    default = {
      'lazydev',
      'lsp',
      'path',
      'snippets',
      'buffer',
      'obsidian',
      'obsidian_new',
      'obsidian_tags',
    },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        -- make lazydev completions top priority (see `:h blink.cmp`)
        score_offset = 100,
      },
    },
  },

  fuzzy = {
    implementation = 'prefer_rust_with_warning',
  },
}
