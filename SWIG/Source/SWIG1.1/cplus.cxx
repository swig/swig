/* ----------------------------------------------------------------------------- 
 * cplus.cxx
 *
 *     This file contains code for C++ support in SWIG1.1.  Beware!
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "internal.h"
extern "C" {
#include "swig.h"
}

static char cvstag[] = "$Header$";

/*******************************************************************************
 * Note:
 *
 * The control flow in this module is completely insane.  But here's the
 * rough outline.
 *
 *       Stage 1 :  SWIG Parsing
 *                  cplus_open_class()        - Open up a new class
 *                  cplus_*                   - Add members to class
 *                  cplus_inherit()           - Inherit from base classes
 *                  cplus_class_close()       - Close class
 *
 *                  ...
 *                  cplus_open_class()
 *                  ... 
 *                  cplus_class_close()
 *
 *                  ... and so on, until the end of the file
 *
 *       After stage 1, all classes have been read, but nothing has been
 *       sent to the language module yet.
 *
 *       Stage 2 :  Code generation
 *                  For each class we've saved, do this :
 *                       lang->cpp_open_class()     - Open class
 *                       lang->cpp_*                - Emit members
 *                       lang->cpp_inherit()        - Inherit
 *                       lang->cpp_close_class()    - Close class
 *
 * This two-stage approach solves a number of problems related to working
 * with multiple files, mutually referenced classes, add adding methods.
 * Just keep in mind that all C++ code is emitted *after* an entire SWIG
 * file has been parsed.
 *
 * Improved code generation and inheritance of added methods (2/18/97):
 *
 * Each C++ declaration now has an associated function name attached to it.
 * For example :
 *
 *            class Foo {
 *                  void bar();
 *            }
 *
 * Generates a member function "bar()" with a accessor function named 
 * "Foo_bar()".  We will use this recorded accessor function to generate
 * better code for inheritance. For example :
 *
 *           class Foo2 : public Foo {
 *
 *               ...
 *           }
 *
 * Will create a function called "Foo2_bar()" that is really mapped
 * onto the base-class method "Foo_bar()".   This should improve
 * code generation substantially.
 *
 * Tricky stuff :
 *        -    Each target language is responsible for naming wrapper
 *             functions.
 *
 *******************************************************************************/


// Some status variables

static int    Inherit_mode = 0;             // Set if we're inheriting members
static char   *ccode = 0;                   // Set to optional C code (if available)
static DOHHash  *localtypes = 0;                  // Localtype hash
static int    abstract =0;                  // Status bit set during code generation
int IsVirtual = 0;

static int    cpp_id = 0;

// Forward references

void cplus_member_func(char *, char *, DataType *, ParmList *, int);
void cplus_constructor(char *, char *, ParmList *);
void cplus_destructor(char *, char *);
void cplus_variable(char *, char *, DataType *);
void cplus_static_func(char *, char *, DataType *, ParmList *);
void cplus_declare_const(char *, char *, DataType *, char *);
void cplus_static_var(char *, char *, DataType *);
void cplus_inherit_decl(char **);

// -----------------------------------------------------------------------------
// void add_local_type(char *type, char *classname) 
// void add_local_type(DataType *type, char *classname)
// 
// Adds a new datatype to the local datatype hash.   This is used to handle
// datatypes defined within a class.
// -----------------------------------------------------------------------------

static void add_local_type(char *type, char *classname) {
  char  str[1024];
  if (!localtypes) return;        // No hash table initialized, ignore this
  sprintf(str,"%s::%s",classname,type);
  Setattr(localtypes,type,str);
}

void add_local_type(DataType *type, char *classname) {
  add_local_type(type->name,classname);
}

// -----------------------------------------------------------------------------
// void update_local_type(DataType *type)
// 
// Checks to see whether this datatype is part of a class definition. If so,
// we update the type-name by appending the class prefix to it.  Uses the
// name stored in current_class unless unavailable.
// -----------------------------------------------------------------------------

static void update_local_type(DataType *type) {
  
  char *newname = 0;

  // Lookup the datatype in the hash table

  if (!localtypes) return;

  newname = GetChar(localtypes,type->name);
  if (newname) {
    strcpy(type->name, newname);
  }
}

// -----------------------------------------------------------------------------
// void update_parms(ParmList *l)
//
// Updates all of the parameters in a parameter list with the proper C++ prefix
// (if neccessary).  
// -----------------------------------------------------------------------------

static void update_parms(ParmList *l) {
  Parm *p;
  p = ParmList_first(l);
  while (p) {
    update_local_type(p->t);

    // Check for default arguments

    if ((p->defvalue) && (localtypes)) {
      char *s;
      s = (char *) GetChar(localtypes,p->defvalue);
      if (s) {
	delete p->defvalue;
	p->defvalue = copy_string(s);
      }
    }
    p = ParmList_next(l);
  }
}

// -----------------------------------------------------------------------
// class CPP_member
//
// Base class for various kinds of C++ members
// -----------------------------------------------------------------------
class CPP_member {
public:
  char          *name;                   // Name of the member
  char          *iname;                  // Name of member in the interpreter
  int            is_static;              // Is this a static member?
  int            new_method;             // Is this a new method (added by SWIG)?
  int            line;                   // What line number was this member on
  char           *file;                  // What file was this in?
  char           *code;                  // Was there any supplied code?
  char           *base;                  // Base class where this was defined
  int            inherited;              // Was this member inherited?
  CPP_member     *next;                  // Next member (for building linked lists)
  int            id;                     // type id when created

  virtual void   inherit(int) { };       // Inheritance rule (optional)
  virtual void   emit() = 0;             // Emit rule
};

// ----------------------------------------------------------------------
// class CPP_function : public CPP_member
//
// Structure for handling a C++ member function
// ----------------------------------------------------------------------

class CPP_function : public CPP_member {
public:
  DataType    *ret_type;  
  ParmList    *parms;
  int          new_object;
  int          is_virtual;

  CPP_function(char *n, char *i, DataType *t, ParmList *l, int s, int v = 0) {
    name = copy_string(n);
    iname = copy_string(i);
    ret_type = CopyDataType(t);
    parms = CopyParmList(l);
    is_static = s;
    is_virtual = v;
    new_method = AddMethods;
    new_object = NewObject;
    inherited = Inherit_mode;
    next = 0;
    line = line_number;
    file = input_file;
    if (Inherit_mode) {
      id = cpp_id;
    } else {
      id = type_id;
    }
    if (AddMethods) {
      if (strlen(Char(CCode)))
	code = copy_string(Char(CCode));
      else
	code = 0;
    } else {
      code = 0;
    }
  }
  void inherit(int mode) {
    if (mode & INHERIT_FUNC) {
      // Set up the proper addmethods mode and provide C code (if provided)
      int oldaddmethods = AddMethods;
      int oldnewobject = NewObject;
      AddMethods = new_method;
      NewObject = new_object;
      Clear(CCode);
      Append(CCode,code);
      if (is_static) {
	cplus_static_func(name, iname, ret_type, parms);
      } else {
	cplus_member_func(name, iname, ret_type, parms, is_virtual);
      }
      AddMethods = oldaddmethods;
      NewObject = oldnewobject;
      Clear(CCode);
    }
  }
  void emit() {
    ParmList *l;
    DataType *t;
    AddMethods = new_method;
    NewObject = new_object;
    line_number = line;        // Restore line and file 
    input_file = file;
    ccode = code;
    IsVirtual = is_virtual;

    // Make a copy of the parameter list and upgrade its types

    l = CopyParmList(parms);
    t = CopyDataType(ret_type);
    update_parms(l);
    update_local_type(t);
    if (is_static) {
      lang->cpp_static_func(name, iname, t, l);
    } else {
      lang->cpp_member_func(name, iname, t, l);
    }
    DelParmList(l);
    DelDataType(t);
    IsVirtual = 0;
  }
};

// --------------------------------------------------------------------------
// class CPP_constructor : public CPP_member
//
// Class for holding a C++ constructor definition.
// --------------------------------------------------------------------------

class CPP_constructor : public CPP_member {
public:
  ParmList  *parms;
  CPP_constructor(char *n, char *i, ParmList *l) {
    name = copy_string(n);
    iname = copy_string(i);
    parms = CopyParmList(l);
    new_method = AddMethods;
    inherited = 0;
    next = 0;
    line = line_number;
    file = input_file;
    id = type_id;
    if (AddMethods) {
      if (strlen(Char(CCode)))
	code = copy_string(Char(CCode));
      else
	code = 0;
    } else {
      code = 0;
    }
  }
  void emit() {
    if (1) {
      ParmList *l;
      AddMethods = new_method;
      line_number = line;
      input_file = file;
      ccode = code;
      
      // Make a copy of the parameter list and upgrade its types
      
      l = CopyParmList(parms);
      update_parms(l);
      lang->cpp_constructor(name,iname,l);
      DelParmList(l);
    }
  }
};


// --------------------------------------------------------------------------
// class CPP_destructor : public CPP_member
//
// Class for holding a destructor definition
// --------------------------------------------------------------------------

class CPP_destructor : public CPP_member {
public:

  CPP_destructor(char *n, char *i) {
    name = copy_string(n);
    iname = copy_string(i);
    new_method = AddMethods;
    next = 0;
    inherited = 0;
    line = line_number;
    file = input_file;
    id = type_id;
    if (AddMethods) {
      if (strlen(Char(CCode)))
	code = copy_string(Char(CCode));
      else
	code = 0;
    } else {
      code = 0;
    }

  }
  void emit() {
    AddMethods = new_method;
    line_number = line;
    input_file = file;
    ccode = code;
    lang->cpp_destructor(name, iname);
  }
};

// -------------------------------------------------------------------------
// class CPP_variable : public CPP_member
//
// Class for a managing a data member
// -------------------------------------------------------------------------

class CPP_variable : public CPP_member {
public:
  DataType *type;
  int status;
  CPP_variable(char *n, char *i, DataType *t, int s) {
    name = copy_string(n);
    iname = copy_string(i);
    type = CopyDataType(t);
    is_static = s;
    status = Status;
    next = 0;
    new_method = AddMethods;
    line = line_number;
    file = input_file;
    if (Inherit_mode) {
      id = cpp_id;
    } else {
      id = type_id;
    }
    code = 0;
    inherited = 0;
  }

  // Emit code for this

  void emit() {
    DataType *t;
    int old_status = Status;
    AddMethods = new_method;
    Status = status;
    line_number = line;
    input_file = file;
    ccode = code;

    t = CopyDataType(type);
    if (t->qualifier) {
      //      if (strcmp(t->qualifier,"const") == 0) Status = Status | STAT_READONLY;
    }
    update_local_type(t);
    if (!is_static) {
      lang->cpp_variable(name,iname,t);
    } else {
      lang->cpp_static_var(name,iname,t);
    }
    Status = old_status;
    DelDataType(t);
  }

  // Inherit into another class

  void inherit(int mode) {
    int oldstatus = Status;
    Status = status;
    if (mode & INHERIT_VAR) {
      if (!is_static) {
	int oldaddmethods = AddMethods;
	AddMethods = new_method;
	Clear(CCode);
	Append(CCode,code);
	cplus_variable(name,iname,type);
	AddMethods = oldaddmethods;
	Clear(CCode);
      } else {
	cplus_static_var(name,iname,type);
      }
    }
    Status = oldstatus;
  }
};

// -------------------------------------------------------------------------
// class CPP_constant : public CPP_member
//
// Class for managing constant values
// -------------------------------------------------------------------------

class CPP_constant : public CPP_member {
public:
  char       *value;
  DataType   *type;
  CPP_constant(char *n, char *i, DataType *t, char *v) {
    name = copy_string(n);
    iname = copy_string(i);
    type = CopyDataType(t);
    value = copy_string(v);
    new_method = AddMethods;
    next = 0;
    line = line_number;
    file = input_file;
    if (Inherit_mode)
      id = cpp_id;
    else
      id = type_id;
    code = 0;
    inherited = 0;
  }

  void emit() {
    AddMethods = new_method;
    line_number = line;
    input_file = file;
    ccode = code;
    lang->cpp_declare_const(name,iname,type,value);
  }

  void inherit(int mode) {
    if (mode & INHERIT_CONST) 
      cplus_declare_const(name, iname, type, value);
  }
};

// ----------------------------------------------------------------------
// class CPP_class
//
// Class for managing class members (internally)
// ----------------------------------------------------------------------

static char   *inherit_base_class = 0;

class CPP_class {
public:
  char        *classname;             // Real class name
  char        *classrename;           // New name of class (if applicable)
  char        *classtype;             // class type (struct, union, class)
  int          strip;                 // Strip off class declarator
  int          wextern;               // Value of extern wrapper variable for this class
  int          have_constructor;      // Status bit indicating if we've seen a constructor
  int          have_destructor;       // Status bit indicating if a destructor has been seen
  int          is_abstract;           // Status bit indicating if this is an abstract class
  int          generate_default;      // Generate default constructors
  int          objective_c;           // Set if this is an objective C class
  int          error;                 // Set if this class can't be generated
  int          line;                  // Line number
  char        **baseclass;            // Base classes (if any)
  DOHHash     *local;                 // Hash table for local types
  void        *scope;                 // Local scope hash table
  CPP_member  *members;               // Linked list of members
  CPP_class   *next;                  // Next class
  static CPP_class *classlist;        // List of all classes stored
  Pragma      *pragmas;               // Class pragmas

  CPP_class(char *name, char *ctype) {
    CPP_class *c;
    classname = copy_string(name);
    classtype = copy_string(ctype);
    classrename = 0;
    baseclass = 0;
    local = NewHash();                 // Create hash table for storing local datatypes
    scope = 0;
    error = 0;
    pragmas = 0;
    line = line_number;

    // Walk down class list and add to end

    c = classlist;
    if (c) {
      while (c->next) {
	c = c->next;
      }
      c->next = this;
    } else {
      classlist = this;
    }
    next = 0;
    members = 0;
    strip = 0;
    wextern = WrapExtern;
    have_constructor = 0;
    have_destructor = 0;
    is_abstract = 0;
    generate_default = GenerateDefault;
    objective_c = ObjCClass;
  }

  // ------------------------------------------------------------------------------
  // Add a new C++ member to this class
  // ------------------------------------------------------------------------------

  void add_member(CPP_member *m) {
    CPP_member *cm;
    
    // Set base class where this was defined
    if (inherit_base_class)          
      m->base = inherit_base_class;
    else
      m->base = classname;              
    if (!members) {
      members = m;
      return;
    }
    cm = members;
    while (cm->next) {
      cm = cm->next;
    }
    cm->next = m;
  }
  // ------------------------------------------------------------------------------
  // Search for a member with the given name. Returns the member on success, 0 on failure
  // ------------------------------------------------------------------------------

  CPP_member *search_member(char *name) {
    CPP_member *m;
    char *c;
    m = members;
    while (m) {
      c = m->iname ? m->iname : m->name;
      if (strcmp(c,name) == 0) return m;
      m = m->next;
    }
    return 0;
  }

  // ------------------------------------------------------------------------------
  // Inherit.  Put all the declarations associated with this class into the current
  // ------------------------------------------------------------------------------

  void inherit_decls(int mode) {
    CPP_member *m;
    m = members;
    while (m) {
      inherit_base_class = m->base;
      cpp_id = m->id;
      m->inherit(mode);
      m = m->next;
    }
    inherit_base_class = 0;
  }

  // ------------------------------------------------------------------------------
  // Emit all of the declarations associated with this class 
  // ------------------------------------------------------------------------------

  void emit_decls() {
    CPP_member    *m = members;
    abstract = is_abstract;
    while (m) {
      cpp_id = m->id;
      m->emit();
      m = m->next;
    }
  }

  // ------------------------------------------------------------------------------  
  // Search for a given class in the list
  // ------------------------------------------------------------------------------

  static CPP_class *search(char *name) {
    CPP_class *c;
    c = classlist;
    if (!name) return 0;
    while (c) {
      if (strcmp(name,c->classname) == 0) return c;
      c = c->next;
    }
    return 0;
  }

  // ------------------------------------------------------------------------------
  // Add default constructors and destructors
  //
  // ------------------------------------------------------------------------------

  void create_default() {
    if (!generate_default) return;
    
    // Try to generate a constructor if not available.
    Clear(CCode);
    AddMethods = 0;
    if ((!have_constructor) && (1)) {
      ParmList *l;
      l = NewParmList();
      cplus_constructor(classname,0,l);
    };
    
    if (!have_destructor) {
      cplus_destructor(classname,0);
    }
  }

  // ------------------------------------------------------------------------------
  // Dump *all* of the classes saved out to the various
  // language modules (this does what cplus_close_class used to do)
  // ------------------------------------------------------------------------------
  static void create_all();
};

CPP_class *CPP_class::classlist = 0;
static CPP_class     *current_class;

void CPP_class::create_all() {
  CPP_class *c;
  c = classlist;
  while (c) {
    if (!c->error) {
      current_class = c;
      localtypes = c->local;
      if ((!c->wextern) && (c->classtype)) {
	ObjCClass = c->objective_c;
	lang->cpp_open_class(c->classname,c->classrename,c->classtype,c->strip);
	lang->cpp_pragma(c->pragmas);
	c->create_default();
	if (c->baseclass)
	  cplus_inherit_decl(c->baseclass);
	c->emit_decls();
	lang->cpp_close_class();
      }
    }
    c = c->next;
  }
}

// -----------------------------------------------------------------------------
// char *cplus_base_class(char *name)
//
// Given a member name, return the base class that it belongs to.
// -----------------------------------------------------------------------------

char *cplus_base_class(char *name) {
  CPP_member *m = current_class->search_member(name);
  if (m) {
    return m->base;
  } 
  return 0;
}

// -----------------------------------------------------------------------------
// void cplus_open_class(char *name, char *rname, char *ctype) 
//
// Opens up a new C++ class.   If rname is given, we'll be renaming the
// class.    This also sets up some basic type equivalence for the
// type checker.
// 
// Inputs :
//          name      = Name of the class
//          rname     = New name of the class (using %name() directive)
//          ctype     = Class type ("class","struct", or "union")
//
// Side Effects :
//          Creates a new class obect internally.
//          Added type-mappings to the SWIG type-checker module.
//          Sets a number of internal state variables for later use.
//
// -----------------------------------------------------------------------------

void cplus_open_class(char *name, char *rname, char *ctype) {

  extern void typeeq_derived(char *, char *, char *cast=0);
  char temp[256];
  CPP_class *c;

  // Add some symbol table management here

  // Search for a previous class definition

  c = CPP_class::search(name);
  if (c) {
    if (c->classtype) {
      // Hmmm. We already seem to have defined this class so we'll
      // create a new class object for whatever reason
      current_class = new CPP_class(name, ctype);
    } else {
      // Looks like a reference was made to this class earlier
      // somehow, but no other information is known.  We'll
      // make it our current class and fix it up a bit
      current_class = c;
      c->classtype = copy_string(ctype);
    }
  } else {
    // Create a new class
    current_class = new CPP_class(name, ctype); 
  }

  // Set localtypes hash to our current class

  localtypes = current_class->local;

  // If renaming the class, set the new name

  if (rname) {
    current_class->classrename = copy_string(rname);
  }
  
  // Make a typedef for both long and short versions of this datatype

  if (name) {
    if (strlen(name)) {
      if (strlen(ctype) > 0) {
	sprintf(temp,"%s %s", ctype, name);   
	typeeq_derived(temp,name);       // Map "struct foo" to "foo"
	typeeq_derived(name,temp);       // Map "foo" to "struct foo"
      }
    }
  }

  AddMethods = 0;          // Reset add methods flag

}

// -----------------------------------------------------------------------------
// void cplus_set_class(char *name)
//
// This function sets the current class to a given name.   If the class
// doesn't exist, this function will create one.   If it already exists,
// we'll just use that.
//
// This function is used primarily to add or manipulate an already
// existing class, but in a different location.  For example :
//
//         %include "class.h"        // Grab some classes
//         ...
//         %addmethods MyClass {     // Add some members for shadow classes
//               ... members ...
//         }
//
// -----------------------------------------------------------------------------

void cplus_set_class(char *name) {
  
  CPP_class *c;

  // Look for a previous class definition

  c = CPP_class::search(name);
  if (c) {
    current_class = c;
    localtypes = c->local;
  } else {
    fprintf(stderr,"%s:%d:  Warning class %s undefined.\n",input_file,line_number,name);
    current_class = new CPP_class(name,0);
    localtypes = current_class->local;
  }
};

// This function closes a class open with cplus_set_class() 

void cplus_unset_class() {
  current_class = 0;
}

// -----------------------------------------------------------------------------
// void cplus_class_close(char *name)
//
// Close a C++ class definition.   Up to this point, we've only been collecting
// member definitions.     This function merely closes the class object and
// stores it in a list.  All classes are dumped after processing has completed.
//
// If name is non-null, it means that the name of the class has actually been
// set after all of the definitions.  For example :
//
//    typedef struct {
//             double x,y,z
//    } Vector;
//
// If this is the case, we'll use that as our classname and datatype.
// Otherwise, we'll just go with the classname and classtype set earlier.
// 
// Inputs : name   = optional "new name" for the class.
//
// Output : None
//
// Side Effects : Resets internal variables. Saves class in internal list.
//                Registers the class with the language module, but doesn't
//                emit any code.
// -----------------------------------------------------------------------------

void cplus_class_close(char *name) {

  if (name) {
    // The name of our class suddenly changed by typedef.  Fix things up
    current_class->classname = copy_string(name);

    // This flag indicates that the class needs to have it's type stripped off
    current_class->strip = 1;
  }

  // If we're in C++ or Objective-C mode. We're going to drop the class specifier

  if ((CPlusPlus) || (ObjCClass)) {
    current_class->strip = 1;
  }
  
  // Register our class with the target language module, but otherwise
  // don't do anything yet.

  char *iname;
  if (current_class->classrename) iname = current_class->classrename;
  else iname = current_class->classname;

  lang->cpp_class_decl(current_class->classname, iname, current_class->classtype);

  // Clear current class variable and reset
  current_class = 0;
  localtypes = 0;

}

// -----------------------------------------------------------------------------
// void cplus_abort(void)
//
// Voids the current class--some kind of unrecoverable parsing error occurred.
// -----------------------------------------------------------------------------

void cplus_abort(void) {
  current_class->error = 1;
  current_class = 0;
  localtypes = 0;
}

// -----------------------------------------------------------------------------
// void cplus_cleanup(void)
//
// This function is called after all parsing has been completed.  It dumps all
// of the stored classes out to the language module.
// 
// Inputs : None
//
// Output : None
//
// Side Effects : Emits all C++ wrapper code.
// -----------------------------------------------------------------------------

void cplus_cleanup(void) {

  // Dump all classes created at once (yikes!)

  CPP_class::create_all();
  lang->cpp_cleanup();
}

// -----------------------------------------------------------------------------
// void cplus_inherit(int count, char **baseclass)
//
// Inherit from a baseclass.  This function only really registers
// the inheritance, but doesn't do anything with it yet.
// 
// Inputs : baseclass  = A NULL terminated array of strings with the names
//                       of baseclasses.   For multiple inheritance, there
//                       will be multiple entries in this list.
//
// Output : None
//
// Side Effects : Sets the baseclass variable of the current class.
// -----------------------------------------------------------------------------

void cplus_inherit(int count, char **baseclass) {
  int i;

  // printf("Inheriting : count = %d, baseclass = %x\n",count,baseclass);
  // If there are baseclasses, make copy of them
  if (count) {
    current_class->baseclass = (char **) new char*[count+1];
    for (i = 0; i < count; i++) 
      current_class->baseclass[i] = copy_string(baseclass[i]);
    current_class->baseclass[i] = 0;
  } else {
    baseclass = 0;
  }
}

// -----------------------------------------------------------------------------
// cplus_generate_types(char **baseclass)
//
// Generates the type-mappings between the current class and any associated
// base classes.  This is done by performing a depth first search of the
// class hierarchy.   Functions for performing correct type-casting are
// generated for each base-derived class pair.
//
// Inputs : baseclass     = NULL terminated list of base classes
//
// Output : None
//
// Side Effects : Emits pointer conversion functions.  Registers type-mappings
//                with the type checking module.
//
// -----------------------------------------------------------------------------

static DOHHash *convert = 0;                // Hash table of conversion functions

void cplus_generate_types(char **baseclass) {
  CPP_class *bc;
  int        i;
  DOHString *cfunc;
  DOHString *temp3;
  char temp1[512], temp2[512];
  extern void typeeq_derived(char *, char *, char *);

  if (!baseclass) {
    return;
  }

  if (!convert) convert = NewHash();

  // Generate type-conversion functions and type-equivalence
  cfunc = NewString("");
  temp3 = NewString("");
  i = 0;
  while(baseclass[i]) {
    Clear(cfunc);

    bc = CPP_class::search(baseclass[i]);
    if (bc) {
      // Generate a conversion function (but only for C++)

      if (!current_class->objective_c) {
	Clear(temp3);
	Printv(temp3, "Swig", current_class->classname, "To", bc->classname,0);

	if (!Getattr(convert,temp3)) {
	  SetVoid(convert,temp3,(void*) 1);

	  // Write a function for casting derived type to parent class

	  Printv(cfunc,
		 "static void *Swig", current_class->classname, "To", bc->classname, 
		 "(void *ptr) {\n",
		 tab4, current_class->classname, " *src;\n",
		 tab4, bc->classname, " *dest;\n",
		 tab4, "src = (", current_class->classname, " *) ptr;\n",
		 tab4, "dest = (", bc->classname, " *) src;\n",
		 tab4, "return (void *) dest;\n",
		 "}\n",
		 0);
	  
	  fprintf(f_wrappers,"%s\n",Char(cfunc));
	}
      } else {
	Clear(temp3);
	Printf(temp3,"0");
      }
      
      // Make a type-equivalence allowing derived classes to be used in functions of the

      if (strlen(current_class->classtype) > 0) {
	sprintf(temp1,"%s %s", current_class->classtype, current_class->classname);
	sprintf(temp2,"%s %s", bc->classtype, bc->classname);

	// Add various equivalences to the pointer table
	
	typeeq_derived(bc->classname, current_class->classname,Char(temp3));
	typeeq_derived(temp2, current_class->classname,Char(temp3));
	typeeq_derived(temp2, temp1,Char(temp3));
	typeeq_derived(bc->classname, temp1,Char(temp3));
      } else {
	typeeq_derived(bc->classname, current_class->classname,Char(temp3));
      }
      DataType_record_base(current_class->classname, bc->classname);
      // Now traverse the hierarchy some more
      cplus_generate_types(bc->baseclass);
    }
    i++;
  }
  Delete(temp3);
  Delete(cfunc);
}

// -----------------------------------------------------------------------------
// void cplus_inherit_decl(char **baseclass)
// 
// This function is called internally to handle inheritance between classes.
// Basically, we're going to generate type-checking information and call
// out to the target language to handle the inheritance.
//
// This function is only called when emitting classes to the language modules
// (after all parsing has been complete).
// 
// Inputs : baseclass   = NULL terminated list of base-class names.
//
// Output : None
//
// Side Effects : Generates type-mappings.  Calls the language-specific
//                inheritance function.
// -----------------------------------------------------------------------------

void cplus_inherit_decl(char **baseclass) {

  // If not base-classes, bail out

  if (!baseclass) return;

  Inherit_mode = 1;         
  lang->cpp_inherit(baseclass);        // Pass inheritance onto the various languages
  Inherit_mode = 0;

  // Create type-information for class hierarchy

  cplus_generate_types(baseclass);
}
// -----------------------------------------------------------------------------
// void cplus_inherit_members(char *baseclass, int mode)
//
// Inherits members from a class. This is called by specific language modules
// to bring in members from base classes.   It may or may  not be called. 
//
// This function is called with a *single* base-class, not multiple classes
// like other functions.   To do multiple inheritance, simply call this
// with each of the associated base classes.
// 
// Inputs :
//          baseclass     = Name of baseclass
//          mode          = Inheritance handling flags
//                  INHERIT_FUNC          - Import functions in base class 
//                  INHERIT_VAR           - Import variables in base class
//                  INHERIT_CONST         - Inherit constants
//                  INHERIT_ALL           - Inherit everything (grossly inefficient)
//
// Output : None
//
// Side Effects : Imports methods from base-classes into derived classes.
//             
// -----------------------------------------------------------------------------

void cplus_inherit_members(char *baseclass, int mode) {
  CPP_class *bc;

  bc = CPP_class::search(baseclass);
  if (bc) {
    bc->inherit_decls(mode);
  } else {
    fprintf(stderr,"%s:%d:  Warning.  Base class %s undefined (ignored).\n", input_file, current_class->line, baseclass);    
  }
}

// -----------------------------------------------------------------------------
// void cplus_member_func(char *name, char *iname, DataType *type, ParmList *, is_virtual)
//
// Parser entry point to creating a C++ member function.   This function primarily
// just records the function and does a few symbol table checks.
// 
// Inputs : 
//          name          = Real name of the member function
//          iname         = Renamed version (may be NULL)
//          type          = Return datatype
//          l             = Parameter list
//          is_virtual    = Set if this is a pure virtual function (ignored)
//
// Output : None
//
// Side Effects :
//          Adds member function to current class. 
// -----------------------------------------------------------------------------

void cplus_member_func(char *name, char *iname, DataType *type, ParmList *l,
		       int is_virtual) {

  CPP_function *f;
  char *temp_iname;

  // First, figure out if we're renaming this function or not

  if (!iname) 
    temp_iname = name;
  else 
    temp_iname = iname;

  // If we're in inherit mode, we need to check for duplicates.
  // Issue a warning.
    
  if (Inherit_mode) {
    if (current_class->search_member(temp_iname)) {
      return;
    }
  }
  
  // Add it to our C++ class list

  f = new CPP_function(name,temp_iname,type,l,0,is_virtual);
  current_class->add_member(f);

  // If this is a pure virtual function, the class is abstract

  if (is_virtual)
    current_class->is_abstract = 1;

}

// -----------------------------------------------------------------------------
// void cplus_constructor(char *name, char *iname, ParmList *l)
//
// Parser entry point for creating a constructor.
//
// Inputs : 
//          name  = Real name of the constructor (usually the same as the class)
//          iname = Renamed version (may be NULL)
//          l     = Parameter list
//
// Output : None
//
// Side Effects :
//          Adds a constructor to the current class.
// -----------------------------------------------------------------------------

void cplus_constructor(char *name, char *iname, ParmList *l) {

    CPP_constructor *c;

    // May want to check the naming scheme here

    c = new CPP_constructor(name,iname,l);
    current_class->add_member(c);
    current_class->have_constructor = 1;

}

// -----------------------------------------------------------------------------
// void cplus_destructor(char *name, char *iname)
//
// Parser entry point for adding a destructor.
// 
// Inputs :
//          name   = Real name of the destructor (usually same as class name)
//          iname  = Renamed version (may be NULL)
//
// Output : None
//
// Side Effects :
//          Adds a destructor to the current class
//
// -----------------------------------------------------------------------------

void cplus_destructor(char *name, char *iname) {

  CPP_destructor *d;

  d = new CPP_destructor(name,iname);
  current_class->add_member(d);
  current_class->have_destructor = 1;
}

// -----------------------------------------------------------------------------
// void cplus_variable(char *name, char *iname, DataType *t)
//
// Parser entry point for creating a new member variable.  
// 
// Inputs :
//          name  = name of the variable
//          iname = Renamed version (may be NULL)
//          t     = Datatype
//
// Output : None
//
// Side Effects :
//          Adds a member variable to the current class
// -----------------------------------------------------------------------------

void cplus_variable(char *name, char *iname, DataType *t) {

    CPP_variable *v;
    char *temp_iname;

    // If we're in inherit mode, we need to check for duplicates.

    if (iname)
      temp_iname = iname;
    else
      temp_iname = name;

    if (Inherit_mode) {
      if (current_class->search_member(temp_iname)) {
	return;
      }
    }
    
    v = new CPP_variable(name,iname,t,0);
    current_class->add_member(v);
}

// -----------------------------------------------------------------------------
// void cplus_static_func(char *name, char *iname, DataType *type, ParmList *l)
//
// Parser entry point for creating a new static member function.
// 
// Inputs :
//          name   = Real name of the function
//          iname  = Renamed version (may be NULL)
//          type   = Return datatype
//          l      = Parameter list
//
// Output : None
//
// Side Effects :
//          Adds a static function to the current class.
//
// -----------------------------------------------------------------------------

void cplus_static_func(char *name, char *iname, DataType *type, ParmList *l) {

  char *temp_iname;

  // If we're in inherit mode, we need to check for duplicates.
  
  if (iname) temp_iname = iname;
  else temp_iname = name;

  if (Inherit_mode) {
    if (current_class->search_member(iname)) {
      // Have a duplication
      return;
    }
  }

  CPP_function *f = new CPP_function(name, temp_iname, type, l, 1);
  current_class->add_member(f);
}

// -----------------------------------------------------------------------------
// void cplus_declare_const(char *name, char *iname, DataType *type, char *value)
//
// Parser entry point for creating a C++ constant (usually contained in an 
// enum).
// 
// Inputs :
//          name   = Real name of the constant
//          iname  = Renamed constant (may be NULL)
//          type   = Datatype of the constant
//          value  = String representation of the value
//
// Output : None
//
// Side Effects :
//          Adds a constant to the current class.
// -----------------------------------------------------------------------------

void cplus_declare_const(char *name, char *iname, DataType *type, char *value) {

  char *temp_iname;

  if (iname) temp_iname = iname;
  else temp_iname = name;

  // If we're in inherit mode, we need to check for duplicates.
  // Possibly issue a warning or perhaps a remapping
    
  if (Inherit_mode) {
    if (current_class->search_member(temp_iname)) {
      return;
    }
  }

  CPP_constant *c =  new CPP_constant(name, temp_iname, type, value);
  current_class->add_member(c);

  // Add this symbol to local scope of a class
  add_local_type(name, current_class->classname);
}

// -----------------------------------------------------------------------------
// void cplus_static_var(char *name, char *iname, DataType *type)
//
// Parser entry point for adding a static variable
// 
// Inputs :
//          name  = Name of the member
//          iname = Renamed version (may be NULL)
//          type  = Datatype
//
// Output : None
//
// Side Effects :
//          Adds a static variable to the current class.
// -----------------------------------------------------------------------------

void cplus_static_var(char *name, char *iname, DataType *type) {

  char *temp_iname;
  
  if (iname) temp_iname = iname;
  else temp_iname = name;

  // If we're in inherit mode, we need to check for duplicates.
  // Possibly issue a warning or perhaps a remapping
  
  if (Inherit_mode) {
    if (current_class->search_member(temp_iname)) {
      return;
    }
  }

  CPP_variable *v = new CPP_variable(name, temp_iname, type, 1);
  current_class->add_member(v);
}

// -----------------------------------------------------------------------------
// cplus_add_pragma(char *lang, char *name, char *value)
//
// Add a pragma to a class 
// -----------------------------------------------------------------------------

void cplus_add_pragma(char *lang, char *name, char *value)
{
  Pragma *pp;
  Pragma *p = new Pragma;
  p->filename = NewString(input_file);
  p->lang = NewString(lang);
  p->name = NewString(name);
  p->value = NewString(value);
  p->next = 0;
  p->lineno = line_number;
  
  if (!current_class->pragmas) {
    current_class->pragmas = p;
    return;
  }
  pp = current_class->pragmas;
  while (pp->next) {
    pp = pp->next;
  }
  pp->next = p;
}

// ------------------------------------------------------------------------------
// C++/Objective-C code generation functions
//
// The following functions are responsible for generating the wrapper functions
// for C++ and Objective-C methods and variables.  These functions are usually
// called by specific language modules, but individual language modules can
// choose to do something else.
//
// The C++ module sets a number of internal state variables before emitting various
// pieces of code.  These variables are often checked implicitly by these
// procedures even though nothing is passed on the command line.
//
// The code generator tries to be somewhat intelligent about what its doing.
// The member_hash Hash table keeps track of wrapped members and is used for
// sharing code between base and derived classes.
// -----------------------------------------------------------------------------

static DOHHash *member_hash = 0;  // Hash wrapping member function wrappers to scripting wrappers

// -----------------------------------------------------------------------------
// void cplus_emit_member_func(char *classname, char *classtype, char *classrename,
//                             char *mname, char *mrename, DataType *type, 
//                             ParmList *l, int mode)
//
// This is a generic function to produce a C wrapper around a C++ member function.
// This function does the following :
// 
//          1.     Create a C wrapper function
//          2.     Wrap the C wrapper function like a normal C function in SWIG
//          3.     Add the function to the scripting language
//          4.     Fill in the documentation entry
//
// Specific languages can choose to provide a different mechanism, but this
// function is used to provide a low-level C++ interface.
//
// The mode variable determines whether to create a new function or only to
// add it to the interpreter.   This is used to support the %addmethods directive
//
//        mode = 0    : Create a wrapper and add it (the normal mode)
//        mode = 1    : Assume wrapper was already made and add it to the
//                      interpreter (%addmethods mode)
//
// Wrapper functions are usually created as follows :
//
//     class Foo {
//       int bar(args)
//     }
//
//     becomes ....
//     Foo_bar(Foo *obj, args) {
//         obj->bar(args);
//     }
//
// if %addmethods mode is set AND there is supporting C code detected, make
// a function from it.  The object is always called 'obj'.
//
// Then we wrap Foo_bar().   The name "Foo_bar" is actually contained in the parameter
// cname.   This is so language modules can provide their own names (possibly for
// function overloading).
//
// This function makes no internal checks of the SWIG symbol table.  This is
// up to the caller.
// 
// Objective-C support (added 5/24/97) :
//
// If the class member function is part of an objective-C interface, everything
// works the same except that we change the calling mechanism to issue an 
// Objective-C message.
//
// Optimizations (added 12/31/97) :
//
// For automatically generated wrapper functions.   We now generate macros such
// as
//        #define Foo_bar(a,b,c)   (a->bar(b,c))
// 
// This should make the wrappers a little faster as well as reducing the amount
// of wrapper code.
//
// Inputs :
//          classname            = Name of C++ class
//          classtype            = Type of class (struct, union, class)
//          classrename          = Renamed class (if any)
//          mname                = Member name
//          mrename              = Renamed member
//          type                 = Return type of the function
//          l                    = Parameter list
//          mode                 = addmethods mode
//
// Output : None
//
// Side Effects :
//          Creates C accessor function in the wrapper file.
//          Calls the language module to create a wrapper function.
// -----------------------------------------------------------------------------

void cplus_emit_member_func(char *classname, char *classtype, char *classrename,
                            char *mname, char *mrename, DataType *type, ParmList *l,
  		            int mode) {
    Parm     *p;
    ParmList *newparms;
    int i;
    DOHString  *wrap;
    char     cname[512],iname[512];
    DOHString *key;
    char     *prefix;
    char     *prev_wrap = 0;
    char     *temp_mname;

    wrap = NewString("");

    key = NewString("");
    // First generate a proper name for the member function

    // Get the base class of this member
    if (!mrename) temp_mname = mname;
    else temp_mname = mrename;

    char *bc = cplus_base_class(temp_mname);
    if (!bc) bc = classname;
    if (strlen(bc) == 0) bc = classname;

    // Generate the name of the C wrapper function (is always the same, regardless
    // of renaming).

    strcpy(cname, Swig_name_member(bc,mname));

    // Generate the scripting name of this function
    if (classrename) 
      prefix = classrename;
    else
      prefix = classname;

    if (mrename)
      strcpy(iname,Swig_name_member(prefix,mrename));
    else
      strcpy(iname,Swig_name_member(prefix,mname));

    // Now check to see if we have already wrapped a function like this.
    // If so, we'll just use the existing wrapper.

    Printf(key,"%s+",cname);
    ParmList_print_types(l,key);
    char *temp = copy_string(iname);
    if (!member_hash) member_hash = NewHash();
    if (Getattr(member_hash,key)) {
      delete [] temp;
      prev_wrap = GetChar(member_hash,key);
    } else {
      Setattr(member_hash,key,temp);
      delete [] temp;
    }
    
    // Only generate code if an already existing wrapper doesn't exist
    
    if (!prev_wrap) {

      // If mode = 0: Then we go ahead and create a wrapper macro
    
      if (!mode) {
	strcpy(cname,iname);
	Printv(wrap, "#define ", cname, "(_swigobj", 0);

	// Walk down the parameter list and Spit out arguments
	
	i = 0;
	p = ParmList_first(l);
	while (p != 0) {
	  if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	    Printf(wrap,",_swigarg%d",i);
	    i++;
	  }
	  p = ParmList_next(l);
	}
	Printf(wrap,")  (");
	
	if (!ObjCClass) {
	  Printv(wrap, "_swigobj->", mname, "(", 0);         // C++ invocation
	} else { 
	  Printv(wrap, "[ _swigobj ", mname, 0);               // Objective C invocation 
	}
	i = 0;
	p = ParmList_first(l);
	while(p != 0) {
	  if (ObjCClass) Printf(wrap," %s", p->objc_separator);
	  if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	    Printf(wrap,"_swigarg%d",i);
	    i++;
	  }
	  p = ParmList_next(l);
	  if ((p != 0) && (!ObjCClass)) 
	  Putc(',',wrap);
	}
	if (!ObjCClass) 
	  Printf(wrap,"))\n");
	else
	  Printf(wrap,"])\n");
	
	// Emit it
	fprintf(f_wrappers,"%s",Char(wrap));
      } else {
	if (ccode) {
	  Printf(wrap,"static ");
	  if (type->is_reference) {
	    type->is_pointer--;
	  }
	  Printf(wrap,"%s", DataType_print_full(type));
	  if (type->is_reference) {
	    Printf(wrap,"&");
	    type->is_pointer++;
	  }
	  Printv(wrap, " ", cname, "(", classtype, classname, " *self", 0);
	  
	  // Walk down the parameter list and Spit out arguments
	  
	  p = ParmList_first(l);
	  while (p != 0) {
	    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	      Printf(wrap,",");
	      if ((p->call_type & CALL_REFERENCE) || (p->t->is_reference)) {
		p->t->is_pointer--;
	      } 
	      Printf(wrap, DataType_print_full(p->t));
	      if ((p->call_type & CALL_REFERENCE) || (p->t->is_reference)) {
		p->t->is_pointer++;
	           if (p->t->is_reference)
		     Printf(wrap,"&");
	      }
	      Printf(wrap," %s", p->name);
	    }
	    p = ParmList_next(l);
	  }
	  Printf(wrap,") %s", ccode);
	  fprintf(f_wrappers,"%s\n",Char(wrap));
	}
      }

      // Now add a parameter to the beginning of the function and call
      // a language specific function to add it.
      
      newparms = CopyParmList(l);
      p = NewParm(0,0);
      p->t = NewDataType(0);
      p->t->type = T_USER;
      p->t->is_pointer = 1;
      p->t->id = cpp_id;
      p->call_type = 0;
      
      sprintf(p->t->name,"%s%s", classtype,classname);
      p->name = (char*)"self";
      ParmList_insert(newparms,p,0);       // Attach parameter to beginning of list
      
      // Now wrap the thing.  The name of the function is iname
      
      lang->create_function(cname, iname, type, newparms);
      DelParmList(newparms);
    } else {
      // Already wrapped this function.   Just patch it up 
      lang->create_command(prev_wrap, iname);
    }
    Delete(key);
    Delete(wrap);
}


// -----------------------------------------------------------------------------
// void cplus_emit_static_func(char *classname, char *classtype, char *classrename,
//                             char *mname, char *mrename, DataType *type, 
//                             ParmList *l, int mode)
//
// This is a generic function to produce a wrapper for a C++ static member function
// or an Objective-C class method.
//
// Specific languages can choose to provide a different mechanism, but this
// function is used to provide a low-level C++ interface.
//
// The mode variable determines whether to create a new function or only to
// add it to the interpreter.   This is used to support the %addmethods directive
//
//        mode = 0    : Create a wrapper and add it (the normal mode)
//        mode = 1    : Assume wrapper was already made and add it to the
//                      interpreter (%addmethods mode)
//
// Wrapper functions are usually created as follows :
//
//     class Foo {
//       static int bar(args)
//     }
//
//     becomes a command called Foo_bar()
//
// if %addmethods mode is set AND there is supporting C code detected, make
// a function from it.  
//
// Then we wrap Foo_bar().   The name "Foo_bar" is actually contained in the parameter
// cname.   This is so language modules can provide their own names (possibly for
// function overloading).
//
// This function makes no internal checks of the SWIG symbol table.  This is
// up to the caller.
// 
// Inputs :
//          classname            = Name of C++ class
//          classtype            = Type of class (struct, union, class)
//          classrename          = Renamed version of class (optional)
//          mname                = Member name
//          mrename              = Renamed member (optional)
//          type                 = Return type of the function
//          l                    = Parameter list
//          mode                 = addmethods mode
//
// Output : None
//
// -----------------------------------------------------------------------------

void cplus_emit_static_func(char *classname, char *, char *classrename,
			    char *mname, char *mrename, DataType *type, ParmList *l,
			    int mode) {
    Parm     *p;
    DOHString  *wrap;
    char     cname[512], iname[512];
    DOHString *key;
    int      i;
    char     *prefix;
    char     *prev_wrap = 0;
    char     *temp_mname;
    
    key = NewString("");
    wrap = NewString("");

    // Generate a function name for the member function
    
    if (!mrename) temp_mname = mname;
    else temp_mname = mrename;
    char *bc = cplus_base_class(temp_mname);
    if (!bc) bc = classname;
    if (strlen(bc) == 0) bc = classname;
    
    // Generate the name of the C wrapper function 
    if ((!mode) && (!ObjCClass)) {
      sprintf(cname,"%s::%s", bc, mname);
    } else {
      strcpy(cname,Swig_name_member(bc,mname));
    }

    // Generate the scripting name of this function
    if (classrename)
      prefix = classrename;
    else
      prefix = classname;

    if (mrename) 
      strcpy(iname,Swig_name_member(prefix,mrename));
    else
      strcpy(iname,Swig_name_member(prefix,mname));

    // Perform a hash table lookup to see if we've wrapped anything like this before

    Printf(key,"%s+",cname);
    ParmList_print_types(l,key);
    char *temp = copy_string(iname);
    if (!member_hash) member_hash = NewHash();
    if (Getattr(member_hash,key)) {
      delete [] temp;
      prev_wrap = GetChar(member_hash,key);
    } else {
      Setattr(member_hash,key,temp);
      delete [] temp;
    }

    if (!prev_wrap) {
      if (!((mode) || (ObjCClass))) {
	// Not an added method and not objective C, just wrap it
	lang->create_function(cname,iname, type, l);
      } else {
	// This is either an added method or an objective C class function
	//
	// If there is attached code, use it.
	// Otherwise, assume the function has been written already and
	// wrap it.
	
	Printv(wrap,"static ", DataType_print_full(type), " ", cname, "(", 0);
	  
	// Walk down the parameter list and Spit out arguments
	p = ParmList_first(l);
	while (p != 0) {
	  if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	    if (p->t->is_reference) {
	      p->t->is_pointer--;
	    } 
	    Printf(wrap, DataType_print_full(p->t));
	    if (p->t->is_reference) {
	      p->t->is_pointer++;
	      Printf(wrap, "&");
	    }
	    Printf(wrap," %s", p->name);
	  }
	  p = ParmList_next(l);
	  if (p) Printf(wrap, ",");
	}
	Printf(wrap, ") ");
	if ((mode) && (ccode)) {
	  Printf(wrap,"%s",ccode);
	} else if (ObjCClass) {
	  // This is an objective-C method
	  Printf(wrap, "{\n");
	  
	  // Emit the function call.  
	  
	  if ((type->type != T_VOID) || (type->is_pointer)) {
	    // Declare the return value
	    
	    if (type->is_reference) {
	      type->is_pointer--;
	      Printv(wrap, tab4, DataType_print_full(type), "& _result = ",0);
	      type->is_pointer++;
	    } else {
	      Printv(wrap, tab4, DataType_print_type(type), " _result = ", DataType_print_cast(type), 0);
	    }
	  } else {
	    Printf(wrap,tab4);
	  }
	  Printv(wrap, "[ ", classname, " ", mname,0);               // Objective C invocation 
	  i = 0;
	  p = ParmList_first(l);
	  while(p != 0) {
	    Printf(wrap," %s", p->objc_separator);
	    if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	      if (p->t->is_reference) {
		Printf(wrap,"*");
	      }
	      Printf(wrap,p->name);
	      i++;
	    }
	    p = ParmList_next(l);
	  }
	  Printf(wrap,"];\n");
	  
	  if ((type->type != T_VOID) || (type->is_pointer)) {
	    if (type->is_reference) {
	      Printv(wrap, tab4, "return ", DataType_print_cast(type), " &_result;\n",0);
	    } else {
	      Printv(wrap, tab4, "return _result;\n",0);
	    }
	  }
	  Printf(wrap,"}\n");
	}
	if (ObjCClass || (mode && ccode)) 
	  fprintf(f_wrappers,"%s\n",Char(wrap));
	lang->create_function(cname,iname,type,l);
      }
    } else {
      // Already wrapped this function.   Just hook up to it.
      lang->create_command(prev_wrap, iname);
    }
    Delete(key);
    Delete(wrap);
}

// -----------------------------------------------------------------------------
// void cplus_emit_destructor(char *classname, char *classtype, char *classrename,
//                            char *mname, char *mrename, int mode)
//
// Emit a C wrapper around a C++ destructor.  
//
// Usually this function is used to do the following :
//     class Foo {
//       ...
//     ~Foo();
//     }
//
//     becomes ....
//     void delete_Foo(Foo *f) {
//         delete f;
//     }
//
// Then we wrap delete_Foo().
// 
// Inputs :
//          classname =       Name of the C++ class
//          classtype =       Type of class (struct,class,union)
//          classrename =     Renamed class (optional)
//          mname     =       Name of the destructor
//          mrename   =       Name of the function in the interpreter
//          mode      =       addmethods mode (0 or 1)
//
// Output : None
//
// Side Effects :
//          Creates a destructor function and wraps it.
// -----------------------------------------------------------------------------

void cplus_emit_destructor(char *classname, char *classtype, char *classrename, 
			   char *mname, char *mrename, int mode)
{
    Parm *p;
    DataType *type;
    ParmList *l;
    DOHString    *wrap;
    char      cname[512],iname[512];
    char      *prefix;

    // Construct names for the function

    wrap = NewString("");

    if (classrename)
      prefix = classrename;
    else
      prefix = classname;
    
    strcpy(cname,Swig_name_destroy(classname));
    if (mrename)
      strcpy(iname, Swig_name_destroy(mrename));
    else
      strcpy(iname, Swig_name_destroy(prefix));
    
    if (!mode) {
      // Spit out a helper function for this member function
      Printv(wrap, "#define ", cname, "(_swigobj) (",0);
      if (ObjCClass) {
	Printv(wrap, "[_swigobj ", mname, "])\n", 0);   // Name of the member is the destructor
      } else if (CPlusPlus) 
	Printv(wrap, "delete _swigobj)\n",0);
      else
	Printv(wrap, "free ((char *) _swigobj))\n", 0);
      fprintf(f_wrappers,"%s", Char(wrap));
    } else {
      if (ccode) {
	Printv(wrap, "static void ", cname, "(", classtype, classname, " *self) ", ccode,0);
	fprintf(f_wrappers,"%s\n",Char(wrap));
      }
    }

    // Make a parameter list for this function
    
    l = NewParmList();
    p = NewParm(0,0);
    p->t = NewDataType(0);
    p->t->type = T_USER;
    p->t->is_pointer = 1;
    p->t->id = cpp_id;
    p->call_type = 0;
    sprintf(p->t->name,"%s%s", classtype, classname);
    p->name = (char*)"self";
    ParmList_insert(l,p,0);
    
    type = NewDataType(0);
    type->type = T_VOID;
    sprintf(type->name,"void");
    type->is_pointer = 0;
    type->id = cpp_id;

    // iname is the desired name of the function in the target language

    lang->create_function(cname,iname,type,l);

    DelDataType(type);
    DelParmList(l);
    Delete(wrap);
}

// -----------------------------------------------------------------------------
// void cplus_emit_constructor(char *classname, char *classtype, char *classrename,
//                             char *mname, char *mrename, ParmList *l, int mode)
//
// Creates a C wrapper around a C++ constructor
//
// Inputs :
//          classname    = name of class
//          classtype    = type of class (struct,class,union)
//          classrename  = Renamed class (optional)
//          mname        = Name of constructor
//          mrename      = Renamed constructor (optional)
//          l            = Parameter list
//          mode         = addmethods mode
//
// Output : None
//
// Side Effects :
//          Creates a C wrapper and calls the language module to wrap it.
// -----------------------------------------------------------------------------

void cplus_emit_constructor(char *classname, char *classtype, char *classrename,
                            char *mname, char *mrename, ParmList *l, int mode)
{
    Parm *p;
    int i;
    DataType *type;
    DOHString *fcall, *wrap;
    char cname[512],iname[512];
    char    *prefix;

    fcall = NewString("");
    wrap = NewString("");

    // Construct names for the function

    if (classrename)
      prefix = classrename;
    else
      prefix = classname;
    
    strcpy(cname,Swig_name_construct(classname));
    if (mrename)
      strcpy(iname, Swig_name_construct(mrename));
    else
      strcpy(iname, Swig_name_construct(prefix));

    // Create a return type

    type = NewDataType(0);
    type->type = T_USER;
    sprintf(type->name,"%s%s", classtype,classname);
    type->is_pointer = 1;
    type->id = cpp_id;

    if (!mode) {
      Printv(wrap, "#define ", iname, "(", 0);
      strcpy(cname,iname);
      if (ObjCClass) {
	Printv(fcall, DataType_print_cast(type), "[", classname, " ", mname,0);
      } else if (CPlusPlus) {
	Printv(fcall, "new ", classname, "(", 0);
      } else {
	Printv(fcall, DataType_print_cast(type), " calloc(1,sizeof(", classtype, classname, "))", 0);
      }

      // Walk down the parameter list and spit out arguments
      
      i = 0;
      p = ParmList_first(l);
      while (p != 0) {
	if (ObjCClass) Printf(fcall," %s", p->objc_separator);
	if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	  Printf(wrap,"_swigarg%d",i);

	  // Emit an argument in the function call if in C++ mode
	  
	  if ((CPlusPlus) || (ObjCClass)) {
	    Printf(fcall,"_swigarg%d",i);
	  }
	}
	i++;
	p = ParmList_next(l);
	if (p) {
	  Printf(wrap,",");
	  if ((CPlusPlus) && (!ObjCClass))
	    Printf(fcall,",");
	}
      }
      Printf(wrap,") ");
      if (ObjCClass) Printf(fcall,"]");
      else if (CPlusPlus) Printf(fcall,")");

      Printf(wrap,"(%s)", fcall);
      fprintf(f_wrappers,"%s\n",Char(wrap));
    } else {
      if (ccode) {
	Printv(wrap, "static ", classtype, classname, " *", cname, "(", 0);

	// Walk down the parameter list and spit out arguments
      
	p = ParmList_first(l);
	while (p != 0) {
	  if ((p->t->type != T_VOID) || (p->t->is_pointer)) {
	    if (p->call_type & CALL_REFERENCE) {
	      p->t->is_pointer--;
	    }
	    Printf(wrap, DataType_print_real(p->t,p->name));
	    if (p->call_type & CALL_REFERENCE) {
	      p->t->is_pointer++;
	    }
	    p = ParmList_next(l);
	    if (p) {
	      Printf(wrap,",");
	    }
	  } else {
	    p = ParmList_next(l);
	  }
	}
	Printv(wrap,") ", ccode, "\n", 0);
	fprintf(f_wrappers,"%s\n",Char(wrap));
     }
    }

    // If we had any C++ references, get rid of them now

    if (!mode) {
      p = ParmList_first(l);
      while (p) {
	//	p->t->is_reference = 0;
	p = ParmList_next(l);
      } 
    }

    // We've now created a C wrapper.  We're going to add it to the interpreter

    lang->create_function(cname, iname, type, l);
    DelDataType(type);
    Delete(wrap);
    Delete(fcall);
}

// -----------------------------------------------------------------------------
// void cplus_emit_variable_get(char *classname, char *classtype, char *classrename,
//                              char *mname, char *mrename, DataType *type, int mode)
//
// Writes a C wrapper to extract a data member
//
// Usually this function works as follows :
// 
// class Foo {
//      double x;
// }
//
// becomes :
// 
// double Foo_x_get(Foo *obj) {
//      return obj->x;
// }
// 
// Optimization : 12/31/97
//
// Now emits a macro like this :
//
//      #define Foo_x_get(obj) (obj->x)
//
// Inputs :
//          classname     = name of C++ class
//          classtype     = type of class (struct, class, union)
//          classrename   = Renamed class
//          mname         = Member name
//          mrename       = Renamed member
//          type          = Datatype of the member
//          mode          = Addmethods mode
//
// Output : None
//
// Side Effects :
//          Creates a C accessor function and calls the language module
//          to make a wrapper around it.
// -----------------------------------------------------------------------------

void cplus_emit_variable_get(char *classname, char *classtype, char *classrename,
			     char *mname, char *mrename, DataType *type, int mode) {

    Parm     *p;
    ParmList *l;
    DOHString  *wrap;
    char      cname[512],iname[512];
    char      key[512];
    char      *prefix;
    char      *tm;
    char      source[512];
    char     *temp_mname;
    char     *prev_wrap = 0;

    wrap = NewString("");

    // First generate a proper name for the get function

    // Get the base class of this member
    if (!mrename) temp_mname = mname;
    else temp_mname = mrename;

    char *bc = cplus_base_class(temp_mname);
    if (!bc) bc = classname;
    if (strlen(bc) == 0) bc = classname;

    // Generate the name of the C wrapper function (is always the same, regardless
    // of renaming).

    strcpy(cname, Swig_name_get(Swig_name_member(bc,mname)));

    // Generate the scripting name of this function
    if (classrename) 
      prefix = classrename;
    else
      prefix = classname;

    if (mrename)
      strcpy(iname, Swig_name_get(Swig_name_member(prefix,mrename)));
    else
      strcpy(iname, Swig_name_get(Swig_name_member(prefix,mname)));

    // Now check to see if we have already wrapped a variable like this.
    
    strcpy(key,cname);
    char *temp = copy_string(iname);
    if (!member_hash) member_hash = NewHash();
    if (Getattr(member_hash,key)) {
      delete [] temp;
      prev_wrap = GetChar(member_hash,key);
    } else {
      Setattr(member_hash,key,temp);
      delete [] temp;
    }

    // Only generate code if already existing wrapper doesn't exist
    if (!prev_wrap) {
      if (!mode) {
	// Get any sort of typemap that might exist

	sprintf(source,"obj->%s",mname);

	// Now write a function to get the value of the variable

	tm = typemap_lookup((char*)"memberout",typemap_lang,type,mname,source,(char*)"result");

	if ((type->type == T_USER) && (!type->is_pointer)) {
	  type->is_pointer++;
	  if (tm) {
	    Printv(wrap, "static ", DataType_print_type(type), " ", cname, "(",  
		   classtype, classname, " *obj) {\n",
		   tab4, DataType_print_type(type), " result;\n",
		   tm, "\n",
		   tab4, "return result;\n",
		   "}\n",
		   0);
	  } else {
	    Printv(wrap, "#define ", cname, "(_swigobj) ",
		   "(&_swigobj->", mname, ")\n",
		   0);
	  }
	  type->is_pointer--;
	} else {
	  if (tm) {
	    Printv(wrap, "static ", DataType_print_type(type), " ", cname, "(",
		   classtype, classname, " *obj) {\n",
		   tab4, DataType_print_type(type), " result;\n",
		   tm, "\n",
		   tab4, "return result;\n",
		   "}\n",
		   0);
	  } else {
	    Printv(wrap, "#define ", cname, "(_swigobj) (",0);
	    if (!type->is_reference) Printf(wrap,DataType_print_cast(type));
	    else
	      Printf(wrap,"&");
	    Printv(wrap, " _swigobj->", mname, ")\n",0);
	  }
	}
	fprintf(f_wrappers,"%s",Char(wrap));
      }
      
      // Wrap this function

      l = NewParmList();
      p = NewParm(0,0);
      p->t =  NewDataType(0);
      p->t->type = T_USER;
      p->t->is_pointer = 1;
      p->t->id = cpp_id;
      p->call_type = 0;	
      p->name = (char*)"self";
      sprintf(p->t->name,"%s%s", classtype,classname);
      ParmList_insert(l,p,0);

      if ((type->type == T_USER) && (!type->is_pointer)) {
	type->is_pointer++;
	lang->create_function(cname,iname, type, l);
	type->is_pointer--;
      } else {
	int is_ref = type->is_reference;
	type->is_reference = 0;
	lang->create_function(cname,iname, type, l);
	type->is_reference = is_ref;
      }
      DelParmList(l);
    } else {
      // Already wrapped this function.  Just patch it up
      lang->create_command(prev_wrap,iname);
    }
    Delete(wrap);

}

// -----------------------------------------------------------------------------
// void cplus_emit_variable_set(char *classname, char *classtype, char *mname,
//                              char *cname, char *iname, DataType *type, int mode)
//
// Writes a C wrapper to set a data member
//
// Usually this function works as follows :
// 
// class Foo {
//      double x;
// }
//
// becomes :
// 
// double Foo_x_set(Foo *obj, double value) {
//      return (obj->x = value);
// }
//
// Need to handle special cases for char * and for user defined types. 
//
// 1.  char *
//
//     Will free previous contents (if any) and allocate
//     new storage.   Could be risky, but it's a reasonably
//     natural thing to do.
//
// 2.  User_Defined
//     Will assign value from a pointer. 
//     Will return a pointer to current value.
// 
//
// Optimization,  now defined as a C preprocessor macro
//
// Inputs :
//          classname     = name of C++ class
//          classtype     = type of class (struct, class, union)
//          mname         = Member name
//          cname         = Name of the C function for this (ie. Foo_bar_get)
//          iname         = Interpreter name of ths function
//          type          = Datatype of the member
//          mode          = Addmethods mode
//
// Output : None
//
// Side Effects :
//          Creates a C accessor function and calls the language module
//          to wrap it.
// -----------------------------------------------------------------------------

void cplus_emit_variable_set(char *classname, char *classtype, char *classrename,
			     char *mname, char *mrename, DataType *type, int mode) {

    Parm     *p;
    ParmList *l;
    DOHString   *wrap;
    int       is_user = 0;
    char      *tm;
    char      target[512];
    char      cname[512], iname[512];
    char      key[512];
    char      *temp_mname;
    char      *prefix;
    char      *prev_wrap = 0;

    wrap = NewString("");

    // First generate a proper name for the get function

    // Get the base class of this member
    if (!mrename) temp_mname = mname;
    else temp_mname = mrename;

    char *bc = cplus_base_class(temp_mname);
    if (!bc) bc = classname;
    if (strlen(bc) == 0) bc = classname;

    // Generate the name of the C wrapper function (is always the same, regardless
    // of renaming).

    strcpy(cname, Swig_name_set(Swig_name_member(bc,mname)));

    // Generate the scripting name of this function
    if (classrename) 
      prefix = classrename;
    else
      prefix = classname;

    if (mrename)
      strcpy(iname, Swig_name_set(Swig_name_member(prefix,mrename)));
    else
      strcpy(iname, Swig_name_set(Swig_name_member(prefix,mname)));

    // Now check to see if we have already wrapped a variable like this.

    strcpy(key,cname);
    char *temp = copy_string(iname);
    if (!member_hash) member_hash = NewHash();
    if (Getattr(member_hash,key)) {
      delete [] temp;
      prev_wrap = GetChar(member_hash,key);
    } else {
      Setattr(member_hash,key,temp);
      delete [] temp;
    }

    // Only generate code if already existing wrapper doesn't exist

    if (!prev_wrap) {
      if (!mode) {
	
	sprintf(target,"obj->%s",mname);
	
	// Lookup any typemaps that might exist
	tm = typemap_lookup((char*)"memberin",typemap_lang,type,mname,(char*)"val",target);
	
	// First write a function to set the variable 

	if (tm) {
	  if ((type->type == T_USER) && (!type->is_pointer)) {
	    type->is_pointer++;
	    is_user = 1;
	  }
	  Printv(wrap,
		 "static ", DataType_print_type(type), " ", cname, "(",
		 classtype, classname, " *obj, ", DataType_print_real(type,(char*)"val"), ") {\n",
		 0);
	  if (is_user) {
	    type->is_pointer--;
	  }
	  Printv(wrap,tm,"\n",0);
	  // Return the member
	  if (is_user) type->is_pointer++;
	  Printv(wrap, tab4, "return ", DataType_print_cast(type), " val;\n",0);
	  if (is_user) type->is_pointer--;
	  Printf(wrap,"}\n");
	} else {
	  if ((type->type != T_VOID) || (type->is_pointer)){
	    if (!type->is_pointer) {

	      Printv(wrap, "#define ", cname, "(_swigobj,_swigval) (",0);	      
	      // Have a real value here (ie.  not a pointer).  
	      // If it's a user defined type, we'll do something special.
	      // Otherwise, just assign it.
	      
	      if (type->type != T_USER) {
		Printv(wrap,"_swigobj->",mname," = _swigval",0);
	      } else {
		Printv(wrap,"_swigobj->",mname, " = *(_swigval)",0);
	      }
	      Printf(wrap,",_swigval)\n");
	    } else {
	      // Is a pointer type here.  If string, we do something
	      // special.  Otherwise. No problem.
	      if ((type->type == T_CHAR) && (type->is_pointer == 1)) {
		char temp[512];
		Printv(wrap,
		       "static ", DataType_print_type(type), " ", cname, "(",
		       classtype, classname, " *obj, ", DataType_print_real(type,(char*)"val"), ") {\n",
		       0);
		sprintf(temp,"obj->%s",mname);
		if (CPlusPlus) {
		  Printv(wrap,
			 tab4, "if (", temp, ") delete [] ", temp, ";\n",
			 tab4, temp, " = new char[strlen(val)+1];\n",
			 tab4, "strcpy((char *)", temp, ",val);\n",
			 0);
		} else {
		  Printv(wrap,
			 tab4, "if (obj->", mname, ") free(obj->", mname, ");\n",
			 tab4, "obj->", mname, " = (char *) malloc(strlen(val)+1);\n",
			 tab4, "strcpy((char *)obj->", mname, ",val);\n",
			 0);
		}
		Printv(wrap,tab4, "return (char *) val;\n","}\n",0);
	      } else {
		// A normal pointer type of some sort
		Printv(wrap, "#define ", cname, "(_swigobj,_swigval) (",0);
		if (type->is_reference) {
		  Printv(wrap, "_swigobj->", mname, " = *_swigval, _swigval)\n",0);
		} else {
		  Printv(wrap, "_swigobj->", mname, " = _swigval,_swigval)\n",0);
		}
	      }
	    }
	  }
	}
      }
      fprintf(f_wrappers,"%s",Char(wrap));
      // Now wrap it.
      
      l = NewParmList();
      p = NewParm(0,0);
      p->t = CopyDataType(type);
      p->t->is_reference = 0;
      p->call_type = 0;	
      p->t->id = cpp_id;
      if ((type->type == T_USER) && (!type->is_pointer)) p->t->is_pointer++;
      if (mrename) 
	p->name = mrename;
      else
	p->name = mname;
      ParmList_insert(l,p,0);
      p = NewParm(0,0);
      p->t =  NewDataType(0);
      p->t->type = T_USER;
      p->call_type = 0;	
      p->t->is_pointer = 1;
      p->t->id = cpp_id;
      sprintf(p->t->name,"%s%s", classtype,classname);
      p->name = (char*)"self";
      ParmList_insert(l,p,0);
      
      if ((type->type == T_USER) && (!type->is_pointer)) {
	type->is_pointer++;
	lang->create_function(cname,iname, type, l);
	type->is_pointer--;
      } else {
	int is_ref = type->is_reference;
	type->is_reference = 0;
	lang->create_function(cname,iname, type, l);
	type->is_reference = is_ref;
      }
      DelParmList(l);
    } else {
      lang->create_command(prev_wrap,iname);
    } 
    Delete(wrap);
}

// -----------------------------------------------------------------------------
// void cplus_register_type(char *typename)
// 
// Registers a datatype name to be associated with the current class.  This
// typename is placed into a local hash table for later use.  For example :
//
//     class foo {
//        public:
//            enum ENUM { ... };
//            typedef double Real;
//            void bar(ENUM a, Real b);      
//     }
//
// Then we need to access bar using fully qualified type names such as
//
//     void wrap_bar(foo::ENUM a, foo::Real b) {
//          bar(a,b);
//     }
//
// Inputs : name of the datatype.
//
// Output : None
//
// Side Effects : Adds datatype to localtypes.
// -----------------------------------------------------------------------------

void cplus_register_type(char *tname) {
  if (current_class)
    add_local_type(tname, current_class->classname);
};

// -----------------------------------------------------------------------------
// void cplus_register_scope(void *h) 
// 
// Saves the scope associated with a particular class.  It will be needed
// later if anything inherits from us.
//
// Inputs : Hash table h containing the scope
//
// Output : None
//
// Side Effects : Saves h with current class
// -----------------------------------------------------------------------------

void cplus_register_scope(void *h) {
  if (current_class) {
    current_class->scope = h;
  }
}

// -----------------------------------------------------------------------------
// void cplus_inherit_scope(int count, char **baseclass) 
// 
// Given a list of base classes, this function extracts their former scopes
// and merges them with the current scope.  This is needed to properly handle
// inheritance.
//
// Inputs : baseclass = NULL terminated array of base-class names
//
// Output : None
//
// Side Effects : Updates current scope with new symbols.
//
// Copies any special symbols if needed.
// -----------------------------------------------------------------------------

void cplus_inherit_scope(int count, char **baseclass) {
  CPP_class *bc;
  int i;
  char *val;
  DOH  *key;
  if (count && current_class) {
    for (i = 0; i < count; i++) {
       bc = CPP_class::search(baseclass[i]);
      if (bc) {
	if (bc->scope)
	  DataType_merge_scope(bc->scope);

	if (bc->local) {
	  // Copy local symbol table
	  key = Firstkey(bc->local);
	  while (key) {
	    val = GetChar(bc->local,key);
	    Setattr(localtypes,key,val);
	    key = Nextkey(bc->local);
	  }
	}
      }
    }
  }
}

