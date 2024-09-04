
import friends_nested.*;

public class friends_nested_runme {

  static {
    try {
	System.loadLibrary("friends_nested");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    option_map om = new option_map();
    mark_t m = new mark_t();
    acc_cond ac = new acc_cond();
    more_acc_cond.squeezed_in.more_mark_t mm = new more_acc_cond.squeezed_in.more_mark_t();

    SWIGTYPE_p_std__ostream cout = friends_nested.std_cout_reference();
    friends_nested.std_cout_badbit(); // uncomment this to see std::cout
    friends_nested.operatorshift(cout, om);
    m.operatorshift(0);
    friends_nested.operatorshift(cout, m);
    friends_nested.operatorshift(cout, ac);
    friends_nested.operatorshift(cout, mm);


    // Test nested templates and classes
    OuterClass oc = new OuterClass();
    OuterClass.InnerDouble inner_double = new OuterClass.InnerDouble(1.1);
    OuterClass.InnerInt inner_int = new OuterClass.InnerInt(2);
    OuterClass.InnerShort inner_short = new OuterClass.InnerShort((short)3);

    friends_nested.friendly(inner_double);
    friends_nested.friendly(inner_int);
    friends_nested.friendly(inner_short);

    OuterClass.InnerDouble.InnerInnerStruct iis_double = new OuterClass.InnerDouble.InnerInnerStruct(11.1);
    OuterClass.InnerInt.InnerInnerStruct iis_int = new OuterClass.InnerInt.InnerInnerStruct(22);
    OuterClass.InnerShort.InnerInnerStruct iis_short = new OuterClass.InnerShort.InnerInnerStruct((short)33);

    friends_nested.friendly_inner_qualified(iis_double);
    friends_nested.friendly_inner_qualified(iis_int);
    friends_nested.friendly_inner_qualified(iis_short);

    OuterClass.InnerDouble.InnerInnerBool iit_bool = new OuterClass.InnerDouble.InnerInnerBool(111.1, true);
    OuterClass.InnerInt.InnerInnerChar iit_char = new OuterClass.InnerInt.InnerInnerChar(222, 'x');
    OuterClass.InnerShort.InnerInnerString iit_string = new OuterClass.InnerShort.InnerInnerString((short)333, "hi");

    friends_nested.friendly_inner_x(iit_bool);
    friends_nested.friendly_inner_x(iit_char);
    friends_nested.friendly_inner_x(iit_string);

    OuterClass.InnerDouble.InnerInnerBool.VeryInner vi_iit_bool = new OuterClass.InnerDouble.InnerInnerBool.VeryInner(111.1, true);
    OuterClass.InnerInt.InnerInnerChar.VeryInner vi_iit_char = new OuterClass.InnerInt.InnerInnerChar.VeryInner(222, 'x');
    OuterClass.InnerShort.InnerInnerString.VeryInner vi_iit_string = new OuterClass.InnerShort.InnerInnerString.VeryInner((short)333, "hi");

    friends_nested.very_inner(vi_iit_bool);
    friends_nested.very_inner(vi_iit_char);
    friends_nested.very_inner(vi_iit_string);
  }
}

