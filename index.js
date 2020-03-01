const bin = require('bindings')('simple_mac_clipboard')
const {path, clearContents, dataForType, setData} = bin

// alias
const clear = clearContents
const readBuffer = dataForType
const writeBuffer = setData

// convenient
// format is the first parameter & required
const readText = format => readBuffer(format).toString('utf8')
const writeText = (format, text) => writeBuffer(format, Buffer.from(text))

// format
const FORMAT_PLAIN_TEXT = 'public.utf8-plain-text'
const FORMAT_FILE_URL = 'public.file-url'

Object.assign(module.exports, {
  path, // the .node path

  clear,
  readBuffer,
  writeBuffer,
  readText,
  writeText,

  FORMAT_PLAIN_TEXT,
  FORMAT_FILE_URL,
})
