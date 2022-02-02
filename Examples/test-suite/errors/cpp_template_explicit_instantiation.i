%module xxx

%inline %{
namespace std {
  template<typename T> class vector {};
}
template<typename T> void Func() {}
%}

%inline %{
// Class template
template class std::vector<int>;        // C++03 template explicit instantiation definition in C++
extern template class std::vector<int>; // C++11 template explicit instantiation declaration (extern template)
%}
%template(VectorInt) std::vector<int>;  // SWIG template instantiation

%inline %{
// Function template
template void Func<int>();             // C++03 template explicit instantiation definition in C++
extern template void Func<int>();      // C++11 template explicit instantiation declaration (extern template)
%}
%template(FuncInt) Func<int>;          // SWIG template instantiation


