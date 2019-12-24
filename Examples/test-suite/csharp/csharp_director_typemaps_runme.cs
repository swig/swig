
using System;
using System.Reflection;
using csharp_director_typemapsNamespace;

public class csharp_director_typemaps_runme {

  class CSharpDirectorTypemaps_InStreamDerived : InStream
  {
    private int constant;
    public CSharpDirectorTypemaps_InStreamDerived(int constant) { this.constant = constant; }
    public override int Read(global::System.IntPtr buf, int len, out int readLen) {
      readLen = (buf == global::System.IntPtr.Zero) ? -len - constant : len + constant;
      return readLen;
    }
    public override int Write(global::System.IntPtr buf, int len, out int writeLen) {
      writeLen = (buf == global::System.IntPtr.Zero) ? -len - constant : len + constant;
      return writeLen;
    }
  }
  public static void Main() {
    int outLen = -1;
    int k = 100;
    int j = 23;
    InStream instream = new CSharpDirectorTypemaps_InStreamDerived(k);

    {
      int ret = csharp_director_typemaps.callRead(instream, InStream.getCPtr(instream).Handle, j, out outLen);
      Assert(outLen, j + k);
      Assert(ret, j + k);
    }
    {
      int ret = csharp_director_typemaps.callRead(instream, global::System.IntPtr.Zero, j, out outLen);
      Assert(outLen, -j - k);
      Assert(ret, -j - k);
    }

    {
      int ret = csharp_director_typemaps.callWrite(instream, InStream.getCPtr(instream).Handle, j, out outLen);
      Assert(outLen, j + k);
      Assert(ret, j + k);
    }
    {
      int ret = csharp_director_typemaps.callWrite(instream, global::System.IntPtr.Zero, j, out outLen);
      Assert(outLen, -j - k);
      Assert(ret, -j - k);
    }
  }
  private static void Assert(int i1, int i2) {
    if (i1 != i2)
      throw new Exception("assertion failure. " + i1 + " != " + i2);
  }
}
