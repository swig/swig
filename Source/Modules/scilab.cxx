/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * scilab.cxx
 *
 * Scilab language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_scilab_cxx[] = "$Id$";

#include "swigmod.h"

static const char *usage = (char *) "\
Scilab Options (available with -scilab)\n\
     (none yet)\n\n";


class SCILAB:public Language {

private:
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  
  String *f_builder_code;
  String *f_example_code;

  bool hasfunction_flag;
  bool hasconstant_flag;
 
public:
  SCILAB():
    f_builder_code(NewString("")), f_example_code(NewString("")), hasfunction_flag(false), hasconstant_flag(false) {
  }
  
    
  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */
  
  virtual void main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  fputs(usage, stderr);
	}
      }
    }
    
    /* Set language-specific subdirectory in SWIG library */ 
    SWIG_library_directory("scilab");
   
    /* Add a symbol to the parser for conditional compilation */
    Preprocessor_define("SWIGSCILAB 1", 0);
    
    /* Set scilab configuration file */
    SWIG_config_file("scilab.swg");
    
    /* Set typemap for scilab */
    SWIG_typemap_lang("scilab");
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {
    
    /* Get the name of the module */ 
    String *module = Getattr(n, "name");
    
    /* One output file for as the wrapper file */
    String *outfile = Getattr(n, "outfile");
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    
    /* Initialize the output files */
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
     }
    f_runtime = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");
    
    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);
     
    /* Insert the banner at the beginning */
    Swig_banner(f_begin);

    /* Include some header file of scilab */
    Printf(f_runtime, "#include \"stack-c.h\"\n");
    Printf(f_runtime, "#include \"sciprint.h\"\n");
    Printf(f_runtime, "#include \"Scierror.h\"\n");
    Printf(f_runtime, "#include \"api_variable.h\"\n");
    Printf(f_runtime, "#include \"localization.h\"\n");
    
    /* Initialize the builder.sce file code */
    Printf(f_builder_code,"ilib_name = \"%slib\";\n",module);
    Printf(f_builder_code,"files = [\"%s\",\"%s.o\"];\n", outfile,module);
    Printf(f_builder_code,"libs = [];\n");
    Printf(f_builder_code, "table = ["); 
    
    /* Emit code for children */
    Language::top(n);
    
    /* create the file to generate the module: "builder.sce" */
    if(hasfunction_flag) {
      Printf(f_builder_code,"];\n");
      Printf(f_builder_code,"ilib_build(ilib_name,table,files,libs);");
      File *f_builder=NewFile(NewStringf("%s%s_builder.sce",SWIG_output_directory(),module),"w",SWIG_output_files());
      Printv(f_builder,f_builder_code,NIL);
      Close(f_builder);
      Delete(f_builder);
      Delete(f_builder_code);
    }
    else {
      Delete(f_builder_code);
    }
    
    /* create the file for constants: "module.sce" */
    if(hasconstant_flag) {
      File *f_example=NewFile(NewStringf("%s%s.sce",SWIG_output_directory(),module),"w",SWIG_output_files());
      Printv(f_example,f_example_code,NIL);
      Close(f_example); 
      Delete(f_example);
      Delete(f_example_code);
    }
    else {
      Delete(f_example_code);
    }
    
    /* Dump out all the files */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);
    
    /* Close all of the files */
    Delete(f_init);
    Delete(f_wrappers);
    Delete(f_header);
    Delete(f_runtime);
    Close(f_begin);
    Delete(f_begin);
    
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    
    hasfunction_flag = true;
    
    /* A new wrapper function object */
    Wrapper *f = NewWrapper();
    Parm *p;
    String *tm;
    int j;

    /* Get the useful information from the node */
    String *nodeType = Getattr(n, "nodeType");
    int constructor = (!Cmp(nodeType, "constructor"));
    // int destructor = (!Cmp(nodeType, "destructor"));
    String *storage = Getattr(n, "storage");
    bool overloaded = !!Getattr(n, "sym:overloaded");
    //bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
    String *iname = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(iname);
    String *overname = Copy(wname);
    SwigType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");

    if (!overloaded && !addSymbol(iname, n))
      return SWIG_ERROR;

    if (overloaded)
      Append(overname, Getattr(n, "sym:overname"));

    Printv(f->def, "int ", overname, " (char *fname,unsigned long fname_len) {\n", NIL);
   
    /* Emit all of the local variables for holding arguments */
    emit_parameter_variables(l, f);
    
    /* Attach typemaps to the parameter list */
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);
     
    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    
    /* the number of the output */
    int out_required = 0;
    //int varargs = emit_isvarargs(l);
   
    
    if (constructor && num_arguments == 1 && num_required == 1) {
      if (Cmp(storage, "explicit") == 0) {
	Node *parent = Swig_methodclass(n);
	if (GetFlag(parent, "feature:implicitconv")) {
	  String *desc = NewStringf("SWIGTYPE%s", SwigType_manglestr(Getattr(n, "type")));
	  Printf(f->code, "if (SWIG_CheckImplicit(%s)) SWIG_fail;\n", desc);
	  Delete(desc);
	}
      }
    }
  
    /* Walk the function parameter list and generate code to get arguments */
    for (j = 0, p = l; j < num_arguments; ++j) {
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");

      /* Get typemap for this argument */
      String *tm = Getattr(p, "tmap:in");
       
      if (tm) {
	if (!tm || checkAttribute(p, "tmap:in:numinputs", "0")) {
	  p = nextSibling(p);
	  continue;
	}
       String *getargs = NewString("");
       Printv(getargs, tm, NIL);
       Printv(f->code, getargs, "\n", NIL);
       Delete(getargs);
       p = Getattr(p, "tmap:in:next");
	continue;
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	break;
      }
    }
    
    Setattr(n, "wrap:name", overname);   
   
    /* Now write code to make the function call */
    Swig_director_emit_dynamic_cast(n, f);
    String *actioncode = emit_action(n);
    
    /* Insert the return variable */ 
    emit_return_variable(n, d, f);

    if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
      Replaceall(tm, "$result", "result");
      if(out_required>0)
        Printf(f->code,"iOutNum++;\niVarOut++;\n");
      Printf(f->code, "%s\n", tm);
      if(strlen(Char(tm))!=0)
        out_required++;
    } 
    else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), iname);
    }
    
    /* Insert argument output code */
    String *outarg = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	if(out_required>0)
           Printf(f->code,"iOutNum++;\niVarOut++;\n");
        Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
        out_required++;
      } else {
	p = nextSibling(p);
      }
    }
    Printv(f->code, outarg, NIL);

    /* Insert cleanup code */
    String *cleanup = NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	if (tm && (Len(tm) != 0)) {
	  Printv(cleanup, tm, "\n", NIL);
	}
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }
  
    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Insert the code checking for the number of input and output */
    int flag;
    if(out_required == 0) {
      out_required = 1;
      flag = 0;
    }
    else {
      flag = 1;
    }
    Printf(f->def, "CheckRhs(%d, %d);\n",num_required,num_required);
    Printf(f->def, "CheckLhs(%d, %d);\n",out_required,out_required);
   
    /* Insert the order of output parameters*/
    if(flag)
      Printf(f->def, "\nint iOutNum = 1;\nint iVarOut = Rhs + 1;");
   
    /* Finish the the code for the function  */
    Printf(f->code, "return 0;\n");	
    Printf(f->code, "}\n");

    Replaceall(f->code, "$symname", iname);
    
    /* Dump the wrapper function */
    Wrapper_print(f, f_wrappers);
    DelWrapper(f);
    Printf(f_builder_code, "\"%s\",\"%s\";", iname, wname);

    Delete(overname);
    Delete(wname);
    Delete(outarg);
  
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    
    hasfunction_flag = true;
    
    /* Get the useful information from the node */
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    
    if (!addSymbol(iname, n))
      return SWIG_ERROR;
    
    String *rowname = NewString("");
    String *colname = NewString("");
    String *iscomplexname = NewString("");
    Printf(rowname, "iRows_%s", iname);
    Printf(colname, "iCols_%s", iname);
    Printf(iscomplexname, "isComplex_%s", iname);
    
    /* two wrapper function to get and set the variable */
    String *tm;
    String *globalVar = NewString("");
    Wrapper *getf = NewWrapper();
    Wrapper *setf = NewWrapper();

    String *getname = Swig_name_get(iname);
    String *setname = Swig_name_set(iname);
    
    Printf(globalVar, "int %s = 0;\n", rowname);
    Printf(globalVar, "int %s = 0;\n", colname);
    if(!Strcmp(t, "p.double"))
      Printf(globalVar, "int %s = 0;\n\n", iscomplexname);
    else
      Printf(globalVar, "\n");
    Printv(setf->def, "int ", setname, " (char *fname,unsigned long fname_len) {\n", NIL);
    
    /* Check the number of input and output */
    Printf(setf->def, "CheckRhs(1,1);\n");
    Printf(setf->def, "CheckLhs(1,1);\n");
    
    /* add the local variable */
    Wrapper_add_local(setf, "piAddrVar", "int *piAddrVar");
   
    /* deal with the set function */
    if (is_assignable(n)) {
      Setattr(n, "wrap:name", setname);
      if (Getattr(n, "unnamedinstance"))
        Setattr(n, "type", "int");
      if ((tm = Swig_typemap_lookup("varin", n, name, 0))) {
	Replaceall(tm, "$argnum", "1");
        Replaceall(tm, "iRows", rowname);
        Replaceall(tm, "iCols", colname);
        Replaceall(tm, "isComplex", iscomplexname);
	emit_action_code(n, setf->code, tm);
	Delete(tm);
      } else {
	Swig_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, "Unable to set variable of type %s.\n", SwigType_str(t, 0));
      }
    } 
    else {
      Append(setf->code, "SWIG_Error(999, \"attempt to set immutable member variable\");");
    }
    Append(setf->code, "}\n");
    Wrapper_print(setf, f_wrappers);
    Printf(f_builder_code, "\"%s\",\"%s\";", setname, setname);
    
    /* deal with the get function */
    Setattr(n, "wrap:name", getname);
    int addfail = 0;
    Printv(getf->def, "int ", getname, " (char *fname,unsigned long fname_len){\n", NIL);
   
    /* Check the number of input and output */
    Printf(getf->def, "CheckRhs(0, 0);\n");
    Printf(getf->def, "CheckLhs(1, 1);\n");
    
    /* Insert the order of output parameters*/
    Printf(getf->def, "\nint iOutNum=1;\nint iVarOut=Rhs+1;");
   
    if ((tm = Swig_typemap_lookup("varout", n, name, 0))) {
      Replaceall(tm, "$result", name);
      if (is_assignable(n)) {
        Replaceall(tm, "iRowsOut", rowname);
        Replaceall(tm, "iColsOut", colname);
      } else {
        Replaceall(tm, "iRowsOut", "1");
        Replaceall(tm, "iColsOut", "1");
      }
      Replaceall(tm, "isComplex", iscomplexname); 
      addfail = emit_action_code(n, getf->code, tm);
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, "Unable to read variable of type %s\n", SwigType_str(t, 0));
    }
   
    /*Dump the wrapper function */ 
    Append(getf->code, "}\n");
    Wrapper_print(getf, f_wrappers);
    Printf(f_header,"%s", globalVar);
    Printf(f_builder_code, "\"%s\",\"%s\";", getname, getname);
    
    Delete(rowname);
    Delete(colname);
    Delete(iscomplexname);
    Delete(globalVar);
    DelWrapper(setf);
    DelWrapper(getf);
    

    return SWIG_OK;
   }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ----------------------------------------------------------------------- */

  virtual int constantWrapper(Node *n) {
    
    /* set the flag so to generate the example.sce */
    hasconstant_flag = true;
   
    /* Get the useful information from the node */
    String *iname = Getattr(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tempvalue = NewString("");
    
    /* set the value format to be  the scilab format */
    if (!Strcmp(type, "char")) {
      value = Getattr(n, "rawvalue");
      char *temp = (Char(value));
      tempvalue = NewString("ascii");
      Printf(tempvalue, "(%i)", (int)*temp);
      value = Copy(tempvalue);
      Delete(tempvalue);
    } 
    else {
      if (!Strcmp(type, "p.char")) {
        char *temp = (Char(value));
        int len = strlen(temp);
        for (int i = 0; i < len; ++i) {
          if (temp[i] == '\\') {
            temp[i] = '"';
            ++i;
          }
        }
        Printf(tempvalue, "%s",temp);
        value = Copy(tempvalue);
      }
      Delete(tempvalue);
    }
    
    /* write into the code string */
    Printf(f_example_code, "%s = %s\n", iname, value);
    
    return SWIG_OK;
  }
  
  /* ---------------------------------------------------------------------
   * enumDeclaration()
   * --------------------------------------------------------------------- */
  
  virtual int enumDeclaration(Node *n) {
    
    /* set the flag so to generate the example.sce */
    hasconstant_flag = true;
    return Language::enumDeclaration(n);
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */
  
  virtual int enumvalueDeclaration(Node *n) {
    
    /* get the name of the enumvalue */
    String *iname = Getattr(n, "sym:name");
    
    /* get the name of the enum name */
    String *parentName = Getattr(parentNode(n), "sym:name");
    
    /* set the name to be the enum.enumvalue format */
    if (parentName) {
      /*if the enum has a name*/
      if(!Getattr(parentNode(n), "unnamedinstance")) {
        String *temp = Copy(parentName);
        Printf(temp, ".%s", iname);
        Setattr(n, "sym:name", temp);
        Delete(temp);
        iname = Getattr(n, "sym:name");
      }
    }
    
    /* set the value attribute to be the integer */
    String *value;
    String *enumvalue = Getattr(n, "enumvalue");
    if (enumvalue) {
      if (Len(enumvalue) == 1) {
        char *temp = (Char(enumvalue));
        /*set the value of char into the format of integer*/
        if (((*temp <= 'z') && (*temp >= 'a')) || ((*temp <= 'Z') && (*temp >= 'A'))) {
          String *tempInteger = NewString("");
          Printf(tempInteger, "%i", int(*temp));
          Setattr(n, "value", tempInteger);
          Delete(tempInteger);
        }
        else {
          Setattr(n, "value", enumvalue);
        }
      }
      else {
        Setattr(n, "value", enumvalue);
      }
    }
    else {
      if (n != firstChild(parentNode(n))) {
        enumvalue = Getattr(n, "enumvalueex");
        if (parentName) {
          if (!Getattr(parentNode(n), "unnamedinstance")) {
            String *temp = Copy(parentName); 
            Printf(temp, ".%s", enumvalue); 
            enumvalue = Copy(temp);
          }
        }
        Setattr(n, "value", enumvalue);
      }
      else {
        Setattr(n, "value", Getattr(n, "enumvalueex"));
      }
    }
    value = Getattr(n, "value");
    
    /* write into the code string */
    Printf(f_example_code, "%s = %s;\n", iname, value);
    return SWIG_OK;
    }
};

extern "C" Language *swig_scilab(void) {
  return new SCILAB();
}
