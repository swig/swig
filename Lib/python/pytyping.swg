/* ------------------------------------------------------------
 * PEP 484 type hints for the primitive types and C strings
 *
 * The type hints for any other type are defined in the library
 * file providing the in and out typemaps for that type.
 * ------------------------------------------------------------ */

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
  float,  float const &,
  double, double const &
"float"

%typemap(pytyping) char, char const & "str"

%typemap(pytyping) char * "typing.Optional[str]"

%typemap(pytyping) void "None"
