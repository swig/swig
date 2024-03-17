
if [ catch { load ./li_std_string[info sharedlibextension] Li_std_string} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

test_value "Fee"

if {[test_value "Fi"] != "Fi"} { error "bad test_value"}

test_const_reference "Fo"

if {[test_const_reference "Fum"] != "Fum"} { error "bad test_const_reference"}

set stringPtr [test_pointer_out]

test_pointer $stringPtr

set stringPtr [test_const_pointer_out]

test_const_pointer $stringPtr

set stringPtr [test_reference_out]

test_reference $stringPtr

# Global variables
if {$ConstGlobalString != "const global string"} { error "bad ConstGlobalString_get"}

# Member variables
Structure s
if {"[s cget -MemberString2]" != "member string 2"} { error "bad string map"}
s configure -MemberString2 "hello"
if {"[s cget -MemberString2]" != "hello"} { error "bad string map"}

if {[s cget -ConstMemberString] != "const member string"} { error "bad ConstMemberString"}

if {"$GlobalString2" != "global string 2"} { error "bad string map"}
if {"$Structure_StaticMemberString2" != "static member string 2"} { error "bad string map"}

set GlobalString2 "hello"
if {"$GlobalString2" != "hello"} { error "bad string map"}

set Structure_StaticMemberString2 "hello"
if {"$Structure_StaticMemberString2" != "hello"} { error "bad string map"}

if {$Structure_ConstStaticMemberString != "const static member string"} { error "bad ConstStaticMemberString"}

test_const_reference_returning_void "foo"

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
