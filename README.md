# native-clipboard

>

[![Build Status](https://img.shields.io/travis/magicdawn/native-clipboard.svg?style=flat-square)](https://travis-ci.org/magicdawn/native-clipboard)
[![Coverage Status](https://img.shields.io/codecov/c/github/magicdawn/native-clipboard.svg?style=flat-square)](https://codecov.io/gh/magicdawn/native-clipboard)
[![npm version](https://img.shields.io/npm/v/native-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/native-clipboard)
[![npm downloads](https://img.shields.io/npm/dm/native-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/native-clipboard)
[![npm license](https://img.shields.io/npm/l/native-clipboard.svg?style=flat-square)](http://magicdawn.mit-license.org)

## Install

```sh
$ npm i native-clipboard --save
```

## API

```js
const nativeClipboard = require('native-clipboard')
```

- `clearContents`
- `setStringData(data, format)`

和 NSPasteboard 提供的方法一样
https://developer.apple.com/documentation/appkit/nspasteboard

## Build

# `process.versions.module`

- v6.1.3, process.versions.module = 73
- v7.1.13, process.versions.module = 75

### 使用 electron-build

```sh
electron-rebuild -v 7.1.13
```

生成 `bin/${process.platform}-${process.arch}-${process.versions.module}/native-clipboard.node`

### 使用 node-gyp

```sh
HOME=~/.electron-gyp node-gyp rebuild --arch=x64 --dist-url=https://electronjs.org/headers --target=7.1.13
```

即 `yarn build --target=7.1.13`, 生成 `build/Release/native_clipboard.node`

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

the MIT License http://magicdawn.mit-license.org
