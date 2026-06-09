import { createRequire } from 'node:module'
import { join } from 'node:path'
import bindings from 'bindings'

export type Addon = {
  path?: string // why this ?
  clearContents: () => void
  dataForType: (format: string) => Buffer
  allDataForType: (format: string) => Buffer[]
  setData: (format: string, data: Buffer) => boolean
  setDataAll: (format: string, datas: Buffer[]) => boolean
}

const require = createRequire(import.meta.dirname)

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
