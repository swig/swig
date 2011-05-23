using System;
using li_boost_shared_ptr_bitsNamespace;

public class runme
{
  static void Main() 
  {
    VectorIntHolder v = new VectorIntHolder();
    v.Add(new IntHolder(11));
    v.Add(new IntHolder(22));
    v.Add(new IntHolder(33));

    int sum = li_boost_shared_ptr_bits.sum(v);
    if (sum != 66)
      throw new ApplicationException("sum is wrong");

    HiddenDestructor hidden = HiddenDestructor.create();
    hidden.Dispose();
  }
}
