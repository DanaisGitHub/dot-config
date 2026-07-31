-- Line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Indentation (Prime uses 4 spaces)
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- No line wrap
vim.opt.wrap = false

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Fast update time
vim.opt.updatetime = 50

-- Column guide at 80 characters
vim.opt.colorcolumn = "80"

-- Leader key
vim.g.mapleader = " "

-- Sync clipboard between OS and Neovim
vim.opt.clipboard = "unnamedplus"

-- Code folding
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
