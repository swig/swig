require("import")
require("mod_a")
require("mod_b")
catch_undef_globs() -- catch "undefined" global variables

c = mod_b.C()
d = mod_b.D()
d:DoSomething(c)
