const bin = require('bindings')('native_clipboard')

// hello
// bin.hello('你好')

// copyToClipboard
bin.clearContents()
bin.setStringData('/a/b/c.txt', 'public.file-url')
