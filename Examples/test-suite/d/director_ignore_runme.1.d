module director_ignore_runme;

import director_ignore.DIgnores;
import director_ignore.DAbstractIgnores;

void main() {
  // Just check the classes can be instantiated and other methods work as expected
  auto a = new DIgnoresDerived();
  if (a.Triple(5) != 15)
    throw new Exception("Triple failed");

  auto b = new DAbstractIgnoresDerived();
  if (b.Quadruple(5) != 20)
    throw new Exception("Quadruple failed");
}

class DIgnoresDerived : DIgnores {
public:
  // These will give a warning if the %ignore is not working
  int OverloadedMethod(int n, int xoffset, int yoffset) { return 0; }
  int OverloadedMethod(int n, int xoffset) { return 0; }
  int OverloadedMethod(int n) { return 0; }

  int OverloadedProtectedMethod(int n, int xoffset, int yoffset) { return 0; }
  int OverloadedProtectedMethod(int n, int xoffset) { return 0; }
  int OverloadedProtectedMethod(int n) { return 0; }
}

class DAbstractIgnoresDerived : DAbstractIgnores {
public:
  // These will give a warning if the %ignore is not working
  int OverloadedMethod(int n, int xoffset, int yoffset) { return 0; }
  int OverloadedMethod(int n, int xoffset) { return 0; }
  int OverloadedMethod(int n) { return 0; }

  int OverloadedProtectedMethod(int n, int xoffset, int yoffset) { return 0; }
  int OverloadedProtectedMethod(int n, int xoffset) { return 0; }
  int OverloadedProtectedMethod(int n) { return 0; }
}
