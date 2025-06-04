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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins"},
    { "NMAC427/guess-indent.nvim"},
    { 'lewis6991/gitsigns.nvim',opts = {}},
    { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme "tokyonight-night" end },
    { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' }},
    { 'folke/lazydev.nvim', ft = 'lua', opts = { library = {{ path = '${3rd}/luv/library', words = { 'vim%.uv' }}}}},
    { 'stevearc/conform.nvim'},
    { 'saghen/blink.cmp' },
    { 'mason-org/mason.nvim' },
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
