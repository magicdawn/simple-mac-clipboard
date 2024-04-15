{
  "targets": [
    {
      "target_name": "simple_mac_clipboard",
      'defines': [
        'NAPI_VERSION=3'
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "sources": ["src/clipboard_mac.mm"],
      "xcode_settings": {
				"GCC_ENABLE_CPP_EXCEPTIONS": "YES",
				"CLANG_CXX_LIBRARY": "libc++",
				"CPP_FILE_TYPE": "sourcecode.cpp.objcpp",
        "OTHER_CFLAGS_CC": [
					"-x objective-c++",
					"-mmacosx-version-min=10.9",
				],
      },
      "msvs_settings": {
        "VCCLCompilerTool": {
          "ExceptionHandling": 1
        }
      },
      "link_settings": {
        "conditions": [
          [
            "OS==\"mac\"",
            {
              "libraries": ["Foundation.framework", "AppKit.framework"]
            }
          ]
        ]
      }
    }
  ]
}
