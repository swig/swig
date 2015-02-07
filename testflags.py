#!/usr/bin/env python
c_common = "-Werror -fdiagnostics-show-option -std=gnu89 -Wno-long-long -Wreturn-type -Wdeclaration-after-statement"
cflags = {
        "csharp":c_common,
             "d":c_common,
            "go":c_common,
         "guile":c_common,
          "java":c_common,
    "javascript":c_common,
           "lua":c_common,
        "octave":c_common,
         "perl5":c_common,
           "php":c_common,
        "python":c_common,
          "ruby":c_common,
        "scilab":c_common,
           "tcl":c_common,
}

cxx_common = "-Werror -fdiagnostics-show-option -std=c++98 -Wno-long-long -Wreturn-type"
cxxflags = {
        "csharp":cxx_common,
             "d":cxx_common,
            "go":cxx_common,
         "guile":cxx_common,
          "java":cxx_common,
    "javascript":cxx_common,
           "lua":cxx_common,
        "octave":cxx_common,
         "perl5":cxx_common,
           "php":cxx_common,
        "python":cxx_common,
          "ruby":cxx_common,
        "scilab":cxx_common,
           "tcl":cxx_common,
}

import argparse
parser = argparse.ArgumentParser(description="Display CFLAGS or CXXFLAGS to use for testing the SWIG examples and test-suite.")
parser.add_argument('-l', '--language', required=True, help='set language to show flags for')
flags = parser.add_mutually_exclusive_group(required=True)
flags.add_argument('-c', '--cflags', action='store_true', default=False, help='show CFLAGS')
flags.add_argument('-x', '--cxxflags', action='store_true', default=False, help='show CXXFLAGS')
args = parser.parse_args()

if args.cflags:
    print("{}".format(cflags[args.language]))
elif args.cxxflags:
    print("{}".format(cxxflags[args.language]))
else:
    parser.print_help()
    exit(1)
