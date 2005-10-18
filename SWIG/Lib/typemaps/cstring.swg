/*
 * cstring.i
 * $Header$
 *
 * Author(s): David Beazley (beazley@cs.uchicago.edu)
 *
 * This file provides typemaps and macros for dealing with various forms
 * of C character string handling.   The primary use of this module
 * is in returning character data that has been allocated or changed in
 * some way.
 */

%define %typemap_cstrings(Name, Char,
			  SWIG_AsCharPtr,
			  SWIG_AsCharPtrAndSize,
			  SWIG_FromCharPtr,
			  SWIG_FromCharPtrAndSize)

/* %cstring_input_binary(TYPEMAP, SIZE)
 * 
 * Macro makes a function accept binary string data along with
 * a size.  For example:
 *
 *     %cstring_input_binary(Char *buff, int size);
 *     void foo(Char *buff, int size) {
 *     }
 *
 */

%define Name ## _input_binary(TYPEMAP, SIZE)                   
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize) (TYPEMAP, SIZE) 
  (Char *buf, size_t size, int alloc)  {
  if (SWIG_AsCharPtrAndSize($input, &buf, &size, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "(TYPEMAP, SIZE)", $argnum);
  }
  $1 = ($1_ltype) buf;					       
  $2 = ($2_ltype) size - 1;				       
}
%typemap(freearg) (TYPEMAP, SIZE) {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}
%enddef								


/*
 * %cstring_bounded_output(TYPEMAP, MAX)
 *
 * This macro is used to return a NULL-terminated output string of
 * some maximum length.  For example:
 *
 *     %cstring_bounded_output(Char *outx, 512);
 *     void foo(Char *outx) {
 *         sprintf(outx,"blah blah\n");
 *     }
 *
 */

%define Name ## _bounded_output(TYPEMAP,MAX)        
%typemap(in,noblock=1,numinputs=0) TYPEMAP (Char temp[MAX+1])  {
  $1 = ($1_ltype) temp;
}
%typemap(freearg) TYPEMAP "";
%typemap(argout,noblock=1,fragment= #SWIG_FromCharPtr ) TYPEMAP {
  $1[MAX] = 0;  
  SWIG_append_result(SWIG_FromCharPtr($1));
}
%enddef


/*
 * %cstring_chunk_output(TYPEMAP, SIZE)
 *
 * This macro is used to return a chunk of binary string data.
 * Embedded NULLs are okay.  For example:
 *
 *     %cstring_chunk_output(Char *outx, 512);
 *     void foo(Char *outx) {
 *         memmove(outx, somedata, 512);
 *     }
 *
 */

%define Name ## _chunk_output(TYPEMAP,SIZE)           
%typemap(in,noblock=1,numinputs=0) TYPEMAP(Char temp[SIZE]) {
  $1 = ($1_ltype) temp;
}
%typemap(freearg) TYPEMAP "";
%typemap(argout,noblock=1,fragment= #SWIG_FromCharPtrAndSize) TYPEMAP {
  SWIG_append_result(SWIG_FromCharPtrAndSize($1,SIZE));
}
%enddef


/*
 * %cstring_bounded_mutable(TYPEMAP, SIZE)
 *
 * This macro is used to wrap a string that's going to mutate.
 *
 *     %cstring_bounded_mutable(Char *in, 512);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */


%define Name ## _bounded_mutable(TYPEMAP,MAX)                              
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize) TYPEMAP (Char temp[MAX+1], Char *t, size_t n, int alloc) {  
  if (SWIG_AsCharPtrAndSize($input, &t, &n, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "TYPEMAP", $argnum);
  }
  if ( n > (size_t) MAX ) n = (size_t) MAX;
  memcpy(temp, t, sizeof(Char)*n);
  if (alloc == SWIG_NEWOBJ) SWIG_delete_array(t);
  temp[n - 1] = 0;                                                             
  $1 = ($1_ltype) temp;                                                    
}
%typemap(freearg) TYPEMAP "";
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtr) TYPEMAP {
  $1[MAX] = 0;
  SWIG_append_result(SWIG_FromCharPtr($1));
}
%enddef


/*
 * %cstring_mutable(TYPEMAP [, expansion])
 *
 * This macro is used to wrap a string that will mutate in place.
 * It may change size up to a user-defined expansion. 
 *
 *     %cstring_mutable(Char *in);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

%define Name ## _mutable(TYPEMAP,EXP...)                  
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize) TYPEMAP (Char* t, size_t n, int alloc, size_t expansion = 0) {
#if #EXP != ""
  expansion += EXP;
#endif
  if (SWIG_AsCharPtrAndSize($input, &t, &n, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "TYPEMAP", $argnum);
  }
  $1 = SWIG_new_array(n+expansion, $*1_ltype);          
  memcpy($1,t,sizeof(Char)*n);
  if (alloc == SWIG_NEWOBJ) SWIG_delete_array(t);
  $1[n-1] = 0;
}
%typemap(freearg) TYPEMAP "";
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtr) TYPEMAP { 
  SWIG_append_result(SWIG_FromCharPtr($1));
  SWIG_delete_array($1);                                  
}
%enddef

/*
 * %cstring_output_maxsize(TYPEMAP, SIZE)
 *
 * This macro returns data in a string of some user-defined size.
 *
 *     %cstring_output_maxsize(Char *outx, int max) {
 *     void foo(Char *outx, int max) {
 *         sprintf(outx,"blah blah\n");
 *     }
 */

%define Name ## _output_maxsize(TYPEMAP, SIZE)                       
%typemap(in,noblock=1,fragment=SWIG_AsVal_frag(unsigned long)) (TYPEMAP, SIZE) (unsigned long size) {   
  if (SWIG_AsVal(unsigned long)($input, &size) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "(TYPEMAP, SIZE)", $argnum);
  }
  $2 = SWIG_numeric_cast(size, $2_ltype);
  $1 = SWIG_new_array(size+1, $*1_ltype);
}                                                                     
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtr) (TYPEMAP,SIZE) { 
  SWIG_append_result(SWIG_FromCharPtr($1));
  SWIG_delete_array($1);                                              
}
%enddef

/*
 * %cstring_output_withsize(TYPEMAP, SIZE)
 *
 * This macro is used to return Character data along with a size
 * parameter.
 *
 *     %cstring_output_maxsize(Char *outx, int *max) {
 *     void foo(Char *outx, int *max) {
 *         sprintf(outx,"blah blah\n");
 *         *max = strlen(outx);  
 *     }
 */

%define Name ## _output_withsize(TYPEMAP, SIZE)                        
%typemap(in,noblock=1,fragment=SWIG_As_frag(unsigned long)) (TYPEMAP, SIZE) (unsigned long n) {    
  if (SWIG_AsVal(unsigned long)($input, &n) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "(TYPEMAP, SIZE)", $argnum);
  }
  $1 = SWIG_new_array(n+1, $*1_ltype);				       
  $2 = SWIG_new($*2_ltype);
  *$2 = SWIG_numeric_cast(n, $*2_ltype);
}								       
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtrAndSize) (TYPEMAP,SIZE) { 
  SWIG_append_result(SWIG_FromCharPtrAndSize($1,*$2));
  SWIG_delete_array($1);					       
  SWIG_delete($2);						       
}
%enddef

 
/*
 * %cstring_output_allocate(TYPEMAP, RELEASE)
 *
 * This macro is used to return Character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(Char **outx, free($1));
 *     void foo(Char **outx) {
 *         *outx = (Char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *     }
 */
 
%define Name ## _output_allocate(TYPEMAP, RELEASE)           
%typemap(in,noblock=1,numinputs=0) TYPEMAP($*1_ltype temp = 0) {
  $1 = &temp;
}						  	     
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtr) TYPEMAP { 
  if (*$1) {
    SWIG_append_result(SWIG_FromCharPtr(*$1));
    RELEASE;					  	     
  }					  	     
}							     
%enddef


/*
 * %cstring_output_allocate_size(TYPEMAP, SIZE, RELEASE)
 *
 * This macro is used to return Character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(Char **outx, int *sz, free($1));
 *     void foo(Char **outx, int *sz) {
 *         *outx = (Char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *         *sz = strlen(outx);
 *     }
 */

%define Name ## _output_allocate_size(TYPEMAP, SIZE, RELEASE)
%typemap(in,noblock=1,numinputs=0) (TYPEMAP, SIZE) ($*1_ltype temp = 0, $*2_ltype tempn) {
  $1 = &temp; $2 = &tempn;
}
%typemap(argout,noblock=1,fragment=#SWIG_FromCharPtrAndSize)(TYPEMAP,SIZE) {   
  if (*$1) {
    SWIG_append_result(SWIG_FromCharPtrAndSize(*$1,*$2));
    RELEASE;
  }
}
%enddef

%enddef

