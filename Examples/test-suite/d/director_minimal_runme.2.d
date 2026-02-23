module director_minimal_runme;

import std.exception;
import director_minimal.Minimal;

class MyMinimal : Minimal {
public:
  override bool run() const {
    return false;
  }
}
void main() {
  auto c = new MyMinimal();
  enforce(!c.get(), "Should return true");
}
