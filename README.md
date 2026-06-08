# simple-mac-clipboard

> simple mac clipboard for node &amp; electron

[![npm version](https://img.shields.io/npm/v/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm downloads](https://img.shields.io/npm/dm/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm license](https://img.shields.io/npm/l/simple-mac-clipboard.svg?style=flat-square)](http://magicdawn.mit-license.org)

## Install

```sh
$ npm i -S simple-mac-clipboard
```

## Related

https://github.com/electron/electron/issues/9035

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

### `read`

```ts
// single item
export function readBuffer(format: string): Buffer
export function readText(format: string): string

// items
export function readBuffers(format: string): Buffer[]
export function readTexts(format: string): string[]
```

### `write`

```ts
// single item
export function writeBuffer(format: string, data: Buffer): boolean
export function writeText(format: string, text: string): boolean

// items
export function writeBuffers(format: string, data: Buffer[]): boolean
export function writeTexts(format: string, text: string[]): boolean
```

### predefined `Formats`

`FORMAT_PLAIN_TEXT` / `FORMAT_FILE_URL` / `FORMAT_SOURCE_APP_BUNDLE_ID`

## read/write File Paths

```ts
import { FORMAT_FILE_URL, readTexts, writeTexts } from 'simple-mac-clipboard'
import { fileURLToPath, pathToFileURL } from 'node:url'

const filePaths = ['/tmp/a/b.txt', '/tmp/c']

// write
writeTexts(
  FORMAT_FILE_URL,
  filePaths.map((p) => pathToFileURL(p).href),
)

// read
console.log(readTexts(FORMAT_FILE_URL).map((u) => fileURLToPath(u)))
```

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

the MIT License http://magicdawn.mit-license.org
