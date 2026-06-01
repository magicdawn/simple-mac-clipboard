import { defineConfig } from 'tsdown'

export default defineConfig({
  entry: ['src-ts/index.ts'],
  format: 'esm',
  target: 'node22',
  clean: true,
  dts: true,
  shims: true,
  fixedExtension: false,
})
