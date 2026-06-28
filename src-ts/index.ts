import { addon } from './load-addon'

// addon export
export const addonPath = addon.path

// base functions
export const clear = addon.clearContents
export const readBuffer = addon.readBuffer
export const readBuffers = addon.readBuffers
export const writeBuffer = addon.writeBuffer
export const writeBuffers = addon.writeBuffers

export type { PasteboardItem } from './load-addon'
export const writePasteboardItems = addon.writePasteboardItems

// convenient functions
// format is the first parameter & required
export const writeText = (format: string, text: string) => writeBuffer(format, Buffer.from(text))
export const writeTexts = (format: string, texts: string[]) =>
  writeBuffers(
    format,
    texts.map((t) => Buffer.from(t)),
  )
export const readText = (format: string) => readBuffer(format).toString('utf8')
export const readTexts = (format: string) => readBuffers(format).map((buf) => buf.toString('utf8'))

// format
export enum ClipboardFormat {
  FileUrl = 'public.file-url',
  PlainText = 'public.utf8-plain-text',
  SourceAppBundleId = 'org.nspasteboard.source',
}
export const FORMAT_PLAIN_TEXT = ClipboardFormat.PlainText
export const FORMAT_FILE_URL = ClipboardFormat.FileUrl
export const FORMAT_SOURCE_APP_BUNDLE_ID = ClipboardFormat.SourceAppBundleId

export const clip = {
  addonPath,
  clear,

  readBuffer,
  readBuffers,
  readText,
  readTexts,

  writeBuffer,
  writeBuffers,
  writeText,
  writeTexts,
  writePasteboardItems,

  ClipboardFormat,
  FORMAT_PLAIN_TEXT,
  FORMAT_FILE_URL,
  FORMAT_SOURCE_APP_BUNDLE_ID,
}
export default clip
