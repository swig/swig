/* -----------------------------------------------------------------------------
 * test.c
 *
 * This module implements a SWIG module in the new tag-based parser.
 * This is work in progress.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "preprocessor.h"
#include "lparse.h"

/* -------- Module variables ------- */

#define CPLUS_PUBLIC    1
#define CPLUS_PRIVATE   2
#define CPLUS_PROTECTED 3

static DOHFile     *runtime = 0;
static DOHFile     *headers = 0;     
static DOHFile     *wrappers = 0;
static DOHFile     *init = 0;

static DOH         *config_top = 0;

static int          ExternMode = 0;
static int          ImportMode = 0;
static int          ReadOnly = 0;
static int          CPlusMode = CPLUS_PUBLIC;
static int          NewMode = 0;
static DOHString   *ModuleName = 0;
static int          NativeMode = 0;
static DOHString   *NewName = 0;
static DOHHash     *RenameHash = 0;
static DOHHash     *Rules = 0;

/* Object oriented flags */

static int          InClass = 0;
static DOHString   *ClassType = 0;
static DOHString   *ClassName = 0;
static DOHString   *ClassRename = 0;
static int          AddMethods = 0;

/* -------- File inclusion directions -------- */

static int
emit_includefile(DOH *obj, void *clientdata) {
  DOH *c;
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
}

static int
emit_externfile(DOH *obj, void *clientdata) {
  DOH *c;
  int  oldem = ExternMode;
  ExternMode = 1;
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  ExternMode = oldem;
}

static int
emit_importfile(DOH *obj, void *clientdata) {
  DOH *c;
  int  oldem = ExternMode;
  ExternMode = 1;
  ImportMode = 1;
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  ExternMode = oldem;
  ImportMode = 0;
}

static int
emit_scope(DOH *obj, void *clientdata) {
  DOH *c;
  c = Getattr(obj,"child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  return 0;
}


/* -------- Code blocks -------- */

/* %{ ... %} directive */
static int
emit_headerblock(DOH *obj, void *clientdata) {
  Dump(Getattr(obj,"code"),headers);
  return 0;
}

/* %wrapper %{ ... %} directive */
static int
emit_wrapperblock(DOH *obj, void *clientdata) {
  Dump(Getattr(obj,"code"),wrappers);
  return 0;
}

/* %init %{ ... %} directive */
static int
emit_initblock(DOH *obj, void *clientdata) {
  Dump(Getattr(obj,"code"),init);
  return 0;
}

/* %runtime %{ ... %} directive */
static int
emit_runtimeblock(DOH *obj, void *clientdata) {
  Dump(Getattr(obj,"code"),runtime);
  return 0;
}

/* ------ Basic C declarations ----- */

/* -----------------------------------------------------------------------------
 * function
 * ----------------------------------------------------------------------------- */

static int
emit_function(DOH *obj, void *clientdata) {
  DOHString   *name, *scriptname, *type, *storage;
  DOHList     *parms;
  DOHHash     *p;
  Wrapper *wf;
  int         numarg = 0, numopt = 0;
  int         i, pn;

  if (ExternMode) return 0;

  name    = Getattr(obj,"name");               /* Name of the function */
  type    = Getattr(obj,"type");               /* Return type          */
  parms   = Getattr(obj,"parms");              /* Parameters           */
  storage = Getattr(obj,"storage");            /* Storage class        */

  /* See if the function is being renamed */
  if (NewName) scriptname = NewName;
  else scriptname = name;

  /* Is this a member function? */
  if (InClass) {
    /* Handle member functions */
    /*    goto function_exit; */
  }

  wf = NewWrapper();

  Printv(wf->def, 
	 "static PyObject *", Swig_name_wrapper(scriptname), "(PyObject *self, PyObject *args) {\n", 
	 0);

  /* Loop over all of the function arguments and build pieces of the wrapper function */
  {
    DOHString   *parsestr;               /* Format string for parsing arguments */
    DOHString   *argstr;                  /* List of arguments */
    DOHString   *inputstr;
    DOHString   *checkstr;
    DOHString   *initstr;
    DOHString   *targetstr;

    parsestr = NewString("");
    argstr    = NewString("");
    inputstr  = NewString("");
    checkstr  = NewString("");
    initstr   = NewString("");
    targetstr = NewString("");

    p = parms;
    pn = 0;
    
    while (p) {
      int nmatch = 0;
      DOHHash  *map;
      DOHHash  *rules;
      char      suffix[32];

      sprintf(suffix,"_%d", pn);

      map = Swig_map_match(Rules, "argument", p, &nmatch);

      if (!map) {
	Printf(stderr,"%s:%d. No argument rule for %S\n", Getfile(p),Getline(p),SwigType_cstr(Getattr(p,"type"),Getattr(p,"name")));
	return;
      }
      /* Pull out the rules */
      rules = Getattr(map,"rules");
      if (rules) {
	DOH *linit;
	DOH *lparse;
	DOH *linput;
	DOH *lcheck;
	DOH *largstr;
	DOH *ltarget;

	linit = Copy(Getattr(rules,"init"));
	lparse = Copy(Getattr(rules,"parse"));
	linput = Copy(Getattr(rules,"input"));
	lcheck = Copy(Getattr(rules,"check"));
	ltarget = Copy(Getattr(rules,"target"));

	largstr = 0;
	/* Construct the parse and argument strings */

	if (lparse) {
	  DOHList *sp;
	  DOHString  *pstr;
	  int i;
	  Seek(lparse,0,SEEK_SET);
	  sp = DohSplit(lparse,",",-1);
	  pstr = Getitem(sp,0);
	  if (pstr) {
	    char *c = Char(pstr);
	    while (*c && (*c != '\"')) c++;
	    c++;
	    while (*c && (*c != '\"')) {
	      Putc(*c, parsestr);
	      c++;
	    }
	  }
	  largstr = NewString("");
	  for (i = 1; i < Len(sp); i++) {
	    Printf(largstr,",%s",Getitem(sp,i));
	  }
	  Delete(sp);
	}

	/* Variable substitution.   We're going to walk down the map's children and perform variable name
	   replacements */

	{
	  DOH *c = Getattr(map,"child");
	  while (c) {
	    if (Cmp(Getattr(c,"tag"),"variable") == 0) {
	      DOH *vname;
	      DOH *rname;
	      DOH *vtype;
	      DOH *vvalue;
	      DOH *storage;
	      DOH *local;

	      storage = Getattr(c,"storage");
	      vname = Getattr(c,"name");
	      vtype = Getattr(c,"type");
	      vvalue = Getattr(c,"value");
	      
	      rname = NewStringf("%s_%d",vname,pn);

	      if (largstr) Replace(largstr,vname,rname,DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	      if (linit) Replace(linit,vname,rname,DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	      if (linput) Replace(linput,vname,rname,DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	      if (lcheck) Replace(lcheck,vname,rname,DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	      if (ltarget) Replace(ltarget,vname,rname, DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);

	      /* Declare as local to wrapper function */
	      local = NewString("");
	      Printf(local,"%S", SwigType_cstr(vtype,rname));
	      if (vvalue) {
		Printf(local," = %s", vvalue);
	      }
	      Wrapper_add_local(wf,rname,local);
	      Delete(local);
	      Delete(rname);
	    }
	    c = Swig_next(c);
	  }
	}
	if (largstr) Append(argstr, largstr);
	if (linput) Append(inputstr,linput);
	if (lcheck) Append(checkstr,lcheck);
	if (linit) Append(initstr,linit);
	if (ltarget) Printf(targetstr,"%s,", ltarget);
	Delete(largstr);
	Delete(linput);
	Delete(lcheck);
	Delete(linit);
	Delete(ltarget);
      }

      while (nmatch > 0) {
	p = Swig_next(p);
	nmatch--;
	pn++;
      }
    }

    /* Dump out the wrapper code */

    if (pn > 0)
      Delitem(targetstr,DOH_END);

    Printv(wf->code,
	   initstr,
	   "if (PyParse_Args(\"", parsestr, "\"", argstr, ") == NULL) return NULL;\n",
	   inputstr,
	   checkstr,
	   "result = ", name, "(", targetstr, ");\n",
	   0);
  }

  Printf(wf->code,"}\n");
  Wrapper_print(wf,wrappers);

 function_exit:
  Delete(NewName);
  NewName = 0;
  return 0;
}

/* -----------------------------------------------------------------------------
 * variable
 * ----------------------------------------------------------------------------- */
                                                                              
static int
emit_variable(DOH *obj, void *clientdata) {
  Printf(stdout,"variable\n");
  return 0;
}

/* -----------------------------------------------------------------------------
 * constant
 * ----------------------------------------------------------------------------- */

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
    int ic = InClass;
    InClass = 1;
    Swig_emit(c,clientdata);
    InClass = ic;
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
  CPlusMode = CPLUS_PRIVATE;
  return 0;
}

static int
emit_protected(DOH *obj, void *clientdata) {
  CPlusMode = CPLUS_PROTECTED;
  return 0;
}

static int
emit_public(DOH *obj, void *clientdata) {
  CPlusMode = CPLUS_PUBLIC;
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
  if (!ModuleName) {
    ModuleName = Getattr(obj,"name");
    DohIncref(ModuleName);
  }
  return 0;
}

static int
emit_renamedirective(DOH *obj, void *clientdata) {
  DOHString *name, *rename;
  name = Getattr(obj,"oldname");
  rename = Getattr(obj,"newname");
  if (name && rename)
    Setattr(RenameHash,name,rename);
  return 0;
}

static int
emit_readonlydirective(DOH *obj, void *clientdata) {
  ReadOnly = 1;
  return 0;
}

static int
emit_readwritedirective(DOH *obj, void *clientdata) {
  ReadOnly = 0;
  return 0;
}

static int
emit_namedirective(DOH *obj, void *clientdata) {
  if (NewName) Delete(NewName);
  NewName = Getattr(obj,"name");
  if (NewName) DohIncref(NewName);
  return 0;
}

static int
emit_newdirective(DOH *obj, void *clientdata) {
  NewMode = 1;
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
  DOH *c;
  int oldnative = NativeMode;
  NativeMode = 1;
  c = Getattr(obj, "child");
  if (c) {
    Swig_emit(c,clientdata);
  }
  NativeMode = oldnative;
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

static int
emit_map(DOH *obj, void *clientdata) {
  DOH *parms;
  DOH *rulename;
  DOH *rules;

  rulename = Getattr(obj,"name");
  parms = Getattr(obj,"parms");
  rules = Getattr(obj,"child");

  Swig_map_add(Rules,rulename,parms,obj);
}

/* -------- Entry point -------- */

static char *runtime_banner = "\n\
/* ----------------------------------------------------------------------------- \n\
                                    Runtime\n\
   ----------------------------------------------------------------------------- */\n";

static char *header_banner = "\n\
/* ----------------------------------------------------------------------------- \n\
                                    Headers\n\
   ----------------------------------------------------------------------------- */\n";

static char *wrapper_banner = "\n\
/* ----------------------------------------------------------------------------- \n\
                                    Wrappers\n\
   ----------------------------------------------------------------------------- */\n";

static char *init_banner = "\n\
/* ----------------------------------------------------------------------------- \n\
                                 Initialization\n\
   ----------------------------------------------------------------------------- */\n";

void test_emit(DOH *top, void *clientdata) {

  /* Initialization */

  runtime = NewString(runtime_banner);
  headers = NewString(header_banner);
  wrappers = NewString(wrapper_banner);
  init = NewString(init_banner);

  Rules = NewHash();
  RenameHash = NewHash();

  if (config_top)
    Swig_emit(config_top, clientdata);

  Swig_emit(top, clientdata);

  Swig_banner(stdout);

  Dump(runtime,stdout);
  Dump(headers,stdout);
  Dump(wrappers,stdout);
  Dump(init, stdout);
  Delete(runtime);
  Delete(headers);
  Delete(wrappers);
  Delete(init);
  Delete(RenameHash);
}

static SwigRule rules[] = {
  "includefile",        emit_includefile,
  "externfile",         emit_externfile,
  "importfile",         emit_importfile,
  "headerblock",        emit_headerblock,
  "wrapperblock",       emit_wrapperblock,
  "initblock",          emit_initblock,
  "runtimeblock",       emit_runtimeblock,
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
  "map",                emit_map,
  NULL, NULL
};

/* Initialize the module */
void test_init() {
  DOHString *config;
  DOHString *pconfig;

  Swig_add_rules(rules);


  /* Try to get the language specific configuration */

  config = Swig_include("pyconf.swg");

  if (!config) {
    Printf(stderr,"*** Fatal error. Unable to find pyconf.swg\n");
    exit(0);
  }

  /* Run the preprocessor on the configuration file and parse it */
  Seek(config,0,SEEK_SET);
  Setline(config,1);
  pconfig = Preprocessor_parse(config);

  Seek(pconfig,0,SEEK_SET);
  config_top = LParse_parse(pconfig);
}




