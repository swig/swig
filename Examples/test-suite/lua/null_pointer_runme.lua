require("null_pointer")

assert(null_pointer.funk(nil), "nil fail to convert to NULL")
assert(null_pointer.getnull() == nil, "NULL fail to convert to nil")
