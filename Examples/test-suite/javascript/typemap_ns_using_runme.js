var typemap_ns_using = require("typemap_ns_using");

if (/* await */(typemap_ns_using.spam(37)) != 37)
    throw "RuntimeError";
