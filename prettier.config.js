module.exports = {
  ...require('@magicdawn/prettier-config'),
  overrides: [
    {
      files: ['**/*.gyp'],
      options: {
        parser: 'json',
      },
    },
  ],
}
