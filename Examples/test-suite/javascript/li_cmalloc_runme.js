var li_cmalloc = require("li_cmalloc");

var p = li_cmalloc.malloc_int(1);
li_cmalloc.free_int(p);

var ok = false;
try {
    p = li_cmalloc.calloc_int(-1);
    li_cmalloc.free_int(p);
} catch {
    ok = true;
}

if (!ok) {
    throw new Error;
}
