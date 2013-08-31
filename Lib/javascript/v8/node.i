%insert("init") %{
#ifndef BUILDING_NODE_EXTENSION
#define BUILDING_NODE_EXTENSION
#endif

#include <node.h>
%}

%define %node(moduleName)
%insert("post-init") %{
extern "C" {
    NODE_MODULE(moduleName, moduleName ## _initialize)
}
%}
%enddef
