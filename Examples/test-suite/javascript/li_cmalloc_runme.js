var li_cmalloc = require("li_cmalloc");

var p = /* await */(li_cmalloc.malloc_int(1));
/* await */(li_cmalloc.free_int(p));

var ok = false;
try {
    var p = /* await */(li_cmalloc.calloc_int(-1));
    /* await */(li_cmalloc.free_int(p));
} catch {
    var ok = true;
}

if (!ok) {
    throw new Error;
}
