
if [ catch { load ./li_std_wstring[info sharedlibextension] Li_std_wstring} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

if {![wstring_default]} { error "wstring_default" }
if {![wstring_joined_default]} { error "wstring_joined_default" }
if {![wstring_joined_first_default]} { error "wstring_joined_first_default" }
if {![wstring_joined_escapes_default]} { error "wstring_joined_escapes_default" }
if {![wstring_beyond_unicode_default]} { error "wstring_beyond_unicode_default" }
if {![wchar_beyond_unicode_default]} { error "wchar_beyond_unicode_default" }
