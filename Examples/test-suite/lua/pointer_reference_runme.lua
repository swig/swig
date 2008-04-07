require("import")	-- the import fn
import("pointer_reference",true)	-- import code


s=pointer_reference.get()
assert(s.value == 10)

ss = pointer_reference.Struct(20);
pointer_reference.set(ss);
assert(pointer_reference.Struct_instance.value == 20)

