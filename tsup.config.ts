import { defineConfig } from 'tsup'

export default defineConfig((options) => {
  return {
    entry: ['src-ts/index.ts'],
    format: ['cjs', 'esm'],
    target: 'node16',
    clean: true,
    dts: true,
    shims: true,
    esbuildOptions(options, context) {
      options.charset = 'utf8'
    },
  }
})
