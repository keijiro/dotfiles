--[[
  File: init.lua
  Description: Entry point file for neovim
]]

-- Bootsraping plugin manager
require "lazy-bootstrap"

-- Settings
require "settings"
require "keybindings"

-- Plugin management {{{
local lazy = require("lazy")
lazy.setup("plugins")
-- }}}

require "cdupm"
vim.api.nvim_create_user_command(
  "CDUPM",
  function() require("cdupm").change_to_package_cache() end,
  {}
)

-- vim:tabstop=2 shiftwidth=2 expandtab syntax=lua foldmethod=marker foldlevelstart=0 foldlevel=0
