/* -----------------------------------------------------------------------------
 * csharp.cxx
 *
 * CSharp (C#) module.
 *
 * Author(s) : Songyan Feng (Tiger) (songyanf@cs.uchicago.edu)
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * songyanf@cs.uchicago.edu
 *
 * Warning : this work is in progress and for test only.
 *
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swigmod.h"
#include "csharp.h"
//#define DEBUG

#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <ctype.h>

//static  String       *const_code = 0;
static  String       *shadow_methods = 0;
static  String       *module = 0;
static  String       *interface = 0;
static  String       *global_name = 0;
static  int           shadow = 0;
static  int           use_kw = 0;

static  File         *f_runtime = 0;
static  File         *f_header = 0;
static  File	     *f_middle = 0;
static  File         *f_wrappers = 0;
static  File	     *f_construct = 0;
static  File	     *f_construct_header= 0;
static  File	     *f_redefine=0;
static  File	     *f_variable = 0;
static  File	     *f_destruct = 0;
static  File	     *f_constant = 0;

//static  File         *f_init = 0;
static  File         *f_shadow = 0;
static  File         *f_shadow_stubs = 0;

static  String       *import_file = 0;
static  List         *import_stack = 0;
static  String       *methods;
static  String       *class_name;
static  String       *shadow_indent = 0;

static char *usage =(char *) "No CSharp Option available currently.\n";

class CSHARP : public Language {
public:

/* -----------------------------------------------------------------------------
 * CSHARP::main()
 * ----------------------------------------------------------------------------- */
virtual void main(int argc, char *argv[]) {

  SWIG_library_directory("csharp");

  if (!global_name) global_name = NewString("cvar");
  Preprocessor_define((void *) "SWIGCSHARP", 0);
  SWIG_typemap_lang("csharp");
  SWIG_config_file("csharp.swg");
}

/* -----------------------------------------------------------------------------
 * CSHARP::top()
 * ----------------------------------------------------------------------------- */

virtual int
top(Node *n) {

  /* Initialize all of the output files */
  String *outfile = Getattr(n,"outfile");
  
  f_runtime = NewFile(outfile,"w");
  if (!f_runtime) {
    Printf(stderr,"*** Can't open '%s'\n", outfile);
    SWIG_exit(EXIT_FAILURE);
  }
  
  f_header = NewString("");
  f_middle=NewString("");
  f_wrappers = NewString("");
  f_construct = NewString("");
  f_construct_header = NewString("");
  f_redefine = NewString("");
  f_variable = NewString("");
  f_destruct = NewString("");
  f_constant = NewString("");

  #ifdef DEBUG
  Printf(f_header,"/*------ Below is the f_header part.------*/\n");
  Printf(f_middle,"\n/*------ Below is the f_middle part.------*/\n");
  Printf(f_wrappers,"\n/*------ Below is the f_wrappers part.------*/\n");
  Printf(f_runtime,"/*------ Below is the f_runtime part.------*/\n");
  #endif
  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("middle",f_middle);
  Swig_register_filebyname("wrapper",f_wrappers);
  Swig_register_filebyname("runtime",f_runtime);

  methods        = NewString("");
  //Printf(methods,"/*\nMethods transfer table:\n{\n");
  import_stack   = NewList();
  
  Swig_banner(f_runtime); //printf the header introduction of the wrapper file.

  Printf(f_runtime,"#define SWIGCSHARP\n\n");

  /* Set module name */
  module = Copy(Getattr(n,"name"));

  char  filen[256];
  
  /* Initialization of all parts */
  /* The Str2Char function, used for typemaps.*/
  Printf(f_header,"// %s_wrap.h\n", module);
  
  if (CPlusPlus==0)
	  Printf(f_header,"extern \"C\" {\n", module);
  
  Printf(f_middle,"\n#pragma once\n\nusing namespace System;\n\n");
  Printf(f_middle,"char * SWIG_Str2Char(String *str)\n");
  Printf(f_middle,"\t{\n");
  Printf(f_middle,"\t\tint length = str->Length;\n");
  Printf(f_middle,"\t\tchar * in_string = new char[length+1];\n");
  Printf(f_middle,"\t\tfor(unsigned short i = 0; i<length; i++)\n");
  Printf(f_middle,"\t\t{\n");
  Printf(f_middle,"\t\t\tin_string[i] = str->Chars[i];\n");
  Printf(f_middle,"\t\t}\n");
  Printf(f_middle,"\t\tin_string[length] =\ '\\0\';\n");
  Printf(f_middle,"\t\treturn in_string;\n");
  Printf(f_middle,"\t}\n\n");
  Printf(f_middle,
	  "namespace %s\n{\n\tpublic __gc class %s\n\t{\n\tpublic:\n",
	  module, module);
#ifdef DEBUG
  Printf(f_constant,"\n\t\t/* global constants of original C files */\n");
  Printf(f_variable,"\n\t\t/* global variables of original C files */\n");
#endif
  Printf(f_construct_header, "\n\t\t%s()\n\t\t\t:\n",module);
  Printf(f_construct, "\t\t{\n",module);
  Printf(f_destruct, "\n\t\t~%s()\n\t\t{\n",module);
  Printf(f_redefine, "\n");
  
  /* emit code */
  Language::top(n);

  /* Ending construction of all parts */
  if (CPlusPlus == 0)
	  Printf(f_header,"}\n");
  Printf(f_variable,"\t\tint VAR_END;\n");
  Printf(f_constant,"\t\tconst int CONST_END;\n");
  Printf(f_construct_header,"\t\tCONST_END(0)\n");
  Printf(f_construct,"\t\t}\n\n");
  Printf(f_destruct, "\t\t}\n\n");
  Printf(f_redefine, "\n");
  //Printf(methods,"}\n*/\n");
  Printf(f_wrappers,"\t};\n}\n");
  Printf(f_wrappers,"%s\n",methods);
  
  /* Close all of the files */
  #ifdef DEBUG
  Printf(f_header,"\n/*------ Above is the f_header part.------*/\n");
  Printf(f_wrappers,"\n/*------ Above is the f_wrappers part.------*/\n");
  Printf(f_middle,"\n/*------ Above is the f_middle part.------*/\n");
  #endif

  Dump(f_header,f_runtime);
  Dump(f_middle,f_runtime);
  Dump(f_constant, f_runtime);
  Dump(f_variable, f_runtime);
  Dump(f_construct_header, f_runtime);
  Dump(f_construct, f_runtime);
  Dump(f_destruct, f_runtime);
  Dump(f_redefine, f_runtime);
  Dump(f_wrappers,f_runtime);
  
  #ifdef DEBUG
  Printf(f_runtime,"\n/*------ Above is the f_runtime part.------*/\n\n");
  #endif
  
  Delete(f_header);
  Delete(f_wrappers);
  Close(f_runtime);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::Swig_cparm_name_csharp(), modified from Swig_cparm_name() in cwrap.c
 * ----------------------------------------------------------------------------- */

static String *
Swig_cparm_name_csharp(Parm *p, int i) {
  String *name = NewStringf("argp%d",i+1);
  if (p) {
    Setattr(p,"lname",name);
  }
  return name;
}

/* -----------------------------------------------------------------------------
 * CSHARP::Swig_cparm_name_csharp(), modified from Swig_cparm_name() in cwrap.c
 * ----------------------------------------------------------------------------- */
static String *
Swig_cparm_name_csharp_user(Parm *p, int i) {
  String *name = NewStringf("*argp%d",i+1);
  if (p) {
    Setattr(p,"lname",name);
  }
  return name;
}

/* -----------------------------------------------------------------------------
 * CSHARP::Swig_cargs_csharp(), modified from Swig_cargs() in cwrap.c
 * ----------------------------------------------------------------------------- */

static 
int Swig_cargs_csharp(Wrapper *w, ParmList *p) {
  int   i;
  SwigType  *pt;
  String  *lname;
  SwigType  *altty;

  i = 0;
  while (p != 0) {
	  if (i!=0)
		  Printf(w->def,",");
	  pt     = Copy(Getattr(p,"type"));
	  if (SwigType_type(pt) != T_VOID) {
		  /*
		  if (SwigType_type(pt) == T_USER)
		  {
			  lname  = Swig_cparm_name_csharp_user(p,i);
		  } else {
			  lname  = Swig_cparm_name_csharp(p,i);
		  }
		  */
		  lname  = Swig_cparm_name_csharp(p,i);
		  if (SwigType_type(pt) == T_POINTER)
		  {
			  Printf(w->def,"%s",SwigType_str("p.void",lname));
		  } else if (SwigType_type(pt) == T_REFERENCE) {
			  Printf(w->def,"%s",SwigType_str("p.void",lname));
		  } else if (SwigType_type(pt) == T_USER) {
			  Printf(w->def,"%s",SwigType_str("p.void",lname));
		  } else if (SwigType_type(pt) == T_STRING) {
			  Printf(w->def,"String *%s",lname);
		  } else {
			  Printf(w->def,"%s",SwigType_str(pt,lname));
		  }
		  i++;
	  }
	  p = nextSibling(p);
  }
  return(i);
}

/* -----------------------------------------------------------------------------
 * CSHARP::functionWrapper()
 * ----------------------------------------------------------------------------- */
int
CSHARP::functionWrapper(Node *n) {
  
  char   *name  = GetChar(n,"name");
  char   *iname = GetChar(n,"sym:name");
  SwigType *d   = Getattr(n,"type");
  SwigType *d_pointer;
  ParmList *l   = Getattr(n,"parms");

  Parm    *p;
  int     i;
  char    wname[256];
  char    source[64];
  Wrapper *f;
  String *tm;
  String *f_code_tail;

  String *parse_args;
  String *arglist;
  String *cleanup;
  String *get_pointers;
  String *outarg;

  int     num_required;
  int     num_arguments;
  
  f = NewWrapper();
  f_code_tail  = NewString(""); //used for the code part before return
  parse_args   = NewString("");
  arglist      = NewString("");
  cleanup      = NewString("");
  get_pointers = NewString("");
  outarg	   = NewString("");

  //strcpy(wname,Char(Swig_name_wrapper(iname)));
  strcpy(wname,iname);
  String *name_global=NewString("::");
  Append(name_global,iname);
  
  if (SwigType_type(d) == T_USER)
  {
	  String *wname_tmp=NewString("");
	  Append(wname_tmp,"*");
	  Append(wname_tmp,wname);
	  Printf(f->def,"%s (",SwigType_lstr(d,wname_tmp));
	  Wrapper_add_local(f,"resultobj", SwigType_lstr(d,"*resultobj"));
	  Printf(f_header,"\n#include <string.h>;\n//<string.h>, used by user defined structures.\n\n");
	  Delete(wname_tmp);
  } else if (SwigType_type(d) == T_STRING){
	  Printf(f->def,"String *%s (",wname);
	  Wrapper_add_local(f,"resultobj","String *resultobj");
  } else {
	  Printf(f->def,"%s (",SwigType_lstr(d,wname));
  }

  Swig_cargs_csharp(f, l); //emit args into f->def field.
  emit_args(d, l, f);
  emit_attach_parmmaps(l,f);  //used for typemaps

  num_arguments = emit_num_arguments(l);
  num_required  = emit_num_required(l);

  for (i = 0, p=l; i < num_arguments; i++) {
    
    SwigType *pt = Getattr(p,"type");
	String   *ln = Getattr(p,"lname");

    String   *source0,*source1, *lname;
	source0=NewStringf("argp%d",i+1);	//argpi, source_name
	source1=NewStringf("*argp%d",i+1);	//*argpi, source_name_pointer
	lname=NewStringf("arg%d",i+1);	//argi, local_name
    	
	/* Look for an input typemap */
	if ((tm = Getattr(p,"tmap:in")))
	{
		String *parse = Getattr(p,"tmap:in:parse");
		if (!parse) {
			Replaceall(tm,"$source",source0);
			Replaceall(tm,"$target",lname);
			Replaceall(tm,"$input", source0);
			Setattr(p,"emit:input", source0);   /* Save the location of the object */
			if (i >= num_required)
				Printv(get_pointers, "if (", source0, ")\n", 0);
			Printv(get_pointers,tm,"\n", 0);
		} else {
			//Printf(parse_args,"%s",parse);
			/* Add arglist code here */
			//Printf(arglist,"&%s", ln);
		}
		p = Getattr(p,"tmap:in:next");
		continue;
	}
	/* Insert argument output code */
	if ((tm = Getattr(p,"tmap:argout"))) {
      Replaceall(tm,"$source",lname);
      Replaceall(tm,"$target",source0);
      Replaceall(tm,"$arg",source0);
      Replaceall(tm,"$input",source0);
      Printv(outarg,tm,"\n",0);
      //p = Getattr(p,"tmap:argout:next");
	  //continue;
    }

	/* if no input typemap, then use default conversion */
	if (SwigType_type(pt) == T_USER)
	{
		Printf(f->code,"%s=* (%s*) %s;\n",lname,SwigType_lstr(pt,""),source0);
		//user defined structure, argi=* (type *)argpi;\n
		//Printf(f_code_tail,"%s=(void *) %s;\n",source0,lname);
		//argpi=(void *)argi;\n, used for return value
	} else if (SwigType_type(pt) == T_STRING){
		Printf(f->code,"%s=SWIG_Str2Char(%s);\n",lname,source0);
		//string(char*), argi=Str2Char(argpi);\n
		//Printf(f_code_tail,"%s=(String*) %s;\n",source0,lname);
		//argpi=(String *) argi;\n
	} else if (SwigType_type(pt) == T_REFERENCE) {
		Printf(f->code,"%s=(%s) %s;\n",lname,SwigType_lstr(pt,""),source0);
		//argi=(type) argpi;\n
		//Printf(f_code_tail,"%s=(void *) %s;\n",source0,lname);
		//argpi=(void *)argi;\n
	} else if (SwigType_type(pt) == T_POINTER) {
		Printf(f->code,"%s=(%s) %s;\n",lname,SwigType_lstr(pt,""),source0);
		//argi=(type) argpi;\n
		//Printf(f_code_tail,"%s=(void *) %s;\n",source0,lname);
		//argpi=(void *)argi;\n
	} else {
		Printf(f->code,"%s=(%s) %s;\n",lname,SwigType_lstr(pt,""),source0);
		//argi=(type) argpi;\n
	}
	p = nextSibling(p);
  }

  Printv(f->code, parse_args, get_pointers,"\n",0);
  
  /* Insert constraint checking code */
  for (i = 0, p = l; p;i++) {
	  String *lname;
	  lname=NewStringf("argp%d",i+1);	//argi
	  if ((tm = Getattr(p,"tmap:check"))) {
		  Replaceall(tm,"$target",lname);
		  Printv(f->code,tm,"\n",0);
		  p = Getattr(p,"tmap:check:next");
	  } else {
		  p = nextSibling(p);
	  }
  }

  /* Insert cleanup code */
  for (i=0, p = l; p;i++) {
	  String *lname;
	  lname=NewStringf("argp%d",i+1);	//argpi
	  if ((tm = Getattr(p,"tmap:freearg"))) {
		  Replaceall(tm,"$source",lname);
		  Printv(cleanup,tm,"\n",0);
		  p = Getattr(p,"tmap:freearg:next");
	  } else {
		  p = nextSibling(p);
	  }
  }
 
  /* Emit the function call */
  String *action_tmp=NewString(Getattr(n,"wrap:action"));
  Replace(action_tmp,iname,name_global,0);
  Setattr(n,"wrap:action",action_tmp);
  emit_action(n,f);
  Delete(action_tmp);

  Printv(f->code,f_code_tail,"\n",0);
  /* Output argument output code */
  Printv(f->code,outarg,"\n",0);

  if (d && (SwigType_type(d) != T_VOID)) {
	  if (SwigType_type(d) == T_USER)
	  {
		  if (CPlusPlus == 0) {
               Printf(f->code,"\tresultobj =  (%s) malloc(sizeof(%s));\n",
				   SwigType_str(d,"*"),SwigType_str(d,""));
			   Printf(f->code,"\tmemmove(resultobj, &result, sizeof(%s));\n",
				   SwigType_str(d,""));
			   Printf(f->code,"\treturn resultobj;\n}\n");
		  } else {
               Printf(f->code,"\tresultobj =  new %s (result);\n",
				   SwigType_str(d,""));
			   Printf(f->code,"\treturn resultobj;\n}\n");
		  }
	  } else if (SwigType_type(d) == T_STRING){
		  Printf(f->code,"\tresultobj=(String *)result;\n");
		  Printf(f->code,"\treturn resultobj;\n}\n");
	  } else {
		  Printf(f->code,"\treturn result;\n}\n");
	  }
  } else {
	  Printf(f->code,"\treturn ;\n}\n");
  }
  
  Printv(f->def,") {",0);

  /* Dump the function out */
  Wrapper_print(f,f_wrappers);

  Delete(parse_args);
  Delete(arglist);
  Delete(get_pointers);
  //Delete(cleanup);
  //Delete(outarg);
  //Delete(kwargs);
  DelWrapper(f);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::variableWrapper()
 * ----------------------------------------------------------------------------- */
int
CSHARP::variableWrapper(Node *n) {

  char *name  = GetChar(n,"name");
  char *iname = GetChar(n,"sym:name");
  SwigType *t = Getattr(n,"type");

    char   *wname;
    static int have_globals = 0;
    String  *tm;
    Wrapper *getf, *setf;
	String *p_wname,*wname_temp;

    getf = NewWrapper();
    setf = NewWrapper();

    /* If this is our first call, add the globals variable to the
       Csharp dictionary. */

    if (!have_globals) {
      have_globals=1;
    }

	//wname = Char(Swig_name_wrapper(name));
	wname = name;
	p_wname=NewString(""); //*wname, pointer of wname
	Append(p_wname,"*");
	Append(p_wname,wname);

	if (!Strcmp(t,"p.q(const).char")) {
		Printf(f_variable,"\t\tchar const *%s;\n",wname);
		Printf(f_construct, "\t\t\t%s = (char *)::%s;\n",wname,name);

		Printf(setf->def,"void %s_set(", wname);
		if (t && (SwigType_type(t) != T_VOID)) {
			Printf(setf->def,"%s",SwigType_lstr(t,"arg1"));
			Printf(setf->code,"%s = (char *) arg1;\n",wname);
		}
	  
		Printf(getf->def,"%s_get() {", SwigType_lstr(t,wname));
		Printf(getf->code,"\treturn (char *)%s;\n}\n",wname);
	} else if ((SwigType_type(t) != T_POINTER)
		&&(SwigType_type(t) != T_STRING)
		&&(SwigType_type(t) != T_ARRAY)) 
	{
        Printf(f_variable,"\t\t%s;\n",SwigType_lstr(t,p_wname));
		Printf(f_construct, "\t\t\t%s = &::%s;\n",wname,name);

		Printf(setf->def,"void %s_set(", wname);
		if (t && (SwigType_type(t) != T_VOID)) {
			Printf(setf->def,"%s",SwigType_lstr(t,"arg1"));
			Printf(setf->code,"%s = arg1;\n",p_wname);
		}

		Printf(getf->def,"%s_get() {", SwigType_lstr(t,wname));
		Printf(getf->code,"\treturn *%s;\n}\n",wname);
	} else if ( (SwigType_type(t) == T_STRING) || 
		((SwigType_type(t) == T_ARRAY) && (Strstr(t,"char") != NULL)))
	{
		Printf(f_variable,"\t\t%s;\n",SwigType_lstr(t,wname));
		Printf(f_construct, "\t\t\t%s = ::%s;\n",wname,name);

		Printf(setf->def,"void %s_set(", wname);
		if (t && (SwigType_type(t) != T_VOID)) {
			Printf(setf->def,"String *arg1");
			Printf(setf->code,"%s = SWIG_Str2Char(arg1);\n",wname);
		}
		Printf(getf->def,"String *%s_get() {", wname);
		Printf(getf->code,"\treturn (String *)%s;\n}\n",wname);
	} else {
		Printv(f_variable,t,0);
		Printf(f_variable,"\n\t\t%s;\n",SwigType_lstr(t,wname));
		Printf(f_construct, "\t\t\t%s = ::%s;\n",wname,name);

		Printf(setf->def,"void %s_set(", wname);
		if (t && (SwigType_type(t) != T_VOID)) {
			Printf(setf->def,"%s",SwigType_lstr(t,"arg1"));
			Printf(setf->code,"%s = arg1;\n",wname);
		}

		wname_temp=NewString("");
		Append(wname_temp,wname);
		Append(wname_temp,"_get()");
		Printf(getf->def,"%s {", SwigType_lstr(t,wname_temp));
		Printf(getf->code,"\treturn %s;\n}\n",wname);
	}

	Printf(setf->code,"return;\n");    
	Printf(setf->def,") {\n");
	Printf(setf->code,"}\n");
	
	Wrapper_print(setf,f_wrappers);
    Wrapper_print(getf,f_wrappers);

    DelWrapper(setf);
    DelWrapper(getf);
    return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::constantWrapper()
 * ----------------------------------------------------------------------------- */
int
CSHARP::constantWrapper(Node *n) {
  char *name      = GetChar(n,"name");
  char *iname     = GetChar(n,"sym:name");
  SwigType *type  = Getattr(n,"type");
  String   *value = Getattr(n,"value");
  String  *tm;
  int     have_tm = 0;

  /* Special hook for member pointer */
  /*
  if (SwigType_type(type) == T_MPOINTER) {
    String *wname = Swig_name_wrapper(iname);
    Printf(f_header, "static %s = %s;\n", SwigType_str(type,wname), value);
    value = Char(wname);
  }
  */

  Printf(f_constant,"\t\t#undef %s;\n",name);
  if (SwigType_type(type) == T_STRING) {
	  Printf(f_constant, "\t\tconst String *%s;\n",name);
  } else {
	  Printf(f_constant, "\t\tconst %s;\n",SwigType_str(type,name));
  }
 
  if (SwigType_type(type) == T_STRING) {
	  Printf(f_construct_header, "\t\t%s(\"%s\"),\n",name,value);
  } else if (SwigType_type(type) == T_CHAR) {
	  Printf(f_construct_header, "\t\t%s(\'%s\'),\n",name,value);
  } else {
	  Printf(f_construct_header, "\t\t%s(%s),\n",name,value);
  }

  if (SwigType_type(type) == T_STRING) {
	  Printf(f_redefine, "\t\t#define %s \"%s\"\n",name,value);
  } else if (SwigType_type(type) == T_CHAR) {
	  Printf(f_redefine, "\t\t#define %s \'%s\'\n",name,value);
  } else {
	  Printf(f_redefine, "\t\t#define %s %s\n",name,value);
  }
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::nativeWrapper()
 * ----------------------------------------------------------------------------- */

int
CSHARP::nativeWrapper(Node *n) {
  char *name     = GetChar(n,"sym:name");
  char *wrapname = GetChar(n,"wrap:name");
  add_method(name, wrapname,0);
  /*shadow code delete here. */
  return SWIG_OK;
}

/* C++ Support + Shadow Classes */

static  int       have_constructor;
static  int       have_repr;
static  String   *real_classname;

/* -----------------------------------------------------------------------------
 * classforwardDeclaration()
 * ----------------------------------------------------------------------------- */

int
CSHARP::classforwardDeclaration(Node *n) {
  String *importname;
  /* shadow code delete here. */
  return Language::classforwardDeclaration(n);
}

/* -----------------------------------------------------------------------------
 * CSHARP::classHandler()
 * ----------------------------------------------------------------------------- */

int
CSHARP::classHandler(Node *n) {
  /* shadow code deleted here. */
  /* Emit all of the members */
  Language::classHandler(n);

  /* Complete the class */
  /* shadow code deleted here. */
  return SWIG_OK;
}


/* -----------------------------------------------------------------------------
 * CSHARP::memberfunctionHandler()
 * ----------------------------------------------------------------------------- */
int
CSHARP::memberfunctionHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow;

  /* Create the default member function */
  oldshadow = shadow;    /* Disable shadowing when wrapping member functions */
  /* shadow code deleted here. */
  Language::memberfunctionHandler(n);
  shadow = oldshadow;

/* shadow code deleted here. */  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::constructorDeclaration()
 * ----------------------------------------------------------------------------- */
int
CSHARP::constructorHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow = shadow;

  /* shadow code deleted here. */
  Language::constructorHandler(n);
  shadow = oldshadow;

  /* shadow code deleted here. */
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::cpp_destructor()
 * ----------------------------------------------------------------------------- */
int
CSHARP::destructorHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int oldshadow = shadow;

  /* shadow code deleted here. */
  Language::destructorHandler(n);
  shadow = oldshadow;
  /* shadow code deleted here. */
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::membervariableHandler()
 * ----------------------------------------------------------------------------- */
int
CSHARP::membervariableHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");

  int   oldshadow = shadow;
  /* shadow code deleted here. */
  Language::membervariableHandler(n);
  shadow = oldshadow;

  /* shadow code deleted here. */
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::memberconstantHandler()
 * ----------------------------------------------------------------------------- */
int
CSHARP::memberconstantHandler(Node *n) {
  char *symname = GetChar(n,"sym:name");
  int   oldshadow = shadow;
  /* shadow code deleted here. */
  Language::memberconstantHandler(n);
  shadow = oldshadow;

  /* shadow code deleted here. */
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * CSHARP::csharpcode()     - Output csharp code into the shadow file
 * ----------------------------------------------------------------------------- */

String *
CSHARP::csharpcode(String *code, const String *indent) {
  String *out = NewString("");
  String *temp;
  char   *t;
  if (!indent) indent = "";

  temp = NewString(code);

  t = Char(temp);
  if (*t == '{') {
    Delitem(temp,0);
    Delitem(temp,DOH_END);
  }
  /* Split the input text into lines */
  List *clist = DohSplit(temp,"\n",-1);
  Delete(temp);
  int   initial = 0;
  String *s;

  /* Get the initial indentation */
  for (s = Firstitem(clist); s; s = Nextitem(clist)) {
    if (Len(s)) {
      char *c = Char(s);
      while (*c) {
	if (!isspace(*c)) break;
	initial++;
	c++;
      }
      break;
    }
  }
  while (s) {
    if (Len(s) > initial) {
      char *c = Char(s);
      c += initial;
      Printv(out,indent,c,"\n",0);
    } else {
      Printv(out,"\n",0);
    }
    s = Nextitem(clist);
  }
  Delete(clist);
  return out;
}

/* ----------------------------------------------------------------------------- 
 * insertDirective()
 * 
 * Hook for %insert directive.   We're going to look for special %shadow inserts
 * as a special case so we can do indenting correctly
 * ----------------------------------------------------------------------------- */

int CSHARP::insertDirective(Node *n) {
  String *code = Getattr(n,"code");
  String *section = Getattr(n,"section");

  if ((!ImportMode) && (Cmp(section,"shadow") == 0)) {
      /* shadow code deleted here. */

  } else {
    Language::insertDirective(n);
  }
  return SWIG_OK;
}
