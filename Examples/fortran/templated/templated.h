/* File : templated.h */
template<typename T>
class Thing {
  T val_;

public:
  Thing(T val);
  T get() const;
};

template<typename T>
void print_thing(const Thing<T> &t);
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
