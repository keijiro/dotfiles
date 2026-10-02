--[[
  File: treesitter.lua
  Description: Configuration of tree-sitter
  See: https://github.com/nvim-treesitter/nvim-treesitter
]]
local treesitter = require("nvim-treesitter")

-- Needed parsers (no-op when already installed; requires tree-sitter-cli)
treesitter.install {
  "lua",
  "typescript",
  "javascript",
  "go",
  "python",
}

-- Highlighting: enable for every filetype that has an available parser
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
