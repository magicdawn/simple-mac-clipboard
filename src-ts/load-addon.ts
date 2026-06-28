import { createRequire } from 'node:module'
import { join } from 'node:path'
import bindings from 'bindings'

export type PasteboardItem = Record<string, string | Buffer>

export type Addon = {
  path?: string // why this ?
  clearContents: () => void
  readBuffer: (format: string) => Buffer
  readBuffers: (format: string) => Buffer[]
  writeBuffer: (format: string, data: Buffer) => boolean
  writeBuffers: (format: string, datas: Buffer[]) => boolean
  writePasteboardItems: (items: PasteboardItem[]) => void
}

const require = createRequire(import.meta.filename)

function tryAddon() {
  try {
    return {
      path: join(import.meta.dirname, '../simple_mac_clipboard.node'),
      ...require('../simple_mac_clipboard.node'),
    }
  } catch {
    return
  }
}

export const addon: Addon = tryAddon() || bindings('simple_mac_clipboard')
