
%module arrays_dimensionless

%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) globalints;    /* Unable to set variable of type int [] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) ints;          /* Unable to set variable of type int [] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) globalints_ref;      /* Unable to set variable of type int (&)[] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) globalchars_ref;     /* Unable to set variable of type char (&)[] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) BarRef::ints_ref;    /* Unable to set variable of type int (&)[] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) BarRef::chars_ref;   /* Unable to set variable of type char (&)[] */

#ifdef SWIGC
// TODO: references to arrays do not compile in the C target language
%ignore globalints_ref;
%ignore globalchars_ref;
%ignore BarRef;
#endif

// An [ANY] typemap can use the array size, so is not used for an array of unknown size, such as arr_int's 'int array[]'
%typemap(check) int [ANY] "(void)$1_dim0;"

%inline %{

int globalints[] = {100, 200, 300};
const int constglobalints[] = {400, 500, 600};

struct Bar {
    static int ints[];
};
int Bar::ints[] = {700, 800, 900};
%}

%{
char globalchars[] = "abc";
%}

%inline %{
// A variable that is a reference to an array of unknown size is read only, as is an array of unknown size
int (&globalints_ref)[] = *reinterpret_cast<int (*)[]>(globalints);
char (&globalchars_ref)[] = *reinterpret_cast<char (*)[]>(globalchars);

struct BarRef {
    int (&ints_ref)[];
    char (&chars_ref)[];
    BarRef() : ints_ref(globalints_ref), chars_ref(globalchars_ref) {}
};

double arr_bool(bool array[], int length)                { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]=!array[i]; } return sum; }
double arr_char(char array[], int length)                { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_schar(signed char array[], int length)        { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_uchar(unsigned char array[], int length)      { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_short(short array[], int length)              { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_ushort(unsigned short array[], int length)    { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_int(int array[], int length)                  { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_uint(unsigned int array[], int length)        { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_long(long array[], int length)                { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_ulong(unsigned long array[], int length)      { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_ll(long long array[], int length)             { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_ull(unsigned long long array[], int length)   { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_float(float array[], int length)              { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }
double arr_double(double array[], int length)            { double sum=0.0; int i=0; for(; i<length; i++) { sum += array[i]; array[i]*=2; } return sum; }

int arr_int_isnull(int array[])                          { return array == 0; }
int arr_double_isnull(double array[])                    { return array == 0; }
enum arr_enum { arr_enum1, arr_enum2 };
int arr_enum_isnull(enum arr_enum array[2])              { return array == 0; }
int arr_enum_second(enum arr_enum array[2])              { return array[1]; }
int arr_x_isnull(double *x, int len)                     { return x == 0 && len == 0; }

%}

%apply SWIGTYPE[] {
 bool *, 
 char *, 
 signed char *, 
 unsigned char *, 
 short *, 
 unsigned short *, 
 int *, 
 unsigned int *, 
 long *, 
 unsigned long *, 
 long *, 
 unsigned long long *, 
 float *, 
 double *
}

%inline %{

double ptr_bool(bool *array, int length)                { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_char(char *array, int length)                { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_schar(signed char *array, int length)        { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_uchar(unsigned char *array, int length)      { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_short(short *array, int length)              { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_ushort(unsigned short *array, int length)    { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_int(int *array, int length)                  { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_uint(unsigned int *array, int length)        { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_long(long *array, int length)                { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_ulong(unsigned long *array, int length)      { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_ll(long long *array, int length)             { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_ull(unsigned long long *array, int length)   { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_float(float *array, int length)              { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }
double ptr_double(double *array, int length)            { double sum=0.0; int i=0; for(; i<length; i++) sum += array[i]; return sum; }

%}

