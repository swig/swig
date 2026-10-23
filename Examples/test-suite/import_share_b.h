#if !defined(IMPORT_SHARE_B_H)
#define IMPORT_SHARE_B_H

#include "import_share_a.h"

class DenseMatrix : public Operator {
  int m_width;
public:
  DenseMatrix(int height, int width) : Operator(height), m_width(width) {}
  int getWidth() { return m_width; }
};
#endif
