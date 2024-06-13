using System;
using director_binary_stringNamespace;

public class director_binary_string_runme
{
    static void Main()
    {
      Caller caller = new Caller();
      Callback callback = new DirectorBinaryStringCallback();
      caller.setCallback(callback);
      int sum = caller.call();
      int sumData = caller.callWriteData();
      caller.delCallback();

      if (sum != 9*2*8 + 13*3*5)
        throw new Exception("Unexpected sum: " + sum);

      if (sumData != 9*2*8)
        throw new Exception("Unexpected sumData: " + sumData);

      new Callback().run(null, null);
      callback = new DirectorBinaryStringCallback();
      caller.setCallback(callback);
      caller.call_null();
    }
}

public class DirectorBinaryStringCallback : Callback {
    public DirectorBinaryStringCallback() : base() {}

    public override int run(string dataBufferAA, string dataBufferBB)
    {
      int ret = 0;
      if (dataBufferAA != null) {
        for (int i = 0; i < dataBufferAA.Length; i++)
          ret += (int)dataBufferAA[i] * 2;
      }

      if (dataBufferBB != null) {
        for (int i = 0; i < dataBufferBB.Length; i++) {
          ret += (int)dataBufferBB[i] * 3;
        }
      }
      return ret;
    }

    public override int writeData(string dataBufferAA)
    {
      int ret = 0;
      if (dataBufferAA != null) {
        for (int i = 0; i < dataBufferAA.Length; i++)
          ret += (int)dataBufferAA[i] * 2;
      }
      return ret;
    }
}
