#include "swigmod.h"

//Documentation file:///Users/jamesfolk/Documents/NJLI/External/tools/swig/Doc/Manual/Extending.html#Extending_nn32
//
class EMBIND : public Language 
{
protected:
  /* General DOH objects used for holding the strings */
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

  String *s_module;
  String *s_class;
public:

  virtual void main(int argc, char *argv[]) {

    /* Set language-specific subdirectory in SWIG library */
    SWIG_library_directory("embind");

    /* Set language-specific preprocessing symbol */
    Preprocessor_define("SWIGEMBIND 1", 0);
    /* Set typemap language (historical) */
    SWIG_typemap_lang("embind");
    /* Set language-specific configuration file */
    SWIG_config_file("embind.swg");

    allow_overloading();
  }

  virtual int top(Node *n) {
    /* Get the module name */
    s_module = Getattr(n,"name");

    /* Get the output file name */
    String *outfile = Getattr(n,"outfile");

    /* Initialize I/O */
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);

    /* Output module initialization code */
    Swig_banner(f_begin);
    //...
    // quick_example.cpp
    // #include <emscripten/bind.h>
    //
    // using namespace emscripten;
    Printf(f_begin,"%s\n", "#include <emscripten/bind.h>");
    Printf(f_begin,"%s\n", "using namespace emscripten;");

    Printf(f_wrappers, "EMSCRIPTEN_BINDINGS(%s) {\n", s_module);
    /* Emit code for children */
    Language::top(n);
    Printf(f_wrappers, "%s", "}\n");

    //...
    /* Write all to the file */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    /* Cleanup files */
    Delete(f_runtime);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_begin);

    return SWIG_OK;
  }

  /* SWIG directives */


  virtual int applyDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::applyDirective(n);
  }

  virtual int clearDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::clearDirective(n);
  }

  virtual int constantDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::constantDirective(n);
  }

  virtual int extendDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::extendDirective(n);
  }

  virtual int fragmentDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::fragmentDirective(n);
  }

  virtual int importDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::importDirective(n);
  }

  virtual int includeDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::includeDirective(n);
  }

  virtual int insertDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::insertDirective(n);
  }

  virtual int moduleDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::moduleDirective(n);
  }

  virtual int nativeDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::nativeDirective(n);
  }

  virtual int pragmaDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::pragmaDirective(n);
  }

  virtual int typemapDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::typemapDirective(n);
  }

  virtual int typemapcopyDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::typemapcopyDirective(n);
  }

  virtual int typesDirective(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "applyDirective", name);
    return Language::typesDirective(n);
  }


  /* C/C++ parsing */

  virtual int cDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    const char * kind = Char(Getattr(n, "kind")); 
  

    if(strcmp("function", kind) == 0)
    {
      String *storage = Getattr(n, "storage");

      if(storage && (strcmp("static", Char(storage)) == 0))
      {
        Printf(f_wrappers, "\t.class_function(\"%s\", &%s::%s)\n", name, s_class, name);
      }
      else
      {
        String *ismember = Getattr(n, "ismember");

        if(ismember && (strcmp("1", Char(ismember)) == 0))
        {
          if (Getattr(n, "sym:overloaded")) 
          {
            String *ret = NewString("");
            String *type = Getattr(n, "type");
            String *pstype = NewString("");

            if(type)
            {
                Append(ret, type);
            }
            else
            {
                Append(ret, "void");
            }

            ParmList *parms  = Getattr(n,"parms");

            Append(ret, "(");
            if(ParmList_len(parms) > 0)
            {
              Append(pstype, "_");
              Parm *p;
              for (p = parms; p; ) 
              {
                SwigType *type = Getattr(p, "type");

                Append(pstype, type);
                Append(ret, type);
                p = nextSibling(p);
                if(p)
                {
                  Append(ret, ", ");
                  Append(pstype, "_");
                }
              }
            }
            Append(ret, ")");

            String *decl = Getattr(n, "decl");
            if(decl)
            {
              const char *_decl = Char(decl);
              char buffer[32] = "";
              if(strlen(_decl) > 3 && _decl[0] == 'q')
              {
                _decl++;
                if(*_decl == '(')
                {
                  int end = 0;
                  while(_decl && end == 0)
                  {
                    _decl++;
                    if(*_decl != ')')
                    {
                      sprintf(buffer, "%s%c", buffer, *_decl);
                    }
                    else
                    {
                      end = 1;
                    }
                  }
                }
                Append(ret, NewString(buffer));
              }
            }
            
            Printf(f_wrappers, "\t.function(\"%s%s\", select_overload<%s>(&%s::%s))\n", name, pstype, ret, s_class, name);
          }
          else
          {
            Printf(f_wrappers, "\t.function(\"%s\", &%s::%s)\n", name, s_class, name);
          }
        }
      }
    }

    return Language::cDeclaration(n);
  }

  virtual int externDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "externDeclaration", name);
    return SWIG_OK;
  }

  virtual int enumDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "\tenum_<%s>(\"%s\")\n", name, name);
    int ret = Language::enumDeclaration(n);
    Printf(f_wrappers, "%s", "\t\t;\n");
    return ret;
  }

  virtual int enumvalueDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    String *value = Getattr(n, "value");
    //Printf(f_wrappers, "%s - %s\n", "enumvalueDeclaration", name);
    Printf(f_wrappers, "\t\t.value(\"%s\", %s)\n", name, value);
    return SWIG_OK;
  }

  virtual int enumforwardDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "enumforwardDeclaration", name);
    return SWIG_OK;
  }

  virtual int classDeclaration(Node *n)
  {
    s_class = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "classDeclaration", s_class);

    return Language::classDeclaration(n);
  }

  virtual int classforwardDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classforwardDeclaration", name);
    return SWIG_OK;
  }


  virtual int constructorDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    ParmList *parms  = Getattr(n,"parms");

    if(ParmList_len(parms) > 0)
    {
      Printf(f_wrappers, "%s", "\t.constructor<");
      //Parm *parms;
      Parm *p;
      for (p = parms; p; ) {
        SwigType *type  = Getattr(p,"type");
        Printf(f_wrappers, "%s", type);
        p = nextSibling(p);
        if(p)
        {
          Printf(f_wrappers, "%s", ",");
        }
      }
      Printf(f_wrappers, "%s", ">()\n");
    }

    return Language::constructorDeclaration(n);
  }

  virtual int destructorDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "destructorDeclaration", name);
    return Language::destructorDeclaration(n);
  }

  virtual int accessDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "accessDeclaration", name);
    return SWIG_OK;
  }

  virtual int namespaceDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "namespaceDeclaration", name);
    return SWIG_OK;
  }

  virtual int usingDeclaration(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "usingDeclaration", name);
    return SWIG_OK;
  }


  /* Function handlers */

  virtual int functionHandler(Node *n)
  {
    /* Get some useful attributes of this function */
    String   *name   = Getattr(n,"name");
    String *ismember = Getattr(n, "ismember");

    if(!ismember)
    {
      SwigType *type  = Getattr(n,"type");
      const char * kind = Char(Getattr(n, "kind")); 
      int returning_pointer = 0;

      if(type && strlen(Char(type)) >= 2)
      {
        char t[10]="";
        strncpy(t, Char(type), 2);
        if(strcmp(t, "p.") == 0)
        {
          returning_pointer = 1;
        }
      }

      Printf(f_wrappers, "\tfunction(\"%s\", &%s%s);\n", name, name, (returning_pointer)?", allow_raw_pointers()":"");
    }

    return SWIG_OK;
  }

  virtual int globalfunctionHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "globalfunctionHandler", name);
    return SWIG_OK;
  }

  virtual int memberfunctionHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "memberfunctionHandler", name);
    return SWIG_OK;
  }

  virtual int staticmemberfunctionHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "staticmemberfunctionHandler", name);
    return SWIG_OK;
  }

  virtual int callbackfunctionHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "callbackfunctionHandler", name);
    return SWIG_OK;
  }


  /* Variable handlers */

  virtual int variableHandler(Node *n)
  {
    String *name = Getattr(n, "name");

    Printf(f_wrappers, "\tconstant(\"%s\", %s);\n", name, name);

    return SWIG_OK;
  }

  virtual int globalvariableHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "globalvariableHandler", name);
    return SWIG_OK;
  }

  virtual int membervariableHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "membervariableHandler", name);
    return SWIG_OK;
  }

  virtual int staticmembervariableHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "staticmembervariableHandler", name);
    return SWIG_OK;
  }


  /* C++ handlers */

  virtual int memberconstantHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "memberconstantHandler", name);
    return SWIG_OK;
  }

  virtual int constructorHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "constructorHandler", name);
    return SWIG_OK;
  }

  virtual int copyconstructorHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "copyconstructorHandler", name);
    return SWIG_OK;
  }

  virtual int destructorHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "destructorHandler", name);
    return SWIG_OK;
  }

  virtual int classHandler(Node *n)
  {
    String *name = Getattr(n, "name");

    List *baselist = Getattr(n, "baselist");
    int has_base = 0;
    String *base_string=NewString(", base<");

    if(Len(baselist))
    {
      has_base = 1;

      Iterator i;

      for (i = First(baselist); i.item; ) {
        Append(base_string, i.item);
        i = Next(i);
        if(i.item)
        {
          Append(base_string, ", ");
        }
      }
      Append(base_string, ">");
    }

    Printf(f_wrappers, "\tclass_<%s%s>(\"%s\")\n", name, ((has_base)?base_string:""), name);
        Language::classHandler(n);
    Printf(f_wrappers, "\t;\n", s_module);

    return SWIG_OK;
  }


  /* Miscellaneous */

  virtual int typedefHandler(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "typedefHandler", name);
    return SWIG_OK;
  }


  /* Low-level code generation */

  virtual int constantWrapper(Node *n)
  {
    String *name = Getattr(n, "name");
    //Printf(f_wrappers, "%s - %s\n", "constantWrapper", name);
    return SWIG_OK;
  }

  virtual int variableWrapper(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "variableWrapper", name);
    return SWIG_OK;
  }

  virtual int functionWrapper(Node *n)
  {
    /* Get some useful attributes of this function */
    String   *name   = Getattr(n,"name");
    String *ismember = Getattr(n, "ismember");
    if(!ismember)
    {
      Printf(f_wrappers, "\tfunction(\"%s\", &%s);\n", name, name);
    }

    return SWIG_OK;
  }

  virtual int nativeWrapper(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "nativeWrapper", name);
    return SWIG_OK;
  }


  /* C++ director class generation */
  virtual int classDirector(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirector", name);
    return SWIG_OK;
  }

  virtual int classDirectorInit(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorInit", name);
    return SWIG_OK;
  }

  virtual int classDirectorEnd(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorEnd", name);
    return SWIG_OK;
  }

  virtual int unrollVirtualMethods(Node *n, Node *parent, List *vm, int default_director, int &virtual_destructor, int protectedbase = 0)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "unrollVirtualMethods", name);
    return SWIG_OK;
  }

  virtual int classDirectorConstructor(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorConstructor", name);
    return SWIG_OK;
  }

  virtual int classDirectorDefaultConstructor(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorDefaultConstructor", name);
    return SWIG_OK;
  }

  virtual int classDirectorMethod(Node *n, Node *parent, String *super)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorMethod", name);
    return SWIG_OK;
  }

  virtual int classDirectorConstructors(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorConstructors", name);
    return SWIG_OK;
  }

  virtual int classDirectorDestructor(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorDestructor", name);
    return SWIG_OK;
  }

  virtual int classDirectorMethods(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorMethods", name);
    return SWIG_OK;
  }

  virtual int classDirectorDisown(Node *n)
  {
    String *name = Getattr(n, "name");
    Printf(f_wrappers, "%s - %s\n", "classDirectorDisown", name);
    return SWIG_OK;
  }


  /* Miscellaneous */
//  virtual int validIdentifier(String *s)	/* valid identifier? */
//  {
//    return SWIG_OK;
//  }
//
//  virtual int addSymbol(const String *s, const Node *n, const_String_or_char_ptr scope = "")	/* Add symbol        */
//  {
//    return SWIG_OK;
//  }
//
//  virtual int addInterfaceSymbol(const String *interface_name, Node *n, const_String_or_char_ptr scope = "")
//  {
//    return SWIG_OK;
//  }
//
//  virtual void dumpSymbols()
//  {
//  }
//
//  virtual Node *symbolLookup(const String *s, const_String_or_char_ptr scope = "") /* Symbol lookup */
//  {
//    return SWIG_OK;
//  }
//
//  virtual Hash* symbolAddScope(const_String_or_char_ptr scope)
//  {
//    return SWIG_OK;
//  }
//
//  virtual Hash* symbolScopeLookup(const_String_or_char_ptr scope)
//  {
//    return SWIG_OK;
//  }
//
//  virtual Hash* symbolScopePseudoSymbolLookup(const_String_or_char_ptr scope)
//  {
//    return SWIG_OK;
//  }
//
//  virtual Node *classLookup(const SwigType *s) const /* Class lookup      */
//  {
//    return SWIG_OK;
//  }
//
//  virtual Node *enumLookup(SwigType *s)	/* Enum lookup       */
//  {
//    return SWIG_OK;
//  }
//
//  virtual int abstractClassTest(Node *n)	/* Is class really abstract? */
//  {
//    return SWIG_OK;
//  }
//
//  virtual int is_assignable(Node *n)	/* Is variable assignable? */
//  {
//    return SWIG_OK;
//  }
//
//  virtual String *runtimeCode()	/* returns the language specific runtime code */
//  {
//    return SWIG_OK;
//  }
//
//  virtual String *defaultExternalRuntimeFilename()	/* the default filename for the external runtime */
//  {
//    return SWIG_OK;
//  }
//
//  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm) /* Language specific special variable substitutions for $typemap() */
//  {
//  }




};

extern "C" Language *swig_embind(void) {
  return new EMBIND();
}

