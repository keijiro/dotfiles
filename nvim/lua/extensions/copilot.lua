require("copilot").setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<Tab>",
      next = "<D-]>",
      prev = "<D-[>",
    },
  },
  filetypes = {
    cs = true,
    ["*"] = false,
  }
})
