const should = require('should')
const { FORMAT_PLAIN_TEXT, clear, readBuffer, readText, readTexts } = require('..')
const { clipboard } = require('electron')
const { execSync } = require('child_process')

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
    readBuffer.should.throw(/arguments count mismatch/)
    readBuffer.bind(null, 1).should.throw(/arguments type mismatch/)
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

describe('.readTexts works', () => {
  it('it works ', () => {
    // set multi-items
    const cmd = `swift '${__dirname}/helpers/set-mul.swift'`
    execSync(cmd)

    // read
    readTexts(FORMAT_PLAIN_TEXT).should.eql(['First string', 'Second string'])
  })
})
