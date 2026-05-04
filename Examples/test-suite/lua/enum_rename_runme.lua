require("import")
require("enum_rename")
er=enum_rename
catch_undef_globs() -- catch "undefined" global variables

assert(er.M_Jan ~= nil)
assert(er.May ~= nil)
