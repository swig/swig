%module class_scope_weird

%inline {
#if !defined(SWIG_NOEXTRA_QUALIFICATION)
class Foo {
public:
  Foo::Foo(void)
  {
  }

  Foo::Foo(int)
  {
  }
  
  int Foo::bar(int x) {
    return x;
  }
};
#else
class Foo {
public:
  Foo(void)
  {
  }

  Foo(int)
  {
  }
  
  int bar(int x) {
    return x;
  }
};
#endif

class Quat;
class matrix4;
class tacka3;

#if !defined(SWIG_NOEXTRA_QUALIFICATION)
class Quat {
public:
  Quat::Quat(void){}  
  Quat::Quat(float in_w, float x, float y, float z){}
  Quat::Quat(const tacka3& axis, float angle){}
  Quat::Quat(const matrix4& m){}
};
#else
class Quat {
public:
  Quat(void){}  
  Quat(float in_w, float x, float y, float z){}
  Quat(const tacka3& axis, float angle){}
  Quat(const matrix4& m){}
};
#endif
}

