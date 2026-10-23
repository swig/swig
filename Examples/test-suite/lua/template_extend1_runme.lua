te=require("template_extend1")
catch_undef_globs() -- catch "undefined" global variables

lb = te.lBaz()
assert(lb:foo() == "lBaz::foo")

db = te.dBaz()
assert(db:foo() == "dBaz::foo")
