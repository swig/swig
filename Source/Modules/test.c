/* -----------------------------------------------------------------------------
 * test.c
 *
 * This module is used to test the tag-based parser.
 * ----------------------------------------------------------------------------- */

#include "swig.h"

int test_unknown(DOH *node, void *clientdata) {
  Printf(stdout,"::: Unknown tag - '%s'\n", Getattr(node,"tag"));
  return 0;
}

int test_file(DOH *node, void *clientdata) {
  DOH *c;
  Printf(stdout,"::: File\n");
  Printf(stdout,"   name       = '%s'\n", Getattr(node,"name"));
  Printf(stdout,"   type       = '%s'\n", Getattr(node,"type"));
  c = Getchild(node);
  Printf(stdout,"   # elements = %d\n", Swig_count_nodes(c));
  Swig_emit_all(c,clientdata);
  return 0;
}

int test_scope(DOH *node, void *clientdata) {
  DOH *c;
  Printf(stdout,"::: Scope\n");
  Printf(stdout,"   name       = '%s'\n", Getattr(node,"name"));
  c = Getchild(node);
  Swig_emit_all(c,clientdata);
  return 0;
}

int test_module(DOH *node, void *clientdata) {
  Printf(stdout,"::: Module\n");
  Printf(stdout,"   name       = '%s'\n", Getname(node));
  return 0;
}

int test_insert(DOH *node, void *clientdata) {
  Printf(stdout,"::: Insert\n");
  Printf(stdout,"   section    = '%s'\n", Getattr(node,"section"));
  Printf(stdout,"   filename   = '%s'\n", Getattr(node,"filename"));
  Printf(stdout,"   code       = '%s'\n", Getattr(node,"code"));
  return 0;
}

int test_pragma(DOH *node, void *clientdata) {
  Printf(stdout,"::: Pragma\n");
  Printf(stdout,"   name       = '%s'\n", Getname(node));
  Printf(stdout,"   value      = '%s'\n", Getvalue(node));
  return 0;
}

int test_typemap(DOH *node, void *clientdata) {
  Printf(stdout,"::: Typemap\n");
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   code      = '%s'\n", Getattr(node,"code"));
  Printf(stdout,"   srcname   = '%s'\n", Getattr(node,"srcname"));
  Printf(stdout,"   srctype   = '%s'\n", Getattr(node,"srctype"));
  { 
    DOH *p = Getattr(node,"parms");
    if (p) {
        Printf(stdout,"   parms     = '%s'\n", ParmList_protostr(p));
    }
  }
  return 0;
}

int test_apply(DOH *node, void *clientdata) {
  Printf(stdout,"::: Apply\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  Printf(stdout,"   parms     = (%s)\n", ParmList_protostr(Getattr(node,"parms")));
  return 0;
}

int test_exception(DOH *node, void *clientdata) {
  Printf(stdout,"::: Exception\n");
  Printf(stdout,"   code      = '%s'\n", Getattr(node,"code"));
  return 0;
}

int test_clear(DOH *node, void *clientdata) {
  Printf(stdout,"::: Clear\n");
  Printf(stdout,"   parms     = (%s)\n", ParmList_protostr(Getattr(node,"parms")));
  return 0;
}

int test_constant(DOH *node, void *clientdata) {
  Printf(stdout,"::: Constant\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  Printf(stdout,"   value     = '%s'\n", Getvalue(node));
  return 0;
}

int test_function(DOH *node, void *clientdata) {
  Printf(stdout,"::: Function\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  Printf(stdout,"   parms     = (%s)\n", ParmList_protostr(Getattr(node,"parms")));
  Printf(stdout,"   storage   = '%s'\n", Getattr(node,"storage"));
  Printf(stdout,"   code      = '%s'\n", Getattr(node,"code"));
  return 0;
}

int test_variable(DOH *node, void *clientdata) {
  Printf(stdout,"::: Variable\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  Printf(stdout,"   storage   = '%s'\n", Getattr(node,"storage"));
  Printf(stdout,"   value     = '%s'\n", Getattr(node,"value"));
  return 0;
}

int test_typedef(DOH *node, void *clientdata) {
  Printf(stdout,"::: Typedef\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   type      = '%s'\n", Gettype(node));
  return 0;
}

int test_enum(DOH *node, void *clientdata) {
  DOH *c;
  Printf(stdout,"::: Enum\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  c = Getchild(node);
  Swig_emit_all(c,clientdata);
  return 0;
}

int test_enumvalue(DOH *node, void *clientdata) {
  Printf(stdout,"::: Enumvalue\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   value     = '%s'\n", Getvalue(node));
  return 0;
}

int test_class(DOH *node, void *clientdata) {
  DOH *c;
  Printf(stdout,"::: Class\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   bases     = %s\n", Getattr(node,"bases"));
  Printf(stdout,"   altname   = '%s'\n", Getattr(node,"altname"));
  Printf(stdout,"   classtype = '%s'\n", Getattr(node,"classtype"));
  c = Getchild(node);
  Swig_emit_all(c,clientdata);  
  return 0;
}

int test_classdecl(DOH *node, void *clientdata) {
  Printf(stdout,"::: Classdecl\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));  
  return 0;
}

int test_addmethods(DOH *node, void *clientdata) {
  DOH *c;
  Printf(stdout,"::: Addmethods\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  c = Getchild(node);
  Swig_emit_all(c,clientdata);  
  return 0;
}

int test_destructor(DOH *node, void *clientdata) {
  Printf(stdout,"::: Destructor\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  Printf(stdout,"   code      = '%s'\n", Getattr(node,"code"));
  return 0;
}

int test_access(DOH *node, void *clientdata) {
  Printf(stdout,"::: AccessSpecifier\n");
  Printf(stdout,"   name      = '%s'\n", Getname(node));
  return 0;
}

static SwigRule rules[] = {
  { "file", test_file},
  { "module", test_module},
  { "scope", test_scope},
  { "insert", test_insert},
  { "pragma", test_pragma},
  { "typemap", test_typemap},
  { "apply", test_apply},
  { "exception", test_exception},
  { "clear", test_clear},
  { "addmethods", test_addmethods},
  { "constant", test_constant},
  { "function", test_function},
  { "variable", test_variable},
  { "typedef", test_typedef},
  { "enum", test_enum},
  { "enumvalue", test_enumvalue},
  { "class", test_class},
  { "classdecl", test_classdecl},
  { "destructor", test_destructor},
  { "access", test_access},
  { "*", test_unknown},
  { 0 }
};

static 
int test_init(int argc, char **argv) {
  Printf(stdout,"test_init:\n");
  return 0;
}

static
DOH *test_run(DOH *node) {
  DOH *c;
  Printf(stdout,"test_run:\n");
  Swig_add_rules(rules);

  c = Getattr(node,"child");
  Swig_emit_all(c,0);
  return 0;
}

void testmodule() {
  Swig_register_module("test","swig:top", test_init, test_run);
}



