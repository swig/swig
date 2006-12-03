// Mainly tests that directors are finalized correctly

import java_director.*;

public class java_director_runme {

  static {
    try {
      System.loadLibrary("java_director");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    QuuxContainer qc = createContainer();

    int instances = Quux.instances();
    if (instances != 4)
      throw new RuntimeException("Quux instances should be 4, actually " + instances);

    for (int i = 0; i < qc.size(); ++i) {
      Quux q = qc.get(i);

      if (!q.director_method().equals(qc.invoke(i))) {
        throw new RuntimeException ( "q.director_method()/qv.invoke(" + i + ")");
      }
    }

    qc = null;
    /* Watch qc get reaped, which causes the C++ object to delete
       objects from the internal vector */
    System.gc();
    System.runFinalization();

    /* Watch the Quux objects formerly in the QuuxContainer object
       get reaped */
    System.gc();
    System.runFinalization();

    instances = Quux.instances();
    if (instances != 0)
      throw new RuntimeException("Quux instances should be 0, actually " + instances);

    /* Test Quux1's director disconnect method rename */
    Quux1 quux1 = new Quux1("quux1");
    if (quux1.disconnectMethodCalled)
      throw new RuntimeException("Oops");
    quux1.delete();
    if (!quux1.disconnectMethodCalled)
      throw new RuntimeException("disconnect method not called");
  }

  public static QuuxContainer createContainer() {
    QuuxContainer qc = new QuuxContainer();

    qc.push(new Quux("element 1"));
    qc.push(new java_director_MyQuux("element 2"));
    qc.push(new java_director_MyQuux("element 3"));
    qc.push(new Quux("element 4"));

    return qc;
  }
}

class java_director_MyQuux extends Quux {
  public java_director_MyQuux(String arg) {
    super(arg);
  }

  public String director_method() {
    return "java_director_MyQuux:" + member();
  }
}
