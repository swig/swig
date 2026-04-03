require("import")
require("inherit_missing")
im=inherit_missing
catch_undef_globs() -- catch "undefined" global variables

bar = im.Bar()
spam = im.Spam()

assert(im.do_blah(bar) == "Bar::blah")
assert(im.do_blah(spam) == "Spam::blah")
