return {
  filetypes = { 'graphql' },
  root_dir = require('lspconfig.util').root_pattern('.git', '.graphqlrc'),
  settings = {
    graphql = {
      schema = {
        files = { 'schema.graphql', 'schema.json' },
      },
    },
  },
}
