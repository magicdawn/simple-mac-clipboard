const should = require('should')
const { FORMAT_PLAIN_TEXT, clear, writeBuffer, writeText } = require('..')
const { clipboard } = require('electron')

describe('.writeBuffer', () => {
  it('it works', () => {
    let data

    const content = '哈哈nihao'
    const format = 'public.utf8-plain-text'

    // addon write
    const success = writeBuffer(format, Buffer.from(content))
    success.should.ok()

    // electron read
    data = clipboard.readBuffer(format)
    data.should.instanceOf(Buffer)
    data.equals(Buffer.from(content)).should.ok()
  })

  it('when arguments error', async () => {
    writeBuffer.should.throw(/arguments count mismatch/)
    writeBuffer.bind(null, 1).should.throw(/arguments count mismatch/)
    writeBuffer.bind(null, 1, 1).should.throw(/arguments type mismatch/)
    writeBuffer.bind(null, FORMAT_PLAIN_TEXT, 1).should.throw(/arguments type mismatch/)
  })
})

describe('.writeText', () => {
  it('it works ', () => {
    const content = __filename + '哈哈'

    // addon write
    const success = writeText(FORMAT_PLAIN_TEXT, content)
    success.should.ok()

    // electron read
    clipboard.readText().should.equal(content)
  })
})
