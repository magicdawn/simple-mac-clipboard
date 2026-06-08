module.exports = {
  ...require('@magicdawn/prettier-config'),
  overrides: [
    {
      files: ['**/*.gyp', '**/.*rc'],
      options: {
        parser: 'json',
      },
    },
  ],
}
