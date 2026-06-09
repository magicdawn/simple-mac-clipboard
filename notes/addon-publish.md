## pre 2026-06-09: `prebuild-install`

```json
{
  "scripts": {
    "install": "prebuild-install -r napi || npm run build:addon"
  },
  "binary": {
    "host": "https://cdn.jsdelivr.net/gh/magicdawn/prebuild-binary@master",
    "remote_path": "files/{name}/v{version}",
    "napi_versions": [3]
  }
}
```

## 2026-06-09: bundle universal addon

universal binary, fat binary: (darwin-arm64 + darwin-x64)

see `./scripts/build-universal-addon.ts`
