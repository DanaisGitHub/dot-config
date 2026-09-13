local M = {}

M.languages = {
  "c", "lua", "vim", "vimdoc", "query",
  "javascript", "typescript", "python", "rust", "go",
  "html", "css", "json", "yaml", "markdown", "markdown_inline",
}

function M.install()
  return require("nvim-treesitter").install(M.languages)
end

function M.setup()
  -- The rewritten plugin installs parsers and matching queries together here.
  -- Prepending this path also supersedes stale parsers from the old plugin tree.
  require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
  M.install()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("DanaTreesitter", { clear = true }),
    callback = function(event)
      -- Some filetypes have no parser; retain normal highlighting for those.
      pcall(vim.treesitter.start, event.buf)
    end,
  })
end

return M
