%module import_share_b

%import "import_share_a.i"

%include "import_share_b.h"
%{
#include "import_share_b.h"
%}
