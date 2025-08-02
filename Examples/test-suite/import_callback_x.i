%module import_callback_x

%{
#include "import_callback_x.h"
%}

%callback("%s_cb_ptr") X::xmethod;

%import "import_callback_y.i"

%include "import_callback_x.h"
