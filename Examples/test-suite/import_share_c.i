%module import_share_c

%import "import_share_a.i"
%import "import_share_b.i"

%include "import_share_c.h"
%{
#include "import_share_c.h"
%}
