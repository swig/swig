%module cpp_basic_template_function

%inline
{
	template <class T>
	T GetMax (T a, T b) {
	  T result;
	  result = (a>b)? a : b;
	  return (result);
	}
}

%template(GetMaxInt) GetMax<int>;