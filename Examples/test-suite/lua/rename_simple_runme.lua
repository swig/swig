require("import")
require("rename_simple")
rs=rename_simple
catch_undef_globs() -- catch "undefined" global variables

assert(rs.NewStruct ~= nil)
assert(rs.NewStruct.NewStaticVariable == 444)
assert(rs.NewStruct_NewStaticVariable == 444)

assert(rs.NewStruct.NewStaticMethod() == 333)
assert(rs.NewStruct_NewStaticMethod() == 333)

assert(rs.NewStruct.ONE == 1)
assert(rs.NewStruct_ONE == 1)

assert(rs.NewFunction() == 555)

assert(rs.OldStruct == nil)
assert(rs.OldFunction == nil)
assert(rs.OldGlobalVariable == nil)
assert(rs.OldStruct_ONE == nil)
