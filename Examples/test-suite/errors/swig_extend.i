%module xxx

typedef struct {
  int myint;
} StructA;

typedef struct StructBName {
  int myint;
} StructB;

typedef struct StructC {
  int myint;
} StructC;

%extend StructA {
  void method() {}
}

%extend StructB {
  void method() {}
}

%extend StructC {
  void method() {}
}

struct StructD {
  int myint;
};
typedef struct StructD StructDName;

%extend StructDName {
  void method() {}
}

