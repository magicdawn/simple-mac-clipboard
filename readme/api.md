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
