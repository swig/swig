
if [ catch { load ./cpp17_string_view[info sharedlibextension] cpp17_string_view} err_msg ] {
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
if {[s cget -ConstMemberString] != "const member string"} { error "bad ConstMemberString"}

if {$Structure_ConstStaticMemberString != "const static member string"} { error "bad ConstStaticMemberString"}

test_const_reference_returning_void "foo"
