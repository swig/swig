import cpp11_auto_variable_new_expression.*;

public class cpp11_auto_variable_new_expression_runme {

  static {
    try {
      System.loadLibrary("cpp11_auto_variable_new_expression");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(long got, long expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " expected: " + expected + " got: " + got);
  }

  public static void main(String argv[]) {
    // Each getter is passed to a function taking exactly the type it should deduce, which only compiles if it does.
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getParens_int()), 5, "parens_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getBraced_int()), 6, "braced_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getNested_parens_int()), 8, "nested_parens_int");
    check(cpp11_auto_variable_new_expression.const_int_value(cpp11_auto_variable_new_expression.getConst_int()), 9, "const_int");
    check(cpp11_auto_variable_new_expression.const_int_value(cpp11_auto_variable_new_expression.getTrailing_const_int()), 10, "trailing_const_int");
    check(cpp11_auto_variable_new_expression.unsigned_value(cpp11_auto_variable_new_expression.getUnsigned_int()), 12, "unsigned_int");
    check(cpp11_auto_variable_new_expression.unsigned_value(cpp11_auto_variable_new_expression.getUnsigned_int_empty()), 0, "unsigned_int_empty");
    check(cpp11_auto_variable_new_expression.unsigned_value(cpp11_auto_variable_new_expression.getUnsigned_int_array()), 24, "unsigned_int_array");
    check(cpp11_auto_variable_new_expression.const_unsigned_value(cpp11_auto_variable_new_expression.getConst_unsigned_int()), 26, "const_unsigned_int");
    check(cpp11_auto_variable_new_expression.unsigned_long_value(cpp11_auto_variable_new_expression.getUnsigned_long_number()), 27, "unsigned_long_number");
    check(cpp11_auto_variable_new_expression.unsigned_long_value(cpp11_auto_variable_new_expression.getLong_unsigned_int()), 28, "long_unsigned_int");
    check(cpp11_auto_variable_new_expression.unsigned_short_value(cpp11_auto_variable_new_expression.getUnsigned_short_number()), 29, "unsigned_short_number");
    check(cpp11_auto_variable_new_expression.unsigned_char_value(cpp11_auto_variable_new_expression.getUnsigned_char_number()), 30, "unsigned_char_number");
    check(cpp11_auto_variable_new_expression.signed_char_value(cpp11_auto_variable_new_expression.getSigned_char_number()), 31, "signed_char_number");
    check(cpp11_auto_variable_new_expression.unsigned_value(cpp11_auto_variable_new_expression.getAuto_unsigned()), 32, "auto_unsigned");
    if (cpp11_auto_variable_new_expression.double_value(cpp11_auto_variable_new_expression.getDouble_number()) != 2.5)
      throw new RuntimeException("double_number");
    cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getBare_int());

    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getPlain_widget()), 7, "plain_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getArgs_widget()), 3, "args_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getBraced_widget()), 7, "braced_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getAliased_widget()), 5, "aliased_widget");
    check(cpp11_auto_variable_new_expression.scoped_value(cpp11_auto_variable_new_expression.getScoped_widget()), 11, "scoped_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getGlobal_widget()), 8, "global_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getStar_widget()), 4, "star_widget");
    check(cpp11_auto_variable_new_expression.getPlain_widget().getValue(), 7, "plain_widget.value");

    check(cpp11_auto_variable_new_expression.box_value(cpp11_auto_variable_new_expression.getBoxed()), 13, "boxed");
    check(cpp11_auto_variable_new_expression.getBoxed().getValue(), 13, "boxed.value");
    check(cpp11_auto_variable_new_expression.pair_sum(cpp11_auto_variable_new_expression.getPaired()), 7, "paired");

    check(cpp11_auto_variable_new_expression.int_at(cpp11_auto_variable_new_expression.getInt_array(), 2), 22, "int_array");
    check(cpp11_auto_variable_new_expression.int_at(cpp11_auto_variable_new_expression.getSized_array(), 2), 0, "sized_array");
    check(cpp11_auto_variable_new_expression.widget_at(cpp11_auto_variable_new_expression.getWidget_array(), 1), 5, "widget_array");
    check(cpp11_auto_variable_new_expression.row_sum(cpp11_auto_variable_new_expression.getRows(), 1), 15, "rows");
    check(cpp11_auto_variable_new_expression.null_pointers(cpp11_auto_variable_new_expression.getInt_pointers(), 2), 2, "int_pointers");
    check(cpp11_auto_variable_new_expression.null_widgets(cpp11_auto_variable_new_expression.getWidget_pointers(), 3), 3, "widget_pointers");

    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getPlaced_widget()), 11, "placed_widget");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getNothrow_int()), 14, "nothrow_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getGlobal_new_int()), 23, "global_new_int");

    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getAuto_int()), 15, "auto_int");
    if (cpp11_auto_variable_new_expression.double_value(cpp11_auto_variable_new_expression.getAuto_double()) != 3.5)
      throw new RuntimeException("auto_double");
    check(cpp11_auto_variable_new_expression.const_int_value(cpp11_auto_variable_new_expression.getConst_auto_int()), 16, "const_auto_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getAuto_braced()), 3, "auto_braced");
    check(cpp11_auto_variable_new_expression.pointed_int_value(cpp11_auto_variable_new_expression.getAuto_paren_address()), 3, "auto_paren_address");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getDecltype_int()), 17, "decltype_int");

    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getAuto_sum()), 4, "auto_sum");
    if (cpp11_auto_variable_new_expression.double_value(cpp11_auto_variable_new_expression.getAuto_scaled()) != 7.5)
      throw new RuntimeException("auto_scaled");
    check(cpp11_auto_variable_new_expression.unsigned_short_value(cpp11_auto_variable_new_expression.getAuto_narrowed()), 3, "auto_narrowed");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getAuto_widget()), 7, "auto_widget");
    check(cpp11_auto_variable_new_expression.const_int_value(cpp11_auto_variable_new_expression.getConst_auto_difference()), 2, "const_auto_difference");

    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getSubscript_int()), 41, "subscript_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getNested_subscript_int()), 82, "nested_subscript_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getBraced_subscript_int()), 42, "braced_subscript_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getSubscript_auto()), 40, "subscript_auto");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getLambda_int()), 42, "lambda_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getNested_lambda_int()), 43, "nested_lambda_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getBraced_lambda_int()), 44, "braced_lambda_int");

    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getDecorated_widget()), 18, "decorated_widget");
    check(cpp11_auto_variable_new_expression.const_int_value(cpp11_auto_variable_new_expression.getDecorated_const_int()), 18, "decorated_const_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getFirst_int()), 19, "first_int");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getSecond_int()), 20, "second_int");
    check(cpp11_auto_variable_new_expression.getPlain_number(), 21, "plain_number");
    check(cpp11_auto_variable_new_expression.int_value(cpp11_auto_variable_new_expression.getNumber_pointer()), 22, "number_pointer");

    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getNested_widget()), 20, "nested_widget");
    check(cpp11_auto_variable_new_expression.widget_value(cpp11_auto_variable_new_expression.getMacro_widget()), 12, "macro_widget");

    check(cpp11_auto_variable_new_expression.getAfter_all(), 99, "after_all");
  }
}
