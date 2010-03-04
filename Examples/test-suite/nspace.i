// Test the nspace feature
%module nspace

#if defined(SWIGJAVA)
SWIG_JAVABODY_METHODS(public, public, SWIGTYPE) 
%pragma(java) jniclassclassmodifiers = "public class"

%feature("nspace");
%feature("nspace", "0") Outer::Inner2::NoNSpacePlease;

%copyctor;
%ignore Outer::Inner2::Color::Color();

%inline %{

namespace Outer {
  class nspace {
  };
  namespace Inner1 {
    enum Channel {
      Diffuse,
      Specular = 0x10,
      Transmission1
    };

    struct Color {
      static Color* create() { return new Color(); }

      enum Channel {
        Diffuse,
        Specular = 0x20,
        Transmission
      };	

      int instanceMemberVariable;
      static int staticMemberVariable;
      void colorInstanceMethod(double d) {}
      static void colorStaticMethod(double d) {}
    }; // Color 
    int Color::staticMemberVariable = 0;

    Color namespaceFunction(Color k) { return k; }
    int namespaceVar = 0;
  } // Inner1 

  namespace Inner2 {
    enum Channel {
      Diffuse,
      Specular /* = 0x30*/,
      Transmission2
    };

    struct Color {
      Color() : instanceMemberVariable(0) {}
      static Color* create() { return new Color(); }

      enum Channel {
        Diffuse,
        Specular/* = 0x40*/,
        Transmission
      };	

      int instanceMemberVariable;
      static int staticMemberVariable;
      void colorInstanceMethod(double d) {}
      static void colorStaticMethod(double d) {}
    }; // Color 
    int Color::staticMemberVariable = 0;
    class NoNSpacePlease {};
  } // Inner2

  class SomeClass {	
  public:				
    Inner1::Color::Channel GetInner1ColorChannel() { return Inner1::Color::Transmission; }
    Inner2::Color::Channel GetInner2ColorChannel() { return Inner2::Color::Transmission; }
    Inner1::Channel GetInner1Channel() { return Inner1::Transmission1; }
    Inner2::Channel GetInner2Channel() { return Inner2::Transmission2; }
  }; // SomeClass

} // Outer

namespace Outer {
  struct MyWorldPart2 {};
}

struct GlobalClass {
  void gmethod() {}
};

void test_classes(Outer::SomeClass c, Outer::Inner2::Color cc) {}
%}

#endif
