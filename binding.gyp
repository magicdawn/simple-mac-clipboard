{
  "targets": [
    {
      "target_name": "simple_mac_clipboard",
      'defines': [
        'NAPI_VERSION=3'
      ],
			'dependencies': [
				"<!(node -p \"require('node-addon-api').targets\"):node_addon_api_except",
			],
      "sources": ["src-addon/clipboard_mac.mm"],
			"cflags": [ "-std=c++20", '-fvisibility=hidden' ],
      "cflags_cc": [ "-std=c++20", '-fvisibility=hidden' ],
      "xcode_settings": {
				"GCC_ENABLE_CPP_EXCEPTIONS": "YES",
				'GCC_SYMBOLS_PRIVATE_EXTERN': 'YES', # -fvisibility=hidden
				"CLANG_CXX_LIBRARY": "libc++",
				"CPP_FILE_TYPE": "sourcecode.cpp.objcpp",
				"CLANG_CXX_LANGUAGE_STANDARD": "c++20",
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
