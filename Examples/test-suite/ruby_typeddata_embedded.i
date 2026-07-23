%module ruby_typeddata_embedded

/* Regression test for the per-class TypedData wrapper using Ruby's embedded data
   slot (RUBY_TYPED_EMBEDDABLE) on Ruby 3.3 and later. If the per-class cext_type
   descriptor does not request embedding, the swig_ruby_wrapped_object is malloc'd
   and, because the free callback skips ruby_xfree when embedding is compiled in,
   leaked on every object. The runme checks that a wrapped object really is
   embedded so the leak can not silently come back. */

%inline %{
class Thing {
public:
  int value;
  Thing(int v) : value(v) {}
};

/* True when obj's TypedData wrapper is stored inside the Ruby object slot rather
   than a separate allocation. Always false on Ruby older than 3.3, which has no
   embedding support. */
bool swig_wrapper_embedded(VALUE obj) {
#ifdef TYPED_DATA_EMBEDDED
  return RTYPEDDATA_EMBEDDED_P(obj) ? true : false;
#else
  (void)obj;
  return false;
#endif
}
%}
