var inherit_missing = require("inherit_missing");

var a = /* await */(inherit_missing.new_Foo());
var b = new inherit_missing.Bar();
var c = new inherit_missing.Spam();

var x = /* await */(inherit_missing.do_blah(a));
if (x != "Foo::blah")
  throw new Error(`Whoa! Bad return ${x}`);

x = /* await */(inherit_missing.do_blah(b))
if (x != "Bar::blah")
  throw new Error(`Whoa! Bad return ${x}`);

x = /* await */(inherit_missing.do_blah(c));
if (x != "Spam::blah")
  throw new Error(`Whoa! Bad return ${x}`);

/* @ts-ignore */
if (typeof inherit_missing.delete_Foo !== 'undefined')
  throw new Error('destructor not ignored');
