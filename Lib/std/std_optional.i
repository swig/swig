%include <std_common.i>

%{
#if __cplusplus >= 201703L
#include <optional>
#endif
%}

namespace std {
  template <typename T> class optional {
  public:
    optional();
    optional(const optional& other);
  };
}
