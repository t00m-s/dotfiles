vim.pack.add {
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },

  {
    src = 'https://github.com/obsidian-nvim/obsidian.nvim',
    version = vim.version.range '*', -- use latest release, remove to use latest commit
  },
}

require('render-markdown').setup {
  file_types = { 'markdown' },
  latex = { enabled = true },
  completions = {
    lsp = { enabled = true },
  },
}

require('obsidian').setup {
  ui = { enable = false, enabled = false },
  frontmatter = {
    func = function(note)
      local out = {
        title = note.id or note.title,
        tags = note.tags,
        status = 'in-progress',
        updated = os.date '%Y-%m-%d',
      }
      -- preserve any extra fields already in the note
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,
  },
  templates = { folder = 'template/' },
  legacy_commands = false,
  completion = { blink = true },
  workspaces = { {
    name = 'Zettelkasten',
    path = '~/Zettelkasten/',
  } },
}

local keymap = vim.keymap.set
keymap(
  'n',
  '<leader>ont',
  '<CMD>Obsidian new_from_template<CR>',
  { desc = '[O]bsidian [N]ew from [T]emplate' }
)
keymap('n', '<leader>ot', '<CMD>Obsidian template<CR>', { desc = '[O]bsidian apply [T]emplate' })
