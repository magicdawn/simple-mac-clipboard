import { describe, expect, it } from 'vitest'
import { clear, FORMAT_PLAIN_TEXT, readBuffer, readText, readTexts, writeTexts } from '../dist'
import { pbcopy } from './helpers/external-pbcopy'
import { pbpasteRead } from './helpers/external-pbpaste'

describe('.readBuffer', () => {
  it('it works', async () => {
    // pbcopy
    const content = '哈哈nihao'
    await pbcopy(content)

    expect(await pbpasteRead()).toBe(content)

    // addon read
    const data = readBuffer(FORMAT_PLAIN_TEXT)
    expect(data).toBeInstanceOf(Buffer)
    expect(data).toEqual(Buffer.from(content))
  })

  it('when arguments error', async () => {
    expect(readBuffer).to.throw(/arguments count mismatch/)
    expect(readBuffer.bind(null, 1 as any)).to.throw(/arguments type mismatch/)
  })

  it('when empty clipboard', async () => {
    // clean
    clear()
    // read
    const data = readBuffer(FORMAT_PLAIN_TEXT)
    expect(data).toBeInstanceOf(Buffer)
    expect(data.byteLength).toEqual(0)
  })
})

describe('.readText', () => {
  it('it works ', async () => {
    await pbcopy(__filename)
    expect(readText(FORMAT_PLAIN_TEXT)).toBe(__filename)
  })
})

describe('.readTexts works', () => {
  it('it works ', () => {
    writeTexts(FORMAT_PLAIN_TEXT, ['First string', 'Second string'])
    expect(readTexts(FORMAT_PLAIN_TEXT)).toEqual(['First string', 'Second string'])
  })
})
