%module fragments


%fragment("Hello","header") %{
/* hello!!! */
int foobar(int a)
{
  return a;
}  
%}

/*
 this fragment include the previous fragment if needed.
*/

%fragment("Hi","header",fragment="Hello") %{
/* hi!!! */
int bar(int a)
{
  return foobar(a);
}  
%}

%typemap(in,fragment="Hi") int hola "$1 = 123;"


%inline %{

int bar(int a);

int foo(int hola) 
{
  return bar(hola);
}

%}

/* Instantiate multiple fragments at once using fragments in comma separated list */
typedef int comma_frag3;

%fragment("comma_frag1","header", noblock=1) {
typedef int comma_frag1;
}

%fragment("comma_frag2","header", noblock=1, noblock=1) {
typedef comma_frag1 comma_frag2;
}

%fragment("comma_frag3","header",
          fragment="comma_frag1,comma_frag2")
%{typedef comma_frag2 comma_frag3;%}

%fragment("comma_frag3");
%inline %{
comma_frag3 my_comma_frag_int = 0;
%}


/* Instantiate multiple fragments at once using multiple keywords */
typedef int explicit_frag3;

%fragment("explicit_frag1","header", noblock=1) {
typedef int explicit_frag1;
}

%fragment("explicit_frag2","header", noblock=1) {
typedef explicit_frag1 explicit_frag2;
}

%fragment("explicit_frag3","header",
          fragment="explicit_frag1", fragment="explicit_frag2")
%{typedef explicit_frag2 explicit_frag3;%}

%fragment("explicit_frag3");
%inline %{
explicit_frag3 my_int = 0;
%}

/* Test typemap's ability to instantiate multiple fragments on demand */
typedef int int_infrag1;
typedef int int_infrag2;
typedef int int_outfrag1;
typedef int int_outfrag2;
typedef int int_outfrag3;

%fragment("infrag2","runtime") %{
typedef int_infrag1 int_infrag2;
%}

%fragment("infrag1","runtime") %{
typedef int int_infrag1;
%}
%fragment("infrag2","runtime") %{
__second_infrag2_fragment_is_ignored_this_will_not_compile_if_emitted_
typedef int_infrag1 int_infrag2;
%}

%fragment("outfrag1","runtime") %{
typedef int int_outfrag1;
%}
%fragment("outfrag2","runtime") %{
typedef int_outfrag1 int_outfrag2;
%}

%fragment("tcfrag1","runtime") %{
typedef int int_tcfrag1;
%}
%fragment("tcfrag2","runtime") %{
typedef int_tcfrag1 int_tcfrag2;
%}

%fragment("outspecial"{bool},"runtime") %{
typedef int int_outfrag3_temp;
%}
%fragment("outfrag3","runtime") %{
typedef int_outfrag3_temp int_outfrag3;
%}

%typemap(in, fragment="infrag1", fragment="infrag2") int_infrag2
%{$typemap(in,int)%}

%typemap(check, fragment="tcfrag1", noblock=1, fragment="tcfrag2") int_infrag2
{(void)sizeof(int_tcfrag2);}

%typemap(out, fragment="outfrag1", fragment="outfrag2", noblock=1) int_outfrag2
{$typemap(out,int)}

/* Test another permutation of keyword order */
%typemap(out, noblock=1, fragment="outfrag1", fragment="outfrag2") int_outfrag1
{$typemap(out,int)}

/* Test fragment specialization */
%typemap(out, noblock=1, fragment="outspecial"{bool}, fragment="outfrag3") int_outfrag3
{$typemap(out,int)}

%inline %{
int identity_in(int_infrag2 inp) { return inp; }
int_outfrag2 identity_out(int inp) { return inp; }
int_outfrag3 identity_out_2(int inp) { return inp; }
%}
