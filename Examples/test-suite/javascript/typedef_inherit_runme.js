var typedef_inherit = require("typedef_inherit");

var a = new typedef_inherit.Foo();
var b = new typedef_inherit.Bar();

var x = typedef_inherit.do_blah(a);
if (x != "Foo::blah")
    print("Whoa! Bad return" + x);

x = typedef_inherit.do_blah(b);
if (x != "Bar::blah")
    print("Whoa! Bad return" + x);

var c = new typedef_inherit.Spam();
var d = new typedef_inherit.Grok();

x = typedef_inherit.do_blah2(c);
if (x != "Spam::blah")
    print("Whoa! Bad return" + x);

x = typedef_inherit.do_blah2(d);
if (x != "Grok::blah")
    print ("Whoa! Bad return" + x);

x = d.far1();
if (x != "Spam::far1")
    print ("Whoa! Bad return" + x);
