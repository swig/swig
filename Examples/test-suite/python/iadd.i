%module iadd

%include attribute.i
%{
#include "iadd.h"
%} 
class Foo; 
%attribute_ref(test::Foo, test::A& , AsA);
%attribute_ref(test::Foo, long, AsLong);


%typemap(out) B & B::operator+=  "hello";





%include "iadd.h"
