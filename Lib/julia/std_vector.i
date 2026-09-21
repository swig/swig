/* Minimal vector interface; primitive vectors also accept native Julia arrays. */
%{
#include <vector>
%}
namespace std {
  template <typename T> class vector {
  public:
    typedef T value_type;
    vector();
    size_t size() const;
    bool empty() const;
    void clear();
    void push_back(const T& value);
    T at(size_t index) const;
  };
}
