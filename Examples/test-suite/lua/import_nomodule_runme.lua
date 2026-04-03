require("import")
require("import_nomodule")
catch_undef_globs() -- catch "undefined" global variables

f = import_nomodule.create_Foo()
import_nomodule.test1(f,42)
import_nomodule.delete_Foo(f)

b = import_nomodule.Bar()
import_nomodule.test1(b,37)

collectgarbage()
