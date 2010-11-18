module runme;

import std.stdio;
import example;

public class DCallback : Callback {
  public override void run() {
    writeln( "DCallback.run()" );
  }
}

void main() {
  auto caller = new Caller();

  writeln( "Adding and calling a normal C++ callback" );
  writeln( "----------------------------------------" );
  {
    scope auto callback = new Callback();
    caller.setCallback(callback);
    caller.call();
    caller.resetCallback();
  }

  writeln();
  writeln( "Adding and calling a D callback" );
  writeln( "-------------------------------" );
  {
    scope auto callback = new DCallback();
    caller.setCallback(callback);
    caller.call();
    caller.resetCallback();
  }

  writeln();
  writeln( "D exit" );
}
