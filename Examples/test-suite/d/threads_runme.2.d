module threads_runme;

import core.thread;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import threads.Kerfuffle;

// Spawn 8 threads.
enum THREADS = iota(0, 9);

// Run test for a few seconds on a 1GHz machine.
enum WORK_RANGE = iota(0, 30000);

void main() {
  auto kerf = new Kerfuffle();
  TestThread[] threads;

  // Invoke the threads.
  foreach (i; THREADS) {
    auto thread = new TestThread(kerf);
    threads ~= thread;
    thread.name = to!string(i);
    thread.start();
  }

  // Wait for the threads to finish.
  foreach (i, thread; threads) {
    thread.join(true);
  }
}

class TestThread : Thread {
  this(Kerfuffle kerf) {
    super(&run);
    m_kerf = kerf;
  }

  void run() {
    foreach (i; WORK_RANGE) {
    	string given = "This is the test string that should come back. A number: " ~ to!string(i);
    	string received = m_kerf.StdString(given);
    	enforce(received == given, "StdString string does not match. Received: '" ~ received ~ "'. Expected: '" ~ given ~ "'.");
    }
    foreach (i; WORK_RANGE) {
    	string given = "This is the test string that should come back. A number: " ~ to!string(i);
    	string received = m_kerf.CharString(given);
    	enforce(received == given, "CharString string does not match. Received: '" ~ received ~ "'. Expected: '" ~ given ~ "'.");
    }
  }

private:
  Kerfuffle m_kerf;
}
