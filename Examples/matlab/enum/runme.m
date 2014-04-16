% file: runme.m

% ----- Object creation -----

% Print out the value of some enums
disp(sprintf('*** color ***'))
disp(sprintf('    RED    = %i', swigexample.RED))
disp(sprintf('    BLUE   = %i', swigexample.BLUE))
disp(sprintf('    GREEN  = %i', swigexample.GREEN))

disp(sprintf('*** Foo::speed ***'))
disp(sprintf('    Foo.IMPULSE   = %i', swigexample.Foo.IMPULSE))
disp(sprintf('    Foo.WARP      = %i', swigexample.Foo.WARP))
disp(sprintf('    Foo.LUDICROUS = %i', swigexample.Foo.LUDICROUS))

disp(sprintf('Testing use of enums with functions'))

swigexample.enum_test(swigexample.RED, swigexample.Foo.IMPULSE);
swigexample.enum_test(swigexample.BLUE,  swigexample.Foo.WARP);
swigexample.enum_test(swigexample.GREEN, swigexample.Foo.LUDICROUS);
swigexample.enum_test(1234,5678)

disp(sprintf('Testing use of enum with class method'))
f = swigexample.Foo();

f.enum_test(swigexample.Foo.IMPULSE);
f.enum_test(swigexample.Foo.WARP);
f.enum_test(swigexample.Foo.LUDICROUS);
