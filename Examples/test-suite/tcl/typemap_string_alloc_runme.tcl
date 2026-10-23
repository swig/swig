if {[catch {load ./typemap_string_alloc[info sharedlibextension] Typemap_string_alloc} err]} {
  puts stderr "Could not load shared object:\n$err"
  exit 1
}

Custom_Reset
set some_text "one"
set some_text "two"

if {![Custom_WasAllocated]} { error "custom allocator was not called" }
if {![Custom_WasDeallocated]} { error "custom deallocator was not called" }
