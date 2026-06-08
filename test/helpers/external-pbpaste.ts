import { execa } from 'execa'

export async function pbpasteRead() {
  const { stdout: text } = await execa`pbpaste`
  return text
}
