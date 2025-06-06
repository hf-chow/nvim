vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins"},
    { "NMAC427/guess-indent.nvim"},
    { 'lewis6991/gitsigns.nvim',opts = {}},
    { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme "tokyonight-night" end },
--    { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' }},
    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
    { 'stevearc/conform.nvim'},
--    { 'saghen/blink.cmp' },
--    { 'mason-org/mason.nvim' },
--    { 'mason-org/mason-lspconfig.nvim' },
    { 'folke/lazydev.nvim', ft = 'lua', opts = { library = {{ path = '${3rd}/luv/library', words = { 'vim%.uv' }}}}},
    {
      'neovim/nvim-lspconfig',
      dependencies = { 
          {'mason-org/mason.nvim', opts={}},
          'mason-org/mason-lspconfig.nvim',
          'WhoIsSethDaniel/mason-tool-installer.nvim',
          'j-hui/fidget.nvim',
          'saghen/blink.cmp',
      }, -- Added explicit dependency
      config = function()
       vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })

          end
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local servers = {
          clangd = {},
          gopls = {},
          pyright = {},
          rust_analyzer = {},
        }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
          'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
          ensure_installed = {},
          automatic_installation = false,
          handlers = {
              function(server_name) 
                local server = servers[server_name] or {}
                server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, sever.capabilities or {})
                require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
     },
     { -- Highlight, edit, and navigate code
         'nvim-treesitter/nvim-treesitter',
         build = ':TSUpdate',
         main = 'nvim-treesitter.configs', -- Sets main module to use for opts
         opts = {
             ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
             auto_install = true,
             highlight = {
                 enable = true,
                 additional_vim_regex_highlighting = { 'ruby' },
             },
             indent = { enable = true, disable = { 'ruby' } },
         },
     },
     { 'WhoIsSethDaniel/mason-tool-installer.nvim', 
        opts = {
            ensure_installed = {
                'gopls',
                'lua-language-server',
                'vim-language-server',
                'stylua',
                'shellcheck',
                'editorconfig-checker',
                'gofumpt',
                'golines',
                'gomodifytags',
                'gotests',
                'impl',
                'json-to-struct',
                'luacheck',
                'misspell',
                'revive',
                'shellcheck',
                'shfmt',
                'staticcheck',
                'vint',
                'zls',
                'pyright',
                'rust_analyzer',
                'sqlls',
            },
            run_on_start = true,
            start_delay = 1000, -- 3 second delay
            debounce_hours = 5, -- at least 5 hours between attempts to install/update
            integrations = {
              ['mason-lspconfig'] = true,
              ['mason-null-ls'] = true,
              ['mason-nvim-dap'] = true,
            },
        } 
    },
  },
  checker = { enabled = true },
})
