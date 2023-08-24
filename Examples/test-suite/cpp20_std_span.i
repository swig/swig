%module cpp20_std_span

%include <std_span.i>

%template() std::span<int>;
%template() std::span<const int>;
%template() std::span<unsigned int>;
%template() std::span<const unsigned int>;

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


