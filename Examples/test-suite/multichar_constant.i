%module multichar_constant
/* A multicharacter constant, such as 'ab', has type int, not char, per the C
   and C++ standards, unlike a single-character constant (tested along with
   other character constants in char_constant.i). */

%inline %{
#if defined(__GNUC__)
/* Silence -Wmultichar for the deliberately multicharacter constants below.
   This works everywhere for C code. However, when compiling as C++ with the real GCC
   front end before version 13 the pragma has no effect. Suppressing the warning
   in GCC prior to version 13 then leads to the complicated setup below. */
#pragma GCC diagnostic ignored "-Wmultichar"
#endif

#if !defined(__GNUC__) || defined(__clang__) || !defined(__cplusplus) || __GNUC__ >= 13
/* Safe to use the literal directly here: this is either not the real GNU
   GCC front end (Clang also defines __GNUC__ for compatibility), not C++
   (multicharacter constants are unaffected in C), or GCC 13+. */
const int imulti_ab = 'ab';
#else
/* Real GCC before version 13, compiling as C++ (should be just Octave and JavaScript):
   #pragma GCC diagnostic ignored "-Wmultichar" cannot suppress this warning
   here - see the follow up for details. Reconstruct the same value GCC's
   own packing of 'ab' produces (first character in the most significant
   byte) without writing a multicharacter literal at all. */
const int imulti_ab = ((int)(unsigned char)'a' << 8) | (int)(unsigned char)'b';
#endif
%}

/* Octave, and JavaScript's node/napi/v8 engines, always compile the
   generated wrapper as C++ regardless of this being a C testcase (their
   runtime APIs require it), so they would still hit the GCC bug above for
   this auto-generated constant. Skip it for those languages rather than
   hand-writing a per-language fallback using each target language's own
   constant-registration API. */
#if !defined(SWIGOCTAVE) && !defined(SWIGJAVASCRIPT)
#define MULTICHAR_AB 'ab'
#endif
