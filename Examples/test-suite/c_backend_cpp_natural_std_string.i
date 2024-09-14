%module c_backend_cpp_natural_std_string

%feature ("nspace", "1");

%include std_string.i

%inline %{
	static std::string& myStringAppend(std::string &someString, const std::string &appendedString)
	{
		someString += appendedString;
		return someString;
	}
%}
