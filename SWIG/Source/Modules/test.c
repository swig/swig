/* Test module */
#include "swig.h"

/* -------- File inclusion directions -------- */

static int
emit_includefile(DOH *obj, void *clientdata) {
  DOH *c;
  printf("includefile\n");
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
}

static int
emit_externfile(DOH *obj, void *clientdata) {
  DOH *c;
  printf("externfile\n");
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
}

static int
emit_importfile(DOH *obj, void *clientdata) {
  DOH *c;
  printf("importfile\n");
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
}

static int
emit_scope(DOH *obj, void *clientdata) {
  DOH *c;
  Printf(stdout,"scope\n");
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  return 0;
}


/* Code blocks */

static int
emit_headerblock(DOH *obj, void *clientdata) {
  Printf(stdout,"headerblock\n");
  return 0;
}

static int
emit_wrapperblock(DOH *obj, void *clientdata) {
  Printf(stdout,"wrapperblock\n");
  return 0;
}

static int
emit_initblock(DOH *obj, void *clientdata) {
  Printf(stdout,"initblock\n");
  return 0;
}

/* ------ Basic C declarations ----- */

static int
emit_function(DOH *obj, void *clientdata) {
  Printf(stdout,"function\n");
  return 0;
}

static int
emit_variable(DOH *obj, void *clientdata) {
  Printf(stdout,"variable\n");
  return 0;
}

static int
emit_constant(DOH *obj, void *clientdata) {
  Printf(stdout,"constant\n");
  return 0;
}

static int
emit_typedef(DOH *obj, void *clientdata) {
  Printf(stdout,"typedef\n");
  return 0;
}

static int
emit_enum(DOH *obj, void *clientdata) {
  DOH *c;
  Printf(stdout,"enum\n");
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  return 0;
}

static int
emit_enumvalue(DOH *obj, void *clientdata) {
  Printf(stdout,"enumvalue\n");
  return 0;
}

/* ------ C++ stuff ------ */

static int
emit_class(DOH *obj, void *clientdata) {
  DOH *c;
  Printf(stdout,"class\n");
  c = Getattr(obj, "child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  return 0;
}

static int
emit_destructor(DOH *obj, void *clientdata) {
  Printf(stdout,"destructor\n");
  return 0;
}

static int
emit_classdecl(DOH *obj, void *clientdata) {
  Printf(stdout,"classdecl\n");
  return 0;
}

static int
emit_private(DOH *obj, void *clientdata) {
  Printf(stdout,"private\n");
  return 0;
}

static int
emit_protected(DOH *obj, void *clientdata) {
  Printf(stdout,"protected\n");
  return 0;
}

static int
emit_public(DOH *obj, void *clientdata) {
  Printf(stdout,"public\n");
  return 0;
}

static int
emit_addmethods(DOH *obj, void *clientdata) {
  DOH *c;
  Printf(stdout,"addmethods\n");
  c = Getattr(obj, "child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  return 0;
}

/* ------ SWIG directives ------ */

static int
emit_moduledirective(DOH *obj, void *clientdata) {
  Printf(stdout,"moduledirective : %s\n", Getattr(obj,"name"));
  return 0;
}

static int
emit_renamedirective(DOH *obj, void *clientdata) {
  Printf(stdout,"renamedirective\n");
  return 0;
}

static int
emit_readonlydirective(DOH *obj, void *clientdata) {
  Printf(stdout,"readonlydirective\n");
  return 0;
}

static int
emit_readwritedirective(DOH *obj, void *clientdata) {
  Printf(stdout,"readwritedirective\n");
  return 0;
}

static int
emit_namedirective(DOH *obj, void *clientdata) {
  Printf(stdout,"namedirective\n");
  return 0;
}

static int
emit_newdirective(DOH *obj, void *clientdata) {
  Printf(stdout,"newdirective\n");
  return 0;
}

static int
emit_exceptiondirective(DOH *obj, void *clientdata) {
  Printf(stdout,"exceptiondirective\n");
  return 0;
}

static int
emit_pragmadirective(DOH *obj, void *clientdata) {
  Printf(stdout,"pragmadirective\n");
  return 0;
}

static int
emit_nativedirective(DOH *obj, void *clientdata) {
  Printf(stdout,"nativedirective\n");
  return 0;
}

static int
emit_typemap(DOH *obj, void *clientdata) {
  Printf(stdout,"typemap\n");
  return 0;
}

static int
emit_typemapcopy(DOH *obj, void *clientdata) {
  Printf(stdout,"typemapcopy\n");
  return 0;
}

static int
emit_applydirective(DOH *obj, void *clientdata) {
  Printf(stdout,"applydirective\n");
  return 0;
}

static int
emit_cleardirective(DOH *obj, void *clientdata) {
  Printf(stdout,"cleardirective\n");
  return 0;
}

/* Entry point */
void test_emit(DOH *top, void *clientdata) {
  Swig_emit(top, clientdata);
}

static SwigRule rules[] = {
  "includefile",        emit_includefile,
  "externfile",         emit_externfile,
  "importfile",         emit_importfile,

  "headerblock",        emit_headerblock,
  "wrapperblock",       emit_wrapperblock,
  "initblock",          emit_initblock,
  "scope",              emit_scope,
  "function",           emit_function,
  "variable",           emit_variable,
  "constant",           emit_constant,
  "typedef",            emit_typedef,

  "class",              emit_class,
  "destructor",         emit_destructor,
  "enum",               emit_enum,
  "enumvalue",          emit_enumvalue,
  "classdecl",          emit_classdecl,
  "private",            emit_private,
  "protected",          emit_protected,
  "public",             emit_public,
  "addmethods",         emit_addmethods,

  "moduledirective",    emit_moduledirective,
  "renamedirective",    emit_renamedirective,
  "readonlydirective",  emit_readonlydirective,
  "readwritedirective", emit_readwritedirective,
  "namedirective",      emit_namedirective,
  "newdirective",       emit_newdirective,
  "exceptiondirective", emit_exceptiondirective,
  "pragmadirective",    emit_pragmadirective,
  "nativedirective",    emit_nativedirective,
  "typemap",            emit_typemap,
  "typemapcopy",        emit_typemapcopy,
  "applydirective",     emit_applydirective,
  "cleardirective",     emit_cleardirective,
  
  NULL, NULL
};

/* Initialize the module */
void test_init() {
  Swig_add_rules(rules);
}
