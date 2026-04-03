require("import")
require("keyword_rename")
kn=keyword_rename
catch_undef_globs() -- catch "undefined" global variables

-- Check renaming of Lua keywords
assert(kn.c_end(5) == 5)
assert(kn.c_nil(7) == 7)
