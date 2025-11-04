var import_nomodule = require("import_nomodule");

var f = import_nomodule.create_Foo();
import_nomodule.test1(f, 42);
import_nomodule.delete_Foo(f);

var b = new import_nomodule.Bar();
import_nomodule.test1(b, 37);
