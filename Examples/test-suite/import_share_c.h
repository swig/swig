#if !defined(IMPORT_SHARE_C_H)
#define IMPORT_SHARE_C_H

#include "import_share_b.h"

Operator* Make_DenseMatrix(int height, int width) {
  return new DenseMatrix(height, width);
}

void Delete_DenseMatrix(DenseMatrix *op) {
  delete op;
}

#endif
