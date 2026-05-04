require("import")
require("smart_pointer_templatemethods")
spt=smart_pointer_templatemethods
catch_undef_globs() -- catch "undefined" global variables

o1 = spt.Objct()

iid = spt.InterfaceId()

po2 = o1:QueryInterfaceObjct(iid)
-- we can't call po2:DisposeObjct, because smart pointer Ptr<T> always return 0 when dereferencing
-- (see interface file). So we only check that po2 has necessary method
assert(po2.DisposeObjct ~= nil)
assert(po2.QueryInterfaceObjct ~= nil)
