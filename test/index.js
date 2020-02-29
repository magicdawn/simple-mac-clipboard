const should = require('should')
const clip = require('..')
const {clipboard} = require('electron')

describe('It works', () => {
  it.skip('demo ', async () => {
    // hello
    // bin.hello('你好')

    // copyToClipboard
    const ret = clip.setStringData('c.txt', 'public.utf8-plain-text')
    console.log(ret)
    clip.setStringData('/a/b/c.txt', 'public.file-url')
  })

  it('#clearContents ', () => {
    clip.clearContents()
    clipboard.readText().length.should.equal(0)
  })

  it('#setStringData', () => {
    // set
    const success = clip.setStringData(__filename, 'public.file-url')
    success.should.equal(true)

    // read
    const content = clipboard.readBuffer('public.file-url').toString('utf8')
    should(content).ok()
    content.should.equal(__filename)
  })

  it('#setStringData error', () => {
    // no args
    clip.setStringData.should.throw(/wrong number/)

    // not string
    clip.setStringData.bind(null, 1, 'hello').should.throw(/arguments type does not match/)
  })
})
