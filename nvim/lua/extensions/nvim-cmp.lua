local cmp = require('cmp')
cmp.setup({
   mapping = {
    ['<C-space>'] = cmp.mapping.complete(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  },
  sources = {
    { name = 'codeium' },
  }, 
})
