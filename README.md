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

> based on https://developer.apple.com/documentation/appkit/nspasteboard

```js
const clip = require('simple-mac-clipboard')
```

### Note

- for read & write, format is required, and format is always the **first** argument
- for write, the boolean return value is for success or not, map from objc `YES` or `NO`

### `clear`

```ts
export function clear(): void
```

clear the clipboard

### readBuffer & writeBuffer

```ts
export function readBuffer(format: string): Buffer
export function writeBuffer(format: string, data: Buffer): boolean
```

read or write `Buffer` from/to the clipboard

### readText & writeText

```ts
export function readText(format: string): string
export function writeText(format: string, text: string): boolean
```

read or write text from/to the clipboard

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

the MIT License http://magicdawn.mit-license.org
