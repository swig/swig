import constant_directive

if not isinstance(constant_directive.TYPE1_CONSTANT1, constant_directive.Type1):
    raise RuntimeError("Failure: TYPE1_CONSTANT1 type: {}".format(
        type(constant_directive.TYPE1_CONSTANT1)))
if not isinstance(constant_directive.getType1Instance(), constant_directive.Type1):
    raise RuntimeError("Failure: getType1Instance() type: {}".format(
        type(constant_directive.getType1Instance())))

if constant_directive.TYPE1_CONSTANT1.val != 1:
    raise RuntimeError("constant_directive.TYPE1_CONSTANT1.val is %r (should be 1)" %
                       constant_directive.TYPE1_CONSTANT1.val)

if constant_directive.TYPE1_CONSTANT2.val != 2:
    raise RuntimeError("constant_directive.TYPE1_CONSTANT2.val is %r (should be 2)" %
                       constant_directive.TYPE1_CONSTANT2.val)

if constant_directive.TYPE1_CONSTANT3.val != 3:
    raise RuntimeError("constant_directive.TYPE1_CONSTANT3.val is %r (should be 3)" %
                       constant_directive.TYPE1_CONSTANT3.val)

if constant_directive.TYPE1CONST_CONSTANT1.val != 1:
    raise RuntimeError("constant_directive.TYPE1CONST_CONSTANT1.val is %r (should be 1)" %
                       constant_directive.TYPE1CONST_CONSTANT1.val)

if constant_directive.TYPE1CPTR_CONSTANT1.val != 1:
    raise RuntimeError("constant_directive.TYPE1CPTR_CONSTANT1.val is %r (should be 1)" %
                       constant_directive.TYPE1CPTR_CONSTANT1.val)

# The type of a %constant initialised with a named cast is the type cast to.
if not isinstance(constant_directive.cast_double_constant, float):
    raise RuntimeError("cast_double_constant type: {}".format(
        type(constant_directive.cast_double_constant)))
if constant_directive.cast_double_constant != 3.0:
    raise RuntimeError("cast_double_constant is %r (should be 3.0)" %
                       constant_directive.cast_double_constant)

if constant_directive.cast_uint_constant != 3:
    raise RuntimeError("cast_uint_constant is %r (should be 3)" %
                       constant_directive.cast_uint_constant)

if constant_directive.cast_bool_constant is not True:
    raise RuntimeError("cast_bool_constant is %r (should be True)" %
                       constant_directive.cast_bool_constant)
