/* File: example.h */


class ExClass {
public:
  ExClass(int val);
  int operator() (void) const;
private:
  const int val;
};
