var import_nomodule = require("import_nomodule");

var f = /* await */(import_nomodule.create_Foo());
/* await */(import_nomodule.test1(f, 42));
/* @ts-ignore */
if (typeof import_nomodule.delete_Foo !== 'undefined')
  throw new Error('destructor not ignored');

var b = new import_nomodule.Bar();
/* await */(import_nomodule.test1(b, 37));
