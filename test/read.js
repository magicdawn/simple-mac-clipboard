const should = require('should')
const {FORMAT_PLAIN_TEXT, clear, readBuffer, readText} = require('..')
const {clipboard} = require('electron')

describe('.readBuffer', () => {
  it('it works', async () => {
    let data

    const content = '哈哈nihao'
    const format = 'public.utf8-plain-text'

    // electron write
    clipboard.writeBuffer(format, Buffer.from(content))

    // addon read
    data = readBuffer(format)
    data.should.instanceOf(Buffer)
    data.equals(Buffer.from(content)).should.ok()
  })

  it('when arguments error', async () => {
    readBuffer.should.throw(/wrong number of arguments/)
    readBuffer.bind(null, 1).should.throw(/string expected/)
  })

  it('when empty clipboard', async () => {
    let data

    // clean
    clear()

    // read
    const format = 'public.utf8-plain-text'
    data = readBuffer(format)
    data.should.instanceOf(Buffer)
    data.byteLength.should.equal(0)
  })
})

describe('.readText', () => {
  it('it works ', () => {
    clipboard.writeText(__filename)
    readText(FORMAT_PLAIN_TEXT).should.equal(__filename)
  })
})
