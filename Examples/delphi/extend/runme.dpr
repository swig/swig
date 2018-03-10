// This file illustrates the cross language polymorphism using directors.
// Not yet supported
program runme;
uses example;

type
    TCEO = class(TManager) 
    
    public
    	constructor Create(name:string);     
    
      function getPosition() : PChar; override;
      
    end;

constructor TCEO.Create(name:string);
begin
	inherited Create(PChar(name));
end; 
  
function TCEO.getPosition() : PChar;
begin
	Result := 'CEO';
end;
  
var
	e : TCEO;
	list : TEmployeeList;
begin
    // Create an instance of CEO, a class derived from the Delphi proxy of the 
    // underlying C++ class. The calls to getName() and getPosition() are standard,
    // the call to getTitle() uses the director wrappers to call CEO.getPosition().

    e := TCEO.Create('Alice');
    WriteLn( e.getName() , ' is a ' , e.getPosition() );
    WriteLn( 'Just call her "' , e.getTitle() , '"' );
    WriteLn( '----------------------' );

    // Create a new EmployeeList instance.  This class does not have a C++
    // director wrapper, but can be used freely with other classes that do.

    list := TEmployeeList.Create();

    // EmployeeList owns its items, so we must surrender ownership of objects we add.
    e.OwnCObjPtr := false;
    list.addEmployee(e);
    WriteLn( '----------------------' );

    // Now we access the first four items in list (three are C++ objects that
    // EmployeeList's constructor adds, the last is our CEO). The virtual
    // methods of all these instances are treated the same. For items 0, 1, and
    // 2, all methods resolve in C++. For item 3, our CEO, getTitle calls
    // getPosition which resolves in C#. The call to getPosition is
    // slightly different, however, because of the overidden getPosition() call, since
    // now the object reference has been 'laundered' by passing through
    // EmployeeList as an Employee*. Previously, Delphi resolved the call
    // immediately in CEO, but now Delphi thinks the object is an instance of
    // class Employee. So the call passes through the
    // Employee proxy class and on to the C wrappers and C++ director,
    // eventually ending up back at the Delphi CEO implementation of getPosition().
    // The call to getTitle() for item 3 runs the C,, Employee::getTitle()
    // method, which in turn calls getPosition(). This virtual method call
    // passes down through the C++ director class to the Delphi implementation
    // in CEO. All this routing takes place transparently.

    WriteLn( '(position, title) for items 0-3:' );

    WriteLn( '  ' , list.get_item(0).getPosition() , ', "' , list.get_item(0).getTitle() , '"' );
    WriteLn( '  ' , list.get_item(1).getPosition() , ', "' , list.get_item(1).getTitle() , '"' );
    WriteLn( '  ' , list.get_item(2).getPosition() , ', "' , list.get_item(2).getTitle() , '"' );
    WriteLn( '  ' , list.get_item(3).getPosition() , ', "' , list.get_item(3).getTitle() , '"' );
    WriteLn( '----------------------' );

    // The using statement ensures the EmployeeList.Dispose() will be called, which will delete all the Employee*
    // items it contains. The last item is our CEO, which gets destroyed as well.
    
    WriteLn( '----------------------' );

    // All done.

		list.Free;

    WriteLn( 'Delphi exit' );


end.