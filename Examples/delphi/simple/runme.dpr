program runme;
uses example;


var
	x,y,g : integer;
  
begin
	x := 42;
  y := 105;
  g := example.gcd(x,y);
  WriteLn('The gcd of ' , x , ' and ' , y , ' is ' , g);

  // Manipulate the Foo global variable

  // Output its current value
  WriteLn('Foo = ' , example.Foo_get);

  // Change its value
  example.Foo_set( 3.1415926 );

  // See if the change took effect
  WriteLn('Foo = ' , example.Foo_get);

end.