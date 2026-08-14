use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('typemap_string_alloc') }
require_ok('typemap_string_alloc');

typemap_string_alloc::Custom_Reset();
$typemap_string_alloc::some_text = "one";
$typemap_string_alloc::some_text = "two";

ok(typemap_string_alloc::Custom_WasAllocated(), "custom allocator called");
ok(typemap_string_alloc::Custom_WasDeallocated(), "custom deallocator called");
