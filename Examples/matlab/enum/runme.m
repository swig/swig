% file: runme.m

% ----- Object creation -----

% Print out the value of some enums
disp(sprintf('*** color ***'))
disp(sprintf('    RED    = %i', example.RED))
disp(sprintf('    BLUE   = %i', example.BLUE))
disp(sprintf('    GREEN  = %i', example.GREEN))

disp(sprintf('*** Foo::speed ***'))
disp(sprintf('    Foo.IMPULSE   = %i', example.Foo.IMPULSE))
disp(sprintf('    Foo.WARP      = %i', example.Foo.WARP))
disp(sprintf('    Foo.LUDICROUS = %i', example.Foo.LUDICROUS))

disp(sprintf('Testing use of enums with functions'))

example.enum_test(example.RED, example.Foo.IMPULSE);
example.enum_test(example.BLUE,  example.Foo.WARP);
example.enum_test(example.GREEN, example.Foo.LUDICROUS);
example.enum_test(1234,5678)

disp(sprintf('Testing use of enum with class method'))
f = example.Foo();

f.enum_test(example.Foo.IMPULSE);
f.enum_test(example.Foo.WARP);
f.enum_test(example.Foo.LUDICROUS);
