require("import")
require("smart_pointer_inherit")
spi=smart_pointer_inherit
catch_undef_globs() -- catch "undefined" global variables

der = spi.Derived(7)

ptr = spi.SmartDerived(der)

assert(ptr.val == 7)
assert(ptr:value() == 7)
assert(ptr:value2() == 7)
assert(ptr:value3() == 7)
assert(ptr:valuehide() == -1)
