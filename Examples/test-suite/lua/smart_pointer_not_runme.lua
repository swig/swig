require("import")
require("smart_pointer_not")
spn=smart_pointer_not
catch_undef_globs() -- catch "undefined" global variables

foo = spn.Foo()
foo.x = 7
assert(foo:getx() == 7)

bar = spn.Bar(foo)
success = pcall(bar.getx, bar) -- Bar is not a smart pointer. Call should fail
assert(not success)

spam = spn.Spam(foo)
success = pcall(spam.getx, spam) -- Spam is not a smart pointer. Call should fail
assert(not success)

grok = spn.Grok(foo)
success = pcall(grok.getx, grok) -- Spam is not a smart pointer. Call should fail
assert(not success)
