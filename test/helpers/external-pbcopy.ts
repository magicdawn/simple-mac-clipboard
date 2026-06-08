import { execa } from 'execa'

export async function pbcopy(content: string) {
  await execa({ shell: true })`printf %s ${content} | pbcopy`
}
