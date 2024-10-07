using System;
using director_rev_len_strNamespace;

public class director_rev_len_str_runme
{
    static void Main()
    {
      Caller caller = new Caller(new DirectorReverseLengthStringCallback());
      int sum = caller.call();

      if (sum != 9*2*8)
        throw new Exception("Unexpected sum: " + sum);
    }
}

public class DirectorReverseLengthStringCallback : Callback {
    public DirectorReverseLengthStringCallback() : base() {}

    public override int run(string dataBufferAA)
    {
      int ret = 0;
      if (dataBufferAA != null) {
        for (int i = 0; i < dataBufferAA.Length; i++)
          ret += (int)dataBufferAA[i] * 2;
      }
      return ret;
    }
}
