%module apply_typemap_typedefs

%typemap(in) int "_this_will_not_compile_"
%typemap(in) int OK "$1 = 10;" // (A)
%typemap(in) Int1 OKAY "$1 = 20;" // (B)

%inline %{
typedef int Int1;
typedef Int1 Int2;
typedef Int2 Int3;
%}

%apply Int2 OK {Int2 i2} // applies (A) as 'Int2 OK' resolves to 'int OK'
%inline %{
int test10(Int2 i2) { return i2; }
%}

%apply Int3 OKAY {Int3 i3} // applies (B) as 'Int3 OKAY' resolves to 'Int1 OKAY'
%inline %{
int test20(Int3 i3) { return i3; }
%}

%typemap(in) int EXACT "_this_too_will_not_compile_"
%typemap(in) Int1 EXACT "_this_too_will_not_compile_"
%typemap(in) Int2 EXACT "_this_too_will_not_compile_"
%typemap(in) Int3 EXACT "$1 = 30;"
%apply Int3 EXACT {Int3 i3}

%inline %{
int test30(Int3 i3) { return i3; }
%}


%typemap(in) int CONFUSING "_this_too_will_not_compile_"
%typemap(in) int ii "$1 = 40;" // (D)
%typemap(in) Int1 CONFUSING "_this_too_will_not_compile_"
%typemap(in) Int2 CONFUSING "_this_too_will_not_compile_"
%typemap(check) Int3 CONFUSING "/*check typemap*/"
%apply Int3 CONFUSING {Int3 ii} // Only applies the (check) typemap above, the other CONFUSING typemaps are not applied as the repeated typedef lookups halts as soon as any typemap method matches

%inline %{
int test40(Int3 ii) { return ii; } // Uses (D) using normal typemap lookup rules as the %apply above does not provide an 'in' typemap method in the family of 'Int3 CONFUSING' typemaps
%}

