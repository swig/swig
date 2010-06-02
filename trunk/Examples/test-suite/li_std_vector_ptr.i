// Bug 2359417
%module li_std_vector_ptr

%include "std_vector.i"

%template(IntPtrVector) std::vector<int *>;

%inline %{
#include <iostream>
using namespace std;
int* makeIntPtr(int v) {
  return new int(v);
}
double* makeDoublePtr(double v) {
  return new double(v);
}

#if 1
int** makeIntPtrPtr(int* v) {
  return new int*(v);
}
#endif

void displayVector(std::vector<int *> vpi) {
  cout << "displayVector..." << endl;
  for (int i=0; i<vpi.size(); ++i)
    cout << *vpi[i] << endl;
}
%}

