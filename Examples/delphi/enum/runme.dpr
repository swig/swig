program runme;
uses example;


var
	f : TFoo;
begin
// Print out the value of some enums
        WriteLn('*** color ***');
        WriteLn('    color_RED    = ' , color_RED);
        WriteLn('    color_BLUE   = ' , color_BLUE);
        WriteLn('    color_GREEN  = ' , color_GREEN);

        WriteLn('*** Foo::speed ***');
        WriteLn('    Foo_speed_IMPULSE  = ' , Foo_speed_IMPULSE);
        WriteLn('    Foo_speed_WARP  = ' , Foo_speed_WARP);
        WriteLn('    Foo_speed_LUDICROUS  = ' , Foo_speed_LUDICROUS);

        WriteLn('Testing use of enums with functions');

        example.enum_test(color_RED, Foo_speed_IMPULSE);
        example.enum_test(color_BLUE, Foo_speed_WARP);
        example.enum_test(color_GREEN, Foo_speed_LUDICROUS);

        WriteLn( 'Testing use of enum with class method' );
        f := TFoo.Create();

        f.enum_test(Foo_speed_IMPULSE);
        f.enum_test(Foo_speed_WARP);
        f.enum_test(Foo_speed_LUDICROUS);

        f.Free;
end.