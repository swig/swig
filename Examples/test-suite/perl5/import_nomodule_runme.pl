use import_nomodule;

$f = import_nomodule::create_Foo();
import_nomodule::test1($f,42);

$b = new import_nomodule::Bar();
import_nomodule::test1($b,37);
