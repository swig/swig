var inherit_missing = require("inherit_missing");

a = /* await */(inherit_missing.new_Foo());
b = new inherit_missing.Bar();
c = new inherit_missing.Spam();

x = /* await */(inherit_missing.do_blah(a));
if (x != "Foo::blah")
  throw new Error(`Whoa! Bad return ${x}`);

x = /* await */(inherit_missing.do_blah(b))
if (x != "Bar::blah")
  throw new Error(`Whoa! Bad return ${x}`);

x = /* await */(inherit_missing.do_blah(c));
if (x != "Spam::blah")
  throw new Error(`Whoa! Bad return ${x}`);

/* await */(inherit_missing.delete_Foo(a));
