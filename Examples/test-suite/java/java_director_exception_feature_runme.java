
import java_director_exception_feature.*;

class java_director_exception_feature_Consts {
    public static final String PINGEXCP1 = "Ping MyJavaException1";  // should get translated through an int on ping
    public static final String PINGEXCP2 = "Ping MyJavaException2";
    public static final String PONGEXCP1 = "Pong MyJavaException1";
    public static final String PONGEXCP2 = "Pong MyJavaException2";
    public static final String PONGUNEXPECTED = "Pong MyJavaUnexpected";
    public static final String TRANSLATED_NPE = "Pong Translated NPE";
}

class java_director_exception_feature_MyFooDirectorImpl extends Foo {

    public java_director_exception_feature_MyFooDirectorImpl() { };

    @Override
    public String ping(int excp) throws MyJavaException1, MyJavaException2 {
	if (excp == 1) throw new MyJavaException1(java_director_exception_feature_Consts.PINGEXCP1);
	if (excp == 2) throw new MyJavaException2(java_director_exception_feature_Consts.PINGEXCP2);
	return "Ping director returned";
    }
    @Override
    public String pong(int excp) throws MyJavaException1, MyJavaException2, MyJavaUnexpected {
	if (excp == 1) throw new MyJavaException1(java_director_exception_feature_Consts.PONGEXCP1);
	if (excp == 2) throw new MyJavaException2(java_director_exception_feature_Consts.PONGEXCP2);
	if (excp == 3) throw new MyJavaUnexpected(java_director_exception_feature_Consts.PONGUNEXPECTED);
	if (excp == 4) throw new java.lang.NullPointerException(java_director_exception_feature_Consts.TRANSLATED_NPE);  // should be translated to ::Unexpected
	return "Pong director returned";
    }
}

public class java_director_exception_feature_runme {

  static {
    try {
      System.loadLibrary("java_director_exception_feature");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void fail(String msg) {
    System.err.println(msg); System.exit(1);
  }
  public static void failif(boolean cond, String msg) {
    if (cond) fail(msg);
  }


  public static void main(String argv[]) {

      Bar b = new Bar(new java_director_exception_feature_MyFooDirectorImpl());
      try {

	  try {  b.ping(0); } catch (Exception e) 
	      { fail("Exception should not have been thrown: " + e + " from ping(0)");  }
	  try {  b.ping(1); fail("No exception thrown in ping(1)"); } catch (MyJavaException1 e) 
              // Should say "Threw some integer", see java_director_exception_feature.i  Foo::ping throws a "1"
	      { failif( ! "Threw some integer".equals(e.getMessage()), "Ping exception not translated through int: '" + e.getMessage() + "'"); }
	  try {  b.ping(2); fail("No exception thrown in ping(2)"); } catch (MyJavaException2 e) 
	      { failif( ! java_director_exception_feature_Consts.PINGEXCP2.equals(e.getMessage()), "Expected exception has unexpected message: '" + e.getMessage() + "'"); }

	  try {  b.pong(0); } catch (Exception e) 
	      { fail("Exception should not have been thrown: " + e + " from pong(0)");  }
	  try {  b.pong(1); fail("No exception thrown in pong(1)"); } catch (MyJavaException1 e) 
	      { failif( ! java_director_exception_feature_Consts.PONGEXCP1.equals(e.getMessage()), "Expected exception has unexpected message: '" + e.getMessage() + "'"); }
	  try {  b.pong(2); fail("No exception thrown in pong(2)");} catch (MyJavaException2 e) 
	      { failif( ! java_director_exception_feature_Consts.PONGEXCP2.equals(e.getMessage()),  "Expected exception has unexpected message: '" + e.getMessage() + "'"); }
	  try {  b.pong(3); fail("No exception thrown in pong(3)");} catch (MyJavaUnexpected e) 
	      { failif( ! java_director_exception_feature_Consts.PONGUNEXPECTED.equals(e.getMessage()),  "Expected exception has unexpected message: '" + e.getMessage() + "'"); }
	  try {  b.pong(4); fail("No exception thrown in pong(4)"); } catch (MyJavaUnexpected e) 
	      { failif( ! java_director_exception_feature_Consts.TRANSLATED_NPE.equals(e.getMessage()),  "Expected exception has unexpected message: '" + e.getMessage() + "'"); }

      }
      catch (Exception e) {
	e.printStackTrace();
	fail("Unexpected exception thrown or exception not mapped properly");
      }

  }
}

