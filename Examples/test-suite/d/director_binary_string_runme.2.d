module director_binary_string_runme;

import director_binary_string.Callback;
import director_binary_string.Caller;
import std.string;
import std.conv : text;
import std.exception : enforce;

void main() {
  auto caller = new Caller();
  Callback callback = new DirectorBinaryStringCallback();
  caller.setCallback(callback);
  int sum = caller.call();
  int sumData = caller.callWriteData();
  caller.delCallback();

  enforce(sum == 9*2*8 + 13*3*5, text("Unexpected sum: ", sum));
  enforce(sumData == 9*2*8, text("Unexpected sumData: ", sumData));

  new Callback().run(null, null);
  callback = new DirectorBinaryStringCallback();
  caller.setCallback(callback);
  caller.call_null();
  caller.delCallback();
}

class DirectorBinaryStringCallback : Callback {
public:
  this() {
    super();
  }
  override int run(string dataBufferAA, string dataBufferBB)
  {
    int ret = 0;
    char[] aa = dataBufferAA.dup;
    for (int i = 0; i < aa.length; i++)
      ret += aa[i] * 2;
    char[] bb = dataBufferBB.dup;
    for (int i = 0; i < bb.length; i++)
      ret += bb[i] * 3;
    return ret;
  }
  override int writeData(string dataBufferAA)
  {
    int ret = 0;
    char[] aa = dataBufferAA.dup;
    for (int i = 0; i < aa.length; i++)
      ret += aa[i] * 2;
    return ret;
  }
}
