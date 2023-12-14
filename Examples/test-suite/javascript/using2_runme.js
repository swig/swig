var using2 = require("using2");

if (/* await */(using2.spam(37)) != 37)
    throw "RuntimeError";
