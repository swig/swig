// One of Luigi's evil tests

%module template_extend1

%warnfilter(801) Baz<long>;	// Ruby, wrong class name
%warnfilter(801) Baz<double>;	// Ruby, wrong class name

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
