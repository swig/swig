// Another evil Luigi test
%module template_extend2

%{
namespace Quux {  
template <class T> class Baz {}; 
}
%}

namespace Quux {  
template <class T> class Baz {}; 

%extend Baz<long> { 
     char *foo(void) { return (char *) "lBaz::foo"; }
} 
%template (lBaz) Baz<long>; 

%extend Baz<double> { 
     char *foo(void) { return (char *) "dBaz::foo"; }
} 
 
%template (dBaz) Baz<double>; 
} 


