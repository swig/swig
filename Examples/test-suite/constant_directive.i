%module constant_directive

// %constant and struct
%{
  struct Type1 {
    Type1(int val = 0) : val(val) {} 
    int val;
  };
  static Type1 TYPE1_CONSTANT1(1);
  static Type1 TYPE1_CONST2(2);
  static Type1 TYPE1_CONST3(3);
%}

struct Type1 {
  Type1(int val = 0) : val(val) {} 
  int val;
};

%inline %{
Type1 getType1Instance() { return Type1(111); }
%}

%constant Type1 TYPE1_CONSTANT1;
%constant Type1 TYPE1_CONSTANT2 = TYPE1_CONST2;
%constant Type1 *TYPE1_CONSTANT3 = &TYPE1_CONST3;

%constant int TYPE_INT = 0;

