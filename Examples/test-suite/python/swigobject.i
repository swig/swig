%module swigobject



%inline
{
  struct A {
    char name[4];
  };

  const char* pointer_str(A *a){
    static char result[1024];
    sprintf(result,"0x%lx", (unsigned long)(void *)a);
    return result;
  }

  A *a_ptr(A *a){
    return a;
  }


  void *v_ptr(void *a){
    return a;
  }
}
