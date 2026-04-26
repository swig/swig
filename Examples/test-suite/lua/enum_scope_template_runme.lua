require("import")
require("enum_scope_template")
est=enum_scope_template
catch_undef_globs() -- catch "undefined" global variables

assert(est.TreeInt.Oak ~= nil)
assert(est.TreeInt_Oak ~= nil)
assert(est.TreeInt.Cedar ~= nil)
