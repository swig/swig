// One of Luigi's evil tests

%module template_extend1

%{
namespace Quux {
  template <class T> class Baz {};
}
%}

namespace Quux {  
template <class T> class Baz {}; 
 
%template (lBaz) Baz<long>; 
%extend Baz<long> { 
     char *foo(void) { return (char *) "lBaz::foo"; }
} 
 
%template (dBaz) Baz<double>; 
%extend Baz<double> { 
     char *foo(void) { return (char *) "dBaz::foo"; }
} 
} 
