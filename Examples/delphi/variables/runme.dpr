program runme;
uses example;

begin

    // Try to set the values of some global variables

    example.ivar_set(42);
    example.svar_set(-31000);
    example.lvar_set(65537);
    example.uivar_set(123456);
    example.usvar_set(61000);
    example.ulvar_set(654321);
    example.scvar_set(-13);
    example.ucvar_set(251);
    example.cvar_set('S');
    example.fvar_set(3.14159);
    example.dvar_set(2.1828);
    example.strvar_set('Hello World');
    example.iptrvar_set(example.new_int(37));
  
  	 example.ptptr_set( example.make_Point(37,42));
   
    example.name_set('Bill');

    // Now print out the values of the variables

    WriteLn( 'Variables (values printed from Delphi)' );

    WriteLn( 'ivar      =' , example.ivar_get() );
    WriteLn( 'svar      =' , example.svar_get()  );
    WriteLn( 'lvar      =' , example.lvar_get()  );
    WriteLn( 'uivar     =' , example.uivar_get()  );
    WriteLn( 'usvar     =' , example.usvar_get()  );
    WriteLn( 'ulvar     =' , example.ulvar_get()  );
    WriteLn( 'scvar     =' , example.scvar_get()  );
    WriteLn( 'ucvar     =' , example.ucvar_get()  );
    WriteLn( 'fvar      =' , example.fvar_get()  );
    WriteLn( 'dvar      =' , example.dvar_get()  );
    WriteLn( 'cvar      =' , example.cvar_get()  );
    WriteLn( 'strvar    =' , example.strvar_get()  );
    WriteLn( 'cstrvar   =' , example.cstrvar_get()  );
    WriteLn( 'iptrvar   =' , longint(example.iptrvar_get())  );
    WriteLn( 'name      =' , example.name_get()  );
    WriteLn( 'ptptr     =' , longint(example.ptptr_get())  , example.Point_print(example.ptptr_get) );
    WriteLn( 'pt        =' , longint(example.pt_get() ) , example.Point_print(example.pt_get) );

    WriteLn( '\nVariables (values printed from C)' );

    example.print_vars();


end.