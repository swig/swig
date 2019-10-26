%module li_std_vector_back_reference

%include <std_vector.i>

%inline %{
// #include <iostream>
struct Wheel {
  int size;
  Wheel(int sz = 0) : size(sz) {}
//  ~Wheel() { std::cout << "~Wheel" << std::endl; }
};
%}

%template(VectorWheel) std::vector<Wheel>;
