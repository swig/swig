/* This test case is meant to be used with run tests that check that
   -- the whole range of the integer types is supported;
   -- errors are signalled when out-of-range values are passed.
*/

%module integers;

%inline %{
  signed char signed_char_identity(signed char x) { return x; }
  unsigned char unsigned_char_identity(unsigned char x) { return x; }
  signed short signed_short_identity(signed short x) { return x; }
  unsigned short unsigned_short_identity(unsigned short x) { return x; }
  signed int signed_int_identity(signed int x) { return x; }
  unsigned int unsigned_int_identity(unsigned int x) { return x; }
  signed long signed_long_identity(signed long x) { return x; }
  unsigned long unsigned_long_identity(unsigned long x) { return x; }
  signed long long signed_long_long_identity(signed long long x) { return x; }
  unsigned long long unsigned_long_long_identity(unsigned long long x) { return x; }

#ifdef __cplusplus
  signed char        & signed_char_ref_identity(       signed char        & x) { return x; }
  unsigned char      & unsigned_char_ref_identity(     unsigned char      & x) { return x; }
  signed short       & signed_short_ref_identity(      signed short       & x) { return x; }
  unsigned short     & unsigned_short_ref_identity(    unsigned short     & x) { return x; }
  signed int         & signed_int_ref_identity(        signed int         & x) { return x; }
  unsigned int       & unsigned_int_ref_identity(      unsigned int       & x) { return x; }
  signed long        & signed_long_ref_identity(       signed long        & x) { return x; }
  unsigned long      & unsigned_long_ref_identity(     unsigned long      & x) { return x; }
  signed long long   & signed_long_long_ref_identity(  signed long long   & x) { return x; }
  unsigned long long & unsigned_long_long_ref_identity(unsigned long long & x) { return x; }

  const signed char        & const_signed_char_ref_identity(       const signed char        & x) { return x; }
  const unsigned char      & const_unsigned_char_ref_identity(     const unsigned char      & x) { return x; }
  const signed short       & const_signed_short_ref_identity(      const signed short       & x) { return x; }
  const unsigned short     & const_unsigned_short_ref_identity(    const unsigned short     & x) { return x; }
  const signed int         & const_signed_int_ref_identity(        const signed int         & x) { return x; }
  const unsigned int       & const_unsigned_int_ref_identity(      const unsigned int       & x) { return x; }
  const signed long        & const_signed_long_ref_identity(       const signed long        & x) { return x; }
  const unsigned long      & const_unsigned_long_ref_identity(     const unsigned long      & x) { return x; }
  const signed long long   & const_signed_long_long_ref_identity(  const signed long long   & x) { return x; }
  const unsigned long long & const_unsigned_long_long_ref_identity(const unsigned long long & x) { return x; }
#endif

  signed char        * signed_char_ptr() { return NULL; }
  unsigned char      * unsigned_char_ptr() { return NULL; }
  signed short       * signed_short_ptr() { return NULL; }
  unsigned short     * unsigned_short_ptr() { return NULL; }
  signed int         * signed_int_ptr() { return NULL; }
  unsigned int       * unsigned_int_ptr() { return NULL; }
  signed long        * signed_long_ptr() { return NULL; }
  unsigned long      * unsigned_long_ptr() { return NULL; }
  signed long long   * signed_long_long_ptr() { return NULL; }
  unsigned long long * unsigned_long_long_ptr() { return NULL; }

  size_t signed_char_size() { return sizeof (signed char); }
  size_t unsigned_char_size() { return sizeof (unsigned char); }
  size_t signed_short_size() { return sizeof (signed short); }
  size_t unsigned_short_size() { return sizeof (unsigned short); }
  size_t signed_int_size() { return sizeof (signed int); }
  size_t unsigned_int_size() { return sizeof (unsigned int); }
  size_t signed_long_size() { return sizeof (signed long); }
  size_t unsigned_long_size() { return sizeof (unsigned long); }
  size_t signed_long_long_size() { return sizeof (signed long long); }
  size_t unsigned_long_long_size() { return sizeof (unsigned long long); }
%}

