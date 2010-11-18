module threads_runme;

import tango.core.Thread;
import tango.io.Console;
import Integer = tango.text.convert.Integer;
import threads.Kerfuffle;

// Spawn 8 threads.
const uint NUM_THREADS = 8;

// Run test for a few seconds on a 1GHz machine.
const uint WORKER_LOOP_PASSES = 30000;

void main() {
  auto kerf = new Kerfuffle();
  TestThread[] threads;

  // Invoke the threads.
  for (uint i = 0; i < NUM_THREADS; i++) {
    auto thread = new TestThread(kerf);
    threads ~= thread;
    thread.name = Integer.toString(i);
    thread.start();
  }

  // Wait for the threads to finish.
  foreach(thread; threads) {
    thread.join();
  }

  // Check if any thread has failed.
  foreach(thread; threads) {
    if (thread.failed) throw new Exception("Test failed.");
  }
}

class TestThread : Thread {
public:
  this(Kerfuffle kerf) {
    super(&run);
    m_kerf = kerf;
  }

  void run() {
    failed = false;
    try {
      for (uint i = 0; i < WORKER_LOOP_PASSES; i++) {
	char[] given = "This is the test char[] that should come back. A number: " ~ Integer.toString(i);
	char[] received = m_kerf.StdString(given);
	if (received != given) {
	  throw new Exception("StdString char[] does not match. Received: '" ~ received ~ "'. Expected: '" ~ given ~ "'.");
	}
      }
      for (uint i = 0; i < WORKER_LOOP_PASSES; i++) {
	char[] given = "This is the test char[] that should come back. A number: " ~ Integer.toString(i);
	char[] received = m_kerf.CharString(given);
	if (received != given) {
	  throw new Exception("StdString char[] does not match. Received: '" ~ received ~ "'. Expected: '" ~ given ~ "'.");
	}
      }
    } catch (Exception e) {
      Cerr("Test failed (thread " ~ name() ~ "): " ~ e.msg).newline;
      failed = true;
    }
  }

  bool failed;
private:
  Kerfuffle m_kerf;
}
