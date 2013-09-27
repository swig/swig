# Mapping C++ language features to Javascript

## Namespaces

A namespace is represented as a static instance (global variable)
containing other namespaces, global variables and functions 
and class templates

### Example:

C++:

~~~~c++
namespace foo {
    int x;
    namespace bar {
        double y;
    }
}
~~~~

Javascript:

~~~~javascript
var foo = new Object();
foo.x = 0;
foo.bar = new Object();
foo.bar.y = 0.0;
~~~~

## Global variables and functions

Global variables and functions are properties of other context objects 
(global or namespaces).

### Example:

C++:

~~~~c++
int x;
namespace foo {
    void bar();
}
~~~~

Javascript:

~~~~javascript
var x = 0;
var foo = new Object();
foo.bar = function() {
    return undefined;
}
~~~~

## Classes

Classes are defined as class templates and instantiated using the `new`
operator.
Class members are set in the constructor function using the `this` reference.
Private class members are set using the `var` keyword.

### Example:

C++:

~~~~c++
class Foo {
    int bar();
    
private:
    int x;
}
~~~~

Javascript:

~~~~javascript
var Foo = function() {
    var x = 42;
    this.bar = function() { return x; };
};

var foo = new Foo();
foo.bar();
~~~~

## Static class members and functions

Static variables and functions should be added to the class template object.

~~~~c++
class Foo {
    static std::string foo();
    std::string bar();
}
~~~~

Javascript:

~~~~javascript
var Foo = function() {
    this.bar = function() {
        return "bar";
    }
};
Foo.foo = function() {
    return "foo";
};

var foo = new Foo();
foo.foo()
> TypeError: Object [object Object] has no method 'foo'
Foo.foo()
> "foo"
foo.bar();
> "bar"
~~~~

## Inheritance

Javascript uses a prototype based inheritance mechanism. This limits 
feature support to single inheritance.

### Example:

C++:

~~~~c++
class Foo {
public:
    int foo();
    
private:
    int x;
}

class Bar: public Foo {
public:
    int bar();
}
~~~~

Javascript:

~~~~javascript
var Foo = function() {
    var x = 42;
    this.foo = function() { return x; };
};

var Bar = function() {
    this.bar = function() { return 6; };
}
Bar.prototype = new Foo();
Bar.prototype.constructor = Bar;

var foo = new Foo();
var bar = new Bar();

foo.foo()
> 42
foo.bar()
> TypeError: Object [object Object] has no method 'bar'
bar.foo()
> 42
bar.bar()
> 6
~~~~

## Virtual methods

The prototype mechanism of Javascript allows method overriding which is
needed to map the concept of virtual functions.

### Example:

C++:

~~~~c++
class Foo {
public:
    virtual int foo();
}

class Bar: public Foo {
public:
    virtual int foo();
}
~~~~

Javascript:

~~~~javascript
var Foo = function() {
    this.foo = function() { return 1; };
};

var Bar = function() {}
Bar.prototype = new Foo();
Bar.prototype.constructor = Bar;
Bar.prototype.foo = function() { return 42; };

var foo = new Foo();
var bar = new Bar();

foo.foo()
> 1
bar.foo()
> 42
~~~~

## Overloading

In Javascript like in other scripting languages method overloading is not
available. I.e., there can only be one function for one function name.
Therefore, it is necessary to implement a method dispatching mechanism
for these methods.

