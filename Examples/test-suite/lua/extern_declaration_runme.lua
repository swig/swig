require("extern_declaration")

assert(extern_declaration.externimport(100) == 100, "externimport")
assert(extern_declaration.externexport(200) == 200, "externexport")
assert(extern_declaration.externstdcall(300) == 300, "externstdcall")
