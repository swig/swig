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

class quat;
class matrix4;
class tacka3;

class quat {
public:
  quat::quat(void){}  
  quat::quat(float in_w, float x, float y, float z){}
  quat::quat(const tacka3& axis, float angle){}
  quat::quat(const matrix4& m){}
};
%}

