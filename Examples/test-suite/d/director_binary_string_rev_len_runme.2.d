module director_binary_string_rev_len_runme;

import director_binary_string_rev_len.Callback;
import director_binary_string_rev_len.Caller;
import std.string;
import std.conv : text;
import std.exception : enforce;

void main() {
  Callback callback = new DirectorBinaryStringCallback();
  auto caller = new Caller(callback);
  int sum = caller.call();

  enforce(sum == 9*2*8, text("Unexpected sum: ", sum));
}

class DirectorBinaryStringCallback : Callback {
public:
  this() {
    super();
  }
  override int run(string dataBufferAA)
  {
    int ret = 0;
    char[] aa = dataBufferAA.dup;
    for (int i = 0; i < aa.length; i++)
      ret += aa[i] * 2;
    return ret;
  }
}
