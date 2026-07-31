-- Install lazy.nvim automatically
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin list
require("lazy").setup({
  -- Telescope (fuzzy finder)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Color scheme
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 10000,
    config = function()
      vim.cmd('colorscheme rose-pine')
    end
  },

  -- Treesitter (better syntax highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    init = function(plugin)
      vim.opt.rtp:prepend(plugin.dir .. '/runtime')
    end,
    opts = {
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "query",
        "javascript", "typescript", "python",
        "rust", "go", "html", "css", "json",
        "yaml", "markdown"
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },
  -- Harpoon (quick file navigation)
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Undotree (visual undo history)
  'mbbill/undotree',

  -- Fugitive (git)
  'tpope/vim-fugitive',

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
    },
  },

  -- Conform (formatter)
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        go = { 'gofmt' },
        rust = { 'rustfmt' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile    = { enabled = false },
      dashboard  = { enabled = false },
      explorer   = { enabled = false },
      image      = { enabled = false },
      gh         = { enabled = false },
      notifier   = { enabled = true },
      quickfile  = { enabled = false },
      scope      = { enabled = false },
      scroll     = { enabled = false },
      statuscolumn = { enabled = false },
      words      = { enabled = false },
      input = {},
      picker = {
        actions = {
          opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },

  -- opencode.nvim
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true

      vim.keymap.set({ 'n', 'x' }, '<C-a>', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode...' })
      vim.keymap.set({ 'n', 'x' }, '<C-x>', function() require('opencode').select() end, { desc = 'Execute opencode action...' })
      vim.keymap.set({ 'n', 't' }, '<C-.>', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
    end,
  },
})
