var class_ignore = require("class_ignore");

var a = new class_ignore.Bar();

if (/* await */(class_ignore.do_blah(a)) != "Bar::blah")
    throw "Error";
