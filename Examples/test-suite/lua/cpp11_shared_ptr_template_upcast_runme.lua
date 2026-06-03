require("cpp11_shared_ptr_template_upcast")

local s = cpp11_shared_ptr_template_upcast

local pd = s.MakePrintableDerived(20)
pd:GetResult()
pd:GetFormatted()
