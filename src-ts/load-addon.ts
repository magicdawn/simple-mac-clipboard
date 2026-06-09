import { createRequire } from 'node:module'
import { join } from 'node:path'
import bindings from 'bindings'

const require = createRequire(__filename)

export type Addon = {
  path?: string // why this ?
  clearContents: () => void
  dataForType: (format: string) => Buffer
  allDataForType: (format: string) => Buffer[]
  setData: (format: string, data: Buffer) => boolean
  setDataAll: (format: string, datas: Buffer[]) => boolean
}

function tryFile(file: string) {
  try {
    return { path: join(__dirname, file), ...require(file) }
  } catch {
    return
  }
}

export const addon: Addon = tryFile('../simple_mac_clipboard.node') || bindings('simple_mac_clipboard')
