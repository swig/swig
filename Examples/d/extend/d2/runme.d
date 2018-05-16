/// This file illustrates the cross language polymorphism using directors.
module runme;

import std.stdio;
import example;

// CEO class, which overrides Employee.getPosition().
class CEO : Manager {
public:
  this( string name ) {
    super( name );
  }

  override string getPosition() const {
    return "CEO";
  }

  // Public method to stop the SWIG proxy base class from thinking it owns the underlying C++ memory.
  void disownMemory() {
    swigCMemOwn = false;
  }
}

void main() {
  // Create an instance of CEO, a class derived from the D proxy of the
  // underlying C++ class. The calls to getName() and getPosition() are standard,
  // the call to getTitle() uses the director wrappers to call CEO.getPosition().

  auto e = new CEO( "Alice" );
  writefln( "%s is a %s.", e.getName(), e.getPosition() );
  writefln( "Just call her '%s'.", e.getTitle() );
  writeln( "----------------------" );

  {
    // Create a new EmployeeList instance.  This class does not have a C++
    // director wrapper, but can be used freely with other classes that do.
    scope auto list = new EmployeeList();

    // EmployeeList owns its items, so we must surrender ownership of objects we add.
    e.disownMemory();
    list.addEmployee(e);
    writeln( "----------------------" );

    // Now we access the first four items in list (three are C++ objects that
    // EmployeeList's constructor adds, the last is our CEO). The virtual
    // methods of all these instances are treated the same. For items 0, 1, and
    // 2, all methods resolve in C++. For item 3, our CEO, getTitle calls
    // getPosition which resolves in D. The call to getPosition is
    // slightly different, however, because of the overridden getPosition() call, since
    // now the object reference has been "laundered" by passing through
    // EmployeeList as an Employee*. Previously, D resolved the call
    // immediately in CEO, but now D thinks the object is an instance of
    // class Employee. So the call passes through the
    // Employee proxy class and on to the C wrappers and C++ director,
    // eventually ending up back at the D CEO implementation of getPosition().
    // The call to getTitle() for item 3 runs the C++ Employee::getTitle()
    // method, which in turn calls getPosition(). This virtual method call
    // passes down through the C++ director class to the D implementation
    // in CEO. All this routing takes place transparently.

    writeln( "(position, title) for items 0-3:" );
    writefln( "  %s, '%s'", list.getItem(0).getPosition(), list.getItem(0).getTitle() );
    writefln( "  %s, '%s'", list.getItem(1).getPosition(), list.getItem(1).getTitle() );
    writefln( "  %s, '%s'", list.getItem(2).getPosition(), list.getItem(2).getTitle() );
    writefln( "  %s, '%s'", list.getItem(3).getPosition(), list.getItem(3).getTitle() );
    writeln( "----------------------" );

    // All Employees will be destroyed when the EmployeeList goes out of scope,
    // including the CEO instance.
  }
  writeln( "----------------------" );

  // All done.
  writeln( "Exiting cleanly from D code." );
}
