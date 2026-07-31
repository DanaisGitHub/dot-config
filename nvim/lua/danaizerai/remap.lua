local keymap = vim.keymap.set

-- File explorer (netrw) - Prime uses this instead of file trees
keymap("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines up/down (visual mode)
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Keep search terms in middle of screen
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- Paste without losing clipboard
keymap("x", "<leader>p", "\"_dP")

-- System clipboard yank
keymap("n", "<leader>y", "\"+y")
keymap("v", "<leader>y", "\"+y")
keymap("n", "<leader>Y", "\"+Y")

-- Delete to void register (don't copy deleted text)
keymap("n", "<leader>d", "\"_d")
keymap("v", "<leader>d", "\"_d")

-- Never press capital Q (ex mode is useless)
keymap("n", "Q", "<nop>")

-- Quick fix navigation
keymap("n", "<C-k>", "<cmd>cnext<CR>zz")
keymap("n", "<C-j>", "<cmd>cprev<CR>zz")

-- Replace word under cursor in entire file
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Make file executable
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Format file
keymap("n", "<leader>I", function()
  require("conform").format({ async = true, lsp_fallback = true })
end)

-- Folding
keymap("n", "<leader><space>", "za", { desc = "Toggle fold" })
