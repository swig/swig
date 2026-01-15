require("import")                          -- the import fn
import("cpp11_shared_ptr_template_upcast") -- import lib

local s = cpp11_shared_ptr_template_upcast

local pd = s.MakePrintableDerived(20)
pd:GetResult()
pd:GetFormatted()
