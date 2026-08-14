typemap_string_alloc

Custom_Reset();
cvar.some_text = "one";
cvar.some_text = "two";

assert(Custom_WasAllocated());
assert(Custom_WasDeallocated());
