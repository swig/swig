using System;
using cpp11_move_only_valuewrapperNamespace;

public class cpp11_move_only_valuewrapper_runme {

  public static void Main() {
    XXX.reset_counts();
    using (XXX xxx = cpp11_move_only_valuewrapper.createXXX()) {
    }
    if (cpp11_move_only_valuewrapper.has_cplusplus11())
      XXX.check_counts(1, 1, 0, 1, 0, 3); // Was (1, 2, 0, 0, 0, 3) before SwigValueWrapper::operator=(T &&) was added.
    cpp11_move_only_valuewrapper.test1();
    cpp11_move_only_valuewrapper.test2();
    cpp11_move_only_valuewrapper.test3();
    cpp11_move_only_valuewrapper.test4();
    cpp11_move_only_valuewrapper.test5();
    cpp11_move_only_valuewrapper.test6();

    // C# only test (SwigValueWrapper and custom typemaps for std::unique_ptr)
    SWIGTYPE_p_std__unique_ptrT_XXX_t ptr = cpp11_move_only_valuewrapper.makeUniqueXXX();
    cpp11_move_only_valuewrapper.cleanup(ptr);

  }

}
