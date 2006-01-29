require("import")	-- the import fn
import("li_std_string")	-- import lib

for k,v in pairs(li_std_string) do _G[k]=v end -- move to global

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- helper to check type
function is_std_string(s) 
	return type(s)=='userdata' and swig_type(s)=='_p_std__string'
end

-- std::string by value is just a Lua string
s=test_value("foo")
assert(type(s)=="string" and s=="foo")

-- std::string by const ref is also just a Lua string
s=test_const_reference("foo")
assert(type(s)=="string" and s=="foo")

-- std:string* is an object
obj=test_pointer_out()
assert(is_std_string(obj) and obj:c_str()=="x")	-- check type & value

test_pointer(obj)	-- this wants an object

cobj=test_const_pointer_out()
assert(is_std_string(cobj) and cobj:c_str()=="x")	-- check type & value

test_const_pointer(cobj)

-- this shouldnt work, but it does
-- swig doesnt appear to diff between const object ptrs & object ptrs very well
test_pointer(cobj)	-- this wants an non const object (give it a const one!)

-- refs are also wrappered as ptrs (unless the correct typemaps are applied)
robj=test_reference_out()
assert(is_std_string(robj) and robj:c_str()=="test_reference_out message")	-- check type & value

test_reference(robj)
test_reference(obj)	-- object ptr is ok
test_reference(cobj)	-- obj const ptr is also ok

-- throwing string
ok,ex=pcall(test_throw)
assert(ok==false and type(ex)=="string")	-- failed & threw string

ok,ex=pcall(test_const_reference_throw)
assert(ok==false and type(ex)=="string")	-- failed & threw string

-- const ptrs are thrown as str::string**
-- not quite right
ok,ex=pcall(test_const_pointer_throw)
assert(ok==false and type(ex)=="userdata")	-- failed & threw object

-- ditto non const ptrs 
ok,ex=pcall(test_pointer_throw)
assert(ok==false and type(ex)=="userdata")	-- failed & threw object

-- testing std::string variables
-- Global variables
s = "initial string"
assert (li_std_string.GlobalString2 == "global string 2")
li_std_string.GlobalString2 = s
assert (li_std_string.GlobalString2 == s)
assert (li_std_string.ConstGlobalString == "const global string")

-- Member variables
myStructure = Structure()
assert(myStructure.MemberString2 == "member string 2")
myStructure.MemberString2 = s
assert (myStructure.MemberString2 == s)
assert (myStructure.ConstMemberString == "const member string")

assert (li_std_string.Structure_StaticMemberString2 == "static member string 2")
li_std_string.Structure_StaticMemberString2 = s
assert (li_std_string.Structure_StaticMemberString2 == s)
assert (li_std_string.Structure_ConstStaticMemberString == "const static member string")


-- testing the structure (these are some old tests which predated the std::string variable tests above)
struc=Structure()

assert(type(struc.MemberString2)=="string") -- typemaps make this a string
assert(type(struc.ConstMemberString)=="string")

-- set them
struc.ConstMemberString="c"	-- silently ignored
--print(struc.MemberString:data(),struc.MemberString2,struc.ConstMemberString:data())

--check type again
assert(type(struc.MemberString2)=="string") -- typemaps make this a string
assert(type(struc.ConstMemberString)=="string")

-- for static types: they are really variables, 
-- so we must still use the module name

-- check static type
assert(type(li_std_string.Structure_StaticMemberString2)=="string")
assert(type(li_std_string.Structure_ConstStaticMemberString)=="string")

-- try setting
--li_std_string.Structure_StaticMemberString2='e'
li_std_string.Structure_ConstStaticMemberString='f' -- silently ignored
--[[print(li_std_string.Structure_StaticMemberString:data(),
		li_std_string.Structure_StaticMemberString2,
		li_std_string.Structure_ConstStaticMemberString:data())]]

-- check static type again
assert(type(li_std_string.Structure_StaticMemberString)=="string")
assert(type(li_std_string.Structure_StaticMemberString2)=="string")
assert(type(li_std_string.Structure_ConstStaticMemberString)=="string")

