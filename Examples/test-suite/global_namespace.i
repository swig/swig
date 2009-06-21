%module global_namespace

// classes
%inline %{
class Klass1 {};
class Klass2 {};
class Klass3 {};
class Klass4 {};
class Klass5 {};
class Klass6 {};
class Klass7 {};

struct KlassMethods {
   static void methodA(::Klass1 v, const ::Klass2 cv, const ::Klass3 *cp, ::Klass4 *p, const ::Klass5 &cr, ::Klass6 &r, Klass7*& pr) {}
   static void methodB(  Klass1 v, const   Klass2 cv, const   Klass3 *cp,   Klass4 *p, const   Klass5 &cr,   Klass6 &r, Klass7*& pr) {}
};
%}

%inline %{
namespace Space {
class XYZ1 {};
class XYZ2 {};
class XYZ3 {};
class XYZ4 {};
class XYZ5 {};
class XYZ6 {};
class XYZ7 {};
}

struct XYZMethods {
   static void methodA(::Space::XYZ1 v, const ::Space::XYZ2 cv, const ::Space::XYZ3 *cp, ::Space::XYZ4 *p, const ::Space::XYZ5 &cr, ::Space::XYZ6 &r, Space::XYZ7*& pr) {}
   static void methodB(  Space::XYZ1 v, const   Space::XYZ2 cv, const   Space::XYZ3 *cp,   Space::XYZ4 *p, const   Space::XYZ5 &cr,   Space::XYZ6 &r, Space::XYZ7*& pr) {}
};
%}

//enums
%inline %{
enum AnEnum1 { anenum1 };
enum AnEnum2 { anenum2 };
enum AnEnum3 { anenum3 };

struct AnEnumMethods {
   static void methodA(::AnEnum1 v, const ::AnEnum2 cv, const ::AnEnum3 &cr) {}
   static void methodB(  AnEnum1 v, const   AnEnum2 cv, const   AnEnum3 &cr) {}
};
%}

%inline %{
namespace Space {
enum TheEnum1 { theenum1 };
enum TheEnum2 { theenum2 };
enum TheEnum3 { theenum3 };

struct TheEnumMethods {
   static void methodA(::Space::TheEnum1 v, const ::Space::TheEnum2 cv, const ::Space::TheEnum3 &cr) {}
   static void methodB(  Space::TheEnum1 v, const   Space::TheEnum2 cv, const   Space::TheEnum3 &cr) {}
};
}
%}

