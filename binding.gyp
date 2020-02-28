{
  "targets": [
    {
      "target_name": "native_clipboard",
      "sources": ["src/clipboard_mac.cc"],
      "cflags!": ["-fno-exceptions"],
      "cflags_cc!": ["-fno-exceptions"],
      "include_dirs": ["<!(node -e \"require('nan')\")"],
      "link_settings": {
        "conditions": [
          [
            "OS==\"mac\"",
            {
              "libraries": ["Foundation.framework", "AppKit.framework"]
            }
          ]
        ]
      },
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
        "OTHER_CFLAGS": ["-x objective-c++ -stdlib=libc++"]
      }
    }
  ]
}
