%module template_arg_replace

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) Matrix<float, 3, 3>;	/* Ruby, wrong class name */

%inline %{

template <typename T, int r, int c> class Matrix { 
public: 
 void Func(const Matrix<T,r,c> &m) { }; 
}; 
%} 

%template (matrix33f) Matrix<float,3, 3>; 

