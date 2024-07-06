import bindings from 'bindings'
import { createRequire } from 'module'
import { join } from 'path'

const _require = createRequire(__filename)

function tryFile(file: string) {
  return { path: join(__dirname, file), ..._require(file) }
}

const tryRelease = () => {
  try {
    // prevent webpack error
    const type = 'Release'
    return tryFile(`../build/${type}/simple_mac_clipboard.node`)
  } catch (e) {
    //  noop
  }
}
const tryDebug = () => {
  try {
    // prevent webpack error
    const type = 'Debug'
    return tryFile(`../build/${type}/simple_mac_clipboard.node`)
  } catch (e) {
    //  noop
  }
}

export type Addon = {
  path?: string // why this ?
  clearContents(): void
  dataForType(format: string): Buffer
  allDataForType(format: string): Buffer[]
  setData(format: string, data: Buffer): boolean
}

export const addon: Addon = tryRelease() || tryDebug() || bindings('simple_mac_clipboard')
