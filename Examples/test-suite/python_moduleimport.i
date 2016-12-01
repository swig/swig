%define MODULEIMPORT
"
#print 'Loading low-level module $module'
import $module
#print 'Module has loaded'
extra_import_variable = 'custom import of $module'
"
%enddef

%module(moduleimport=MODULEIMPORT) python_moduleimport

%inline %{
int simple_function(int i) { return i; }
%}
