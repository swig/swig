using System;
using li_std_tupleNamespace;

public class li_std_tuple_runme {

  public static void Main() {
    // Test make_int_double returns a valid IntDoubleTuple
    IntDoubleTuple t = li_std_tuple.make_int_double(10, 20.5);

    // Test sum_pair_values with a tuple from make_int_double
    IntDoubleTuple t2 = li_std_tuple.make_int_double(3, 4.5);
    double r = li_std_tuple.sum_pair_values(t2);
    if (r != 7.5)
      throw new Exception("sum_pair_values test failed: " + r);

    // Test pass_tuples with two IntDoubleTuples
    IntDoubleTuple t3 = li_std_tuple.make_int_double(1, 2.5);
    IntDoubleTuple t4 = li_std_tuple.make_int_double(10, 20.0);
    IntDoubleTuple t5 = li_std_tuple.pass_tuples(t3, t4);
  }
}
