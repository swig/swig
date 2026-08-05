/* Check that SWIG_FromCharPtrAndSize and SWIG_FromBinaryCharPtrAndSize reach the C
   compiler rather than being consumed by the SWIG preprocessor.

   A typemap delimited with %{ ... %} is not macro expanded by SWIG, so the macro
   names below survive into the generated wrapper, and the generated code only
   compiles if the library defines them for the C compiler too.

   Guile is a UTL language but provides no SWIG_FromCharPtrAndSize fragment.
   Tcl, Scilab and JavaScript provide no SWIG_FromBinaryCharPtrAndSize. The
   languages without these typemaps wrap the functions using the default
   typemaps instead. */

%module charptr_fragment

#if defined(SWIGUTL) && !defined(SWIGGUILE)

%wrapper %{
/* Code inserted verbatim like this is not macro expanded by SWIG either, so
   SWIG_FromCharPtrAndSize has to be usable by the C compiler.  The typemaps go
   through these aliases so that %set_output can still be used - %set_output is
   itself a SWIG macro, is not expanded inside a verbatim delimited typemap
   either, and its expansion differs per target language. */
#define swig_charbuf_from(b) SWIG_FromCharPtrAndSize((b).str, (b).len)
%}

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") struct CharBuf {
  %set_output(swig_charbuf_from($1));
}

#endif

#if defined(SWIGUTL) && !defined(SWIGGUILE) && !defined(SWIGTCL) && !defined(SWIGSCILAB) && !defined(SWIGJAVASCRIPT)

%wrapper %{
#define swig_charbuf_from_binary(b) SWIG_FromBinaryCharPtrAndSize((b).str, (b).len, 0)
%}

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") struct BinaryCharBuf {
  %set_output(swig_charbuf_from_binary($1));
}

#endif

#ifdef SWIGR
/* The out typemaps above already return a character vector, but the R proxy
   layer would otherwise wrap it up again in a _p_CharBuf S4 object. */
%typemap(scoerceout) struct CharBuf, struct BinaryCharBuf %{ %}
#endif

/* Only the functions are wrapped - the structs are deliberately not exposed, so
   that the out typemaps above are the only thing under test. */
%{
struct CharBuf {
  size_t len;
  const char *str;
};

struct BinaryCharBuf {
  size_t len;
  const char *str;
};

static struct CharBuf getCharBuf(void) {
  struct CharBuf b;
  b.len = 5;
  b.str = "hello world";
  return b;
}

static struct BinaryCharBuf getBinaryCharBuf(void) {
  struct BinaryCharBuf b;
  b.len = 5;
  b.str = "hello world";
  return b;
}
%}

struct CharBuf getCharBuf(void);
struct BinaryCharBuf getBinaryCharBuf(void);
