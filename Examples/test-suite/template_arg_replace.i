%module template_arg_replace

%inline %{

template <typename T, int r, int c> class Matrix { 
public: 
 void Func(const Matrix<T,r,c> &m) { }; 
}; 
%} 

%template (matrix33f) Matrix<float,3, 3>; 
 

