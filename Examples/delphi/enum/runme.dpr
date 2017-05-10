program runme;
uses example;


var
	f : TFoo;
begin
// Print out the value of some enums
        WriteLn('*** color ***');
        WriteLn('    color_RED    = ' , ord(TColor.RED));
        WriteLn('    color_BLUE   = ' , ord(TColor.BLUE));
        WriteLn('    color_GREEN  = ' , ord(TColor.GREEN));

        WriteLn('*** Foo::speed ***');
        WriteLn('    Foo_speed_IMPULSE  = ' , ord(TFoo_speed.IMPULSE));
        WriteLn('    Foo_speed_WARP  = ' , ord(TFoo_speed.WARP));
        WriteLn('    Foo_speed_LUDICROUS  = ' , ord(TFoo_speed.LUDICROUS));

        WriteLn('Testing use of enums with functions');

        example.enum_test(ord(TColor.RED), ord(TFoo_speed.IMPULSE));
        example.enum_test(ord(TColor.BLUE),  ord(TFoo_speed.WARP));
        example.enum_test(ord(TColor.GREEN), ord(TFoo_speed.LUDICROUS));

        WriteLn( 'Testing use of enum with class method' );
        f := TFoo.Create();

        f.enum_test(ord(TFoo_speed.IMPULSE));
        f.enum_test(ord(TFoo_speed.WARP));
        f.enum_test(ord(TFoo_speed.LUDICROUS));

        f.Free;
end.