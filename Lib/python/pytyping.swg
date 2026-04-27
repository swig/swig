%typemap(pytyping) SWIGTYPE "typing.Any"

%typemap(pytyping) bool, bool const & "bool"

%typemap(pytyping)
  signed char,        signed char const &,
  unsigned char,      unsigned char const &,
  short,              short const &,
  unsigned short,     unsigned short const &,
  int,                int const &,
  unsigned int,       unsigned int const &,
  long,               long const &,
  unsigned long,      unsigned long const &,
  long long,          long long const &,
  unsigned long long, unsigned long long const &,
  size_t,             size_t const &,
  ptrdiff_t,          ptrdiff_t const &
"int"

%typemap(pytyping)
  float,       float const &,
  double,      double const &,
  long double, long double const &
"float"

/* No 'T const &' maps for these */
%typemap(pytyping) float _Complex, double _Complex, _Complex "complex"

%typemap(pytyping)
    char,    char const &,
    wchar_t, wchar_t const &
    "str"

%typemap(pytyping) char *, wchar_t * "str"

%typemap(pytyping) void "None"
