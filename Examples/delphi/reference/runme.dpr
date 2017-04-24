program runme;
uses SysUtils, example;

var
	a,b,c : TVector;
	va : TVectorArray; 
	i : integer;
begin
 		WriteLn( 'Creating some objects:' );
    a := TVector.Create(3,4,5);
    b := TVector.Create(10,11,12);
    
    WriteLn( '    Created ' , a.print() );
    WriteLn( '    Created ' , b.print() );
    
    // ----- Call an overloaded operator -----
    
    // This calls the wrapper we placed around
    //
    //      operator,(const Vector &a, const Vector &) 
    //
    // It returns a new allocated object.
    
    WriteLn( 'Adding a,b' );
   
    c := TVector.Create( example.addv(a.CObjPtr ,b.CObjPtr ), true);
   
   
    WriteLn( '    a,b = ' , c.print() );
    
    FreeAndNil(c);
    
    // ----- Create a vector array -----
    
    WriteLn( 'Creating an array of vectors' );
    va := TVectorArray.Create(10);
    //WriteLn( '    va = ' , va.ToString() );
    
    // ----- Set some values in the array -----
    
    // These operators copy the value of Vector a and Vector b to the vector array
    va._set(0,a);
    va._set(1,b);
    
   
   
 
    c := TVector.Create( example.addv(a.CObjPtr,b.CObjPtr), true);
    va._set(2, c);
    

    // Get some values from the array
    
    WriteLn( 'Getting some array values' );
    for  i := 0 to 5 do
        WriteLn( '    va(' , i , ') = ' , va._get(i).print() );
    
    
    // ----- Clean up -----
    
    WriteLn( 'Cleaning up' );
    va.Free;
    a.Free;
    b.Free;
    c.Free;
end.