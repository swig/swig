var using1 = require("using1");

if (/* await */(using1.spam(37)) != 37)
    throw "RuntimeError";
