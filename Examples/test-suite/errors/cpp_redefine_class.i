%module xxx

namespace Space {
struct MyStruct {
  int b;
};
}

namespace Space {
struct MyStruct {
  int b;
};
}

namespace Space {
class MyClass {
public:
  int a;
};
}

class Space::MyClass {
public:
  int a;
};

namespace Space {
template<typename T>
class MyTemplateClass {
public:
  int a;
};
template<typename T>
class MyTemplateClass {
public:
  int a;
};
}
