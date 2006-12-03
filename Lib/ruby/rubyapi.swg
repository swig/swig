/* -----------------------------------------------------------------------------
 * Ruby API portion that goes into the runtime
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

SWIGINTERN VALUE
SWIG_Ruby_AppendOutput(VALUE target, VALUE o) {
  if (NIL_P(target)) {
    target = o;
  } else {
    if (TYPE(target) != T_ARRAY) {
      VALUE o2 = target;
      target = rb_ary_new();
      rb_ary_push(target, o2);
    }
    rb_ary_push(target, o);
  }
  return target;
}

#ifdef __cplusplus
}
#endif

