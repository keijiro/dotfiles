--[[
  File: noneckpain.lua
  Description: Center the buffer at a fixed width and provide a "prose" toggle
               that combines soft wrap, visual-line movement and centering.
  See: https://github.com/shortcuts/no-neck-pain.nvim
]]

require("no-neck-pain").setup({
  -- Fix the main buffer width so soft wrap folds at this column
  width = 80,
})

-- ProseMode: toggle soft wrap + visual-line movement + centered 80 columns {{{
local function enable_prose(buf)
  -- Remember the current wrap so we can restore it on disable
  vim.b[buf].prose_saved_wrap = vim.wo.wrap

  -- Soft wrap (display only, no real newlines inserted)
  vim.wo.wrap = true

  -- Move by visual line; keep data-line move when a count is given (e.g. 5j)
  vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, buffer = buf })
  vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, buffer = buf })

  -- Constrain the buffer to 80 columns so soft wrap folds there
  require("no-neck-pain").enable()

  vim.b[buf].prose_mode = true
end

local function disable_prose(buf)
  -- Drop the buffer local visual-line mappings (back to default j/k)
  pcall(vim.keymap.del, "n", "j", { buffer = buf })
  pcall(vim.keymap.del, "n", "k", { buffer = buf })

  -- Restore the previous wrap setting
  if vim.b[buf].prose_saved_wrap ~= nil then
    vim.wo.wrap = vim.b[buf].prose_saved_wrap
  end

  -- Remove the centering
  require("no-neck-pain").disable()

  vim.b[buf].prose_mode = false
end

local function toggle_prose()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].prose_mode then
    disable_prose(buf)
  else
    enable_prose(buf)
  end
end

vim.api.nvim_create_user_command("ProseMode", toggle_prose, {
  desc = "Toggle prose mode (soft wrap + visual-line movement + 80 col centering)",
})
-- }}}
