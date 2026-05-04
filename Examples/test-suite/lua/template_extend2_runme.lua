require("import")
require("template_extend2")
te=template_extend2
catch_undef_globs() -- catch "undefined" global variables

lb = te.lBaz()
assert(lb:foo() == "lBaz::foo")

db = te.dBaz()
assert(db:foo() == "dBaz::foo")
