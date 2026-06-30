# simple-mac-clipboard

> simple mac clipboard for node &amp; electron

[![npm version](https://img.shields.io/npm/v/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm downloads](https://img.shields.io/npm/dm/simple-mac-clipboard.svg?style=flat-square)](https://www.npmjs.com/package/simple-mac-clipboard)
[![npm license](https://img.shields.io/npm/l/simple-mac-clipboard.svg?style=flat-square)](http://magicdawn.mit-license.org)

## Install

```sh
$ pnpm add simple-mac-clipboard
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

#### `writeFormat`

```ts
// typedef
export function writeFormat(format: string, ...datas: Array<Buffer | string | Buffer[] | string[]>): boolean
```

```ts
// example
import clip from 'simple-mac-clipboard'
clip.writeFormat(clip.FORMAT_PLAIN_TEXT, 'text1', Buffer.from('text2'), [Buffer.from('text3'), 'text4'])
```

#### `writePasteboardItems`

```ts
// typedef
export type PasteboardItem = Record<string, Buffer | string>
export function writePasteboardItems(...items: Array<PasteboardItem | PasteboardItem[]>): boolean
```

```ts
// example
import clip from 'simple-mac-clipboard'
clip.writePasteboardItems(
  { 'item1-format1': 'text1' },
  { 'item2-format1': Buffer.from('text2'), 'item2-format2': 'text2', [clip.FORMAT_PLAIN_TEXT]: 'text3' },
)
clip.writePasteboardItems([
  { 'item1-format1': 'text1' },
  { 'item2-format1': Buffer.from('text2'), 'item2-format2': 'text2', [clip.FORMAT_PLAIN_TEXT]: 'text3' },
])
```

#### `declareTypeAndSetData`

> write single item with invalid UTI
> [NSPasteboard declareTypes:owner:] 是极早期版本的 macOS API
> 它对字符串的格式校验非常宽松，允许通过传统的非 UTI 字符串来建立剪贴板通道。

```ts
// typedef
export function declareTypeAndSetData(format: string, data: Buffer | string): boolean
```

```ts
// example
import { declareTypeAndSetData, readText } from 'simple-mac-clipboard'
declareTypeAndSetData('invalid-uti-without-dot', 'invalid-uti-without-dot-content')
expect(readText('invalid-uti-without-dot')).toEqual('invalid-uti-without-dot-content')
```

### predefined `Formats`

`FORMAT_PLAIN_TEXT` / `FORMAT_FILE_URL` / `FORMAT_SOURCE_APP_BUNDLE_ID`

## read/write File Paths

```ts
import { FORMAT_FILE_URL, readTexts, writeFormat } from 'simple-mac-clipboard'
import { fileURLToPath, pathToFileURL } from 'node:url'

const filePaths = ['/tmp/a/b.txt', '/tmp/c']

// write
writeFormat(FORMAT_FILE_URL, ...filePaths.map((p) => pathToFileURL(p).href))

// read
console.log(readTexts(FORMAT_FILE_URL).map((u) => fileURLToPath(u)))
```

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

the MIT License http://magicdawn.mit-license.org
