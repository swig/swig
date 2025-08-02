%module template_duplicate

%include <std_vector.i>

%warnfilter(SWIGWARN_TYPE_REDEFINED) std::vector<boolean_T>;
%warnfilter(SWIGWARN_TYPE_REDEFINED) std::vector<uint8_T>;

%inline %{
typedef unsigned char uint8_T;
typedef unsigned char boolean_T;
%}

%template(std_vector_boolean_type) std::vector<boolean_T>;
%template(std_vector_boolean_type_duplicate) std::vector<boolean_T>;
%template(std_vector_uint8_type) std::vector<uint8_T>;

namespace std {
%template(std_vector_boolean_type_again) vector<boolean_T>;
%template(std_vector_uint8_type_again) vector<uint8_T>;
%template(std_vector_unsigned_char) vector<unsigned char>;
}
