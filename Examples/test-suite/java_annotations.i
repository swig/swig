%module(directors="1") java_annotations

%include "enums.swg"
%javaconst(1);

%typemap(javaimports) JavaAnnotationTest %{
import java.lang.annotation.*;
import java_annotations.JavaAnnotationTest.*;
%}

%pragma(java) moduleimports=%{
import java_annotations.JavaAnnotationTest.*;
%}

%typemap(javacode) JavaAnnotationTest %{
  @Retention(RetentionPolicy.RUNTIME)
  @Target(ElementType.METHOD)
  public @interface MethodAnnotation {}

  @Retention(RetentionPolicy.RUNTIME)
  @Target(ElementType.TYPE)
  public @interface TypeAnnotation {}

  @Retention(RetentionPolicy.RUNTIME)
  @Target(ElementType.CONSTRUCTOR)
  public @interface ConstructorAnnotation {}
%}

// Test the annotations feature
%javaannotations JavaAnnotationTest::JavaAnnotationTest "@ConstructorAnnotation"
%javaannotations JavaAnnotationTest::C::C "@ConstructorAnnotation"

%javaannotations JavaAnnotationTest::Method1() "@MethodAnnotation"
%javaannotations JavaAnnotationTest::Method2() "@MethodAnnotation"
%javaannotations JavaAnnotationTest::C::Method1() "@MethodAnnotation"
%javaannotations JavaAnnotationTest::C::Method2() "@MethodAnnotation"
%javaannotations Procedure() "@MethodAnnotation"

%typemap(javaannotations) JavaAnnotationTest "@TypeAnnotation"
%typemap(javaannotations) JavaAnnotationTest::E "@TypeAnnotation"
%typemap(javaannotations) JavaAnnotationTest::C "@TypeAnnotation"
%typemap(javaannotations) JavaAnnotationTest::C::E "@TypeAnnotation"

%inline %{
class JavaAnnotationTest {
public:
  JavaAnnotationTest() {}

  void Method1() {}
  static void Method2() {}

  enum E { F = 1 };

  class C {
   public:
    C() {}
    void Method1() {}
    static void Method2() {}

    enum E { F = 1 };
  };
};

void Procedure() {}
%}
