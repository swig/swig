// Another evil Luigi test
%module template_extend2

%warnfilter(801) Baz<long>;	// Ruby, wrong class name
%warnfilter(801) Baz<double>;	// Ruby, wrong class name

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


