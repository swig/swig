program runme;
uses example;

var
	a,b : integer;
	do_op : funptr ; 
begin
	a := 37;
  b := 42;

 // Now call our C function with a bunch of callbacks

	WriteLn( 'Trying some C callback functions' );
  WriteLn( '    a        = ' , a );
  WriteLn( '    b        = ' , b );
  
  do_op := example.ADD;
  
  WriteLn( '    ADD(a,b) = ' ,do_op(a,b) );
  do_op := example.SUB;
  
  WriteLn( '    SUB(a,b) = ' , do_op(a,b) );
  
  do_op := example.MUL;
  
  WriteLn( '    MUL(a,b) = ' , do_op(a,b) );

  WriteLn( 'Here is what the C callback function classes are called in delphi' );
  WriteLn( '    ADD      = ' , longint(@example.ADD) );
  WriteLn( '    SUB      = ' , longint(@example.SUB) );
  WriteLn( '    MUL      = ' , longint(@example.MUL) );
end.