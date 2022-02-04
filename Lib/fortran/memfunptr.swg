/* -------------------------------------------------------------------------
 * memfunptr.swg
 * ------------------------------------------------------------------------- */

%fragment("SwigFortranPackedData", "header",
          fragment="<string.h>", fragment="<stdlib.h>") %{
class SwigFortranPackedData {
 private:
  char* packed_;

 public:
  template<class T>
  SwigFortranPackedData(const T* data) {
    packed_ = (char *)malloc(sizeof(T));
    memcpy(packed_, data, sizeof(T));
  }

  ~SwigFortranPackedData() { free(packed_); }

  template<class T>
  void unpack(T* data) const {
    memcpy(data, packed_, sizeof(T));
  }

 private:
  SwigFortranPackedData& operator=(const SwigFortranPackedData& other);
};
%}

/* -------------------------------------------------------------------------
 * TYPEMAPS
 * ------------------------------------------------------------------------- */

%typemap(in, noblock=1, fragment="SwigFortranPackedData") SWIGTYPE (CLASS::*) {
  ((SwigFortranPackedData*)($input->cptr))->unpack<$1_ltype>(&$1);
}

%typemap(out, noblock=1, fragment="SwigFortranPackedData") SWIGTYPE (CLASS::*) {
  $result.cptr = new SwigFortranPackedData(&$1);
  $result.cmemflags = SWIG_MEM_RVALUE | SWIG_MEM_OWN;
}

// The SWIG type system does not check the non-const memfunptr when looking for a const memfunptr. Also apply 
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::* const) };

// References to member function pointers will look like regular class references
%apply SWIGTYPE & { SWIGTYPE (CLASS::*const&) }
