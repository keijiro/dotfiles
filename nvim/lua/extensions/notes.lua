require("notes").setup{
  dir = vim.fn.expand("~/.notes"),
  repo = "git@github.com:keijiro/notes.git",
}

-- Hide line numbers and wrap per character in the editor window {{{
local open_in_edit = require("notes.ui").open_in_edit
require("notes.ui").open_in_edit = function(path)
  open_in_edit(path)
  local st = require("notes").state
  if st.edit_win and vim.api.nvim_win_is_valid(st.edit_win) then
    vim.wo[st.edit_win].number = false
    vim.wo[st.edit_win].relativenumber = false
    vim.wo[st.edit_win].linebreak = false
  end
end
-- }}}

-- Enable ProseMode while the Folders/Notes panels are hidden {{{
local ui = require("notes.ui")
local prose = require("extensions.noneckpain")

local function with_edit_win(fn)
  local st = require("notes").state
  if not (st.edit_win and vim.api.nvim_win_is_valid(st.edit_win)) then return end
  vim.api.nvim_win_call(st.edit_win, function()
    fn(vim.api.nvim_get_current_buf())
  end)
end

local function prose_off()
  with_edit_win(function(buf)
    if vim.b[buf].prose_mode then prose.disable_prose(buf) end
  end)
end

local toggle_panels = ui.toggle_panels
ui.toggle_panels = function()
  local st = require("notes").state
  if st.panels_hidden then
    -- Remove the side buffers before the panels are split off again
    prose_off()
    toggle_panels()
  else
    toggle_panels()
    if st.panels_hidden then
      with_edit_win(function(buf)
        if not vim.b[buf].prose_mode then prose.enable_prose(buf) end
      end)
    end
  end
end

local close = ui.close
ui.close = function()
  local st = require("notes").state
  if st.panels_hidden and st.tab == vim.api.nvim_get_current_tabpage() then
    prose_off()
  end
  close()
end
-- }}}
