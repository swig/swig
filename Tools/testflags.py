#!/usr/bin/env python

def get_cflags(language, std, compiler):
    if not std:
        std = "gnu89"
    c_common = ["-fdiagnostics-show-option", "-std=" + std, "-Wno-long-long",
            "-Wreturn-type", "-Wdeclaration-after-statement",
            "-Wmissing-field-initializers"]
    cflags = {
        "csharp": ["-Werror"],
             "d": ["-Werror"],
       "fortran": ["-Werror"],
            "go": ["-Werror", "-Wno-declaration-after-statement"],
         "guile": ["-Werror"],
          "java": ["-Werror"],
    "javascript": ["-Werror"],
           "lua": ["-Werror"],
        "octave": ["-Werror"],
         "perl5": ["-Werror"],
           "php": ["-Werror"],
          "php5": ["-Werror"],
        "python": ["-Werror"],
             "r": ["-Werror"],
          "ruby": ["-Werror"],
        "scilab": ["-Werror"],
           "tcl": ["-Werror"],
    }
    if compiler == 'clang':
        cflags["guile"].append("-Wno-attributes") # -Wno-attributes is for clang LLVM 3.5 and bdw-gc < 7.5 used by guile

    try:
        flags = cflags[language]
    except KeyError:
        raise RuntimeError("{} is not a supported language".format(language))
    return " ".join(flags + c_common)


def get_cxxflags(language, std, compiler):
    if not std:
        std = "c++98"
    cxx_common = ["-fdiagnostics-show-option", "-std=" + std, "-Wno-long-long",
            "-Wreturn-type", "-Wmissing-field-initializers"]
    cxxflags = {
        "csharp": ["-Werror"],
             "d": ["-Werror"],
       "fortran": ["-Werror"],
            "go": ["-Werror"],
         "guile": ["-Werror"],
          "java": ["-Werror"],
    "javascript": ["-Werror", "-Wno-error=unused-function"], # Until overload_rename is fixed for node
           "lua": ["-Werror"],
        "octave": ["-Werror"],
         "perl5": ["-Werror"],
           "php": ["-Werror"],
          "php5": ["-Werror"],
        "python": ["-Werror"],
             "r": ["-Werror"],
          "ruby": ["-Werror"],
        "scilab": ["-Werror"],
           "tcl": ["-Werror"],
    }
    if compiler == 'clang':
        cxxflags["guile"].append("-Wno-attributes") # -Wno-attributes is for clang LLVM 3.5 and bdw-gc < 7.5 used by guile

    try:
        flags = cxxflags[language]
    except KeyError:
        raise RuntimeError("{} is not a supported language".format(language))
    return " ".join(flags + cxx_common)


import argparse
parser = argparse.ArgumentParser(description="Display CFLAGS or CXXFLAGS to use for testing the SWIG examples and test-suite.")
parser.add_argument('-l', '--language', required=True, help='set language to show flags for')
flags = parser.add_mutually_exclusive_group(required=True)
flags.add_argument('-c', '--cflags', action='store_true', default=False, help='show CFLAGS')
flags.add_argument('-x', '--cxxflags', action='store_true', default=False, help='show CXXFLAGS')
parser.add_argument('-s', '--std', required=False, help='language standard flags for the -std= option')
parser.add_argument('-C', '--compiler', required=False, help='compiler used (clang or gcc)')
args = parser.parse_args()

if args.cflags:
    get_flags = get_cflags
elif args.cxxflags:
    get_flags = get_cxxflags
else:
    parser.print_help()
    exit(1)

print(get_flags(args.language, args.std, args.compiler))
