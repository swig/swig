
class A {
  public:
    void fA() {}
};

typedef A tA;

inline void test_A(A *a) {}
inline void test_tA(tA *a) {}

inline tA *new_tA() { return new tA(); }
