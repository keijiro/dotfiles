--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

require "helpers/globals"

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Set associating between turned on plugins and filetype
cmd[[filetype plugin on]]

-- Disable comments on pressing Enter
local general_group = augroup("dotfiles_general", { clear = true })
autocmd("FileType", {
  group = general_group,
  callback = function()
    vim.opt_local.formatoptions = vim.opt_local.formatoptions - { "c", "r", "o" }
  end,
})

vim.filetype.add({
  extension = {
    compute = "hlsl",
    uss = "css",
    tss = "css",
    uxml = "xml",
  },
})

opt.colorcolumn = "80"
opt.wrap = false
opt.termguicolors = true

-- Tabs {{{
opt.expandtab = true                -- Use spaces by default
opt.shiftwidth = 4                  -- Set amount of space characters, when we press "<" or ">"
opt.tabstop = 4                     -- Keep tab characters aligned to 4 spaces
opt.smartindent = true              -- Turn on smart indentation. See in the docs for more info
-- }}}

-- Clipboard {{{
opt.clipboard = 'unnamedplus' -- Use system clipboard
opt.fixeol = false -- Turn off appending new line in the end of a file
-- }}}

-- Folding {{{
opt.foldmethod = 'syntax'
opt.foldlevel = 99
-- }}}

-- Search {{{
opt.ignorecase = true               -- Ignore case if all characters in lower case
opt.joinspaces = false              -- Join multiple spaces in search
opt.smartcase = true                -- When there is a one capital letter search for exact match
opt.showmatch = true                -- Highlight search instances
-- }}}

-- Window {{{
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new vertical splits to right
-- }}}

-- Wild Menu {{{
opt.wildmenu = true
opt.wildmode = "longest:full,full"
-- }}}

-- Default Plugins {{{
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin] = 1
end
-- }}}

-- vim: tabstop=2 shiftwidth=2 expandtab syntax=lua foldmethod=marker foldlevelstart=1
