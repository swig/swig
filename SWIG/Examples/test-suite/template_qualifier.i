%module template_qualifier

/* Stroustruo, 3rd Ed, C.13.6 */
%inline %{

class Memory {
public:
    template<class T> T *get_new() { return new T(); }
};

%}

%extend Memory {
%template(get_new_int) get_new<int>;
};
