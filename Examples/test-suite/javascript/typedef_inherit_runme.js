var typedef_inherit = require("typedef_inherit");

var a = new typedef_inherit.Foo();
var b = new typedef_inherit.Bar();

var x = /* await */(typedef_inherit.do_blah(a));
if (x != "Foo::blah")
    throw new Error("Whoa! Bad return" + x);

x = /* await */(typedef_inherit.do_blah(b));
if (x != "Bar::blah")
    throw new Error("Whoa! Bad return" + x);

var c = new typedef_inherit.Spam();
var d = new typedef_inherit.Grok();

x = /* await */(typedef_inherit.do_blah2(c));
if (x != "Spam::blah")
    throw new Error("Whoa! Bad return" + x);

x = /* await */(typedef_inherit.do_blah2(d));
if (x != "Grok::blah")
    throw new Error("Whoa! Bad return" + x);

x = /* await */(d.far1());
if (x != "Spam::far1")
    throw new Error("Whoa! Bad return" + x);
