import { addon, type PasteboardItem } from './addon'

// addon export
export const addonPath = addon.path

export const clear = addon.clearContents

// #region format
export enum ClipboardFormat {
  FileUrl = 'public.file-url',
  PlainText = 'public.utf8-plain-text',
  SourceAppBundleId = 'org.nspasteboard.source',
}
export const FORMAT_PLAIN_TEXT = ClipboardFormat.PlainText
export const FORMAT_FILE_URL = ClipboardFormat.FileUrl
export const FORMAT_SOURCE_APP_BUNDLE_ID = ClipboardFormat.SourceAppBundleId
// #endregion

// #region read
export const readBuffer = addon.readBuffer
export const readBuffers = addon.readBuffers
export const readText = (format: string) => readBuffer(format).toString('utf8')
export const readTexts = (format: string) => readBuffers(format).map((buf) => buf.toString('utf8'))
// #endregion

// #region write
export type { PasteboardItem } from './addon'

export function writePasteboardItems(...items: Array<PasteboardItem | PasteboardItem[]>): boolean {
  const _items = items.flat()
  return addon.writeVariadicPasteboardItems(..._items)
}

export function writeFormat(format: string, ...datas: Array<Buffer | string | Buffer[] | string[]>): boolean {
  if (!format) throw new Error('format is required')
  const _datas = datas.flat()
  return writePasteboardItems(..._datas.map((d) => ({ [format]: d })))
}

/**
 * write single item with invalid UTI
 * [NSPasteboard declareTypes:owner:] 是极早期版本的 macOS API
 * 它对字符串的格式校验非常宽松，允许通过传统的非 UTI 字符串来建立剪贴板通道。
 */
export const declareTypeAndSetData = addon.declareTypeAndSetData
// #endregion

export const clip = {
  addonPath,
  clear,

  readBuffer,
  readBuffers,
  readText,
  readTexts,

  writePasteboardItems,
  writeFormat,
  declareTypeAndSetData,

  ClipboardFormat,
  FORMAT_PLAIN_TEXT,
  FORMAT_FILE_URL,
  FORMAT_SOURCE_APP_BUNDLE_ID,
}
export default clip
