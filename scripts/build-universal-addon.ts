import path from 'node:path'
import { execa } from 'execa'

const repoRoot = path.join(import.meta.dirname, '..')
const $ = execa({ cwd: repoRoot, stdio: 'inherit', verbose: 'short' })

await $`pnpm node-gyp rebuild --arch=x64 --target_arch=x64`
await $`cp ./build/Release/simple_mac_clipboard.node ./simple_mac_clipboard.darwin-x64.node`

await $`pnpm node-gyp rebuild --arch=arm64 --target_arch=arm64`
await $`cp ./build/Release/simple_mac_clipboard.node ./simple_mac_clipboard.darwin-arm64.node`

await $`lipo -create -output simple_mac_clipboard.node ./simple_mac_clipboard.darwin-arm64.node ./simple_mac_clipboard.darwin-x64.node`
await $`file ./simple_mac_clipboard.node`
