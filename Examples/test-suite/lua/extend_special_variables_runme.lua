local v=require("extend_special_variables")

function check(received, expected)
    assert(received == expected, "Incorrect, received: " .. received)
end

local f = v.ForExtensionNewName()
check(f:extended_renamed(), "name:extended symname:extended_renamed wrapname: overname:__SWIG_0 decl:ForExtension::extended() fulldecl:char const * ForExtension::extended() parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
check(f:extended_renamed(10), "name:extended symname:extended_renamed wrapname: overname:__SWIG_1 decl:ForExtension::extended(int) fulldecl:char const * ForExtension::extended(int) parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
