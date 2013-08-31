%insert("begin") %{
#ifndef BUILDING_NODE_EXTENSION
#define BUILDING_NODE_EXTENSION
#endif
%}

%insert("runtime") %{
// we are including relative to the src folder because of issues
// with other files which might be named "node.h"
#include <src/node.h>
%}

