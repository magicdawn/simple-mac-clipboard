## pre 2026-06-09: `prebuild-install`

```json
{
  "scripts": {
    "install": "prebuild-install -r napi || npm run build:addon"
  }
}
```

## 2026-06-09: bundle universal addon

universal binary, fat binary: (darwin-arm64 + darwin-x64)

see `./scripts/build-universal-addon.ts`
