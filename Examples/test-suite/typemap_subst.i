/* This interface file tests for type-related typemap substitutions.
 */

%module typemap_subst

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) xyzzy; /* Ruby, wrong class name */

%inline %{
  struct xyzzy {
    int member;
  };
%}

%typemap(in) const struct xyzzy **TEST
  ($type temp, $*type startemp, $&type amptemp, $basetype basetemp)
{
  { /* Test C type name substitutions */
    $ltype a = (struct xyzzy **) NULL;
    const struct xyzzy **b = ($type) NULL;
    $&ltype c = (struct xyzzy ***) NULL;
    const struct xyzzy ***d = ($&type) NULL;
    $*ltype e = *a;
    $basetype f;
    f.member = 42;
  }
  { /* Test locals */
    basetemp.member = 0;
    startemp = &basetemp;
    temp = &startemp;
    amptemp = &temp;
  }
  { /* Test descriptors */
    void *desc = $descriptor;
    void *stardesc = $*descriptor;
    void *ampdesc = $&descriptor;
  }
  { /* Test mangled names */
    void *desc = SWIGTYPE$mangle;
    void *stardesc = SWIGTYPE$*mangle;
    void *ampdesc = SWIGTYPE$&mangle;
  }
  $1 = ($ltype) temp;
}

/* Java and C# modules don't use SWIG's runtime type system */
#if !defined(SWIGJAVA) && !defined(SWIGCSHARP)
%inline %{
  void foo(const struct xyzzy **TEST) {}
%}
#endif




