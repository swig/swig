/* -----------------------------------------------------------------------------
 * cpointer.i
 *
 * Author(s):  David Beazley (beazley@cs.uchicago.edu)
 *
 * This library file contains macros that can be used to manipulate simple
 * pointer objects.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * %pointer_class(type,name)
 *
 * Places a simple proxy around a simple type like 'int', 'float', or whatever.
 * The proxy provides this interface:
 *
 *       class type {
 *       public:
 *           type(type value = 0);
 *          ~type();
 *           type value();
 *           void assign(type value);
 *       };
 *         
 * Example:
 *
 *    %pointer_class(int, intp);
 *
 *    int add(int *x, int *y) { return *x + *y; }
 *
 * In python (with proxies)
 *
 *    >>> a = intp(2)
 *    >>> a.value()
 *    2
 *    >>> a.assign(10)
 *    >>> b = intp(20)
 *    >>> print add(a,b)
 *    30
 *
 * As a general rule, this macro should not be used on class/structures that
 * are already defined in the interface.
 * ----------------------------------------------------------------------------- */


%define %pointer_class(TYPE, NAME)
%{
  typedef TYPE NAME;
%}
  typedef struct {
     %extend {
         NAME() {
  	     TYPE *self;
#ifdef __cplusplus
             self = new TYPE();
#else
             self = (TYPE *) calloc(1, sizeof(TYPE));
#endif
             return self;
	 }
	 ~NAME() {
#ifdef __cplusplus
	   if (self) {
	     delete self;
	   }
#else
	   if (self) {
	     free(self);
	   }
#endif
	 }
	 void assign(TYPE value) {
	   *self = value;
	 }
	 TYPE value() {
	   return *self;
	 }
	 TYPE * cast() {
           return self;
	 }
	 static NAME * frompointer(TYPE *t) {
	   return (NAME *) t;
         }
     }
  } NAME;
  %types(NAME = TYPE);
%enddef

/* ----------------------------------------------------------------------------- 
 * %pointer_functions(type,name)
 *
 * Create functions for allocating/deallocating pointers.   This can be used
 * if you don't want to create a proxy class or if the pointer is complex.
 *
 *    %pointer_functions(int, intp)
 *
 *    int add(int *x, int *y) { return *x + *y; }
 *
 * In python (with proxies)
 *
 *    >>> a = new_intp(2)
 *    >>> intp_value(a)
 *    2
 *    >>> intp_assign(a,10)
 *    >>> b = new_intp(20)
 *    >>> print add(a,b)
 *    30
 *    >>> delete_intp(a)
 *    >>> delete_intp(b)
 * 
 * ----------------------------------------------------------------------------- */

%define %pointer_functions(TYPE,NAME)
%{
static 
TYPE *new_##NAME(TYPE value) {
  TYPE *self;
#if __cplusplus
  self = new TYPE();
#else
  self = (TYPE *) calloc(1,sizeof(TYPE));
#endif
  return self;
}
static
void delete_##NAME(TYPE *self) {
#if __cplusplus
  if (self) {
    delete self;
  }
#else
  if (self) {
    free(self);
  }
#endif
}
static
void NAME ##_assign(TYPE *self, TYPE value) {
   *self = value;
 }
static
TYPE NAME ##_value(TYPE *self) {
   return *self;
}
%}
TYPE *new_##NAME(TYPE value = 0);
void  delete_##NAME(TYPE *self);
void  NAME##_assign(TYPE *self, TYPE value);
TYPE  NAME##_value(TYPE *self);
%enddef

/* -----------------------------------------------------------------------------
 * %pointer_cast(type1,type2,name)
 *
 * Generates a pointer casting function.
 * ----------------------------------------------------------------------------- */

%define %pointer_cast(TYPE1,TYPE2,NAME)
%inline %{
TYPE2 NAME(TYPE1 x) {
   return (TYPE2) x;
}
%}
%enddef








