
/* ----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * scilab.cxx
 *
 * Scilab language module for SWIG.
 * --------------------------------------------------------------------------*/

#include "swigmod.h"

/*#define SWIG_DEBUG*/

static const char *usage = (char*) "\
Scilab options\n\
     -addsrc <source files>  additionnal source files (separated by space) to include in build script (ex: myfile.cxx myfile2.cxx)\n\
     -addcflag -I<path>      additionnal include path to include in build script (ex: -I/usr/includes/)\n\
     -addldlag <flag>        additionnal link flag to include in build script (ex: -lm)\n\n";

const char* SWIG_INIT_FUNCTION_NAME = "SWIG_Init";

class SCILAB : public Language {
protected:
  /* General objects used for holding the strings */
  File *beginSection;
  File *runtimeSection;
  File *headerSection;
  File *wrappersSection;
  File *initSection;

  File *builderFile;
  String *builderCode;
  int builderFunctionCount;

  List *sourceFileList;
  String *cflag;
  String *ldflag;

public:
  /* ------------------------------------------------------------------------
   * main()
   * ----------------------------------------------------------------------*/
  virtual void main(int argc, char* argv[]) {

    sourceFileList = NewList();
    ldflag = NULL;
    cflag = NULL;

    /* Manage command line arguments */
    for (int argIndex = 1; argIndex < argc; argIndex++) {
      if (argv[argIndex] != NULL) {
        if (strcmp(argv[argIndex], "-help") == 0) {
          /* Display message */
          fputs(usage, stderr);
          /* Indicate arg as valid */
          Swig_mark_arg(argIndex);
        } else if (strcmp(argv[argIndex], "-addsrc") == 0) {
          if (argv[argIndex+1] != NULL) {
            Swig_mark_arg(argIndex);
            char *sourceFile = strtok(argv[argIndex+1], " ");
            while (sourceFile != NULL)
            {
              DohInsertitem(sourceFileList, Len(sourceFileList), sourceFile);
              sourceFile = strtok(NULL, " ");
            }
            Swig_mark_arg(argIndex+1);
          }
        } else if (strcmp(argv[argIndex], "-addcflag") == 0) {
          Swig_mark_arg(argIndex);
          if (argv[argIndex+1] != NULL) {
            cflag = NewString(argv[argIndex+1]);
            Swig_mark_arg(argIndex+1);
          }
        } else if (strcmp(argv[argIndex], "-addldflag") == 0) {
          Swig_mark_arg(argIndex);
          if (argv[argIndex+1] != NULL) {
            ldflag = NewString(argv[argIndex+1]);
            Swig_mark_arg(argIndex+1);
          }
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

    allow_overloading();
  }

  /* ------------------------------------------------------------------------
   * top()
   * ----------------------------------------------------------------------*/
  virtual int top(Node *node) {

    /* Get the module name */
    String* moduleName = Getattr(node, "name");

    /* Get the output file name */
    String* outputFilename = Getattr(node, "outfile");

    /* Initialize I/O */
    beginSection = NewFile(NewStringf("%s%s", SWIG_output_directory(), outputFilename), "w", SWIG_output_files());
    if (!beginSection) {
      FileErrorDisplay(outputFilename);
      SWIG_exit(EXIT_FAILURE);
    }
    runtimeSection = NewString("");
    initSection = NewString("");
    headerSection = NewString("");
    wrappersSection = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", beginSection);
    Swig_register_filebyname("header", headerSection);
    Swig_register_filebyname("wrapper", wrappersSection);
    Swig_register_filebyname("runtime", runtimeSection);
    Swig_register_filebyname("init", initSection);

    /* Output module initialization code */
    Swig_banner(beginSection);

    /* Initialize builder.sce contents */
    builderFunctionCount = 0;
    builderCode = NewString("");
    Printf(builderCode, "mode(-1);\n");
    Printf(builderCode, "lines(0);\n"); /* Useful for automatic tests */
    #ifdef SWIG_DEBUG
      Printf(builderCode, "try\n");
      Printf(builderCode, "ilib_verbose(1);\n");
    #else
      Printf(builderCode, "ilib_verbose(0);\n");
    #endif
    Printf(builderCode, "ilib_name = \"%slib\";\n", moduleName);

    Printf(builderCode, "libs = [];\n");
    if (ldflag != NULL) {
      Printf(builderCode, "ldflags = \"%s\";\n", ldflag);
    } else {
      Printf(builderCode, "ldflags = \"\";\n");
    }

    Printf(builderCode, "cflags = [\"-g -I\" + get_absolute_file_path(\"builder.sce\")];\n");
    if (cflag != NULL) {
      Printf(builderCode, "includepath = \"%s\";\n", cflag);
      Printf(builderCode, "includepath = fullpath(part(includepath, 3:length(includepath)));\n");
      Printf(builderCode, "cflags = cflags + \" -I\" + includepath;\n");
    }

    DohInsertitem(sourceFileList, 0, outputFilename);
    for (int i=0; i<Len(sourceFileList); i++)
    {
      String* sourceFile = Getitem(sourceFileList, i);
      if (i==0)
      {
          Printf(builderCode, "files = \"%s\";\n", sourceFile);
      }
      else
      {
          Printf(builderCode, "files($ + 1) = \"%s\";\n", sourceFile);
      }
    }

    Printf(builderCode, "table = [");

    /* In C++ mode, add initialization function to builder table */
    if (CPlusPlus) {
      Printf(builderCode, "\"%s\",\"%s\";", SWIG_INIT_FUNCTION_NAME, SWIG_INIT_FUNCTION_NAME);
    }

    /* Emit code for children */
    if (CPlusPlus) {
      Printf(wrappersSection, "extern \"C\" {\n");
    }

    Language::top(node);

    if (CPlusPlus) {
      Printf(wrappersSection, "}\n");
    }

    /* Write all to the builder.sce file */
    Printf(builderCode, "];\n");
    Printf(builderCode, "if ~isempty(table) then\n");
    Printf(builderCode, "  ilib_build(ilib_name, table, files, libs, [], ldflags, cflags);\n");
    Printf(builderCode, "end\n");
    #ifdef SWIG_DEBUG
      Printf(builderCode, "catch\n");
      Printf(builderCode, "  printf(\"\"*** builder.sce file execution FAILED ***\"\");\n");
      Printf(builderCode, "end\n");
    #endif
    Printf(builderCode, "exit");
    builderFile = NewFile(NewStringf("%sbuilder.sce", SWIG_output_directory()), "w", SWIG_output_files());
    Printv(builderFile, builderCode, NIL);
    Delete(builderFile);

    /* Close the init function (opened in sciinit.swg) */
    Printf(initSection, "return 0;\n}\n#endif\n");

    /* Write all to the wrapper file */
    SwigType_emit_type_table(runtimeSection, wrappersSection); // Declare pointer types, ... (Ex: SWIGTYPE_p_p_double)
    Dump(runtimeSection, beginSection);
    Dump(headerSection, beginSection);
    Dump(wrappersSection, beginSection);
    Wrapper_pretty_print(initSection, beginSection);

    /* Cleanup files */
    Delete(runtimeSection);
    Delete(headerSection);
    Delete(wrappersSection);
    Delete(initSection);
    Delete(beginSection);

    Delete(sourceFileList);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------------------
   * functionWrapper()
   * ----------------------------------------------------------------------*/
  virtual int functionWrapper(Node *node) {

    /* Get some useful attributes of this function */
    String *functionName = Getattr(node, "sym:name");
    SwigType *functionReturnType = Getattr(node, "type");
    ParmList *functionParamsList = Getattr(node, "parms");

    int paramIndex = 0; // Used for loops over ParmsList
    Parm *param = NULL; // Used for loops over ParamsList

    /* Create the wrapper object */
    Wrapper *wrapper = NewWrapper();

    /* Create the function wrapper name */
    String *wrapperName = Swig_name_wrapper(functionName);

    /* Deal with overloading */
    String *overloadedName = Copy(wrapperName);
    /* Determine whether the function is overloaded or not */
    bool isOverloaded = !!Getattr(node, "sym:overloaded");
    /* Determine whether the function is the last overloaded */
    bool isLastOverloaded = isOverloaded && !Getattr(node, "sym:nextSibling");

    if (!isOverloaded && !addSymbol(functionName, node)) {
        return SWIG_ERROR;
    }

    if (isOverloaded) {
        Append(overloadedName, Getattr(node, "sym:overname"));
    }

    /* Write the wrapper function definition (standard Scilab gateway function prototype) */
    Printv(wrapper->def, "int ", overloadedName, "(char *fname, unsigned long fname_len) {", NIL);

    /* Emit all of the local variables for holding arguments */
    // E.g.: double arg1;
    emit_parameter_variables(functionParamsList, wrapper);

    /* Attach typemaps to the parameter list */
    // Add local variables used in typemaps (iRows, iCols, ...)
    emit_attach_parmmaps(functionParamsList, wrapper);
    Setattr(node, "wrap:parms", functionParamsList);

    /* Check arguments */
    int maxInputArguments = emit_num_arguments(functionParamsList);
    int minInputArguments = emit_num_required(functionParamsList);
    int minOutputArguments = 0;
    int maxOutputArguments = 0;
    /* Insert calls to CheckInputArgument and CheckOutputArgument */
    Printf(wrapper->code, "CheckInputArgument(pvApiCtx, $mininputarguments, $maxinputarguments);\n");
    Printf(wrapper->code, "CheckOutputArgument(pvApiCtx, $minoutputarguments, $maxoutputarguments);\n");
    Printf(wrapper->code, "SWIG_Scilab_SetFname(fname);\n");

    for (paramIndex = 0, param = functionParamsList; paramIndex < maxInputArguments; ++paramIndex) {

      // Ignore parameter if the typemap specifies numinputs=0
      while (checkAttribute(param, "tmap:in:numinputs", "0")) {
        param = Getattr(param, "tmap:in:next");
      }

      SwigType *paramType = Getattr(param, "type");
      String *paramTypemap = Getattr(param, "tmap:in");

      if (paramTypemap) {
        // Replace $input by the position on Scilab stack
        char source[64];
        sprintf(source, "%d", paramIndex + 1);
        Setattr(param, "emit:input", source);
        Replaceall(paramTypemap, "$input", Getattr(param, "emit:input"));

        if (Getattr(param, "wrap:disown") || (Getattr(param, "tmap:in:disown"))) {
          Replaceall(paramTypemap, "$disown", "SWIG_POINTER_DISOWN");
        } else {
          Replaceall(paramTypemap, "$disown", "0");
        }

        if (paramIndex >= minInputArguments) { /* Optional input argument management */
          Printf(wrapper->code, "if (Rhs > %d) {\n%s\n}\n", paramIndex, paramTypemap);
        } else {
          Printf(wrapper->code, "%s\n", paramTypemap);
        }
        // Delete(paramTypemap); // Make SWIG crash with 'class' example
        param = Getattr(param, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(paramType, 0));
        break;
      }
    }

    /* Write typemaps(in) */

    /* Write constraints */

    Setattr(node, "wrap:name", overloadedName);

    /* Emit the function call */
    Swig_director_emit_dynamic_cast(node, wrapper);
    String *functionActionCode = emit_action(node); /* Function code with standard args names (arg1, ...) */

    /* Insert the return variable */
    emit_return_variable(node, functionReturnType, wrapper);

    /* Return the function value if necessary */
    String *functionReturnTypemap = Swig_typemap_lookup_out("out", node, "result", wrapper, functionActionCode);
    if (functionReturnTypemap) {
      // Result is actually the position of output value on stack
      if (Len(functionReturnTypemap) > 0) {
        Printf(wrapper->code, "SWIG_Scilab_SetOutputPosition(%d); /* functionReturnTypemap */ \n", 1);
      }
      Replaceall(functionReturnTypemap, "$result", "1");

      if (GetFlag(node, "feature:new")) {
        Replaceall(functionReturnTypemap, "$owner", "1");
      } else {
        Replaceall(functionReturnTypemap, "$owner", "0");
      }

      Printf(wrapper->code, "%s\n", functionReturnTypemap);

      /* If the typemap is not empty, the function return one more argument than the typemaps gives */
      if (Len(functionReturnTypemap) > 0) {
        minOutputArguments++;
        maxOutputArguments++;
      }

      //Delete(functionReturnTypemap); // Makes SWIG crash on vararg test case.

    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(functionReturnType, 0), functionName);
    }

    /* Write typemaps(out) */
    for (param = functionParamsList; param;) {
      String *paramTypemap = Getattr(param, "tmap:argout");
      if (paramTypemap) {
        minOutputArguments++;
        maxOutputArguments++;
        Printf(wrapper->code, "SWIG_Scilab_SetOutputPosition(%d); /* paramTypemap */ \n", minOutputArguments);
        char result[64] = {};
        sprintf(result, "%d", minOutputArguments);
        Replaceall(paramTypemap, "$result", result);
        Printf(wrapper->code, "%s\n", paramTypemap);
        Delete(paramTypemap);
        param = Getattr(param, "tmap:argout:next");
      } else {
        param = nextSibling(param);
      }
    }
    /* Add cleanup code */
    for (param = functionParamsList; param;) {
      String *tm;
      if ((tm = Getattr(param, "tmap:freearg"))) {
		if (tm && (Len(tm) != 0)) {
		  Replaceall(tm, "$source", Getattr(param, "lname"));
          Printf(wrapper->code, "%s\n", tm);
	      Delete(tm);
		}
		param= Getattr(param, "tmap:freearg:next");
      } else {
		param = nextSibling(param);
      }
    }


    /* Close the function(ok) */
    Printv(wrapper->code, "return SWIG_OK;\n", NIL);
    Printv(wrapper->code, "}\n", NIL);

    /* Add the failure cleanup code */
    /* TODO */

    /* Final substititions if applicable */
    Replaceall(wrapper->code, "$symname", functionName);

    /* Set CheckInputArgument and CheckOutputArgument input arguments */
    /* In Scilab there is always one output even if not defined */
    if (minOutputArguments == 0) {
      maxOutputArguments = 1;
    }
    char argnumber[64] = {};
    sprintf(argnumber, "%d", minInputArguments);
    Replaceall(wrapper->code, "$mininputarguments", argnumber);
    sprintf(argnumber, "%d", maxInputArguments);
    Replaceall(wrapper->code, "$maxinputarguments", argnumber);
    sprintf(argnumber, "%d", minOutputArguments);
    Replaceall(wrapper->code, "$minoutputarguments", argnumber);
    sprintf(argnumber, "%d", maxOutputArguments);
    Replaceall(wrapper->code, "$maxoutputarguments", argnumber);

    /* Dump the function out */
    Wrapper_print(wrapper, wrappersSection);

    /* Update builder.sce contents */
    if (isLastOverloaded) {
        addFunctionInBuilder(functionName, wrapperName);
        dispatchFunction(node);
    }

    if (!isOverloaded) {
        addFunctionInBuilder(functionName, wrapperName);
    }

    /* tidy up */
    Delete(overloadedName);
    Delete(wrapperName);
    DelWrapper(wrapper);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * dispatchFunctionWrapper()
   * ----------------------------------------------------------------------- */
  void dispatchFunction(Node *node) {
    Wrapper *wrapper = NewWrapper();

    String *functionName = Getattr(node, "sym:name");
    String *wrapperName = Swig_name_wrapper(functionName);
    int maxargs = 0;

    /* Generate the dispatch function */
    String *dispatch = Swig_overload_dispatch(node, "return %s(fname, fname_len);", &maxargs);
    String *tmp = NewString("");

    Printv(wrapper->def, "int ", wrapperName, " (char *fname, unsigned long fname_len) {\n", NIL);

    /* Get the number of the parameters */
    Wrapper_add_local(wrapper, "argc", "int argc = Rhs");
    Printf(tmp, "int argv[%d] = {", maxargs);
    for (int j = 0; j < maxargs; ++j) {
      Printf(tmp, "%s%d", j ? "," : " ", j + 1);
    }
    Printf(tmp, "}");
    Wrapper_add_local(wrapper, "argv", tmp);

    /* Dump the dispatch function */
    Printv(wrapper->code, dispatch, "\n", NIL);
    Printf(wrapper->code, "Scierror(999, _(\"No matching function for overload\"));\n");
    Printf(wrapper->code, "return SWIG_OK;\n");
    Printv(wrapper->code, "}\n", NIL);
    Wrapper_print(wrapper, wrappersSection);

    Delete(tmp);
    DelWrapper(wrapper);
    Delete(dispatch);
    Delete(wrapperName);
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */
  virtual int variableWrapper(Node *node) {

    /* Get information about variable */
    String *origVariableName = Getattr(node, "name"); // Ex: Shape::nshapes
    String *variableName = Getattr(node, "sym:name"); // Ex; Shape_nshapes (can be used for function names, ...)

    /* Manage GET function */
    Wrapper *getFunctionWrapper = NewWrapper();
    String *getFunctionName = Swig_name_get(NSPACE_TODO, variableName);

    Setattr(node, "wrap:name", getFunctionName);
    Printv(getFunctionWrapper->def, "int ", getFunctionName, "(char *fname, unsigned long fname_len) {\n", NIL);

    /* Check the number of input and output */
    Printf(getFunctionWrapper->def, "CheckInputArgument(pvApiCtx, 0, 0);\n");
    Printf(getFunctionWrapper->def, "CheckOutputArgument(pvApiCtx, 1, 1);\n");

    String *varoutTypemap = Swig_typemap_lookup("varout", node, origVariableName, 0);
    if (varoutTypemap != NULL) {
      Printf(getFunctionWrapper->code, "SWIG_Scilab_SetOutputPosition(%d); /* varoutTypemap */ \n", 1);
      Replaceall(varoutTypemap, "$value", origVariableName);
      Replaceall(varoutTypemap, "$result", "1");
      emit_action_code(node, getFunctionWrapper->code, varoutTypemap);
      Delete(varoutTypemap);
    }
    Append(getFunctionWrapper->code, "return SWIG_OK;\n");
    Append(getFunctionWrapper->code, "}\n");
    Wrapper_print(getFunctionWrapper, wrappersSection);

    /* Add function to builder table */
    Printf(builderCode, "\"%s\",\"%s\";", getFunctionName, getFunctionName);

    /* Manage SET function */
    if (is_assignable(node)) {
      Wrapper *setFunctionWrapper = NewWrapper();
      String *setFunctionName = Swig_name_set(NSPACE_TODO, variableName);

      Setattr(node, "wrap:name", setFunctionName);
      Printv(setFunctionWrapper->def, "int ", setFunctionName, "(char *fname, unsigned long fname_len) {\n", NIL);

      /* Check the number of input and output */
      Printf(setFunctionWrapper->def, "CheckInputArgument(pvApiCtx, 1, 1);\n");
      Printf(setFunctionWrapper->def, "CheckOutputArgument(pvApiCtx, 1, 1);\n");

      String *varinTypemap = Swig_typemap_lookup("varin", node, origVariableName, 0);
      if (varinTypemap != NULL) {
        Replaceall(varinTypemap, "$input", "1");
        emit_action_code(node, setFunctionWrapper->code, varinTypemap);
        Delete(varinTypemap);
      }
      Append(setFunctionWrapper->code, "return SWIG_OK;\n");
      Append(setFunctionWrapper->code, "}\n");
      Wrapper_print(setFunctionWrapper, wrappersSection);

      /* Add function to builder table */
      Printf(builderCode, "\"%s\",\"%s\";", setFunctionName, setFunctionName);
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ----------------------------------------------------------------------- */
  virtual int constantWrapper(Node *node) {

    /* Get the useful information from the node */
    String *nodeName = Getattr(node, "name");
    SwigType *type = Getattr(node, "type");
    String *constantName = Getattr(node, "sym:name");
    String *rawValue = Getattr(node, "rawval");
    String *constantValue = rawValue ? rawValue : Getattr(node, "value");
    String *constantTypemap = NULL;

    /* Create variables for member pointer constants, not suppported by typemaps (like Python wrapper does) */
    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(constantName);
      String *str = SwigType_str(type, wname);
      Printf(headerSection, "static %s = %s;\n", str, constantValue);
      Delete(str);
      constantValue = wname;
    }

    /* Create GET function to get the constant value */
    Wrapper *getFunctionWrapper = NewWrapper();
    String *getFunctionName = Swig_name_get(NSPACE_TODO, constantName);
    Setattr(node, "wrap:name", getFunctionName);
    Printv(getFunctionWrapper->def, "int ", getFunctionName, "(char *fname, unsigned long fname_len) {\n", NIL);

    /* Check the number of input and output */
    Printf(getFunctionWrapper->def, "CheckInputArgument(pvApiCtx, 0, 0);\n");
    Printf(getFunctionWrapper->def, "CheckOutputArgument(pvApiCtx, 1, 1);\n");

    constantTypemap = Swig_typemap_lookup("constcode", node, nodeName, 0);
    if (constantTypemap != NULL) {
      Printf(getFunctionWrapper->code, "SWIG_Scilab_SetOutputPosition(%d); /* constantTypemap */ \n", 1);
      Replaceall(constantTypemap, "$value", constantValue);
      Replaceall(constantTypemap, "$result", "1");
      emit_action_code(node, getFunctionWrapper->code, constantTypemap);
      Delete(constantTypemap);
    }

    /* Dump the wrapper function */
    Append(getFunctionWrapper->code, "return SWIG_OK;\n");
    Append(getFunctionWrapper->code, "}\n");
    Wrapper_print(getFunctionWrapper, wrappersSection);

    /* Add the function to the builder table */
    Printf(builderCode, "\"%s\",\"%s\";", getFunctionName, getFunctionName);

    DelWrapper(getFunctionWrapper);

    return SWIG_OK;
  }

  /* ---------------------------------------------------------------------
   * enumvalueDeclaration()
   * --------------------------------------------------------------------- */
  virtual int enumvalueDeclaration(Node *node) {

    /* Force type to be an enum (See scitypemaps.swg) */
    Setattr(node, "type", "enum SWIG");

    return Language::enumvalueDeclaration(node);
  }

  /* -----------------------------------------------------------------------
   * addFunctionInBuilder(): add a new function wrapper in builder.sce file
   * ----------------------------------------------------------------------- */
  void addFunctionInBuilder(String *scilabFunctionName, String *wrapperFunctionName) {
    if (++builderFunctionCount % 10 == 0) {
      Printf(builderCode, "];\n\ntable = [table;");
    }
    Printf(builderCode, "\"%s\",\"%s\";", scilabFunctionName, wrapperFunctionName);
  }
};

extern "C" Language* swig_scilab(void) {
  return new SCILAB();
}
