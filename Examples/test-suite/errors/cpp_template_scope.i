%module xxx

namespace std {
  template<typename T> class vector {};
}

struct S1 {};
struct S2 {};
struct S3 {};
struct S4 {};
struct S5 {};
struct S6 {};
struct S7 {};

// valid
namespace std {
  %template(vi1) vector<S1>;
  template class vector<S1>;
}

// valid
using namespace std;
%template(vi2) vector<S2>;
template class vector<S2>;

// valid
using std::vector;
%template(vi3) vector<S3>;
template class vector<S3>;

// ill-formed
namespace unrelated {
  using std::vector;
  %template(vi4) vector<S4>;
  template class vector<S4>;
}

// ill-formed
namespace unrelated {
  using namespace std;
  %template(vi5) vector<S5>;
  template class vector<S5>;
}

// ill-formed
namespace unrelated {
  namespace std {
    %template(vi6) vector<S6>;
    template class vector<S6>;
  }
}

// ill-formed
namespace unrelated {
  %template(vi7) std::vector<S7>;
  template class std::vector<S7>;
}
