#if !defined(IMPORT_SHARE_A_H)
#define IMPORT_SHARE_A_H

class Operator {
  int m_height;
public:
  Operator(int height) : m_height(height) {}
  int getHeight() { return m_height; }
};

int Operator_Height(Operator *op) {
  return op->getHeight();
}

#endif
