%module newobject2

%nodefault Foo;

%newobject makeFoo();

#ifdef SWIGRUBY
%freefunc Foo "free_Foo";
#endif

%{
/* Global initialization (not wrapped) */
int g_fooCount = 0;
%}

#ifdef SWIGRUBY
%{
void free_Foo(void *p) {
    free(p);
    g_fooCount--;
}
%}
#endif

%inline %{
typedef struct {
} Foo;

/* Factory function */
Foo *makeFoo() {
    Foo *foo = (Foo *) malloc(sizeof(Foo));
    g_fooCount++;
    return foo;
}

/* Return the number of instances */
int fooCount() {
    return g_fooCount;
}
%}
