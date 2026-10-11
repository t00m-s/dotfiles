vim.pack.add { { src = 'https://github.com/ibhagwan/fzf-lua' } }
require('fzf-lua').setup { 'fzf-native' }

local keymap = vim.keymap.set

keymap('n', '<leader>sf', function()
  local is_git_project = vim.fn.systemlist({ 'git', 'rev-parse', '--is-inside-work-tree' })[1]
    == 'true'

  if is_git_project then
    require('fzf-lua').git_files()
  else
    require('fzf-lua').files()
  end
end, { desc = '[S]earch [F]iles' })

keymap(
  'n',
  '<leader>sc',
  function() require('fzf-lua').files { cwd = vim.fn.stdpath 'config' } end,
  { desc = '[S]earch [C]onfig' }
)

keymap(
  'n',
  '<leader><leader>',
  function() require('fzf-lua').history() end,
  { desc = 'Search History' }
)

keymap(
  'n',
  '<leader>sw',
  function() require('fzf-lua').live_grep_native() end,
  { desc = '[S]earch [W]ord' }
)

keymap('n', '<leader>ut', function() require('fzf-lua').undotree() end, { desc = '[U]ndo [T]ree' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp.bufdir', { clear = true }),

  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method('workspace/symbol', ev.buf) then
      keymap(
        'n',
        '<leader>ws',
        function() require('fzf-lua').lsp_live_workspace_symbols() end,
        { buffer = ev.buf, desc = '[W]orkspace [S]ymbols' }
      )
    end

    if client:supports_method('textDocument/codeAction', ev.buf) then
      keymap(
        'n',
        '<leader>ca',
        function() require('fzf-lua').lsp_code_actions() end,
        { buffer = ev.buf, desc = '[C]ode [A]ction' }
      )
    end

    if client:supports_method('textDocument/references', ev.buf) then
      keymap(
        'n',
        '<leader>cr',
        function() require('fzf-lua').lsp_references() end,
        { buffer = ev.buf, desc = '[C]ode [R]eferences' }
      )
    end

    if client:supports_method('textDocument/definition', ev.buf) then
      keymap(
        'n',
        '<leader>cd',
        function() require('fzf-lua').lsp_definitions() end,
        { buffer = ev.buf, desc = '[C]ode [D]efinition' }
      )
    end

    if client:supports_method('textDocument/declaration', ev.buf) then
      keymap(
        'n',
        '<leader>cD',
        function() require('fzf-lua').lsp_declarations() end,
        { buffer = ev.buf, desc = '[C]ode [D]eclaration' }
      )
    end

    if client:supports_method('textDocument/implementation', ev.buf) then
      keymap(
        'n',
        '<leader>ci',
        function() require('fzf-lua').lsp_implementations() end,
        { buffer = ev.buf, desc = '[C]ode [I]mplementation' }
      )
    end

    if client:supports_method('textDocument/rename', ev.buf) then
      keymap(
        'n',
        '<leader>crn',
        function() vim.lsp.buf.rename() end,
        { buffer = ev.buf, desc = 'Code [R]e[n]ame' }
      )
    end

    if client:supports_method('textDocument/typeDefinition', ev.buf) then
      keymap(
        'n',
        '<leader>ct',
        function() require('fzf-lua').lsp_typedefs() end,
        { buffer = ev.buf, desc = '[C]ode [T]ype Definition' }
      )
    end

    if client:supports_method('textDocument/documentSymbol', ev.buf) then
      keymap(
        'n',
        '<leader>cs',
        function() require('fzf-lua').lsp_document_symbols() end,
        { buffer = ev.buf, desc = '[C]ode [S]ymbols' }
      )
    end

    if client:supports_method('textDocument/hover', ev.buf) then
      keymap(
        'n',
        '<leader>ch',
        function() vim.lsp.buf.hover() end,
        { buffer = ev.buf, desc = '[C]ode [H]over' }
      )
    end

    if client:supports_method('textDocument/signatureHelp', ev.buf) then
      keymap(
        'n',
        '<leader>ck',
        function() vim.lsp.buf.signature_help() end,
        { buffer = ev.buf, desc = '[C]ode Signature Help' }
      )
    end

    if client:supports_method('textDocument/codeLens', ev.buf) then
      keymap(
        'n',
        '<leader>cl',
        function() vim.lsp.codelens.run() end,
        { buffer = ev.buf, desc = '[C]ode [L]ens' }
      )
    end

    if client.root_dir then
      -- TODO: nvim 0.13 use bcd
      vim.api.nvim_buf_call(ev.buf, function() vim.cmd.lcd(client.root_dir) end)
    end
  end,
})
