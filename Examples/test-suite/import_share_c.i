%module import_share_c

%import "import_share_a.i"

%{
#include "import_share_c.h"
%}

// Forward declare DenseMatrix for SWIG without inheritance info.
// This causes module C to register DenseMatrix in the shared type
// table without the DenseMatrix->Operator cast, which is needed
// to exercise the bug fixed in swiginit.swg.
class DenseMatrix;

Operator* Make_DenseMatrix(int height, int width);
void Delete_DenseMatrix(DenseMatrix *op);
