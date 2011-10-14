%module redefined_not

// These should not emit an Identifer redefined warning
%inline %{
typedef unsigned int size_t;
namespace std {
  using ::size_t;
}
using std::size_t;
typedef unsigned int size_t;
using std::size_t;
%}

