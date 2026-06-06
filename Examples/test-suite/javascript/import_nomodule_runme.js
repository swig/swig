var import_nomodule = require("import_nomodule");

f = import_nomodule.create_Foo();
import_nomodule.test1(f, 42);
import_nomodule.delete_Foo(f);

b = new import_nomodule.Bar();
import_nomodule.test1(b, 37);
