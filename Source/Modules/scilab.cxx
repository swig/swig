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

static const char *usage = (char *) "\
Scilab options (available with -scilab)\n\
     -addcflag <flag> - Additional compilation flag <flag> to include in build script\n\
     -addldflag <flag>- Additional link flag <flag> to include in build script\n\
     -addsrc <files> - Additional comma separated source <files> to include in build script\n\
     -vbl <level>    - Sets the build verbose <level> (default 0)\n\
     -buildflags <file> - Uses a Scilab script in <file> to set build flags\n\
     -nobuilder      - Do not generate builder script\n\n";

static const char *SWIG_CREATE_VARIABLES_FUNCTION_NAME = "SWIG_CreateScilabVariables";

class SCILAB:public Language {
protected:
  /* General objects used for holding the strings */
  File *beginSection;
  File *runtimeSection;
  File *headerSection;
  File *wrappersSection;
  File *initSection;

  String *variablesCode;

  File *builderFile;
  String *builderCode;
  int builderFunctionCount;

  List *sourceFileList;
  List *cflags;
  List *ldflags;

  String *verboseBuildLevel;
  String *buildFlagsScript;

  bool generateBuilder;
  bool extraWarning;
public:

  /* ------------------------------------------------------------------------
   * main()
   * ----------------------------------------------------------------------*/

   virtual void main(int argc, char *argv[]) {

    sourceFileList = NewList();
    cflags = NewList();
    ldflags = NewList();
    verboseBuildLevel = NULL;
    buildFlagsScript = NULL;
    generateBuilder = true;
    extraWarning = false;

    /* Manage command line arguments */
    for (int argIndex = 1; argIndex < argc; argIndex++) {
      if (argv[argIndex] != NULL) {
	if (strcmp(argv[argIndex], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	} else if (strcmp(argv[argIndex], "-addsrc") == 0) {
	  if (argv[argIndex + 1] != NULL) {
	    Swig_mark_arg(argIndex);
	    char *sourceFile = strtok(argv[argIndex + 1], ",");
	    while (sourceFile != NULL) {
	      DohInsertitem(sourceFileList, Len(sourceFileList), sourceFile);
	      sourceFile = strtok(NULL, ",");
	    }
	    Swig_mark_arg(argIndex + 1);
	  }
	} else if (strcmp(argv[argIndex], "-addcflag") == 0) {
	  Swig_mark_arg(argIndex);
	  if (argv[argIndex + 1] != NULL) {
            DohInsertitem(cflags, Len(cflags), argv[argIndex + 1]);
	    Swig_mark_arg(argIndex + 1);
	  }
	} else if (strcmp(argv[argIndex], "-addldflag") == 0) {
	  Swig_mark_arg(argIndex);
	  if (argv[argIndex + 1] != NULL) {
            DohInsertitem(ldflags, Len(ldflags), argv[argIndex + 1]);
	    Swig_mark_arg(argIndex + 1);
	  }
	} else if (strcmp(argv[argIndex], "-vbl") == 0) {
	  Swig_mark_arg(argIndex);
	  verboseBuildLevel = NewString(argv[argIndex + 1]);
	  Swig_mark_arg(argIndex + 1);
  } else if (strcmp(argv[argIndex], "-buildflags") == 0) {
    Swig_mark_arg(argIndex);
    buildFlagsScript = NewString(argv[argIndex + 1]);
    Swig_mark_arg(argIndex + 1);
  } else if (strcmp(argv[argIndex], "-nobuilder") == 0) {
    Swig_mark_arg(argIndex);
    generateBuilder = false;
  }
  else if (strcmp(argv[argIndex], "-Wextra") == 0) {
    extraWarning = true;
  }
      }
    }

    if (verboseBuildLevel == NULL) {
      verboseBuildLevel = NewString("0");
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
    String *moduleName = Getattr(node, "name");

    /* Get the output file name */
    String *outputFilename = Getattr(node, "outfile");

    /* Initialize I/O */
    beginSection = NewFile(outputFilename, "w", SWIG_output_files());
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

    // Add builder header code
    if (generateBuilder) {
      createBuilderFile();
      startBuilderCode(moduleName, outputFilename);
    }

    // Module initialization function
    String *moduleInitFunctionName = NewString("");
    Printf(moduleInitFunctionName, "%s_Init", moduleName);

    /* Add initialization function to builder table */
    addFunctionInBuilder(moduleInitFunctionName, moduleInitFunctionName);

    // Open Scilab wrapper variables creation function
    variablesCode = NewString("");
    Printf(variablesCode, "int %s() {\n", SWIG_CREATE_VARIABLES_FUNCTION_NAME);

    /* Emit code for children */
    if (CPlusPlus) {
      Printf(wrappersSection, "extern \"C\" {\n");
    }

    Language::top(node);

    if (CPlusPlus) {
      Printf(wrappersSection, "}\n");
    }

    // Close Scilab wrapper variables creation function
    Printf(variablesCode, "  return SWIG_OK;\n}\n");

    // Add Builder footer code and save
    if (generateBuilder) {
      terminateBuilderCode();
      saveBuilderFile();
    }

    /* Close the init function and rename with module name */
    Printf(initSection, "return 0;\n}\n");
    Replaceall(initSection, "<module>", moduleName);

    /* Write all to the wrapper file */
    SwigType_emit_type_table(runtimeSection, wrappersSection);	// Declare pointer types, ... (Ex: SWIGTYPE_p_p_double)
    Dump(runtimeSection, beginSection);
    Dump(headerSection, beginSection);
    Dump(wrappersSection, beginSection);
    Dump(variablesCode, beginSection);
    Wrapper_pretty_print(initSection, beginSection);

    /* Cleanup files */
    Delete(runtimeSection);
    Delete(headerSection);
    Delete(wrappersSection);
    Delete(initSection);
    Delete(beginSection);

    Delete(sourceFileList);
    Delete(cflags);
    Delete(ldflags);

    return SWIG_OK;
  }

  /* ------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------*/

  void emitBanner(File *f) {
    Printf(f, "// ----------------------------------------------------------------------------\n");
    Swig_banner_target_lang(f, "// ");
    Printf(f, "// ----------------------------------------------------------------------------- */\n\n");
  }

  /* ------------------------------------------------------------------------
   * functionWrapper()
   * ----------------------------------------------------------------------*/

  virtual int functionWrapper(Node *node) {

    /* Get some useful attributes of this function */
    String *functionName = Getattr(node, "sym:name");
    SwigType *functionReturnType = Getattr(node, "type");
    ParmList *functionParamsList = Getattr(node, "parms");

    checkIdentifierName(functionName);

    int paramIndex = 0;		// Used for loops over ParmsList
    Parm *param = NULL;		// Used for loops over ParamsList

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
    Printf(wrapper->code, "SWIG_CheckInputArgument(pvApiCtx, $mininputarguments, $maxinputarguments);\n");
    Printf(wrapper->code, "SWIG_CheckOutputArgument(pvApiCtx, $minoutputarguments, $maxoutputarguments);\n");
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

	if (paramIndex >= minInputArguments) {	/* Optional input argument management */
	  Printf(wrapper->code, "if (SWIG_NbInputArgument(pvApiCtx) > %d) {\n%s\n}\n", paramIndex, paramTypemap);
	} else {
	  Printf(wrapper->code, "%s\n", paramTypemap);
	}
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
    String *functionActionCode = emit_action(node);	/* Function code with standard args names (arg1, ...) */

    /* Insert the return variable */
    emit_return_variable(node, functionReturnType, wrapper);

    /* Return the function value if necessary */
    String *functionReturnTypemap = Swig_typemap_lookup_out("out", node, "result", wrapper, functionActionCode);
    if (functionReturnTypemap) {
      // Result is actually the position of output value on stack
      if (Len(functionReturnTypemap) > 0) {
	Printf(wrapper->code, "SWIG_Scilab_SetOutputPosition(%d);\n", 1);
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
      Delete(functionReturnTypemap);

    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(functionReturnType, 0),
		   functionName);
    }

    /* Write typemaps(out) */
    for (param = functionParamsList; param;) {
      String *paramTypemap = Getattr(param, "tmap:argout");
      if (paramTypemap) {
	minOutputArguments++;
	maxOutputArguments++;
	Printf(wrapper->code, "SWIG_Scilab_SetOutputPosition(%d);\n", minOutputArguments);
	char result[64] = { };
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
	}
	param = Getattr(param, "tmap:freearg:next");
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
    char argnumber[64] = { };
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
   * dispatchFunction()
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
    Wrapper_add_local(wrapper, "argc", "int argc = SWIG_NbInputArgument(pvApiCtx)");
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
    String *origVariableName = Getattr(node, "name");	// Ex: Shape::nshapes
    String *variableName = Getattr(node, "sym:name");	// Ex; Shape_nshapes (can be used for function names, ...)

    checkIdentifierName(variableName);

    /* Manage GET function */
    Wrapper *getFunctionWrapper = NewWrapper();
    String *getFunctionName = Swig_name_get(NSPACE_TODO, variableName);

    Setattr(node, "wrap:name", getFunctionName);
    Printv(getFunctionWrapper->def, "int ", getFunctionName, "(char *fname, unsigned long fname_len) {\n", NIL);

    /* Check the number of input and output */
    Printf(getFunctionWrapper->def, "SWIG_CheckInputArgument(pvApiCtx, 0, 0);\n");
    Printf(getFunctionWrapper->def, "SWIG_CheckOutputArgument(pvApiCtx, 1, 1);\n");

    String *varoutTypemap = Swig_typemap_lookup("varout", node, origVariableName, 0);
    if (varoutTypemap != NULL) {
      Printf(getFunctionWrapper->code, "SWIG_Scilab_SetOutputPosition(%d);\n", 1);
      Replaceall(varoutTypemap, "$value", origVariableName);
      Replaceall(varoutTypemap, "$result", "1");
      emit_action_code(node, getFunctionWrapper->code, varoutTypemap);
      Delete(varoutTypemap);
    }
    Append(getFunctionWrapper->code, "return SWIG_OK;\n");
    Append(getFunctionWrapper->code, "}\n");
    Wrapper_print(getFunctionWrapper, wrappersSection);

    /* Add function to builder table */
    addFunctionInBuilder(getFunctionName, getFunctionName);

    /* Manage SET function */
    if (is_assignable(node)) {
      Wrapper *setFunctionWrapper = NewWrapper();
      String *setFunctionName = Swig_name_set(NSPACE_TODO, variableName);

      Setattr(node, "wrap:name", setFunctionName);
      Printv(setFunctionWrapper->def, "int ", setFunctionName, "(char *fname, unsigned long fname_len) {\n", NIL);

      /* Check the number of input and output */
      Printf(setFunctionWrapper->def, "SWIG_CheckInputArgument(pvApiCtx, 1, 1);\n");
      Printf(setFunctionWrapper->def, "SWIG_CheckOutputArgument(pvApiCtx, 1, 1);\n");

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

    checkIdentifierName(constantName);

    // If feature scilab:const enabled, constants & enums are wrapped to Scilab variables
    if (GetFlag(node, "feature:scilab:const")) {
      bool isConstant = ((SwigType_issimple(type)) || (SwigType_type(type) == T_STRING));
      bool isEnum = (Cmp(nodeType(node), "enumitem") == 0);

      if (isConstant || isEnum) {
        if (isEnum) {
          Setattr(node, "type", "double");
          constantValue = Getattr(node, "enumvalue");
        }

        constantTypemap = Swig_typemap_lookup("scilabconstcode", node, nodeName, 0);
        if (constantTypemap != NULL) {
          Setattr(node, "wrap:name", constantName);
          Replaceall(constantTypemap, "$result", constantName);
          Replaceall(constantTypemap, "$value", constantValue);

          emit_action_code(node, variablesCode, constantTypemap);
          Delete(constantTypemap);
          return SWIG_OK;
        }
      }
    }

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
    Printf(getFunctionWrapper->def, "SWIG_CheckInputArgument(pvApiCtx, 0, 0);\n");
    Printf(getFunctionWrapper->def, "SWIG_CheckOutputArgument(pvApiCtx, 1, 1);\n");

    constantTypemap = Swig_typemap_lookup("constcode", node, nodeName, 0);
    if (constantTypemap != NULL) {
      Printf(getFunctionWrapper->code, "SWIG_Scilab_SetOutputPosition(%d);\n", 1);
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
    static int iPreviousEnumValue = 0;

    if (GetFlag(node, "feature:scilab:const")) {
      // Compute the "absolute" value of enum if needed
      // (most of time enum values are a linked list of relative values)
      String *enumValue = Getattr(node, "enumvalue");
      String *enumValueEx = Getattr(node, "enumvalueex");

      // First enum value ?
      String *firstenumitem = Getattr(node, "firstenumitem");
      if (firstenumitem) {
        if (enumValue) {
          // Value is in 'enumvalue'
          iPreviousEnumValue = atoi(Char(enumValue));
        }
        else if (enumValueEx) {
          // Or value is in 'enumValueEx'
          iPreviousEnumValue = atoi(Char(enumValueEx));

          enumValue = NewString("");
          Printf(enumValue, "%d", iPreviousEnumValue);
          Setattr(node, "enumvalue", enumValue);
        }
      }
      else if (!enumValue && enumValueEx) {
        // Value is not specified, set it by incrementing last value
        enumValue = NewString("");
        Printf(enumValue, "%d", ++iPreviousEnumValue);
        Setattr(node, "enumvalue", enumValue);
      }

      // Enums in Scilab are mapped to double
      Setattr(node, "type", "double");
    }

    return Language::enumvalueDeclaration(node);
  }

  void checkIdentifierName(String *name) {
    if (Len(name) > 24) {
      if (extraWarning) {
        // Warning on too long identifiers
        Swig_warning(WARN_LANG_IDENTIFIER, input_file, line_number,
          "Identifier %s exceeds 24 characters, it may be impossible to use it.\n", name);
      }
    }
  }

  void createBuilderFile() {
    String *builderFilename = NewStringf("%sbuilder.sce", SWIG_output_directory());
    builderFile = NewFile(builderFilename, "w", SWIG_output_files());
    if (!builderFile) {
      FileErrorDisplay(builderFilename);
      SWIG_exit(EXIT_FAILURE);
    }
    emitBanner(builderFile);
  }

  void startBuilderCode(String *moduleName, String *outputFilename) {
    builderFunctionCount = 0;
    builderCode = NewString("");
    Printf(builderCode, "mode(-1);\n");
    Printf(builderCode, "lines(0);\n"); /* Useful for automatic tests */

    // Scilab needs to be in the build directory
    Printf(builderCode, "originaldir = pwd();\n");
    Printf(builderCode, "builddir = get_absolute_file_path('builder.sce');\n");
    Printf(builderCode, "cd(builddir);\n");

    Printf(builderCode, "ilib_verbose(%s);\n", verboseBuildLevel);

    Printf(builderCode, "ilib_name = \"%slib\";\n", moduleName);

    Printf(builderCode, "libs = [];\n");

    // Flags from command line arguments
    Printf(builderCode, "cflags = \"-I\" + builddir;\n");
    for (int i = 0; i < Len(cflags); i++) {
      String *cflag = Getitem(cflags, i);
      Printf(builderCode, "cflags = cflags + \" %s\";\n", cflag);
    }

    if (Len(ldflags) > 0) {
      for (int i = 0; i < Len(ldflags); i++) {
        String *ldflag = Getitem(ldflags, i);
        if (i == 0) {
          Printf(builderCode, "ldflags = \"%s\";\n", ldflag);
        } else {
          Printf(builderCode, "ldflags = ldflags + \" %s\";\n", ldflag);
        }
      }
    }
    else {
      Printf(builderCode, "ldflags = [];\n");
    }

    // External script to set flags
    if (buildFlagsScript) {
      Printf(builderCode, "exec(\"%s\");\n", buildFlagsScript);
      Printf(builderCode, "cflags = cflags + getCompilationFlags();\n");
      Printf(builderCode, "ldflags = ldflags + getLinkFlags();\n");
    }

    // Additional sources
    DohInsertitem(sourceFileList, 0, outputFilename);
    for (int i = 0; i < Len(sourceFileList); i++) {
      String *sourceFile = Getitem(sourceFileList, i);
      if (i == 0) {
         Printf(builderCode, "files = \"%s\";\n", sourceFile);
      } else {
         Printf(builderCode, "files($ + 1) = \"%s\";\n", sourceFile);
      }
    }

    Printf(builderCode, "table = [");
  }

  void terminateBuilderCode() {

    Printf(builderCode, "];\n");
    Printf(builderCode, "err_msg = [];\n");
    Printf(builderCode, "if ~isempty(table) then\n");
    Printf(builderCode, "  ilib_build(ilib_name, table, files, libs, [], ldflags, cflags);\n");
    Printf(builderCode, "  libfilename = 'lib' + ilib_name + getdynlibext();\n");
    Printf(builderCode, "  if ~isfile(libfilename) then\n");
    Printf(builderCode, "    err_msg = 'Error while building library ' + libfilename ' + '.');\n");
    Printf(builderCode, "  end\n");
    Printf(builderCode, "  if ~isfile('loader.sce') then\n");
    Printf(builderCode, "    err_msg = 'Error while generating loader script loader.sce.');\n");
    Printf(builderCode, "  end\n");
    Printf(builderCode, "end\n");
    Printf(builderCode, "cd(originaldir);\n");
    Printf(builderCode, "if err_msg <> [] then\n");
    Printf(builderCode, "  error(err_msg, 1);\n");
    Printf(builderCode, "end\n");
  }

  void saveBuilderFile() {
    // Save builder
    Printv(builderFile, builderCode, NIL);
    Delete(builderFile);
    }

  /* -----------------------------------------------------------------------
   * addFunctionInBuilder(): add a new function wrapper in builder.sce file
   * ----------------------------------------------------------------------- */

  void addFunctionInBuilder(const_String_or_char_ptr scilabFunctionName, const_String_or_char_ptr wrapperFunctionName) {
    if (generateBuilder) {
      if (++builderFunctionCount % 10 == 0) {
        Printf(builderCode, "];\n\ntable = [table;");
      }
      Printf(builderCode, "\"%s\",\"%s\";", scilabFunctionName, wrapperFunctionName);
    }
  }
};

extern "C" Language *swig_scilab(void) {
  return new SCILAB();
}
