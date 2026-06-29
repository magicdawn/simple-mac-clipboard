{
  "targets": [
    {
      "target_name": "simple_mac_clipboard",
      "defines": ["NAPI_VERSION=3"],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').targets\"):node_addon_api_except"
      ],
      "sources": ["src-addon/clipboard_mac.mm"],
      "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
      "cflags_cc": ["-std=c++20", "-fvisibility=hidden"],
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
        "GCC_SYMBOLS_PRIVATE_EXTERN": "YES",
        "CLANG_CXX_LIBRARY": "libc++",
        "CLANG_CXX_LANGUAGE_STANDARD": "c++20",
        # std::format 13.3
        "MACOSX_DEPLOYMENT_TARGET": "10.9",
        "OTHER_CPLUSPLUSFLAGS": ["-mmacosx-version-min=10.9"],
        "OTHER_LDFLAGS": ["-mmacosx-version-min=10.9"],
      },
      "msvs_settings": {
        "VCCLCompilerTool": {
          "ExceptionHandling": 1,
          "AdditionalOptions": ["/std:c++20"],
        }
      },
      "link_settings": {
        "conditions": [
          [
            'OS=="mac"',
            {"libraries": ["-framework Foundation", "-framework AppKit"]},
          ]
        ]
      },
    }
  ]
}
