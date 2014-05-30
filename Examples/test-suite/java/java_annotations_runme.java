import java_annotations.*;

import java.lang.annotation.*;
import java.lang.reflect.*;

public class java_annotations_runme {
  static {
    try {
        System.loadLibrary("java_annotations");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void checkAnnotation(AnnotatedElement e, Class<? extends Annotation> a) throws Exception {
    for (Annotation b : e.getDeclaredAnnotations()) {
      if (a.isInstance(b)) {
        return;
      }
    }

    throw new Exception();
  }

  private static void checkConstructorAnnotation(Constructor c) throws Exception {
    checkAnnotation(c, JavaAnnotationTest.ConstructorAnnotation.class);
  }

  private static void checkMethodAnnotation(Method m) throws Exception {
    checkAnnotation(m, JavaAnnotationTest.MethodAnnotation.class);
  }

  private static void checkTypeAnnotation(Class c) throws Exception {
    checkAnnotation(c, JavaAnnotationTest.TypeAnnotation.class);
  }

  public static void main(String argv[]) {
    String reason = "no reason";

    Class[] empty = (Class[]) null;
    try {
      //
      // annotations feature
      //
      // Constructors
      reason = "JavaAnnotationTest::JavaAnnotationTest annotation failed";
      checkConstructorAnnotation(JavaAnnotationTest.class.getDeclaredConstructor(empty));

      reason = "JavaAnnotationTest::C::C annotation failed";
      checkConstructorAnnotation(JavaAnnotationTest.C.class.getDeclaredConstructor(empty));

      // Methods
      reason = "JavaAnnotationTest::Method1() annotation failed";
      checkMethodAnnotation(JavaAnnotationTest.class.getDeclaredMethod("Method1", empty));

      reason = "JavaAnnotationTest::Method2() annotation failed";
      checkMethodAnnotation(JavaAnnotationTest.class.getDeclaredMethod("Method2", empty));

      reason = "JavaAnnotationTest::C::Method1() annotation failed";
      checkMethodAnnotation(JavaAnnotationTest.C.class.getDeclaredMethod("Method1", empty));

      reason = "JavaAnnotationTest::C::Method2() annotation failed";
      checkMethodAnnotation(JavaAnnotationTest.C.class.getDeclaredMethod("Method2", empty));

      reason = "Procedure() annotation failed";
      checkMethodAnnotation(java_annotations.class.getDeclaredMethod("Procedure", empty));

      // Types
      reason = "JavaAnnotationTest annotation failed";
      checkTypeAnnotation(JavaAnnotationTest.class);

      reason = "JavaAnnotationTest::C annotation failed";
      checkTypeAnnotation(JavaAnnotationTest.C.class);

      reason = "JavaAnnotationTest::E annotation failed";
      checkTypeAnnotation(JavaAnnotationTest.E.class);

      reason = "JavaAnnotationTest::E::E annotation failed";
      checkTypeAnnotation(JavaAnnotationTest.C.E.class);
    } catch(Exception e) {
      throw new RuntimeException(reason);
    }
  }
}