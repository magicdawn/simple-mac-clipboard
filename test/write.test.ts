import { describe, expect, it } from 'vitest'
import { FORMAT_PLAIN_TEXT, readBuffer, readTexts, writeFormat, writePasteboardItems } from '../dist'
import { pbpasteRead } from './helpers/external-pbpaste'

describe('.writeFormat(Buffer)', () => {
  it('it works', async () => {
    // addon write
    const content = '哈哈nihao'
    const format = 'public.utf8-plain-text'
    const success = writeFormat(format, Buffer.from(content))
    expect(success).toBe(true)

    // addon read
    {
      const data = readBuffer(format)
      expect(data).toBeInstanceOf(Buffer)
      expect(data).toEqual(Buffer.from(content))
    }
    // external pbpaste read
    expect(await pbpasteRead()).toBe(content)
  })

  it('when arguments error', async () => {
    expect(writeFormat).to.throw(/format is required/)
  })
})

describe('.writeFormat(string)', () => {
  it('it works ', async () => {
    const content = __filename + '哈哈'
    // addon write
    const success = writeFormat(FORMAT_PLAIN_TEXT, content)
    expect(success).toBe(true)
    // external pbpaste read
    expect(await pbpasteRead()).toBe(content)
  })
})

describe('.writePasteboardItems', () => {
  it('works', () => {
    writePasteboardItems({ [FORMAT_PLAIN_TEXT]: '1' }, { [FORMAT_PLAIN_TEXT]: '2' })
    expect(readTexts(FORMAT_PLAIN_TEXT)).toEqual(['1', '2'])
  })
})
