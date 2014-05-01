{
  "targets": [
    {
      "target_name": "example",
      "sources": [ "example.cxx", "example_wrap.cxx" ],
      'defines': [
        'BUILDING_NODE_EXTENSION=1',
      ],
      'conditions': [
        ['OS=="mac"',
          {
            'xcode_settings': {
              'GCC_ENABLE_CPP_RTTI': 'YES',
              'GCC_ENABLE_CPP_EXCEPTIONS' : 'YES'
            }
          }
        ],
        ['OS=="linux" or OS=="freebsd" or OS=="openbsd" or OS=="solaris"',
          {
            'cflags': [ "-Wno-unused-variable", "-Wno-unused-but-set-variable", "-Wno-unused-but-set-parameter"],
            'cflags_cc': [ "-Wno-unused-variable", "-Wno-unused-but-set-variable", "-Wno-unused-but-set-parameter"],
            'cflags!': [ '-fno-exceptions' ],
            'cflags_cc!': [ '-fno-exceptions', '-fno-rtti' ]
          }
        ]
      ]
    }
  ]
}
