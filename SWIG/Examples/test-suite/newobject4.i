%module newobject4

%nodefault Foo;

%newobject makeFoo();

#ifdef SWIGRUBY
%freefunc Foo "free_Foo";
#endif

/**
 * These declarations aren't wrapped
 */

%{
int g_fooCount = 0;

typedef struct {
} Foo;
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
