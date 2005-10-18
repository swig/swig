%module class_scope_weird

%inline %{
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

class Quat;
class matrix4;
class tacka3;

class Quat {
public:
  Quat::Quat(void){}  
  Quat::Quat(float in_w, float x, float y, float z){}
  Quat::Quat(const tacka3& axis, float angle){}
  Quat::Quat(const matrix4& m){}
};
%}

