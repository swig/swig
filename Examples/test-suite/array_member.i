%module array_member

%inline %{

typedef struct Foo {
    char   text[8]; 
    int    data[8];
} Foo;

int global_data[8] = { 0,1,2,3,4,5,6,7 };

void set_value(int *x, int i, int v) {
    x[i] = v;
}

int get_value(int *x, int i) {
    return x[i];
}
%}






#ifdef __cplusplus
%inline 
{

  struct Material
  {
  };

  class RayPacketData {
  public:
    enum {
      Size = 32
    };
    
    const Material * chitMat[Size];
    Material hitMat_val[Size];
    Material *hitMat[Size];
  };
}

#endif
