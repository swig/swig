var import_nomodule = require("import_nomodule");

var f = /* await */(import_nomodule.create_Foo());
/* await */(import_nomodule.test1(f, 42));
/* await */(import_nomodule.delete_Foo(f));

var b = new import_nomodule.Bar();
/* await */(import_nomodule.test1(b, 37));
