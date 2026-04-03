require("import")
require("smart_pointer_multi")
spm=smart_pointer_multi
catch_undef_globs() -- catch "undefined" global variables

foo = spm.Foo()
foo.x = 5
assert(foo:getx() == 5)

bar = spm.Bar(foo)
spam = spm.Spam(bar)
grok = spm.Grok(bar)

assert(bar:getx() == 5)
assert(spam:getx() == 5)
spam.x = 7
assert(grok:getx() == 7)
grok.x = 10
assert(foo:getx() == 10)
