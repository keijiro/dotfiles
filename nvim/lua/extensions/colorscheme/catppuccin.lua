require("catppuccin").setup({
    styles = {
        comments = {"italic"},
        conditionals = {},
        loops = {"italic"},
        functions = {},
        keywords = {"italic"},
        strings = {"italic"},
        variables = {},
        numbers = {},
        booleans = {"italic"},
        properties = {},
        types = {},
        operators = {},
    },
    color_overrides = {
      all = {
        base = "#282C34",
        text = "#DCDFE4",
      },
    },
})

vim.cmd("colorscheme catppuccin")
