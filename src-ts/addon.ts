import { createRequire } from 'node:module'
import { join } from 'node:path'
import bindings from 'bindings'

export type PasteboardItem = Record<string, string | Buffer>

export type Addon = {
  path?: string // why this ?
  clearContents: () => void
  readBuffer: (format: string) => Buffer
  readBuffers: (format: string) => Buffer[]
  writeVariadicPasteboardItems: (...items: PasteboardItem[]) => boolean
  declareTypeAndSetData: (format: string, data: Buffer | string) => boolean
}

const require = createRequire(import.meta.filename)

function tryBuildRelease() {
  try {
    return {
      path: join(import.meta.dirname, '../build/Release/simple_mac_clipboard.node'),
      ...require('../build/Release/simple_mac_clipboard.node'),
    }
  } catch {
    return
  }
}

function tryFatNode() {
  try {
    return {
      path: join(import.meta.dirname, '../simple_mac_clipboard.node'),
      ...require('../simple_mac_clipboard.node'),
    }
  } catch {
    return
  }
}

export const addon: Addon = tryBuildRelease() || tryFatNode() || bindings('simple_mac_clipboard')
