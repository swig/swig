program runme;
uses example;

var
	shape:TShape;
	shapes: array of TShape;
	s:TSquare;
  c:TCircle;
	i:integer;
  
begin

		WriteLn( 'Creating some objects:' );

   	s := TSquare.Create(10);
   	c := TCircle.Create(10);
        
  	WriteLn( '    Created circle ' );
  	WriteLn( '    Created square ');
		WriteLn( 'A total of ' , TShape.GetNshapes , ' shapes were created' );

 		// ----- Member data access -----

    // Notice how we can do this using functions specific to
    // the 'Circle' class.
    c.x := 20;
    c.y := 30;

    // Now use the same functions in the base class
    shape := s;
    shape.x := -10;
    shape.y := 5;

    WriteLn( 'Here is their current position:' );
    WriteLn( '    Circle = (' , c.x, ' ', c.y, ')' );
    WriteLn( '    Square = (' , s.x, ' ', s.y , ')' );

    // ----- Call some methods -----

    WriteLn( 'Here are some properties of the shapes:' );
    SetLength(shapes,2);
    shapes[0] :=  c;
    shapes[1] :=  s;
            
	  for i := low(shapes) to high(shapes) do begin
        
    	WriteLn( '   ',  shapes[i].ClassName );
      WriteLn( '        area      = ', shapes[i].area() );
      WriteLn( '        perimeter = ', shapes[i].perimeter() );
    
    end;

    // Notice how the area() and perimeter() functions really
    // invoke the appropriate virtual method on each object.

    // ----- Delete everything -----

		s.Free;
		c.Free;

    WriteLn( 'Guess I''ll clean up now' );

    WriteLn( Shape.Getnshapes ,' shapes remain' );
    WriteLn( 'Goodbye' );
   

	

end.