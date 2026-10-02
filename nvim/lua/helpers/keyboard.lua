-- Keybinding setters (noremap) for each mode
local M = {}

local function setter(mode)
  return function(key, command)
    vim.keymap.set(mode, key, command, { noremap = true })
  end
end

M.nm = setter('n') -- Normal mode
M.im = setter('i') -- Insert mode
M.vm = setter('v') -- Visual mode
M.tm = setter('t') -- Terminal mode

return M
