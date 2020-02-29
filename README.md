# simple-mac-clipboard

> simple mac clipboard for node &amp; electron

[![npm version](https://img.shields.io/npm/v/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm downloads](https://img.shields.io/npm/dm/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm license](https://img.shields.io/npm/l/simple-mac-clipboard.svg?style=flat-square)](http://magicdawn.mit-license.org)

## Install

```sh
$ npm i -S simple-mac-clipboard
```

## API

```js
const clip = require('simple-mac-clipboard')
```

- `clearContents`
- `setStringData(data, format)`

as NSPasteboard.generalPasteboard provides, see
https://developer.apple.com/documentation/appkit/nspasteboard

### `setData`

this module only support set string type data

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

the MIT License http://magicdawn.mit-license.org
