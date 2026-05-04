require("import")
require("template_construct")
tc=template_construct
catch_undef_globs() -- catch "undefined" global variables

foo = tc.Foo_int(1)
