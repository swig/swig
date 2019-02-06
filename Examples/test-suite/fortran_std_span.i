/* File: fortran_std_span.i */
%module fortran_std_span

%{
// Simplified span class
namespace std {
template<class _Tp, int _Ex = -1>
class span
{
 public:
  typedef int index_type;
  typedef _Tp* pointer;

  span() : d_ptr(NULL), d_size(0) {}
  span(pointer d, index_type s) : d_ptr(d), d_size(s) {}
  span(pointer first, pointer last) : d_ptr(first), d_size(last - first) {}

  pointer data() const { return d_ptr; }
  index_type size() const { return d_size; }

 private:
  pointer d_ptr;
  index_type d_size;
};
} // namespace std

%}

%include <std_span.i>

%template() std::span<int>;
%template() std::span<const int>;

%inline %{
std::span<int> get_by_value() {
  static int tmp[] = {1, 2, 3};
  return std::span<int>(tmp, tmp + 3);
}

void get_by_reference(std::span<int>& arr) {
  arr = get_by_value();
}

void copy(std::span<const int> src, std::span<const int>& dst) {
  dst = src;
}

void increment_and_disassociate(std::span<int>& dst) {
  int* ptr = dst.data();
  for (int i = 0; i < dst.size(); ++i)
    ptr[i]++;
  dst = std::span<int>();
}

const std::span<const int>& const_ref(const std::span<const int>& src) {
  return src;
}

%}


