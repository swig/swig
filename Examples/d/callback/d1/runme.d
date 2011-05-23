module runme;

import tango.io.Stdout;
import example;

public class DCallback : Callback {
  public override void run() {
    Stdout( "DCallback.run()" ).newline;
  }
}

void main() {
  auto caller = new Caller();

  Stdout( "Adding and calling a normal C++ callback" ).newline;
  Stdout( "----------------------------------------" ).newline;
  {
    scope auto callback = new Callback();
    caller.setCallback(callback);
    caller.call();
    caller.resetCallback();
  }

  Stdout.newline;
  Stdout( "Adding and calling a D callback" ).newline;
  Stdout( "-------------------------------" ).newline;
  {
    scope auto callback = new DCallback();
    caller.setCallback(callback);
    caller.call();
    caller.resetCallback();
  }

  Stdout.newline;
  Stdout( "D exit" ).newline;
}
