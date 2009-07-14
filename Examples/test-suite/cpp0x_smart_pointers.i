/* This testcase checks whether Swig correctly uses the new general-purpose
   smart pointers introduced in C++0x:
   - shared_ptr
   - weak_ptr
   - unique_ptr
*/
%module cpp0x_smart_pointers

%inline %{
#include <tr1/shared_ptr.h>
#include <tr1/unique_ptr.h>
#include <tr1/weak_ptr.h>

struct A {
  std::shared_ptr<double> a1(new double);
  std::unique_ptr<double> a2(new double);
  std::weak_ptr<double> a3(a1);
};
%}
