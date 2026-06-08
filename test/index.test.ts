import { describe, expect, it } from 'vitest'
import clip, { FORMAT_PLAIN_TEXT } from '../dist'
import { pbpasteRead } from './helpers/external-pbpaste'

describe('write', () => {
  it('.clear ', async () => {
    clip.clear()
    expect(await pbpasteRead()).toBe('')
    expect(clip.readText(FORMAT_PLAIN_TEXT)).toBe('')
  })
})
