
if [ catch { load ./li_std_string[info sharedlibextension] li_std_string} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


Structure s 
if {"[s cget -MemberString2]" != "member string 2"} { error "bad string map"}
s configure -MemberString2 "hello"
if {"[s cget -MemberString2]" != "hello"} { error "bad string map"}

if {"[s cget -ConstMemberString]" != "const member string"} { error "bad string map"}

if {"$GlobalString2" != "global string 2"} { error "bad string map"}
if {"$Structure_StaticMemberString2" != "static member string 2"} { error "bad string map"}

set GlobalString2 "hello"
if {"$GlobalString2" != "hello"} { error "bad string map"}

set Structure_StaticMemberString2 "hello"
if {"$Structure_StaticMemberString2" != "hello"} { error "bad string map"}

if {[stdstring_empty] != ""} { error "bad stdstring_empty test" }
if {[c_empty] != ""} { error "bad c_empty test" }
# FIXME: [c_null] seems to give an empty string currently, but Tcl doesn't have
# a real NULL value and the string "NULL" we used for elsewhere for NULL
# pointers doesn't work well here as it's indistinguishable from the string
# "NULL" being returned.
#if {[c_null] != "NULL"} { error "bad c_null test" }
#if {[get_null [c_null]] != "NULL"} { error "bad get_null c_null test" }
if {[get_null [c_empty]] != "non-null"} { error "bad get_null c_empty test" }
if {[get_null [stdstring_empty]] != "non-null"} { error "bad get_null stdstring_empty test" }
