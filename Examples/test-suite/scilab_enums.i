%module scilab_enums

%scilabconst(1);

%inline %{

enum ENUM {
  ENUM_1,
  ENUM_2
};

enum ENUM_EXPLICIT_1 {
  ENUM_EXPLICIT_1_1 = 5,
  ENUM_EXPLICIT_1_2
};

enum ENUM_EXPLICIT_2 {
  ENUM_EXPLICIT_2_1,
  ENUM_EXPLICIT_2_2 = 10
};

enum ENUM_EXPLICIT_3 {
  ENUM_EXPLICIT_3_1 = 2,
  ENUM_EXPLICIT_3_2 = 5,
  ENUM_EXPLICIT_3_3 = 8
};

typedef enum {
  TYPEDEF_ENUM_1_1 = 21,
  TYPEDEF_ENUM_1_2 = 22
} TYPEDEF_ENUM_1;

typedef enum TYPEDEF_ENUM_2 {
  TYPEDEF_ENUM_2_1 = 31,
  TYPEDEF_ENUM_2_2 = 32
} TYPEDEF_ENUM_2;

%}
