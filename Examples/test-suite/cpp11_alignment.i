%module cpp11_alignment

%inline %{
struct A {
  int member;
};
const int align1 = alignof(int);
const int align2 = alignof(int *);
%}

%{
// alignas - not yet working
struct alignas(16) S {
  int num;
};
alignas(double) unsigned char c[sizeof(double)];
%}
