import { createRequire } from 'node:module'
import { join } from 'node:path'
import bindings from 'bindings'

const _require = createRequire(__filename)

function tryFile(file: string) {
  return { path: join(__dirname, file), ..._require(file) }
}

const tryRelease = () => {
  try {
    // prevent webpack error
    const type = 'Release'
    return tryFile(`../build/${type}/simple_mac_clipboard.node`)
  } catch {
    //  noop
  }
}
const tryDebug = () => {
  try {
    // prevent webpack error
    const type = 'Debug'
    return tryFile(`../build/${type}/simple_mac_clipboard.node`)
  } catch {
    //  noop
  }
}

export type Addon = {
  path?: string // why this ?
  clearContents: () => void
  dataForType: (format: string) => Buffer
  allDataForType: (format: string) => Buffer[]
  setData: (format: string, data: Buffer) => boolean
  setDataAll: (format: string, datas: Buffer[]) => boolean
}

export const addon: Addon = tryRelease() || tryDebug() || bindings('simple_mac_clipboard')
