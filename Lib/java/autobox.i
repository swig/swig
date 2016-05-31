/*
 Java typemaps for autoboxing in return types of generics.

 Java generics let you define interfaces, e.g.  Collection which operate on any homogenous
 collection of Objects, with compile time type checking. For example Collection<String> can
 only store String objects and the compiler helps enforce that.

 Unfortunately Java treats primitive types as a special case. They're not first class objects,
 so in order to have a collection of ints we have to actually maintain a Collection<Integer>.
 For each primitive type in Java (boolean, byte, short, int, long, float, double) there 
 exists a corresponding "proper" Object type in java.lang.*. 

 Although these proper Objects include a constructor and a xValue() method that allow for 
 explicit conversion between primitives and the corresponding Object type if programmers
 were required to explicitly perform this conversion every time it would rapidly become
 tedious for no real benefits. To address this the language designers introduced the 
 concepts of "autoboxing" and a corresponding unboxing which can happen implicitly. Thus it
 becomes legal to write:

    Collection<Double> c = new ArrayList<Double>();
    double d1 = 0;
    c.add(d1); // 1: void add(Double);
    double d2 = c.iterator().next(); // 2: Double next();

 The conversions required to allow lines commented 1: and 2: to compile are inserted 
 implicitly.

 When it comes to wrapping primitives from C or C++ code to Java SWIG by default take the path
 most expected. This means that double in C++ is represented by double in Java etc. as expected.
 Normally this behaviour is ideal, however when it comes to wrapping C++ templates which are 
 being mapped onto implementations of Java interfaces this behaviour is unhelpful because it
 is a syntax error in Java to claim to implement Collection<double> instead of 
 Collection<Double>.

 So to transparently allow a C++ template when wrapped to Java to accept template type 
 parameters of primitive, struct, enum etc. fluidly from the user perspective we need to support
 the same mapping, outside of the normal default.

 This autobox typemap exists to solve exactly that problem. With it we can map primitives onto
 the corresponding java.lang.* type, whilst mapping all other types onto type that they would
 usually map onto. (That is to say it falls back to simply be the result of the jstype typemap
 for all non-primitive types).

 So for example if a given container template in exists in C++:

   template <typename T>
   struct ExampleContainer {
     typedef T value_type;
     // .....
   };

 When wrapped in Java we'd like it to implement the Collection interface correctly, even for
 primitives. With these autobox typemaps we can now simply write the following for example:

   %typemap(javabase) ExampleContainer "Collection<$typemap(autobox,$1_basetype::value_type)>"

 Which does exactly the right thing for both primitive and non-primitive types.

*/
%define AUTOBOX(CTYPE, JTYPE)
%typemap(autobox) CTYPE, const CTYPE& "JTYPE"
%enddef
AUTOBOX(double, Double)
AUTOBOX(float, Float)
AUTOBOX(boolean, Boolean)
AUTOBOX(signed char, Byte)
AUTOBOX(short, Short)
AUTOBOX(int, Integer)
AUTOBOX(long, Long)
AUTOBOX(SWIGTYPE, $typemap(jstype,$1_basetype))
