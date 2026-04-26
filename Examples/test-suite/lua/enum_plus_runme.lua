require("import")
require("enum_plus")
ep=enum_plus
catch_undef_globs() -- catch "undefined" global variables

assert(ep.iFoo_Phoo == 50) -- Old variant of enum bindings
assert(ep.iFoo.Phoo == 50) -- New variant of enum bindings
