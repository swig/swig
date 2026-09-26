import cpp_new_expression

from swig_test_utils import swig_check

# The variables initialised by a new-expression are wrapped.
swig_check(cpp_new_expression.cvar.new_with_parens is not None, True)
swig_check(cpp_new_expression.cvar.new_bare is not None, True)
swig_check(cpp_new_expression.cvar.new_multi_b is not None, True)

# The declarations following each new-expression are still seen.
swig_check(cpp_new_expression.cvar.after_parens, 1)
swig_check(cpp_new_expression.cvar.after_bare, 2)
swig_check(cpp_new_expression.cvar.after_array, 3)
swig_check(cpp_new_expression.cvar.after_empty_parens, 5)
swig_check(cpp_new_expression.cvar.after_multi, 6)
swig_check(cpp_new_expression.cvar.after_global, 9)
swig_check(cpp_new_expression.cvar.after_offset, 10)

# A new-expression as a default argument is used when the argument is omitted.
swig_check(cpp_new_expression.default_with_parens(), 5)
swig_check(cpp_new_expression.default_bare(), 7)
swig_check(cpp_new_expression.default_args(), 3)
swig_check(cpp_new_expression.default_array(), 0)
swig_check(cpp_new_expression.default_global(), 6)
swig_check(cpp_new_expression.default_offset(), 0)
swig_check(cpp_new_expression.default_template(), 17)
swig_check(cpp_new_expression.compact_defaults(), 17)

# A new-expression in a function body is unaffected.
swig_check(cpp_new_expression.make_widget().w, 7)

# 'new' can be the name given by %rename, %constant and %template.
swig_check(cpp_new_expression.NewNames.new(), 11)
swig_check(cpp_new_expression.new, 12)
swig_check(cpp_new_expression.NewMaker.new(13), 13)
