/* ----------------------------------------------------------------------------- 
 * htoi.cxx
 *
 *     Produce a .i file given input.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "mod11.h"
#include "preprocessor.h"
#include "htoi.h"


File *f_output = 0;
String *f_decl = 0;

/* -----------------------------------------------------------------------------
 * HTOI::main()
 * ----------------------------------------------------------------------------- */

void
HTOI::main(int argc, char *argv[]) {
  int i;
  SWIG_library_directory("htoi");
  for (i = 1; i < argc; i++) {
  }
  Preprocessor_define((void *) "SWIGHTOI 1",0);
  Preprocessor_include_all(1);
  Preprocessor_ignore_missing(1);
  SWIG_typemap_lang("htoi");
}

void HTOI::emit_node(Node *n) {
    String *err;
    Symtab *symtab;

    char *tag = Char(nodeType(n));
    if (!tag) {
      Printf(stderr,"SWIG: Fatal internal error. Malformed parse tree node!\n");
      return;
    }
    if ((err = Geterror(n))) {
      return;
    }
    if (strcmp(tag,"top") == 0) {
      top(n);
    }
    else if (strcmp(tag,"include") == 0) {
      includeDirective(n);
    } else if (strcmp(tag,"constant") == 0) {
      constantDirective(n);
    }

      /* ============================================================
       * C/C++ parsing
       * ============================================================ */

    else if (strcmp(tag,"extern") == 0) {
      externDeclaration(n);
    } else if (strcmp(tag,"cdecl") == 0) {
      cDeclaration(n);
    } else if (strcmp(tag,"enum") == 0) {
      enumDeclaration(n);
    } else if (strcmp(tag,"enumitem") == 0) {
      enumvalueDeclaration(n);
    } else if (strcmp(tag,"class") == 0) {
      classDeclaration(n);
    } else if (strcmp(tag,"classforward") == 0) {
      classforwardDeclaration(n);
    } else if (strcmp(tag,"constructor") == 0) {
      constructorDeclaration(n);
    } else if (strcmp(tag,"destructor") == 0) {
      destructorDeclaration(n);
    } else if (strcmp(tag,"operator") == 0) {
      operatorDeclaration(n);
    } else if (strcmp(tag,"access") == 0) {
      accessDeclaration(n);
    }
}
/*
/* ----------------------------------------------------------------------
 * HTOI::top()   - Top of parsing tree 
 * ---------------------------------------------------------------------- */

void HTOI::top(Node *n) {
  Node *c;
  String *modname = Getname(n);
  String *outname = Getattr(n,"outfile");
  f_output = NewFile(outname,"w");
  f_decl = NewString("");

  Printf(f_output,"// This file was automatically generated using 'swig -htoi'\n");
  Printf(f_output,"%%module %s\n", modname);
  Printf(f_output,"%%{\n");
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_node(c);
  }
  Printf(f_output,"%%}\n");
  Dump(f_decl, f_output);
  Close(f_output);
  Delete(f_output);
  Delete(f_decl);
}

void HTOI::includeDirective(Node *n) {
  Node *c;
  Printf(f_output,"#include \"%s\"\n", Getname(n));
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_node(c);
  }
}

/* ----------------------------------------------------------------------
 * HTOI::constantDirective()
 * ---------------------------------------------------------------------- */

void HTOI::constantDirective(Node *n) {
  String *name = Getname(n);
  String *value = Getvalue(n);
  String *type  = Gettype(n);
  Printf(f_decl, "%%constant %s = %s\n", SwigType_str(type,name), value);
}

/* ----------------------------------------------------------------------
 * HTOI::cDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::cDeclaration(Node *n) {
  String *name    = Getname(n);
  SwigType *type  = Gettype(n);
  SwigType *decl  = Getdecl(n);
  String *storage = Getattr(n,"storage");
  String *code    = Getattr(n,"code");
  Parm   *parms   = Getparms(n);
  String *value   = Getvalue(n);
  SwigType *t;

  t = Copy(type);
  SwigType_push(t, decl);

  if (storage)
    Printf(f_decl,"%s ", storage);

  Printf(f_decl,"%s", SwigType_str(t,name));

  if (value) {
    Printf(f_decl,"= %s", value);
  }
  Printf(f_decl,";\n");
  Delete(t);
}

/* ----------------------------------------------------------------------
 * HTOI::externDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::externDeclaration(Node *n) {
  Node *c;
  Printf(f_decl,"extern \"C\" {\n");
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_node(c);
  }
  Printf(f_decl,"}\n");
}

/* ----------------------------------------------------------------------
 * HTOI::enumDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::enumDeclaration(Node *n) {
  String *name = Getname(n);
  Node *c;
  Printf(f_decl,"enum %s {\n", name);
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_node(c);
  }
  Printf(f_decl,"}\n");
}

/* ----------------------------------------------------------------------
 * HTOI::enumvalueDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::enumvalueDeclaration(Node *n) {
  String *newvalue;
  String *name = Getname(n);
  String *symname = Getsymname(n);
  String *value = Getvalue(n);
  String *type  = Gettype(n);
  if (Cmp(value,name) == 0) {
    newvalue = 0;
  } else {
    newvalue = value;
  }
  Printf(f_decl,"    %s = %s,\n", name, newvalue);
}

/* ----------------------------------------------------------------------
 * HTOI::classDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::classDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getattr(n,"name");
  List   *bases = Getattr(n,"bases");
  String *tdname = Getattr(n,"tdname");
  String *symname = Getsymname(n);
  char *classname = tdname ? Char(tdname) : Char(name);
  char *iname = Char(symname);
  int   strip = (tdname || CPlusPlus) ? 1 : 0;

  if (tdname) {
    Printf(f_decl,"typedef ");
  }
  Printf(f_decl,"%s %s {\n", kind, name);

  /* Emit all of the members */
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    emit_node(c);
  }
  Printf(f_decl,"} ");
  if (tdname) Printf(f_decl,"%s", tdname);
  Printf(f_decl,";\n\n");
}

/* ----------------------------------------------------------------------
 * HTOI::classforwardDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::classforwardDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  String *name = Getname(n);
  Printf(f_decl,"%s %s;\n", kind, name);
}

/* ----------------------------------------------------------------------
 * HTOI::constructorDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::constructorDeclaration(Node *n) {
  String *name = Getname(n);
  String *symname = Getsymname(n);
  Parm   *parms = Getparms(n);
}

/* ----------------------------------------------------------------------
 * HTOI::destructorDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::destructorDeclaration(Node *n) {
  String *name = Getname(n);
  Printf(f_decl,"%s();\n", name);
}

/* ----------------------------------------------------------------------
 * HTOI::accessDeclaration()
 * ---------------------------------------------------------------------- */

void HTOI::accessDeclaration(Node *n) {
  String *kind = Getattr(n,"kind");
  Printf(f_decl,"%s:\n", kind);
}

