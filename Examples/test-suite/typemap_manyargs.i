%module typemap_manyargs

%typemap(in,numinputs=0) (double* a1, short* a2, int* a3, int* a4, int* a5, int* a6, int *a7, int *a8, int *a9, int *a10) ($*1_ltype temp1,$*2_ltype temp2,int temp3,int temp4,int $5_tmpvar,int temp6,int temp7,int temp8, int temp9, $*10_ltype temp10)
{
  $1 = &temp1;      // the code generated for this is arg2 = &temp1;
  $2 = &temp2;      // the code generated for this is arg3 = &temp2;
  $3 = &temp3;      // and so on...
  $4 = &temp4;
  $5 = &$5_tmpvar;
  $6 = &temp6;
  $7 = &temp7;
  $8 = &temp8;
  $9 = &temp9;
  $10 = &temp10;   // the code generated for this was arg20 = &temp10; and arg20 does not exist.
  int $10_ptr = 0; // Was arg20_ptr
  $*1_ltype ltype1 = *$1;
  $*10_ltype ltype10 = *$10;
  (void)$10_ptr;
  (void)ltype1;
  (void)ltype10;
}

// Test $1, $2 temp variable substitutions
%inline %{
void my_c_function(char * filename,double* a1, short* a2, int* a3, int* a4, int* a5, int* a6, int *a7, int *a8, int *a9, int *a10) {}
%}

%typemap(in, numinputs=0) (const char *s, double *d) ($1_type string_temp_$1 = "hello", $*2_ltype double_$2_temp = 0.0, int dummy_$1_$2 = 0)
{
  $1 = const_cast<char *>(string_temp_$1);
  $2 = &double_$2_temp;
  (void)dummy_$1_$2;
}
%typemap(freearg) (const char *s, double *d) ""

void my_funk(const char *s, double *d, int i, const char *s, double *d) {}
%{
void my_funk(const char *s1, double *d1, int i, const char *s2, double *d2) {}
%}
