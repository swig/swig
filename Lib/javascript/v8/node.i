%insert("init") %{
#include <node.h>
%}

%define %node(moduleName)
%insert("post-init") %{
extern "C" {
    NODE_MODULE(moduleName, moduleName ## _initialize)
}    
%}
%enddef
