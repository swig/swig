/* -*- c -*- */
/* ------------------------------------------------------------------------- 
 * swig.i
 *
 *     Interface file for the SWIG core.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *             Dustin Mitchell (djmitche@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 *
 * $Header$
 * ------------------------------------------------------------------------- */

%module swig

%{
#include "doh.h"
%}

%typemap(python,in) FILE * {
   $target = PyFile_AsFile($source);
}

%typemap(python,out) FILE * {
   $target = PyFile_FromFile($source, "unknown", "?", fclose);
}

%{
/* ------------------------------------------------------------------------- 
 * An extension type for DOH objects -- we could use shadow classes,
 * but this will be lots faster.
 * ------------------------------------------------------------------------- */

   typedef struct PyDOH {
      PyObject_HEAD
      DOH *doh;
   } PyDOH;

   staticforward PyTypeObject PyDOHType;

   /* methods */
   static PyObject * Swig_PyDOH_new(DOH *in) {
      PyDOH *self = PyObject_NEW(PyDOH, &PyDOHType);
      if (!self) return (PyObject *)self;
      self->doh = in;
      Incref(in);		/* increase the DOH refcount */
      return (PyObject *)self;
   }

   static void Swig_PyDOH_delete(PyDOH *self) {
      Delete(self->doh);		/* decrease the DOH refcount */
      PyMem_DEL(self);
   }

   static int Swig_PyDOH_check(void *self) {
      return (((PyObject *)self)->ob_type == &PyDOHType);
   }

   static PyObject *Swig_PyDOH_repr(PyDOH *self) {
      return PyString_FromString(Char(self->doh));
   }

   static char PyDOH_docstring[] = 
" Interface to DOH objects from Python.  DOH objects behave largely\n\
 like Python objects, although some functionality may be different.";

   /* Type object */
   static PyTypeObject PyDOHType = {
      PyObject_HEAD_INIT(&PyType_Type)
      0,
      "DOH",
      sizeof(PyDOH),
      0,
      (destructor)Swig_PyDOH_delete,
      (printfunc)0,
      (getattrfunc)0,
      (setattrfunc)0,
      (cmpfunc)0,
      (reprfunc)Swig_PyDOH_repr,

      0,			/* tp_as_number */
      0,			/* tp_as_sequence */
      0,			/* tp_as_mapping */
      (hashfunc)0,		/* tp_hash */
      (ternaryfunc)0,		/* tp_call */
      (reprfunc)0,		/* tp_str */
      (getattrofunc)0,		/* tp_getattro */
      (setattrofunc)0,		/* tp_setattro */
      0,			/* tp_as_buffer */
      0,			/* tp_xxx4 */
      PyDOH_docstring
   };
%}

%typemap(python,in) DOH * {
   if (Swig_PyDOH_check($source))
      $target = ((PyDOH *)$source)->doh, printf("PyDOH\n");
   else if (PyString_Check($source))
      $target = (DOH *)PyString_AsString($source), printf("String\n");
   else if (PySequence_Check($source))
      $target = 0, printf("Sequence\n");
   else if (PyMapping_Check($source))
      $target = 0, printf("Mapping\n");
   else if (PyNumber_Check($source))
      $target = (DOH *)$source, printf("Number\n");
   else if (PyFile_Check($source))
      $target = (DOH *)PyFile_AsFile($source), printf("File\n");
   else
      $target = (DOH *)NULL;	/* do better later? */
}

%typemap(python,out) DOH * {
   $target = Swig_PyDOH_new($source);
}

%title "SWIG", after

%section "DOH Objects", before

%subsection "Constants"

/* The beginning of a sequence */
#define DOH_BEGIN    -1
/* The end of a sequence */
#define DOH_END      -2
/* The current point in a sequence */
#define DOH_CUR      -3
/* Synonymous with DOH_CUR */
#define DOH_CURRENT  -3

/* Replace any matches of the given text */
#define   DOH_REPLACE_ANY         0x00
/* Replace, but not inside of quotes */
#define   DOH_REPLACE_NOQUOTE     0x01
/* Replace only full identifiers */
#define   DOH_REPLACE_ID          0x02
/* Replace only the first match */
#define   DOH_REPLACE_FIRST       0x04

%subsection "SuperStrings"
/* SuperString constructor */
extern DOH *NewSuperString(char *string, DOH *filename, int firstline);
/* Is this a SuperString? */
extern int SuperString_check(DOH *);

%subsection "Strings"
/* String constructor */
extern DOH   *NewString(char *c);
/* Is this a string? */
extern int    String_check(DOH *);

%subsection "Files"
/* File constructor */
extern DOH *NewFile(DOH *file, char *mode);
/* File constructor from Python file */
extern DOH *NewFileFromFile(FILE *file);
/* File constructor from a file descriptor */
extern DOH *NewFileFromFd(int fd);
/* Copy from file to file */
%name(CopyTo) extern int  DohCopyto(DOH *input, DOH *output);

%subsection "Lists"
/* List constructor */
extern DOH  *NewList();
/* Is this a list? */
extern int  List_check(DOH *);
/* Sort a list */
extern void List_sort(DOH *);

%subsection "Hash tables"
/* Hash table constructor */
extern DOH   *NewHash();
/* Is this a hash table? */
extern int    Hash_check(DOH *);
/* Get a List of the keys in a hash table */
extern DOH   *Hash_keys(DOH *);

%section "Files"

extern void  Swig_add_directory(DOH *dirname);
extern DOH  *Swig_last_file();
extern DOH  *Swig_search_path();
extern FILE *Swig_open(DOH *name);
extern DOH  *Swig_read_file(FILE *file);
extern DOH  *Swig_include(DOH *name);

#define  SWIG_FILE_DELIMETER   "/"

%section "Command Line Parsing"

extern void  Swig_init_args(int argc, char **argv);
extern void  Swig_mark_arg(int n);
extern void  Swig_check_options();
extern void  Swig_arg_error();

%section "Scanner Interface"

/*  typedef struct SwigScanner SwigScanner; */

/*  extern SwigScanner *NewSwigScanner(); */
/*  extern void     DelSwigScanner(SwigScanner *); */
/*  extern void     SwigScanner_clear(SwigScanner *); */
/*  extern void     SwigScanner_push(SwigScanner *, DOH *); */
/*  extern void     SwigScanner_pushtoken(SwigScanner *, int); */
/*  extern int      SwigScanner_token(SwigScanner *); */
/*  extern DOH     *SwigScanner_text(SwigScanner *); */
/*  extern void     SwigScanner_skip_line(SwigScanner *); */
/*  extern int      SwigScanner_skip_balanced(SwigScanner *, int startchar, int endchar); */
/*  extern void     SwigScanner_set_location(SwigScanner *, DOH *file, int line); */
/*  extern DOH     *SwigScanner_get_file(SwigScanner *); */
/*  extern int      SwigScanner_get_line(SwigScanner *); */
/*  extern void     SwigScanner_idstart(SwigScanner *, char *idchar); */

/*  #define   SWIG_MAXTOKENS          512 */
/*  #define   SWIG_TOKEN_LPAREN        1   */
/*  #define   SWIG_TOKEN_RPAREN        2 */
/*  #define   SWIG_TOKEN_SEMI          3 */
/*  #define   SWIG_TOKEN_COMMA         4 */
/*  #define   SWIG_TOKEN_STAR          5 */
/*  #define   SWIG_TOKEN_LBRACE        6 */
/*  #define   SWIG_TOKEN_RBRACE        7 */
/*  #define   SWIG_TOKEN_EQUAL         8 */
/*  #define   SWIG_TOKEN_EQUALTO       9 */
/*  #define   SWIG_TOKEN_NOTEQUAL     10 */
/*  #define   SWIG_TOKEN_PLUS         11 */
/*  #define   SWIG_TOKEN_MINUS        12 */
/*  #define   SWIG_TOKEN_AND          13 */
/*  #define   SWIG_TOKEN_LAND         14 */
/*  #define   SWIG_TOKEN_OR           15 */
/*  #define   SWIG_TOKEN_LOR          16 */
/*  #define   SWIG_TOKEN_XOR          17 */
/*  #define   SWIG_TOKEN_LESSTHAN     18 */
/*  #define   SWIG_TOKEN_GREATERTHAN  19 */
/*  #define   SWIG_TOKEN_LTEQUAL      20 */
/*  #define   SWIG_TOKEN_GTEQUAL      21 */
/*  #define   SWIG_TOKEN_NOT          22 */
/*  #define   SWIG_TOKEN_LNOT         23 */
/*  #define   SWIG_TOKEN_LBRACKET     24 */
/*  #define   SWIG_TOKEN_RBRACKET     25 */
/*  #define   SWIG_TOKEN_SLASH        26 */
/*  #define   SWIG_TOKEN_BACKSLASH    27 */
/*  #define   SWIG_TOKEN_ENDLINE      28 */
/*  #define   SWIG_TOKEN_STRING       29 */
/*  #define   SWIG_TOKEN_POUND        30 */
/*  #define   SWIG_TOKEN_PERCENT      31 */
/*  #define   SWIG_TOKEN_COLON        32 */
/*  #define   SWIG_TOKEN_DCOLON       33 */
/*  #define   SWIG_TOKEN_LSHIFT       34 */
/*  #define   SWIG_TOKEN_RSHIFT       35 */
/*  #define   SWIG_TOKEN_ID           36 */
/*  #define   SWIG_TOKEN_FLOAT        37 */
/*  #define   SWIG_TOKEN_DOUBLE       38 */
/*  #define   SWIG_TOKEN_INT          39 */
/*  #define   SWIG_TOKEN_UINT         40 */
/*  #define   SWIG_TOKEN_LONG         41 */
/*  #define   SWIG_TOKEN_ULONG        42 */
/*  #define   SWIG_TOKEN_CHAR         43 */
/*  #define   SWIG_TOKEN_PERIOD       44 */
/*  #define   SWIG_TOKEN_AT           45 */
/*  #define   SWIG_TOKEN_DOLLAR       46 */
/*  #define   SWIG_TOKEN_CODEBLOCK    47 */
/*  #define   SWIG_TOKEN_ILLEGAL      98 */
/*  #define   SWIG_TOKEN_LAST         99  */

%section "SWIG types"

/*  #define   SWIG_TYPE_BYTE          1 */
/*  #define   SWIG_TYPE_UBYTE         2 */
/*  #define   SWIG_TYPE_SHORT         3 */
/*  #define   SWIG_TYPE_USHORT        4 */
/*  #define   SWIG_TYPE_INT           5 */
/*  #define   SWIG_TYPE_UINT          6 */
/*  #define   SWIG_TYPE_LONG          7 */
/*  #define   SWIG_TYPE_ULONG         8 */
/*  #define   SWIG_TYPE_LONGLONG      9 */
/*  #define   SWIG_TYPE_ULONGLONG    10 */
/*  #define   SWIG_TYPE_FLOAT        11 */
/*  #define   SWIG_TYPE_DOUBLE       12 */
/*  #define   SWIG_TYPE_QUAD         13 */
/*  #define   SWIG_TYPE_CHAR         14 */
/*  #define   SWIG_TYPE_WCHAR        15 */
/*  #define   SWIG_TYPE_VOID         16 */
/*  #define   SWIG_TYPE_ENUM         17 */
/*  #define   SWIG_TYPE_VARARGS      18 */
/*  #define   SWIG_TYPE_TYPEDEF      19 */

/*  #define   SWIG_TYPE_POINTER      50 */
/*  #define   SWIG_TYPE_REFERENCE    51 */
/*  #define   SWIG_TYPE_FUNCTION     52 */
/*  #define   SWIG_TYPE_ARRAY        53 */
/*  #define   SWIG_TYPE_RECORD       54 */
/*  #define   SWIG_TYPE_NAME         55 */

/*  DOH *NewSwigType(int tc, DOH *value); */





