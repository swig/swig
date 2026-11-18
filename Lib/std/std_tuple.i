%include <std_common.i>

%{
#if __cplusplus >= 201103L
#include <tuple>
#endif
%}

namespace std {
  template <typename... T> class tuple {
  public:
    tuple();
    tuple(const tuple& other);
  };
}
