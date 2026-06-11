import path from 'node:path'
import { execa } from 'execa'

const repoRoot = path.join(import.meta.dirname, '..')
const $ = execa({ cwd: repoRoot, stdio: 'inherit', verbose: 'short' })

const buildReleaseNode = './build/Release/simple_mac_clipboard.node'
const x64Node = './node_modules/.tmp/simple_mac_clipboard.darwin-x64.node'
const arm64Node = './node_modules/.tmp/simple_mac_clipboard.darwin-arm64.node'
const fatNode = './simple_mac_clipboard.node'

await $`mkdir -p ./node_modules/.tmp`

await $`pnpm node-gyp rebuild --arch=x64 --target_arch=x64`
await $`cp ${buildReleaseNode} ${x64Node}`

await $`pnpm node-gyp rebuild --arch=arm64 --target_arch=arm64`
await $`cp ${buildReleaseNode} ${arm64Node}`

await $`lipo -create -output ${fatNode} ${x64Node} ${arm64Node}`
await $`strip -Sx ${fatNode}`
await $`file ${fatNode}`
