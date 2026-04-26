require("import")
require("exception_memory_leak")
eml=exception_memory_leak
catch_undef_globs() -- catch "undefined" global variables

a = eml.Foo()
assert(eml.Foo_get_count() == 1)
b = eml.Foo()
assert(eml.Foo_get_count() == 2)

-- Normal behaviour
eml.trigger_internal_swig_exception("no problem", a)
assert(eml.Foo_get_count() == 2)
assert(eml.Foo_get_freearg_count() == 1)

-- SWIG exception triggered and handled (return new object case)
ok,ex=pcall(eml.trigger_internal_swig_exception, "null", b)
assert(ok==false)
assert(eml.Foo_get_count() == 2)
assert(eml.Foo_get_freearg_count() == 2)

-- SWIG exception triggered and handled (return by value case).
ok,ex=pcall(eml.trigger_internal_swig_exception, "null")
assert(ok==false)
assert(eml.Foo_get_count() == 2)
