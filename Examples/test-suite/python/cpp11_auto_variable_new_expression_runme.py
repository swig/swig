from cpp11_auto_variable_new_expression import *
import cpp11_auto_variable_new_expression as m

from swig_test_utils import swig_assert, swig_check

v = m.cvar

swig_check(int_value(v.parens_int), 5)
swig_check(int_value(v.braced_int), 6)
swig_check(int_value(v.nested_parens_int), 8)
swig_check(const_int_value(v.const_int), 9)
swig_check(const_int_value(v.trailing_const_int), 10)
swig_check(double_value(v.double_number), 2.5)

swig_check(unsigned_value(v.unsigned_int), 12)
swig_check(unsigned_value(v.unsigned_int_empty), 0)
swig_check(unsigned_value(v.unsigned_int_array), 24)
swig_check(const_unsigned_value(v.const_unsigned_int), 26)
swig_check(unsigned_long_value(v.unsigned_long_number), 27)
swig_check(unsigned_long_value(v.long_unsigned_int), 28)
swig_check(unsigned_short_value(v.unsigned_short_number), 29)
swig_check(unsigned_char_value(v.unsigned_char_number), 30)
swig_check(signed_char_value(v.signed_char_number), 31)
int_value(v.bare_int)

swig_check(widget_value(v.plain_widget), 7)
swig_check(widget_value(v.args_widget), 3)
swig_check(widget_value(v.braced_widget), 7)
swig_check(widget_value(v.aliased_widget), 5)
swig_check(scoped_value(v.scoped_widget), 11)
swig_check(widget_value(v.global_widget), 8)
swig_check(widget_value(v.star_widget), 4)
swig_check(v.plain_widget.value, 7)

swig_check(box_value(v.boxed), 13)
swig_check(v.boxed.value, 13)
swig_check(pair_sum(v.paired), 7)

swig_check(int_at(v.int_array, 2), 22)
swig_check(int_at(v.sized_array, 2), 0)
swig_check(widget_at(v.widget_array, 1), 5)
swig_check(row_sum(v.rows, 1), 15)
swig_check(null_pointers(v.int_pointers, 2), 2)
swig_check(null_widgets(v.widget_pointers, 3), 3)

swig_check(widget_value(v.placed_widget), 11)
swig_check(int_value(v.nothrow_int), 14)
swig_check(int_value(v.global_new_int), 23)

swig_check(int_value(v.auto_int), 15)
swig_check(double_value(v.auto_double), 3.5)
swig_check(const_int_value(v.const_auto_int), 16)
swig_check(int_value(v.auto_braced), 3)
swig_check(pointed_int_value(v.auto_paren_address), 3)
swig_check(unsigned_value(v.auto_unsigned), 32)
swig_check(int_value(v.decltype_int), 17)

swig_check(int_value(v.auto_sum), 4)
swig_check(double_value(v.auto_scaled), 7.5)
swig_check(unsigned_short_value(v.auto_narrowed), 3)
swig_check(widget_value(v.auto_widget), 7)
swig_check(const_int_value(v.const_auto_difference), 2)
swig_check(auto_default(), 7)

swig_check(int_value(v.subscript_int), 41)
swig_check(int_value(v.nested_subscript_int), 82)
swig_check(int_value(v.braced_subscript_int), 42)
swig_check(int_value(v.subscript_auto), 40)
swig_check(int_value(v.lambda_int), 42)
swig_check(int_value(v.nested_lambda_int), 43)
swig_check(int_value(v.braced_lambda_int), 44)
swig_check(subscript_default(), 41)
swig_check(lambda_default(), 43)

swig_check(widget_value(v.decorated_widget), 18)
swig_check(const_int_value(v.decorated_const_int), 18)
swig_check(int_value(v.first_int), 19)
swig_check(int_value(v.second_int), 20)
swig_check(v.plain_number, 21)
swig_check(int_value(v.number_pointer), 22)

swig_check(widget_value(v.nested_widget), 20)
swig_check(widget_value(v.macro_widget), 12)

for name in ["plus_after_initialiser", "plus_after_array", "parenthesised_type_id", "lambda_auto"]:
    swig_assert(not hasattr(v, name), name + " should be ignored")

swig_check(v.after_all, 99)
