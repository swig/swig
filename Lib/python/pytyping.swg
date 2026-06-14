%typemap(pytyping) SWIGTYPE "$&pytypename"

%typemap(pytyping) SWIGTYPE [] "typing.Optional[$pytypename]"

%typemap(pytyping) SWIGTYPE * "typing.Optional[$pytypename]"

%typemap(pytyping) SWIGTYPE & "$pytypename"

%typemap(pytyping) SWIGTYPE && "$pytypename"

%typemap(pytyping) enum SWIGTYPE "int"

%typemap(pytyping) bool "bool"

/*
    Map both 'T' and 'T const &' to 'PyType'.
    Keep in sync with primtypes.swg.
*/
%define %_pytyping_primtype(Type, PyType)
    %typemap(pytyping) Type, Type const & "PyType"
%enddef

%_pytyping_primtype(bool, bool);

%_pytyping_primtype(signed char       , int);
%_pytyping_primtype(unsigned char     , int);
%_pytyping_primtype(short             , int);
%_pytyping_primtype(unsigned short    , int);
%_pytyping_primtype(int               , int);
%_pytyping_primtype(unsigned int      , int);
%_pytyping_primtype(long              , int);
%_pytyping_primtype(unsigned long     , int);
%_pytyping_primtype(long long         , int);
%_pytyping_primtype(unsigned long long, int);
%_pytyping_primtype(size_t            , int);
%_pytyping_primtype(std::size_t       , int);
%_pytyping_primtype(ptrdiff_t         , int);
%_pytyping_primtype(std::ptrdiff_t    , int);

%_pytyping_primtype(float , float);
%_pytyping_primtype(double, float);

%_pytyping_primtype(std::complex< float > , complex);
%_pytyping_primtype(std::complex< double >, complex);

/* No 'T const &' maps for these */
%typemap(pytyping) float _Complex, double _Complex, _Complex "complex"

%_pytyping_primtype(char        , str);
%_pytyping_primtype(wchar_t     , str);
%_pytyping_primtype(std::string , str);
%_pytyping_primtype(std::wstring, str);

%typemap(pytyping) long double "float"

%typemap(pytyping) char *, wchar_t * "str"

%typemap(pytyping) void "None"
