/* -----------------------------------------------------------------------------
* See the LICENSE file for information on copyright, usage and redistribution
* of SWIG, and the README file for authors - http://www.swig.org/release.html.
*
* delphi.cxx
*
* delphi language module for SWIG.
* ----------------------------------------------------------------------------- */

//char cvsroot_delphi_cxx[] = "$Header: /cvsroot/swig/SWIG/Source/Modules/delphi.cxx Exp $";

/* Some documentation: */

/****************************************************************************************************************

This module is based on the Modula3 module contained in the standard SWIG distribuition

***************************************************************************************************************

The purpouse of this module is to generate import units for DLL


Parameters:


***************************************************************************************************************

The generated unit's code can be customized in the .i file using the following sections of code that are injected
in the .pas file

interface_uses
interface_begin
interface_end
interface_functions
interface_functions_wrapper
implementation_uses
implementation_begin
implementation_end
implementation_functions
implementation_functions_wrapper
implementation_end

The generated unit has this structure:

unit modulename;

interface

uses
%interface_uses %{
%}

%interface_begin %{
%}

....

%interface_end %{
%}

%interface_functions %{
%}

%interface_functions_wrapper %{
%}


implementation

initialization

uses

%implementation_uses %{
%}

%implementation_begin %{
%}

....

%implementation_end %{
%}


%implementation_functions %{
%}

%implementation_functions_wrapper %{
%}

%initialization %{
%}

finalization

%finalization %{
%}

end;


*/



/*

This is from the original code for Modula3

Report:
- It's not a good concept to use member variables or global variables
for passing parameters to functions.
It's not a good concept to use functions of superclasses for specific services.
E.g. For SWIG this means: Generating accessor functions for member variables
is the most common but no general task to be processed in membervariableHandler.
Better provide a service function which generates accessor function code
and equip this service function with all parameters needed for input (parse node)
and output (generated code).
- How can I make globalvariableHandler not to generate
interface functions to two accessor functions
(that don't exist) ?
- How can I generate a typemap that turns every C reference argument into
its Pascal counterpart, that is
void test(Complex &z);
PROCEDURE test(VAR z:Complex);
- neither $*n_mangle nor $*n_type nor $*n_ltype return the type without
pointer converted to delphi equivalent,
$*n_mangle is the variant closest to what I expect
- using a typemap like
typemap(paswrapintype) int * %{VAR $1_name: INTEGER%}
has the advantages:
- one C parameter can be turned into multiple PAS parameters
- the argument can be renamed
- using typemaps like
typemap(paswrapinmode) int * "VAR"
typemap(paswrapintype) int * "INTEGER"
has the advantages:
- multiple parameters with same type and default value can be bundled
- more conform to the other language modules
- Where takes the reduction of multi-typemaps place?
How can I preserve all parameters for functions of the intermediary class?
The answer is Getattrs(n,"tmap:pasrawintype:next")
- Char() can be used to transform a String to (char *)
which can be used for output with printf
- What is the while (checkAttribute()) loop in functionWrapper good for?
Appearently for skipping (numinputs=0) typemaps.
- SWIGTYPE const * - typemap is ignored, whereas
SWIGTYPE *       - typemap is invoked, why?
Had it been (const SWIGTYPE *) instead?
- enumeration items should definitely be equipped
with its plain numerical value
One could add tag 'numvalue' in CParse/parser.y,
but it is still possible that someone declares an
enumeration using a symbolic constant.
I have quickly hacked
that the successive number is assigned
if "enumvalue" has suffix "+1".
The ultimate solution would be to generate a C program
which includes the header and outputs all constants.
This program might be compiled and run
by 'make' or by SWIG and the resulting output is fed back to SWIG.
- It's a bad idea to interpret feature value ""
'disable feature' because the value ""
might be sensible in case of feature:delphi:oldprefix.
- What's the difference between "sym:name" and "name" ?
"name" is the original name and
"sym:name" is probably modified by the user using %rename
- Is it possible for 'configure' to find out if paspp is installed
and to invoke it for generated delphi files?
- It would be better to separate an arguments purpose and its name,
because an output variable with name "OUTPUT" is not very descriptive.
In case of PLPlot this could be solved by typedefs
that assign special purposes to the array types.
- Can one interpret $n_basetype as the identifier matched with SWIGTYPE ?

Swig's odds:
- arguments of type (Node *) for SWIG functions
should be most often better (const Node *):
Swig_symbol_qualified, Getattr, nodeType, parentNode
- unique identifier style instead of
NewString, Getattr, firstChild
- 'class'.name is qualified,
'enum'.name and 'enumitem'.name is not
- Swig_symbol_qualified() returns NIL for enumeration nodes

- Is there a function that creates a C representation of a SWIG type string?

ToDo:
- create WeakRefs only for resources returned by function marked with %newobject
-> part of output conversion
- clean typemap conception
- should a multi-typemap for paswrapouttype skip the corresponding input parameters?
when yes - How to handle inout-arguments? In this case like in-argument.
- C++ classes
- C++ exceptions
- allow for moving RECORD and OBJECT definitions
to separate files, with the main type called T
- call-back functions
- special option: fast access to class members by pointer arithmetic,
member offsets can be determined by a C++ program that print them.
- emit enumeration definitions when its first item is declared,
currently enumerations are emitted at the beginning of the file

Done:
- addThrow should convert the typemap by itself
- not possible because routine for attaching mapped types to parameter nodes
won't work for the function node
- turning error codes into exceptions
-> part of output value checking
- create WeakRefs for resources allocated by the library
-> part of output conversion
- TRY..FINALLY..END; can be omitted
- if there is no paswrapfreearg
- no exception can be raised in the body (empty RAISES) list
*/





#include "swigmod.h"

#include <limits.h>		// for INT_MAX
#include <ctype.h>

#include <vector>
#include <string>

using namespace std;


const char usageArgDir[] = "paswrapargdir typemap expect values: in, out, inout\n";

/* Hash type used for upcalls from C/C++ */
typedef DOH UpcallData;

class DELPHI:public Language {
public:
	enum block_type { no_block, constant, variable, blocktype, revelation };

private:
	struct PASFile {
		String *f;
		Hash *import;
		block_type bt;
		/* VC++ 6 doesn't allow the access to 'no_block'
		if it is a private member of DELPHI class */
		PASFile():f(NewString("")), import(NewHash()), bt(no_block) {
		};
		~PASFile() {
			Delete(f);
			Delete(import);
		};

		/* -----------------------------------------------------------------------------
		* enterBlock()
		*
		* Make sure that a given declaration is written to the right declaration block,
		* that is constants are written after "CONST" and so on ...
		* ----------------------------------------------------------------------------- */
		void enterBlock(block_type newbt) {
			static const char *ident[] = { "", "\nconst\n", "\nvar\n", "\ntype\n", "\nREVEAL\n" };
#ifdef DEBUG
			if ((bt < 0) || (4 < bt)) {
				printf("bt %d out of range\n", bt);
			};
#endif
			if (newbt != bt) {
				Append(f, ident[newbt]);
				bt = newbt;
			};
		};

	};

	static const char *usage;
	const String *empty_string;

	String * callconv;


	Hash *swig_types_hash;
	File *f_runtime;
	File *f_runtime_h;
	File *f_header;
	File *f_wrappers;
	File *f_init;
	File *f_directors;
	File *f_directors_h;


	String* m_namespace;
	bool opaque_record;
	bool proxy_flag;		// Flag for generating proxy classes
	bool have_default_constructor_flag;

	bool nowrap_function_flag;	// Flag for when wrapping a native function

	bool native_function_flag;	// Flag for when wrapping a native function
	bool enum_constant_flag;	// Flag for when wrapping an enum or constant
	bool static_flag;		// Flag for when wrapping a static functions or member variables
	bool wrapping_member_flag;	// Flag for when wrapping a member variable/enum/const
	bool global_variable_flag;	// Flag for when wrapping a global variable		bool unsafe_module;
	bool wrapping_constructor_flag; // Flag for when wrapping a class constructor
	bool unsafe_module;
	bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable

	bool enum_wrap_flag;
	String *outfile;

	bool old_variable_names;	// Flag for old style variable names in the intermediary class
	bool global_runtime_const_flag; // Flag for when wrapping a class constructor

	String * intf_uses;
	int enum_begin;
	String *pasraw_name;		// raw interface name
	PASFile pasraw_intf;		// raw interface
	PASFile pasraw_impl;		// raw implementation (usually empty)
	String *paswrap_name;		// wrapper module
	PASFile paswrap_intf;
	PASFile paswrap_impl;
	String *pasmakefile;
	String *targetlibrary;
	String *proxy_class_def;
	String *proxy_class_constructor_def;
	String *proxy_class_code;
	String *proxy_class_name;
	String *variable_name;	//Name of a variable being wrapped
	String *variable_type;	//Type of this variable
	String *enumeration_name;	//Name of the current enumeration type
//	Hash *enumeration_items;	//and its members


	Hash *nested_classes_hash;

	Hash *types_hash;	//and its members
	File *types_decl;		// raw implementation (usually empty)

	String *interface_uses;
	String *interface_begin;
	String *interface_end;	
	String *interface_functions;
	String *interface_functions_wrapper;
	String *implementation_uses;
	String *implementation_begin;
	String *implementation_end;
	String *implementation_functions;
	String *implementation_functions_wrapper;
	String *constant_initialization;
	String *initialization;
	String *finalization;
	Hash *reserved_keyword;
	String *wrapdllname;
	String *dllname;
	String *wrapsourcename;




//	int enumeration_max;
	Hash *enumeration_coll;	//Collection of all enumerations.
	/* The items are nodes with members:
	"items"  - hash of with key 'itemname' and content 'itemvalue'
	"max"    - maximum value in item list
	*/
	String *constant_values;
	String *constantfilename;
	String *renamefilename;
	String *typemapfilename;
	String *pasraw_imports;	//intermediary class imports from %pragma
	String *module_imports;	//module imports from %pragma
	String *pasraw_baseclass;	//inheritance for intermediary class class from %pragma
	String *module_baseclass;	//inheritance for module class from %pragma
	String *pasraw_interfaces;	//interfaces for intermediary class class from %pragma
	String *module_interfaces;	//interfaces for module class from %pragma
	String *pasraw_class_modifiers;	//class modifiers for intermediary class overriden by %pragma
	String *paswrap_modifiers;	//class modifiers for module class overriden by %pragma
	String *upcasts_code;		//C++ casts for inheritance hierarchies C++ code
	String *pasraw_cppcasts_code;	//C++ casts up inheritance hierarchies intermediary class code
	String *destructor_call;	//C++ destructor call if any

	String *director_callback_typedefs;	// Director function pointer typedefs for callbacks
	String *director_callbacks;	// Director callback function pointer member variables
	String *director_delegate_callback;	// Director callback method that delegates are set to call
	String *director_delegate_definitions;	// Director delegates definitions in proxy class
	String *director_delegate_instances;	// Director delegates member variables in proxy class
	String *director_method_types;	// Director method types
	String *director_connect_parms;	// Director delegates parameter list for director connect call


	// Director method stuff:
	List *dmethods_seq;
	Hash *dmethods_table;
	int n_dmethods;
	int n_directors;
	int first_class_dmethod;
	int curr_class_dmethod;

	enum type_additions { none, pointer, reference };

public:

	/* -----------------------------------------------------------------------------
	* DELPHI()
	* ----------------------------------------------------------------------------- */

	DELPHI():

	  pasraw_intf(),
		  pasraw_impl(),
		  paswrap_intf(),
		  paswrap_impl()

	  {

		  empty_string = NewString("");

		  callconv = 0;
		  swig_types_hash = NULL;
		  f_runtime = NULL;
		  f_runtime_h = NULL;
		  f_header = NULL;
		  f_wrappers = NULL;
		  f_init = NULL;
		  f_directors = NULL;
		  f_directors_h = NULL;
		  opaque_record = true;
		  proxy_flag = true;
		  have_default_constructor_flag = false;
		  nowrap_function_flag = false;
		  native_function_flag = false;
		  enum_constant_flag = false;
		  static_flag = false;
		  wrapping_member_flag = false;
		  global_variable_flag = false;		 
		  wrapping_constructor_flag = false;
		  unsafe_module = false;
		  variable_wrapper_flag = false;
		  enum_wrap_flag = false;
		  outfile = NULL;
		  old_variable_names = false;
		  global_runtime_const_flag = false;
		  pasraw_name = NULL;
		  paswrap_name = NULL;	  
		  pasmakefile = NULL;
		  targetlibrary= NULL;
		  proxy_class_def= NULL;
		  proxy_class_constructor_def= NULL;
		  proxy_class_code= NULL;
		  proxy_class_name= NULL;
		  variable_name= NULL;
		  variable_type= NULL;
		  enumeration_name= NULL;
//		  enumeration_items= NULL;
//		  enumeration_max= 0;
		  enumeration_coll= NULL;
		  constant_values= NULL;
		  constantfilename= NULL;
		  renamefilename= NULL;
		  typemapfilename= NULL;
		  pasraw_imports= NULL;
		  module_imports = NULL;
		  pasraw_baseclass= NULL;
		  module_baseclass= NULL;
		  pasraw_interfaces= NULL;
		  module_interfaces= NULL;
		  pasraw_class_modifiers= NULL;
		  paswrap_modifiers= NULL;
		  upcasts_code= NULL;
		  pasraw_cppcasts_code= NULL;
		  types_hash= NULL;
		  types_decl= NULL;
		  intf_uses= NULL;
		  dllname= NULL;
		  nested_classes_hash = NULL;
		  wrapsourcename= NULL;
		  director_callback_typedefs= NULL;
		  director_callbacks= NULL;
		  director_delegate_callback= NULL;
		  director_delegate_definitions= NULL;
		  director_delegate_instances= NULL;
		  director_method_types= NULL;
		  director_connect_parms= NULL;
		  dmethods_seq= NULL;
		  dmethods_table= NULL;
		  n_dmethods= 0;
		  n_directors= 0;
		  destructor_call = NULL;
		  reserved_keyword = NULL;
		  wrapdllname = NULL;
		  // SM 
		  director_language = 0;	
		  //		  String *name = NewString("self");
		  reserved_keyword = NewHash();
		  m_namespace = NewString("");

		  Setattr(reserved_keyword,"type", "1");
		  Setattr(reserved_keyword,"record", "1");
		  Setattr(reserved_keyword,"label", "1");
		  Setattr(reserved_keyword,"var", "1");
		  Setattr(reserved_keyword,"const", "1");
		  Setattr(reserved_keyword,"class", "1");
		  Setattr(reserved_keyword,"set", "1");
		  Setattr(reserved_keyword,"string", "1");
		  Setattr(reserved_keyword,"array", "1");
		  Setattr(reserved_keyword,"real", "1");
		  Setattr(reserved_keyword,"double", "1");
		  Setattr(reserved_keyword,"integer", "1");
		  Setattr(reserved_keyword,"char", "1");
		  Setattr(reserved_keyword,"byte", "1");
		  Setattr(reserved_keyword,"const", "1");
		  Setattr(reserved_keyword,"object", "1");
		  Setattr(reserved_keyword,"begin", "1");
		  Setattr(reserved_keyword,"end", "1");



	  }

	  virtual ~DELPHI()
	  {
		  Delete(reserved_keyword);
	  }

	  /************** some utility functions ***************/

	  int SplitString(const string& input, 
		  const string& delimiter, vector<string>& results, 
		  bool includeEmpties)
	  {
		  int iPos = 0;
		  int newPos = -1;
		  int sizeS2 = (int)delimiter.size();
		  int isize = (int)input.size();

		  if( 
			  ( isize == 0 )
			  ||
			  ( sizeS2 == 0 )
			  )
		  {
			  return 0;
		  }

		  vector<int> positions;

		  newPos = (int)input.find (delimiter, 0);

		  if( newPos < 0 )
		  { 
			  results.push_back(input);
			  return 0; 
		  }

		  int numFound = 0;

		  while( newPos >= iPos )
		  {
			  numFound++;
			  positions.push_back(newPos);
			  iPos = newPos;
			  newPos = (int)input.find (delimiter, iPos+sizeS2);
		  }

		  if( numFound == 0 )
		  {
			  return 0;
		  }

		  for( int i=0; i <= (int)positions.size(); ++i )
		  {
			  string s("");
			  if( i == 0 ) 
			  { 
				  s = input.substr( i, positions[i] ); 
			  }
			  else {
				  int offset = positions[i-1] + sizeS2;
				  if( offset < isize )
				  {
					  if( i == (int)positions.size() )
					  {
						  s = input.substr(offset);
					  }
					  else if( i > 0 )
					  {
						  s = input.substr( positions[i-1] + sizeS2, 
							  positions[i] - positions[i-1] - sizeS2 );
					  }
				  }
			  }
			  if( includeEmpties || ( s.size() > 0 ) )
			  {
				  results.push_back(s);
			  }
		  }
		  return numFound;
	  }

	  void RemoveNamespace(String * &tm)
	  {

		  if (tm == 0)
			  return;

		  //		  char *ns ;
		  //		  char *ctm ;
		  //		  char *next;

		  char tmp[1024];
		  strcpy(tmp, Char(tm));

		  vector<string> v;

		  SplitString(tmp,"::",v,true);

		  Delete(tm);

		  if (v.size())

			  tm = NewString(v.back().c_str());
		  else
			  tm = NewString("");

		  // Replace(tm,m_namespace,"", DOH_REPLACE_ANY );

		  /*
		  ctm = strtok (tmp,"::");

		  while (ctm != 0) 
		  {

		  next = strtok (0, "::");

		  if (!next) {

		  tm = NewString(ctm);
		  }

		  ctm = next;

		  }
		  */
		  return;
#if 0

		  if (ns != 0) {

			  char ss[256];
			  /*	if (ctm[0]=='P')
			  ctm++;*/
			  strncpy(ss, ctm, (int)ns - (int)ctm+2);
			  ss[(int)ns - (int)ctm+2]= 0;

			  Replace(tm,ss,"", DOH_REPLACE_ANY );

		  }
#endif
	  }

	  /* -----------------------------------------------------------------------------
	  * getMappedType()
	  *
	  * Return the type of 'p' mapped by 'map'.
	  * Print a standard warning if 'p' can't be mapped.
	  * ----------------------------------------------------------------------------- */

	  String *getMappedType(Node *p, const char *map, bool warn = true) {
		  String *mapattr = NewString("tmap:");
		  Append(mapattr, map);

		  String *tm = GetattrNew(p, (const char *)mapattr);
		  if ((tm == NIL)&&warn) {
			  //Swig_error("My Debugging",  101010, "=============> p1 : %s\n", p);
			  //Swig_error("My Debugging",  101010, "=============> map : %s\n", map);
			 // Swig_warning(WARN_DELPHI_TYPEMAP_TYPE_UNDEF, input_file, line_number,
			//	  "No '%s' typemap defined for type '%s'\n", map, SwigType_str(GetattrNew(p, "type"), 0));
		  }
		  Delete(mapattr);

		  //RemoveNamespace(tm);

		  return tm;
	  }
	  /* -----------------------------------------------------------------------------
	  * getMappedTypeNew()
	  *
	  * Similar to getMappedType but uses Swig_type_lookup_new.
	  * ----------------------------------------------------------------------------- */

	  String *getMappedTypeNew(Node *n, const char *map, const char *lname = "", bool warn = true) {

			 //String * ret = Getattr(n, "type");
			 //ret = checkGrammarWithString(ret);
			 //ret = checkTAndReplace_inHeader(ret, "TF");
			 //Setattr(n, "type", ret);


		  String * tm  = Swig_typemap_lookup(map, n, lname, 0);
		  //	String *tm = Swig_typemap_lookup_new(map, n, lname, 0);
		  if ((tm == NIL) && warn) {

			 // Swig_warning(WARN_DELPHI_TYPEMAP_TYPE_UNDEF, input_file, line_number,
				//  "No '%s' typemap defined for type '%s'\n", map, SwigType_str(GetattrNew(n, "type"), 0));
		  }  
		  //RemoveNamespace(tm);
		  tm = checkTAndReplace_inHeader(tm, "TF");
		  tm = checkGrammarWithString(tm);


		  return tm;
	  }

	  /* -----------------------------------------------------------------------------
	  * attachMappedType()
	  *
	  * Obtain the type mapped by 'map' and attach it to the node
	  * ----------------------------------------------------------------------------- */

	  void attachMappedType(Node *n, const char *map, const char *lname = "") {
		  //String *tm = Swig_typemap_lookup_new(map, n, lname, 0);
		  String *tm = Swig_typemap_lookup(map, n, lname, 0);
		  if (tm != NIL) {
			  String *attr = NewStringf("tmap:%s", map);
			  tm = checkGrammarWithString(tm);

			  Setattr(n, attr, tm);
			  Delete(attr);
		  }
	  }

	  /* -----------------------------------------------------------------------------
	  * skipIgnored()
	  *
	  * Skip all parameters that have 'numinputs=0'
	  * with respect to a given typemap.
	  * ----------------------------------------------------------------------------- */

	  Node *skipIgnored(Node *p, const char *map) {
		  String *niattr = NewStringf("tmap:%s:numinputs", map);
		  String *nextattr = NewStringf("tmap:%s:next", map);

		  while ((p != NIL) && checkAttribute(p, niattr, "0")) {
			  p = Getattr(p, nextattr);
		  }

		  Delete(nextattr);
		  Delete(niattr);
		  return p;
	  }

	  /* -----------------------------------------------------------------------------
	  * isInParam()
	  * isOutParam()
	  *
	  * Check if the parameter is intended for input or for output.
	  * ----------------------------------------------------------------------------- */

	  bool isInParam(Node *p) {
		  String *dir = GetattrNew(p, "tmap:paswrapargdir");
		  //printf("dir for %s: %s\n", Char(GetattrNew(p,"name")), Char(dir));
		  if ((dir == NIL) || (Strcmp(dir, "in") == 0)
			  || (Strcmp(dir, "inout") == 0)) {
				  return true;
		  } else if (Strcmp(dir, "out") == 0) {
			  return false;
		  } else {
			  printf(usageArgDir);
			  return false;
		  }
	  }

	  bool isOutParam(Node *p) {
		  String *dir = GetattrNew(p, "tmap:paswrapargdir");
		  if ((dir == NIL) || (Strcmp(dir, "in") == 0)) {
			  return false;
		  } else if ((Strcmp(dir, "out") == 0) || (Strcmp(dir, "inout") == 0)) {
			  return true;
		  } else {
			  printf(usageArgDir);
			  return false;
		  }
	  }

	  /* -----------------------------------------------------------------------------
	  * printAttrs()
	  *
	  * For debugging: Show all attributes of a node and their values.
	  * ----------------------------------------------------------------------------- */
	  void printAttrs(Node *n) {
		  Iterator it;
		  for (it = First(n); it.key != NIL; it = Next(it)) {
			  printf("%s = %s\n", Char(it.key), Char(GetattrNew(n, (const char *)it.key)));
		  }
	  }

	  /* -----------------------------------------------------------------------------
	  * hasPrefix()
	  *
	  * Check if a string have a given prefix.
	  * ----------------------------------------------------------------------------- */
	  bool hasPrefix(const String *str, const String *prefix) {
		  int len_prefix = Len(prefix);
		  return (Len(str) > len_prefix)
			  && (Strncmp(str, prefix, len_prefix) == 0);
	  }

	  /* -----------------------------------------------------------------------------
	  * getQualifiedName()
	  *
	  * Return fully qualified identifier of n.
	  * ----------------------------------------------------------------------------- */
#if 0
	  // Swig_symbol_qualified returns NIL for enumeration nodes
	  String *getQualifiedName(Node *n) {
		  String *qual = Swig_symbol_qualified(n);
		  String *name = GetattrNew(n, "name");
		  if (hasContent(qual)) {
			  return NewStringf("%s::%s", qual, name);
		  } else {
			  return name;
		  }
	  }
#else
	  String *getQualifiedName(Node *n) {
		  String *name = Copy(GetattrNew(n, "name"));
		  n = parentNode(n);
		  while (n != NIL) {
			  const String *type = nodeType(n);
			  if ((Strcmp(type, "class") == 0) || (Strcmp(type, "struct") == 0) || (Strcmp(type, "namespace") == 0)) {
				  String *newname = NewStringf("%s.%s", GetattrNew(n, "name"), name);
				  Delete(name);
				  //name = newname;
				  // Hmpf, the class name is already qualified.
				  return newname;
			  }
			  n = parentNode(n);
		  }
		  //printf("qualified name: %s\n", Char(name));
		  return name;
	  }
#endif

	  /* -----------------------------------------------------------------------------
	  * nameTodelphi()
	  *
	  * Turn usual C identifiers like "this_is_an_identifier"
	  * into usual Pascal identifier like "thisIsAnIdentifier"
	  * ----------------------------------------------------------------------------- */
	  String *nameToDelphi(const String *sym, bool leadingCap) {
		  int len_sym = Len(sym);
		  char *csym = Char(sym);
		  char *passym = new char[len_sym + 1];
		  int i, j;
		  bool cap = leadingCap;
		  for (i = 0, j = 0; j < len_sym; j++) {
			  char c = csym[j];
			  if ((c == '_') || (c == ':')) {
				  cap = true;
			  } else {
				  if (isdigit(c)) {
					  passym[i] = c;
					  cap = true;
				  } else {
					  if (cap) {
						  passym[i] = toupper(c);
					  } else {
						  passym[i] = tolower(c);
					  }
					  cap = false;
				  }
				  i++;
			  }
		  }
		  passym[i] = 0;
		  String *result = NewString(passym);
		  delete[]passym;
		  return result;
	  }

	  /* -----------------------------------------------------------------------------
	  * capitalizeFirst()
	  *
	  * Make the first character upper case.
	  * ----------------------------------------------------------------------------- */
	  String *capitalizeFirst(const String *str) {
		  return NewStringf("%c%s", toupper(*Char(str)), Char(str) + 1);
	  }

	  /* -----------------------------------------------------------------------------
	  * prefixedNameToDelphi()
	  *
	  * If feature Delphi:oldprefix and Delphi:newprefix is present
	  * and the C identifier has leading 'oldprefix'
	  * then it is replaced by the 'newprefix'.
	  * The rest is converted to Modula style.
	  * ----------------------------------------------------------------------------- */
	  String *prefixedNameToDelphi(Node *n, const String *sym, bool leadingCap) {
		  String *oldPrefix = GetattrNew(n, "feature:delphi:oldprefix");
		  String *newPrefix = GetattrNew(n, "feature:delphi:newprefix");
		  String *result = NewString("");
		  char *short_sym = Char(sym);
		  // if at least one prefix feature is present
		  // the replacement takes place
		  if ((oldPrefix != NIL) || (newPrefix != NIL)) {
			  if ((oldPrefix == NIL) || hasPrefix(sym, oldPrefix)) {
				  short_sym += Len(oldPrefix);
				  if (newPrefix != NIL) {
					  Append(result, newPrefix);
				  }
			  }
		  }
		  String *suffix = nameToDelphi(short_sym, leadingCap || hasContent(newPrefix));
		  Append(result, suffix);
		  Delete(suffix);
		  return result;
	  }

	  /* -----------------------------------------------------------------------------
	  * hasContent()
	  *
	  * Check if the string exists and contains something.
	  * ----------------------------------------------------------------------------- */
	  bool hasContent(const String *str) {
		  return (str != NIL) && (Strcmp(str, "") != 0);
	  }

	  /* -----------------------------------------------------------------------------
	  * openWriteFile()
	  *
	  * Caution: The file must be freshly allocated and will be destroyed
	  *          by this routine.
	  * ----------------------------------------------------------------------------- */

	  File *openWriteFile(String *name) {
		  File *file = NewFile(name, "w", SWIG_output_files());
		  if (!file) {
			  FileErrorDisplay(name);
			  SWIG_exit(EXIT_FAILURE);
		  }
		  Delete(name);
		  return file;
	  }

	  /* -----------------------------------------------------------------------------
	  * aToL()
	  *
	  * like atol but with additional user warning
	  * ----------------------------------------------------------------------------- */

	  long aToL(const String *value) {
		  char *endptr;
		  long numvalue = strtol(Char(value), &endptr, 0);
		  if (*endptr != 0) {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "The string <%s> does not denote a numeric value.\n", value);
		  }
		  return numvalue;
	  }

	  /* -----------------------------------------------------------------------------
	  * strToL()
	  *
	  * like strtol but returns if the conversion was successful
	  * ----------------------------------------------------------------------------- */

	  bool strToL(const String *value, long &numvalue) {
		  char *endptr;
		  numvalue = strtol(Char(value), &endptr, 0);
		  return (*endptr == 0);
	  }

	  /* -----------------------------------------------------------------------------
	  * evalExpr()
	  *
	  * Evaluate simple expression as they may occur in "enumvalue" attributes.
	  * ----------------------------------------------------------------------------- */

	  bool evalExpr(String *value, long &numvalue) {
		  // Split changes file status of String and thus cannot receive 'const' strings
		  //printf("evaluate <%s>\n", Char(value));
		  List *summands = Split(value, '+', INT_MAX);
		  Iterator sm = First(summands);
		  numvalue = 0;
		  for (; sm.item != NIL; sm = Next(sm)) {
			  String *smvalue = GetattrNew(constant_values, (const char *)sm.item);
			  long smnumvalue;
			  if (smvalue != NIL) {
				  if (!strToL(smvalue, smnumvalue)) {
					  //printf("evaluation: abort 0 <%s>\n", Char(smvalue));
					  return false;
				  }
			  } else {
				  if (!strToL(sm.item, smnumvalue)) {
					  //printf("evaluation: abort 1 <%s>\n", Char(sm));
					  return false;
				  }
			  }
			  numvalue += smnumvalue;
		  }
		  //printf("evaluation: return %ld\n", numvalue);
		  return true;
	  }

	  /* -----------------------------------------------------------------------------
	  * log2()
	  *
	  * Determine the position of the single bit of a power of two.
	  * Returns true if the given number is a power of two.
	  * ----------------------------------------------------------------------------- */

	  bool log2(long n, long &exp) {
		  exp = 0;
		  while (n > 0) {
			  if ((n & 1) != 0) {
				  return n == 1;
			  }
			  exp++;
			  n >>= 1;
		  }
		  return false;
	  }

	  /* -----------------------------------------------------------------------------
	  * writeArg
	  *
	  * Write a function argument or RECORD entry definition.
	  * Bundles arguments of same type and default value.
	  * 'name.next==NIL' denotes the end of the entry or argument list.
	  * ----------------------------------------------------------------------------- */

	  bool equalNilStr(const String *str0, const String *str1) {
		  if (str0 == NIL) {
			  return (str1 == NIL);
			  //return (str0==NIL) == (str1==NIL);
		  } else {
			  return (str1 != NIL) && (Cmp(str0, str1) == 0);
			  //return Cmp(str0,str1)==0;
		  }
	  }

	  struct writeArgState {
		  String *mode, *name, *type, *value;
		  bool hold;
		  writeArgState():mode(NIL), name(NIL), type(NIL), value(NIL), hold(false) {
		  };
	  };

	  void writeArg(File *f, writeArgState & state, String *mode, String *name, String *type, String *value) {
		  /* skip the first argument,
		  only store the information for the next call in this case */

		  char *_name = Char(name); 
		  //char *_mode = Char(mode);
		  //char *_type = Char(type);
		  //char *_value = Char(value);


		  String * newname;

		  if (name) {

			  String * __name = NewStringf(Swig_string_lower(name) );

			  if (_name && GetattrNew(reserved_keyword, (const char *)_name) != 0) {

				  newname = NewStringf("_%s", name);

			  }
			  else
				  newname = Copy(name);


			  Delete(__name);

		  }
		  else
			  newname = 0;

		  if (state.name != NIL) {
			  if ((!state.hold) && (state.mode != NIL)) {
				  Printf(f, "%s ", state.mode);
			  }
			  if ((newname != NIL) && equalNilStr(state.mode, mode) && equalNilStr(state.type, type) && (state.value == NIL) && (value == NIL)
				  /* the same expression may have different values
				  due to side effects of the called function */
				  /*equalNilStr(state.value,value) */
				  ) {
					  Printf(f, "%s, ", state.name);
					  state.hold = true; // SM
			  } else {
				  Append(f, state.name);
				  if (state.type != NIL) {
					  Printf(f, ": %s", state.type);
				  }
				  if (state.value != NIL) {
					  Printf(f, ":= %s", state.value);
				  }
				  Append(f, ";\n");
				  state.hold = false;
			  }
		  }
		  /* at the next call the current argument will be the previous one */
		  state.mode = mode;
		  state.name = newname;
		  state.type = type;
		  state.value = value;
	  }

	  /* -----------------------------------------------------------------------------
	  * getProxyName()
	  *
	  * Test to see if a type corresponds to something wrapped with a proxy class
	  * Return NULL if not otherwise the proxy class name
	  * ----------------------------------------------------------------------------- */

	  String *getProxyName(SwigType *t) {
		  if (proxy_flag) {
			  Node *n = classLookup(t);
			  if (n) {
				  return GetattrNew(n, "sym:name");
			  }
		  }
		  return NULL;
	  }

	  /*************** language processing ********************/

	  /* ------------------------------------------------------------
	  * main()
	  * ------------------------------------------------------------ */

	  virtual void main(int argc, char *argv[]) {

		  SWIG_library_directory("delphi");

		  callconv = NewString("stdcall");

		  wrapdllname = NewString("");
		  dllname = NewString("");
		  wrapsourcename = NewString("");

		  // Look for certain command line options
		  for (int i = 1; i < argc; i++) {
			  if (argv[i]) {		

				  if (strcmp(argv[i], "-wrapdllname") == 0) {
					  if (argv[i + 1]) {
						  wrapdllname = NewString(argv[i + 1]);
						  Swig_mark_arg(i);
						  Swig_mark_arg(i + 1);
						  i++;
					  } else {
						  Swig_arg_error();
					  }
				  }	  
				  else 
					  if (strcmp(argv[i], "-dllname") == 0) {
						  if (argv[i + 1]) {
							  dllname = NewString(argv[i + 1]);
							  Swig_mark_arg(i);
							  Swig_mark_arg(i + 1);
							  i++;
						  } else {
							  Swig_arg_error();
						  }
					  }	  
					  else 
						  if (strcmp(argv[i], "-wrapsourcename") == 0) {
							  if (argv[i + 1]) {
								  wrapsourcename = NewString(argv[i + 1]);
								  Swig_mark_arg(i);
								  Swig_mark_arg(i + 1);
								  i++;
							  } else {
								  Swig_arg_error();
							  }
						  }	  
						  else 
							  if (strcmp(argv[i], "-callconv") == 0) {
								  if (argv[i + 1]) {
									  callconv = NewString(argv[i + 1]);
									  Swig_mark_arg(i);
									  Swig_mark_arg(i + 1);
									  i++;
								  } else {
									  Swig_arg_error();
								  }
							  }	  
							  else if (strcmp(argv[i], "-generateconst") == 0) {
								  if (argv[i + 1]) {
									  constantfilename = NewString(argv[i + 1]);
									  Swig_mark_arg(i);
									  Swig_mark_arg(i + 1);
									  i++;
								  } else {
									  Swig_arg_error();
								  }
							  } else if (strcmp(argv[i], "-generaterename") == 0) {
								  if (argv[i + 1]) {
									  renamefilename = NewString(argv[i + 1]);
									  Swig_mark_arg(i);
									  Swig_mark_arg(i + 1);
									  i++;
								  } else {
									  Swig_arg_error();
								  }
							  } else if (strcmp(argv[i], "-generatetypemap") == 0) {
								  if (argv[i + 1]) {
									  typemapfilename = NewString(argv[i + 1]);
									  Swig_mark_arg(i);
									  Swig_mark_arg(i + 1);
									  i++;
								  } else {
									  Swig_arg_error();
								  }
							  } else if (strcmp(argv[i], "-noproxy") == 0) {
								  Swig_mark_arg(i);
								  proxy_flag = false;
							  } else if (strcmp(argv[i], "-runtime_const") == 0) {
								  Swig_mark_arg(i);
								  global_runtime_const_flag = true;
							  } else if (strcmp(argv[i], "-opaquerecord") == 0) {
								  Swig_mark_arg(i);
								  opaque_record = true;
							  } else if (strcmp(argv[i], "-oldvarnames") == 0) {
								  Swig_mark_arg(i);
								  old_variable_names = true;
							  } else if (strcmp(argv[i], "-help") == 0) {
								  Printf(stdout, "%s\n", usage);
							  }
			  }
		  }

		  // Add a symbol to the parser for conditional compilation
		  Preprocessor_define("SWIGDELPHI 1", 0);

		  // Add typemap definitions
		  SWIG_typemap_lang("delphi");
		  SWIG_config_file("delphi.swg");

		  allow_overloading();

	  }

	  /* ---------------------------------------------------------------------
	  * top()
	  * --------------------------------------------------------------------- */

	  virtual int top(Node *n) {
		  if (hasContent(constantfilename) || hasContent(renamefilename) || hasContent(typemapfilename)) {
			  int result = SWIG_OK;
			  if (hasContent(constantfilename)) {
				  result = generateConstantTop(n) && result;
			  }
			  if (hasContent(renamefilename)) {
				  result = generateRenameTop(n) && result;
			  }
			  if (hasContent(typemapfilename)) {
				  result = generateTypemapTop(n) && result;
			  }
			  return result;
		  } else {
			  return generatePASTop(n);
		  }
	  }

	  void scanConstant(File *file, Node *n) {
		  Node *child = firstChild(n);
		  while (child != NIL) {
			  String *constname = NIL;
			  String *type = nodeType(child);
			  if ((Strcmp(type, "enumitem") == 0)
				  || (Strcmp(type, "constant") == 0)) {
#if 1
					  constname = getQualifiedName(child);
#else
					  constname = GetattrNew(child, "value");
					  if ((!hasContent(constname))
						  || (('0' <= *Char(constname)) && (*Char(constname) <= '9'))) {
							  constname = GetattrNew(child, "name");
					  }
#endif
			  }
			  if (constname != NIL) {
				  Printf(file, "  printf(\"%%%%constnumeric(%%Lg) %s;\\n\", (long double)%s);\n", constname, constname);
			  }
			  scanConstant(file, child);
			  child = nextSibling(child);
		  }
	  }

	  int generateConstantTop(Node *n) {
		  File *file = openWriteFile(NewStringf("%s.c", constantfilename));
		  if (CPlusPlus) {
			  Printf(file, "#include <cstdio>\n");
		  } else {
			  Printf(file, "#include <stdio.h>\n");
		  }
		  Printf(file, "#include \"%s\"\n", input_file);
		  Printf(file, "\n");
		  Printf(file, "int main (int argc, char *argv[]) {\n");
		  Printf(file, "\
					   /*This progam must work for floating point numbers and integers.\n\
					   Thus all numbers are converted to double precision floating point format.*/\n");
		  scanConstant(file, n);
		  Printf(file, "  return 0;\n");
		  Printf(file, "}\n");
		  Delete(file);
		  return SWIG_OK;
	  }

	  void scanRename(File *file, Node *n) {
		  Node *child = firstChild(n);
		  //Swig_error("My Debugging", 101010, "=============> scanRename n : %s\n", n);
		  while (child != NIL) {
			  //Swig_error("My Debugging", 101010, "=============> scanRename child : %s\n", n);
			  String *type = nodeType(child);
			  if (Strcmp(type, "cdecl") == 0) {
				  ParmList *p = Getattr(child, "parms");
				  if (p != NIL) {
					  String *name = getQualifiedName(child);
					  String *pasname = nameToDelphi(name, true);
					  /*don't know how to get the original C type identifiers */
					  //String *arguments = createCSignature (child);
					  Printf(file, "%%rename(\"%s\") %s;\n", pasname, name);
					  /*Printf(file, "%%rename(\"%s\") %s %s(%s);\n",
					  pasname, GetattrNew(n,"type"), name, arguments); */
					  Delete(name);
					  Delete(pasname);
					  //Delete (arguments);
				  }
			  }
			  scanRename(file, child);
			  child = nextSibling(child);
		  }
	  }

	  int generateRenameTop(Node *n) {
		  File *file = openWriteFile(NewStringf("%s.i", renamefilename));
		  Printf(file, "\
					   /* This file was generated from %s\n\
					   by SWIG with option -generaterename. */\n\
					   \n", input_file);
		  scanRename(file, n);
		  Delete(file);
		  return SWIG_OK;
	  }

	  void scanTypemap(File *file, Node *n) {
		  Node *child = firstChild(n);
		  while (child != NIL) {
			  String *type = nodeType(child);
			  //printf("nodetype %s\n", Char(type));
			  String *storage = GetattrNew(child, "storage");
			  if ((Strcmp(type, "class") == 0) || ((Strcmp(type, "cdecl") == 0) && (storage != NIL)
				  && (Strcmp(storage, "typedef") == 0))) {
					  String *name = getQualifiedName(child);
					  String *pasname = nameToDelphi(name, true);
					  Printf(file, "%%typemap(\"paswrapintype\") %s %%{%s%%}\n", name, pasname);
					  Printf(file, "%%typemap(\"pasrawintype\") %s %%{%s%%}\n", name, pasname);
					  Printf(file, "\n");
			  }
			  scanTypemap(file, child);
			  child = nextSibling(child);
		  }
	  }

	  int generateTypemapTop(Node *n) {
		  File *file = openWriteFile(NewStringf("%s.i", typemapfilename));
		  Printf(file, "\
					   /* This file was generated from %s\n\
					   by SWIG with option -generatetypemap. */\n\
					   \n", input_file);
		  scanTypemap(file, n);
		  Delete(file);
		  return SWIG_OK;
	  }
	  void emitTypes(File *f_swigtype, String *classname, SwigType *type) {
		  String *swigtype = NewString("");

		  // Emit banner name
		  emitBanner(f_swigtype);

		  // Pure Pascal baseclass and interfaces
		  const String *pure_baseclass = typemapLookup("pasbase", type, WARN_NONE);
		  const String *pure_interfaces = typemapLookup("pasinterfaces", type, WARN_NONE);

		  // Emit the class
		  Printv(swigtype, typemapLookup("pasimports", type, WARN_NONE),	// Import statements
			  "\n", typemapLookup("pasclassmodifiers", type, WARN_DELPHI_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers
			  " class $pasclassname",	// Class name and bases
			  *Char(pure_baseclass) ? " : " : "", pure_baseclass, *Char(pure_interfaces) ?	// Interfaces
			  " : " : "", pure_interfaces, " {\n", "  private IntPtr swigCPtr;\n", "\n", "  ", typemapLookup("pasptrconstructormodifiers", type, WARN_DELPHI_TYPEMAP_PTRCONSTMOD_UNDEF),	// pointer constructor modifiers
			  " $pasclassname(IntPtr cPtr, bool bFutureUse) {\n",	// Constructor used for wrapping pointers
			  "    swigCPtr = cPtr;\n", "  }\n", "\n", "  protected $pasclassname() {\n",	// Default constructor
			  "    swigCPtr = IntPtr.Zero;\n", "  }\n", typemapLookup("pasgetcptr", type, WARN_DELPHI_TYPEMAP_GETCPTR_UNDEF),	// getCPtr method
			  typemapLookup("pascode", type, WARN_NONE),	// extra Pascal code
			  "}\n", "\n", NIL);

		  Replaceall(swigtype, "$pasclassname", classname);
		  Printv(f_swigtype, swigtype, NIL);


		  Delete(swigtype);
	  }



	  int generatePASTop(Node *n) {




		  /* Initialize all of the output files */
		  outfile = GetattrNew(n, "outfile");
		  String *outfile_h = GetattrNew(n, "outfile_h");

		  f_runtime = NewFile(outfile, "w", SWIG_output_files());
		  if (!f_runtime) {
			  FileErrorDisplay(outfile);
			  SWIG_exit(EXIT_FAILURE);
		  }

		  if (directorsEnabled()) {
			  if (!outfile_h) {
				  Printf(stderr, "Unable to determine outfile_h\n");
				  SWIG_exit(EXIT_FAILURE);
			  }
			  f_runtime_h = NewFile(outfile_h, "w", SWIG_output_files());
			  if (!f_runtime_h) {
				  FileErrorDisplay(outfile_h);
				  SWIG_exit(EXIT_FAILURE);
			  }
		  }

		  f_init = NewString("");
		  f_header = NewString("");
		  f_wrappers = NewString("");
		  f_directors_h = NewString("");
		  f_directors = NewString("");

		  pasmakefile = NewString("");

		  /* Register file targets with the SWIG file handler */
		  Swig_register_filebyname("header", f_header);
		  Swig_register_filebyname("wrapper", f_wrappers);
		  Swig_register_filebyname("runtime", f_runtime);
		  Swig_register_filebyname("init", f_init);

		  Swig_register_filebyname("director", f_directors);
		  Swig_register_filebyname("director_h", f_directors_h);


		  Swig_register_filebyname("pasrawintf", pasraw_intf.f);
		  Swig_register_filebyname("pasrawimpl", pasraw_impl.f);
		  Swig_register_filebyname("paswrapintf", paswrap_intf.f);
		  Swig_register_filebyname("paswrapimpl", paswrap_impl.f);



		  interface_uses = NewString("");
		  interface_begin= NewString("");
		  interface_end= NewString("");
		  interface_functions= NewString("");
		  interface_functions_wrapper= NewString("\n// Functions Wrapper \n\n");
		  implementation_uses= NewString("");
		  implementation_begin= NewString("");
		  implementation_end= NewString("");
		  implementation_functions= NewString("");
		  implementation_functions_wrapper= NewString("\n// Functions Wrapper \n\n");
		  implementation_end= NewString("");

		  initialization= NewString("\n\n//initialization\n\n");
		  finalization= NewString("\n\n//finalization\n\n");

		  constant_initialization = NewString("\n\n// constant initialization\n\n");



		  //Swig_register_filebyname("ugo",  interface_uses); 
		  Swig_register_filebyname("interface_uses",  interface_uses); 
		  Swig_register_filebyname("interface_begin",  interface_begin);
		  Swig_register_filebyname("interface_end",  interface_end);
		  Swig_register_filebyname("interface_functions",  interface_functions);
		  Swig_register_filebyname("interface_functions_wrapper",  interface_functions_wrapper);
		  Swig_register_filebyname("implementation_uses",  implementation_uses);
		  Swig_register_filebyname("implementation_begin",  implementation_begin);
		  Swig_register_filebyname("implementation_end",  implementation_end);
		  Swig_register_filebyname("implementation_functions",  implementation_functions);
		  Swig_register_filebyname("implementation_functions_wrapper",  implementation_functions_wrapper);
		  Swig_register_filebyname("initialization",  initialization);
		  Swig_register_filebyname("finalization",  finalization);



		  Swig_register_filebyname("pasmakefile", pasmakefile);

		  swig_types_hash = NewHash();

		  String *name = GetattrNew(n, "name");
		  // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
		  Node *optionsnode = Getattr(Getattr(n, "module"), "options");
		  if (optionsnode != NIL) {
			  String *pasraw_name_tmp = GetattrNew(optionsnode, "pasrawname");
			  if (pasraw_name_tmp != NIL) {
				  pasraw_name = Copy(pasraw_name_tmp);
			  }


			  /* check if directors are enabled for this module.  note: this 
			  * is a "master" switch, without which no director code will be
			  * emitted.  %feature("director") statements are also required
			  * to enable directors for individual classes or methods.
			  *
			  * use %module(directors="1") modulename at the start of the 
			  * interface file to enable director generation.
			  */
			  if (Getattr(optionsnode, "directors")) {
				  allow_directors();
			  }
		  }
		  if (pasraw_name == NIL) {
			  pasraw_name = NewStringf("%s", name);
		  }
		  Setattr(paswrap_impl.import, pasraw_name, "");

		  paswrap_name = Copy(name);

		  proxy_class_constructor_def = NewString("");
		  proxy_class_def = NewString("");
		  proxy_class_code = NewString("");
		  pasraw_baseclass = NewString("");
		  pasraw_interfaces = NewString("");
		  pasraw_class_modifiers = NewString("");	// package access only to the intermediary class by default
		  pasraw_imports = NewString("");
		  pasraw_cppcasts_code = NewString("");
		  paswrap_modifiers = NewString("public");
		  module_baseclass = NewString("");
		  module_interfaces = NewString("");
		  module_imports = NewString("");
		  upcasts_code = NewString("");

		  Swig_banner(f_runtime);	// Print the SWIG banner message

		  if (directorsEnabled()) {
			  Printf(f_runtime, "\n\n#ifndef SWIG_DIRECTORS\n#define SWIG_DIRECTORS\n#endif\n\n");

			  char module_class_name[] = "CLASS";

			  /* Emit initial director header and director code: */
			  Swig_banner(f_directors_h);
			  Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module_class_name);
			  Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module_class_name);

			  Printf(f_directors, "\n\n");
			  Printf(f_directors, "/* ---------------------------------------------------\n");
			  Printf(f_directors, " * C++ director class methods\n");
			  Printf(f_directors, " * --------------------------------------------------- */\n\n");
			  if (outfile_h)
				  Printf(f_directors, "#include \"%s\"\n\n", Swig_file_filename(outfile_h));
		  }


		  String *wrapper_name = NewString("");

		  Printf(wrapper_name, "Delphi_%%f", pasraw_name);
		  //	Swig_name_register((char *) "wrapper", Char(wrapper_name));
		  Swig_name_register((char *) "wrapper", (char*)"Delphi_%f");

		  if (old_variable_names) {
			  Swig_name_register((char *) "set", (char *) "set_%v");
			  Swig_name_register((char *) "get", (char *) "get_%v");
		  }

		  Delete(wrapper_name);

		  Printf(f_wrappers, "\n#ifdef __cplusplus\n");
		  Printf(f_wrappers, "extern \"C\" {\n");
		  Printf(f_wrappers, "#endif\n\n");

		  constant_values = NewHash();
		  scanForConstPragmas(n);
		  enumeration_coll = NewHash();
		  collectEnumerations(enumeration_coll, n);

		  types_hash = NewHash();
		  nested_classes_hash = NewHash();
		  //	types_decl = openWriteFile(NewStringf("%s%s.inc", SWIG_output_directory(), pasraw_name));
		  Swig_register_filebyname("delphi_typesdecl", types_decl);


		  if (Strcmp(dllname, "") == 0)
			  dllname = NewStringf("%s.dll",pasraw_name);

		  if (Strcmp(wrapdllname, "") == 0)
			  wrapdllname = NewStringf("%s.dll",pasraw_name);


		  Printf(implementation_begin,"\nconst __DLLNAME= '%s';\n\n", dllname);
		  Printf(implementation_begin,"\nconst __WRAPDLLNAME= '%s';\n\n", wrapdllname);


		  /* Emit code */
		  Language::top(n);

		  if (directorsEnabled()) {
			  // Insert director runtime into the f_runtime file (make it occur before %header section)
			  Swig_insert_file("director.swg", f_runtime);
		  }



#if 0
		  // Generate pasmakefile
		  // This will be unnecessary if SWIG is invoked from Quake.
		  {
			  File *file = openWriteFile(NewStringf("%spasmakefile", SWIG_output_directory()));

			  Printf(file, "%% automatically generated quake file for %s\n\n", name);

			  /* Write the fragments written by '%insert'
			  collected while 'top' processed the parse tree */
			  Printv(file, pasmakefile, NIL);

			  Printf(file, "import(\"libpas\")\n");
			  //Printf(file, "import_lib(\"%s\",\"/usr/lib\")\n", name);
			  Printf(file, "module(\"%s\")\n", pasraw_name);
			  Printf(file, "module(\"%s\")\n\n", paswrap_name);

			  if (targetlibrary != NIL) {
				  Printf(file, "library(\"%s\")\n", targetlibrary);
			  } else {
				  Printf(file, "library(\"pas%s\")\n", name);
			  }
			  Delete(file);
		  }
#endif 
#if 0
		  // Generate the raw interface
		  {
			  File *file = openWriteFile(NewStringf("%s%s.inc", SWIG_output_directory(), pasraw_name));

			  emitBanner(file);

			  Printf(file, "interface %s;\n\n", pasraw_name);

			  emitImportStatements(pasraw_intf.import, file);
			  Printf(file, "\n");

			  // Write the interface generated within 'top'
			  Printv(file, pasraw_intf.f, NIL);

			  // Printf(file, "\nEND %s.\n", pasraw_name);
			  Delete(file);
		  }

		  // Generate the raw module
		  {
			  File *file = openWriteFile(NewStringf("%s%s.pas", SWIG_output_directory(), pasraw_name));

			  emitBanner(file);

			  Printf(file, "{$include '%s'};\n\n", NewStringf("%s.inc",  pasraw_name));

			  Printf(file, "implementation\n\n", pasraw_name);

			  emitImportStatements(pasraw_impl.import, file);
			  Printf(file, "\n");

			  // will be empty usually
			  Printv(file, pasraw_impl.f, NIL);

			  Printf(file, "initialization\n");
			  Printf(file, "finalization\n");
			  Printf(file, "end.\n");
			  Delete(file);
		  }
#else
		  // Generate the raw interface


		  {
			  File *file = openWriteFile(NewStringf("%s%s.pas", SWIG_output_directory(), pasraw_name));

			  emitBanner(file);

			  Printf(file, "unit %s;\n\n", pasraw_name);

			  Printf(file, "\n{$define %s_FUNCTION_WRAPPER}\n\n",  pasraw_name);
			  Printf(file, "\n{$define %s_CLASS_WRAPPER}\n\n",  pasraw_name);


			  //implementation

			  Printf(file, "interface\n\n");


			  {
				  Iterator it = First(enumeration_coll);
				  if (it.key != NIL) {
					  Printf(file, "type\n");
				  }
				  for (; it.key != NIL; it = Next(it)) {
					  Printf(file, "\n");
					  emitEnumeration(file, it.key, it.item);
				  }

			  }


			  emitImportStatements(pasraw_intf.import, file);
			  Printf(file, "\n");





			  //	  Printv(file, interface_uses, NIL);
			  Printv(file, interface_begin, NIL);

			  // Write the interface generated within 'top'
			  Printv(file, pasraw_intf.f, NIL);


			  Printv(file, interface_end, NIL);
			  Printv(file, interface_functions, NIL);


			  Printf(file, "\n{$ifdef %s_CLASS_WRAPPER}\n",  pasraw_name);
			  Printv(file, paswrap_intf.f, NIL);	
			  Printf(file, "\n{$endif} //%s_CLASS_WRAPPER\n",  pasraw_name);


			  Printf(file, "\n{$ifdef %s_FUNCTION_WRAPPER}\n",  pasraw_name);
			  Printv(file, interface_functions_wrapper, NIL);
			  Printf(file, "\n{$endif} //%s_FUNCTION_WRAPPER\n",  pasraw_name);





			  // Output a Pascal type wrapper class for each SWIG type
			  for (Iterator swig_type = First(swig_types_hash); swig_type.item != NIL; swig_type = Next(swig_type)) {

				  //		emitTypes(file, swig_type.key, swig_type.item);

				  //			emitTypeWrapperClass(swig_type.key, swig_type.item);
			  }	

			  //implementation

			  Printf(file, "\nimplementation\n\n", pasraw_name);

			  Printv(file, implementation_begin, NIL);

			  // emitImportStatements(pasraw_impl.import, file);
			  // Printf(file, "\n");

			  Printv(file, implementation_uses, NIL);

			  // will be empty usually
			  Printv(file, pasraw_impl.f, NIL);

			  Printv(file, implementation_end, NIL);
			  Printv(file, implementation_functions, NIL);
			  Printf(file, "\n{$ifdef %s_FUNCTION_WRAPPER}\n",  pasraw_name);
			  Printv(file, implementation_functions_wrapper, NIL);
			  Printf(file, "\n{$endif} //%s_FUNCTION_WRAPPER\n",  pasraw_name);


			  Printf(file, "\n{$ifdef %s_CLASS_WRAPPER}\n",  pasraw_name);
			  Printv(file, paswrap_impl.f, NIL);	
			  Printf(file, "\n{$endif} //%s_CLASS_WRAPPER\n",  pasraw_name);


			  Printf(file, "\ninitialization\n\n", pasraw_name);
			  Printv(file, constant_initialization, NIL);			
			  Printv(file, initialization 	, NIL);

			  Printf(file, "\nfinalization\n", pasraw_name);
			  Printv(file, finalization 	, NIL);
			  Printf(file, "\nend.\n", pasraw_name);


			  Delete(file);

			  if (upcasts_code)
				  Printv(f_wrappers, upcasts_code, NIL);

			  Printf(f_wrappers, "#ifdef __cplusplus\n");
			  Printf(f_wrappers, "}\n");
			  Printf(f_wrappers, "#endif\n");

		  }

#endif
#if 0
		  // Generate the interface for the comfort wrappers
		  {
			  File *file = openWriteFile(NewStringf("%s%s.i3", SWIG_output_directory(), paswrap_name));

			  emitBanner(file);

			  Printf(file, "INTERFACE %s;\n", paswrap_name);

			  emitImportStatements(paswrap_intf.import, file);
			  Printf(file, "\n");

			  {
				  Iterator it = First(enumeration_coll);
				  if (it.key != NIL) {
					  Printf(file, "TYPE\n");
				  }
				  for (; it.key != NIL; it = Next(it)) {
					  Printf(file, "\n");
					  emitEnumeration(file, it.key, it.item);
				  }
			  }

			  // Add the wrapper methods
			  Printv(file, paswrap_intf.f, NIL);

			  // Finish off the class
			  Printf(file, "\nEND %s.\n", paswrap_name);
			  Delete(file);
		  }

		  // Generate the wrapper routines implemented in Pascal
		  {
			  File *file = openWriteFile(NewStringf("%s%s.pas", SWIG_output_directory(), paswrap_name));

			  emitBanner(file);

			  if (unsafe_module) {
				  Printf(file, "UNSAFE ");
			  }
			  Printf(file, "MODULE %s;\n\n", paswrap_name);

			  emitImportStatements(paswrap_impl.import, file);
			  Printf(file, "\n");

			  // Add the wrapper methods
			  Printv(file, paswrap_impl.f, NIL);

			  Printf(file, "\nBEGIN\nEND %s.\n", paswrap_name);
			  Delete(file);
		  }

		  if (upcasts_code)
			  Printv(f_wrappers, upcasts_code, NIL);

		  Printf(f_wrappers, "#ifdef __cplusplus\n");
		  Printf(f_wrappers, "}\n");
		  Printf(f_wrappers, "#endif\n");

		  // Output a Pascal type wrapper class for each SWIG type
		  for (Iterator swig_type = First(swig_types_hash); swig_type.item != NIL; swig_type = Next(swig_type)) {
			  emitTypeWrapperClass(swig_type.key, swig_type.item);
		  }
#endif
		  Delete(swig_types_hash);
		  swig_types_hash = NULL;
		  Delete(constant_values);
		  constant_values = NULL;
		  Delete(enumeration_coll);
		  enumeration_coll = NULL;
		  Delete(pasraw_name);
		  pasraw_name = NULL;
		  Delete(pasraw_baseclass);
		  pasraw_baseclass = NULL;
		  Delete(pasraw_interfaces);
		  pasraw_interfaces = NULL;
		  Delete(pasraw_class_modifiers);
		  pasraw_class_modifiers = NULL;
		  Delete(pasraw_imports);
		  pasraw_imports = NULL;
		  Delete(pasraw_cppcasts_code);
		  pasraw_cppcasts_code = NULL;
		  Delete(proxy_class_def);
		  Delete(proxy_class_constructor_def);
		  proxy_class_def = NULL;
		  Delete(proxy_class_code);
		  proxy_class_code = NULL;
		  Delete(paswrap_name);
		  paswrap_name = NULL;
		  Delete(paswrap_modifiers);
		  paswrap_modifiers = NULL;
		  Delete(targetlibrary);
		  targetlibrary = NULL;
		  Delete(module_baseclass);
		  module_baseclass = NULL;
		  Delete(module_interfaces);
		  module_interfaces = NULL;
		  Delete(module_imports);
		  module_imports = NULL;
		  Delete(upcasts_code);
		  upcasts_code = NULL;
		  Delete(constantfilename);
		  constantfilename = NULL;
		  Delete(renamefilename);
		  renamefilename = NULL;
		  Delete(typemapfilename);
		  typemapfilename = NULL;

		  Delete(nested_classes_hash);
		  nested_classes_hash = NULL;
		  /*
		  Close(types_decl);
		  Delete(types_decl);
		  types_decl = 0;
		  */
		  Delete(types_hash);
		  types_hash = 0;


		  /* Close all of the files */
		  Dump(f_header, f_runtime);

		  if (directorsEnabled()) {
			  Dump(f_directors, f_runtime);
			  Dump(f_directors_h, f_runtime_h);

			  Printf(f_runtime_h, "\n");
			  Printf(f_runtime_h, "#endif\n");

//			  Close(f_runtime_h);
			  Delete(f_runtime_h);
			  f_runtime_h = NULL;
			  Delete(f_directors);
			  f_directors = NULL;
			  Delete(f_directors_h);
			  f_directors_h = NULL;
		  }


		  Dump(f_wrappers, f_runtime);
		  Wrapper_pretty_print(f_init, f_runtime);
		  Delete(f_header);
		  Delete(f_wrappers);
		  Delete(f_init);
//		  Close(f_runtime);
		  Delete(f_runtime);


		  Delete(interface_uses);
		  Delete(interface_begin);
		  Delete(interface_end);
		  Delete(interface_functions);
		  Delete(interface_functions_wrapper);
		  Delete(implementation_uses);
		  Delete(implementation_begin);
		  Delete(implementation_end);
		  Delete(implementation_functions);
		  Delete(implementation_functions_wrapper);
		  Delete(initialization);
		  Delete(finalization);


		  return SWIG_OK;
	  }

	  /* -----------------------------------------------------------------------------
	  * emitBanner()
	  * ----------------------------------------------------------------------------- */

	  void emitBanner(File *f) {
		  Printf(f, "(* ----------------------------------------------------------------------------\n");
		  Swig_banner_target_lang(f, " *");
		  Printf(f, " * ----------------------------------------------------------------------------- *)\n\n");
	  }

	  /* ----------------------------------------------------------------------
	  * nativeWrapper()
	  * ---------------------------------------------------------------------- */

	  virtual int nativeWrapper(Node *n) {
		  String *wrapname = GetattrNew(n, "wrap:name");

		  if (!addSymbol(wrapname, n))
			  return SWIG_ERROR;

		  if (Getattr(n, "type")) {
			  Swig_save("nativeWrapper", n, "name", NIL);
			  Setattr(n, "name", wrapname);
			  native_function_flag = true;
			  functionWrapper(n);
			  Swig_restore(n);
			  native_function_flag = false;
		  } else {
			  Printf(stderr, "%s : Line %d. No return type for %%native method %s.\n", input_file, line_number, GetattrNew(n, "wrap:name"));
		  }

		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * functionWrapper()
	  * ---------------------------------------------------------------------- */

	  virtual int functionWrapper(Node *n) {
		  String *type = nodeType(n);
		  String *funcType = GetattrNew(n, "delphi:functype");
		  String *rawname = Copy(GetattrNew(n, "name"));
		  String *symname = Copy(GetattrNew(n, "sym:name"));

		  int nowrap_function = Getfeature(n, "delphi:nowrap_function") != 0;		

		  Replace(rawname,"::","_", DOH_REPLACE_ANY);
		  Replace(symname,"::","_", DOH_REPLACE_ANY);


		  String *capname = capitalizeFirst(symname);
		  String *wname = Swig_name_wrapper(symname);



		  //printf("function: %s\n", Char(symname));
		  //printf(" purpose: %s\n", Char(funcType));

		  if (Strcmp(type, "constant") == 0) {
			  Setattr(n, "delphi:funcname", capname);
			  emitCWrapper(n, wname);
			  emitPASRawPrototype(n, wname, capname);
		  }

		  if (Strcmp(type, "enumitem") == 0) {
			  Setattr(n, "delphi:funcname", capname);
			  emitCWrapper(n, wname);
			  emitPASRawPrototype(n, wname, capname);
		  }

		  if (Strcmp(type, "cdecl") == 0) {
			  if (funcType == NIL) {
				  // no wrapper needed for plain functions ?

				  if (wrapping_member_flag && static_flag ) {
					  emitCWrapper(n, wname);
					  emitPASRawPrototype(n, wname, symname);
				  }
				  else if (Getattr(n,"template") != 0) {
					  emitCWrapper(n, wname);
					  emitPASRawPrototype(n, wname, symname);
				  }
				  else if (variable_wrapper_flag || global_variable_flag) {

					  Setattr(n, "proxyfuncname", capname);
					  Setattr(n, "imfuncname", symname);
					  if (hasPrefix(capname, "Set")) {
						  Setattr(n, "delphi:setname", capname);
					  } else {
						  Setattr(n, "delphi:getname", capname);
					  }

					  //char *ch = Char(capname);

					  //					printf("%X\n", n);

					  emitCWrapper(n, wname);
					  emitPASRawPrototype(n, wname, capname);
					  /*
					  emitPASRawPrototype(n, rawname, symname);
					  emitCWrapper(n, wname);
					  */
				  }
				  else {

					  if (native_function_flag || nowrap_function)

						  emitPASRawPrototype(n, rawname, symname);						

					  else
						  emitPASRawPrototype(n, wname, capname);

					  if (!nowrap_function)

						  emitCWrapper(n, wname);
				  }
				  //	emitPASWrapper(n, symname);
			  } else if (Strcmp(funcType, "method") == 0) {
				  Setattr(n, "delphi:funcname", capname);
				  emitCWrapper(n, wname);
				  emitPASRawPrototype(n, wname, capname);
				  //emitPASWrapper(n, capname);
			  } else if (Strcmp(funcType, "accessor") == 0) {
				  /*
				  * Generate the proxy class properties for public member variables.
				  * Not for enums and constants.
				  */
				  if (/*proxy_flag && */wrapping_member_flag && !enum_constant_flag) {
					  // Capitalize the first letter in the function name
					  Setattr(n, "proxyfuncname", capname);
					  Setattr(n, "imfuncname", symname);
					  if (hasPrefix(capname, "Set")) {
						  Setattr(n, "delphi:setname", capname);
					  } else {
						  Setattr(n, "delphi:getname", capname);
					  }

					  //char *ch = Char(capname);

					  //					printf("%X\n", n);

					  emitCWrapper(n, wname);
					  emitPASRawPrototype(n, wname, capname);
					  //	  emitPASWrapper(n, capname);
					  if (proxy_flag)	
						  proxyClassFunctionHandler(n);

				  }
#ifdef DEBUG
			  } else {
				  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Function type <%s> unknown.\n", Char(funcType));
#endif
			  }
		  } else if ((Strcmp(type, "constructor") == 0) || (Strcmp(type, "destructor") == 0)) {
			  emitCWrapper(n, wname);
			  emitPASRawPrototype(n, wname, capname);
			  //   emitPASWrapper(n, capname);
		  }
		  // a Java relict
#if 0
		  if (!(proxy_flag && is_wrapping_class()) && !enum_constant_flag) {
			  emitPASWrapper(n, capname);
		  }
#endif
#if 0
		  //	Delete(capname);
		  //	Delete(wname);
		  //	Delete(rawname);
		  //	Delete(symname);
#endif 
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * emitCWrapper()
	  *
	  * Generate the wrapper in C which calls C++ methods.
	  * ---------------------------------------------------------------------- */

#if old

	  virtual int emitCWrapper(Node *n, const String *wname) {

		  String *rawname = GetattrNew(n, "name");
		  String *c_return_type = NewString("");
		  String *cleanup = NewString("");
		  String *outarg = NewString("");
		  String *body = NewString("");
		  Hash *throws_hash = NewHash();
		  ParmList *l = Getattr(n, "parms");
		  SwigType *t = GetattrNew(n, "type");
		  String *symname = GetattrNew(n, "sym:name");

		  String * overloaded = GetattrNew(n,"sym:overloaded");
		  String * overloaded_name = GetattrNew(n,"sym:overname");


		  String *fname;




		  if (hasContent(overloaded))
			  fname = NewStringf("%s%s", wname, overloaded_name);
		  else
			  fname = Copy(wname);


		  char *ch = 0;

		  ch = Char(rawname);

		  int br =  strcmp(ch, "paList");

		  if (!Getattr(n, "sym:overloaded")) {
			  if (!addSymbol(wname, n)) {
				  return SWIG_ERROR;
			  }
		  }
		  // A new wrapper function object
		  Wrapper *f = NewWrapper();


		  /* Attach the non-standard typemaps to the parameter list. */
		  Swig_typemap_attach_parms("ctype", l, f);

		  /* Get return types */
		  {
			  String *tm = getMappedTypeNew(n, "ctype", "");
			  if (tm != NIL) {
				  Printf(c_return_type, "%s", tm);
			  }
		  }

		  bool is_void_return = (Cmp(c_return_type, "void") == 0);
		  if (!is_void_return) {
			  Wrapper_add_localv(f, "cresult", c_return_type, "cresult = 0", NIL);
		  }

		  Printv(f->def, " SWIGEXPORT ", c_return_type, " SWIGSTDCALL ", fname, "(", NIL);

		  // Emit all of the local variables for holding arguments.
		  emit_parameter_variables(t, l, f);

		  /* Attach the standard typemaps */
		  emit_attach_parmmaps(l, f);
		  Setattr(n, "wrap:name", Copy(fname));
		  Setattr(n, "wrap:parms", l);

		  // Generate signature and argument conversion for C wrapper
		  {
			  Parm *p;
			  attachParameterNames(n, "tmap:name", "c:wrapname", "pasarg%d");
			  bool gencomma = false;
			  for (p = skipIgnored(l, "in"); p != NULL; p = skipIgnored(p, "in")) {

				  String *arg = GetattrNew(p, "c:wrapname");
				  {
					  /* Get the ctype types of the parameter */
					  String *c_param_type = getMappedType(p, "ctype");
					  // Add parameter to C function
					  Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);
#if 0
					  Delete(c_param_type);
#endif
					  gencomma = true;
				  }

				  // Get typemap for this argument
				  String *tm = getMappedType(p, "in");
				  if (tm != NIL) {
					  addThrows(throws_hash, "in", p);
					  Replaceall(tm, "$input", arg);
					  Setattr(p, "emit:input", arg);	/*??? */
					  Printf(f->code, "%s\n", tm);
					  p = Getattr(p, "tmap:in:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert constraint checking code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:check");
				  if (tm != NIL) {
					  addThrows(throws_hash, "check", p);
					  Replaceall(tm, "$target", GetattrNew(p, "lname"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(f->code, tm, "\n", NIL);
					  p = Getattr(p, "tmap:check:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert cleanup code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:freearg");
				  if (tm != NIL) {
					  addThrows(throws_hash, "freearg", p);
					  Replaceall(tm, "$source", GetattrNew(p, "emit:input"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(cleanup, tm, "\n", NIL);
					  p = Getattr(p, "tmap:freearg:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert argument output code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:argout");
				  if (tm != NIL) {
					  addThrows(throws_hash, "argout", p);
					  Replaceall(tm, "$source", GetattrNew(p, "emit:input"));	/* deprecated */
					  Replaceall(tm, "$target", GetattrNew(p, "lname"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$result", "cresult");
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(outarg, tm, "\n", NIL);
					  p = Getattr(p, "tmap:argout:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  // Get any Pascal exception classes in the throws typemap
		  ParmList *throw_parm_list = NULL;
		  if ((throw_parm_list = Getattr(n, "throws"))) {
			  Swig_typemap_attach_parms("throws", throw_parm_list, f);
			  Parm *p;
			  for (p = throw_parm_list; p; p = nextSibling(p)) {
				  addThrows(throws_hash, "throws", p);
			  }
		  }

		  if (Cmp(nodeType(n), "constant") == 0) {
			  // Wrapping a constant hack
			  Swig_save("functionWrapper", n, "wrap:action", NIL);

			  // below based on Swig_VargetToFunction()
			  SwigType *ty = Swig_wrapped_var_type(GetattrNew(n, "type"), use_naturalvar_mode(n));
			  Setattr(n, "wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty, 0), GetattrNew(n, "value")));
		  }/**/
		  // Now write code to make the function call
		  if (!native_function_flag) {
			  emit_action(n, f);
		  }

		  if (Cmp(nodeType(n), "constant") == 0) {
			  Swig_restore(n);
		  }/**/

		  /* Return value if necessary  */
		  if (!native_function_flag) {
			  String *tm = getMappedTypeNew(n, "out", "result");
			  if (tm != NIL) {
				  addThrows(throws_hash, "out", n);
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Replaceall(tm, "$target", "cresult");	/* deprecated */
				  Replaceall(tm, "$result", "cresult");
				  Printf(f->code, "%s", tm);
				  if (hasContent(tm))
					  Printf(f->code, "\n");
			  } else {
				  Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), rawname);
			  }
		  }

		  /* Output argument output code */
		  Printv(f->code, outarg, NIL);

		  /* Output cleanup code */
		  Printv(f->code, cleanup, NIL);

		  /* Look to see if there is any newfree cleanup code */
		  if (GetFlag(n, "feature:new")) {
			  //		String *tm = Swig_typemap_lookup_new("newfree", n, "result", 0);
			  String *tm = Swig_typemap_lookup("newfree", n, "result", 0);

			  if (tm != NIL) {
				  addThrows(throws_hash, "newfree", n);
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Printf(f->code, "%s\n", tm);
			  }
		  }

		  /* See if there is any return cleanup code */
		  if (!native_function_flag) {
			  //String *tm = Swig_typemap_lookup_new("ret", n, "result", 0);
			  String *tm = Swig_typemap_lookup("ret", n, "result", 0);
			  if (tm != NIL) {
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Printf(f->code, "%s\n", tm);
			  }
		  }

		  /* Finish C wrapper */
		  Printf(f->def, ") {");

		  if (!is_void_return)
			  Printv(f->code, "    return cresult;\n", NIL);
		  Printf(f->code, "}\n");

		  /* Substitute the cleanup code */
		  Replaceall(f->code, "$cleanup", cleanup);

		  /* Substitute the function name */
		  Replaceall(f->code, "$symname", symname);

		  if (!is_void_return) {
			  Replaceall(f->code, "$null", "0");
		  } else {
			  Replaceall(f->code, "$null", "");
		  }

		  /* Dump the function out */
		  if (!native_function_flag) {
			  Wrapper_print(f, f_wrappers);
		  }

		  //	Setattr(n, "wrap:parms", 0);



#if 0
		  Delete(c_return_type);
		  Delete(cleanup);
		  Delete(outarg);
		  Delete(body);
		  Delete(throws_hash);
		  DelWrapper(f);
		  Delete(fname);
#endif

		  return SWIG_OK;
	  }

#endif

	  virtual int emitCWrapper(Node *n, const String *wname) {
		  String *rawname = GetattrNew(n, "name");
		  String *c_return_type = NewString("");
		  String *cleanup = NewString("");
		  String *outarg = NewString("");
		  //String *body = NewString("");
		  Hash *throws_hash = NewHash();
		  ParmList *l = Getattr(n, "parms");
		  SwigType *t = GetattrNew(n, "type");
		  String *symname = GetattrNew(n, "sym:name");

		  String * overloaded = GetattrNew(n,"sym:overloaded");
		  String * overloaded_name = GetattrNew(n,"sym:overname");
		  String *fname;

		  if (hasContent(overloaded))
			  fname = NewStringf("%s%s", wname, overloaded_name);
		  else
			  fname = Copy(wname);


		  if (!Getattr(n, "sym:overloaded")) {
			  if (!addSymbol(wname, n)) {
				  return SWIG_ERROR;
			  }
		  }
		  // A new wrapper function object
		  Wrapper *f = NewWrapper();

		  /* Attach the non-standard typemaps to the parameter list. */
		  Swig_typemap_attach_parms("ctype", l, f);

		  /* Get return types */
		  {
			  String *tm = getMappedTypeNew(n, "ctype", "");
			  if (tm != NIL) {
				  Printf(c_return_type, "%s", tm);
			  }
		  }

		  bool is_void_return = (Cmp(c_return_type, "void") == 0);
		  if (!is_void_return) {
			  Wrapper_add_localv(f, "cresult", c_return_type, "cresult = 0", NIL);
		  }

		  Printv(f->def, " SWIGEXPORT ", c_return_type, " ", fname, "(", NIL);

		  // Emit all of the local variables for holding arguments.
		  emit_parameter_variables(l, f);

		  /* Attach the standard typemaps */
		  emit_attach_parmmaps(l, f);
		  Setattr(n, "wrap:parms", l);

		  // Generate signature and argument conversion for C wrapper
		  {
			  Parm *p;
			  attachParameterNames(n, "tmap:name", "c:wrapname", "pasarg%d");
			  bool gencomma = false;
			  for (p = skipIgnored(l, "in"); p != NULL; p = skipIgnored(p, "in")) {

				  String *arg = GetattrNew(p, "c:wrapname");
				  {
					  /* Get the ctype types of the parameter */
					  String *c_param_type = getMappedType(p, "ctype");
					  // Add parameter to C function
					  Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);
#if 0	
					  Delete(c_param_type);
#endif
					  gencomma = true;
				  }

				  // Get typemap for this argument
				  String *tm = getMappedType(p, "in");
				  if (tm != NIL) {
					  addThrows(throws_hash, "in", p);
					  Replaceall(tm, "$input", arg);
					  Setattr(p, "emit:input", arg);	/*??? */
					  Printf(f->code, "%s\n", tm);
					  p = Getattr(p, "tmap:in:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert constraint checking code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:check");
				  if (tm != NIL) {
					  addThrows(throws_hash, "check", p);
					  Replaceall(tm, "$target", GetattrNew(p, "lname"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(f->code, tm, "\n", NIL);
					  p = Getattr(p, "tmap:check:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert cleanup code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:freearg");
				  if (tm != NIL) {
					  addThrows(throws_hash, "freearg", p);
					  Replaceall(tm, "$source", GetattrNew(p, "emit:input"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(cleanup, tm, "\n", NIL);
					  p = Getattr(p, "tmap:freearg:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Insert argument output code */
		  {
			  Parm *p;
			  for (p = l; p;) {
				  String *tm = GetattrNew(p, "tmap:argout");
				  if (tm != NIL) {
					  addThrows(throws_hash, "argout", p);
					  Replaceall(tm, "$source", GetattrNew(p, "emit:input"));	/* deprecated */
					  Replaceall(tm, "$target", GetattrNew(p, "lname"));	/* deprecated */
					  Replaceall(tm, "$arg", GetattrNew(p, "emit:input"));	/* deprecated? */
					  Replaceall(tm, "$result", "cresult");
					  Replaceall(tm, "$input", GetattrNew(p, "emit:input"));
					  Printv(outarg, tm, "\n", NIL);
					  p = Getattr(p, "tmap:argout:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  // Get any Pascal exception classes in the throws typemap
		  ParmList *throw_parm_list = NULL;
		  if ((throw_parm_list = Getattr(n, "throws"))) {
			  Swig_typemap_attach_parms("throws", throw_parm_list, f);
			  Parm *p;
			  for (p = throw_parm_list; p; p = nextSibling(p)) {
				  addThrows(throws_hash, "throws", p);
			  }
		  }

		  if (Cmp(nodeType(n), "constant") == 0) {
			  // Wrapping a constant hack
			  Swig_save("functionWrapper", n, "wrap:action", NIL);

			  // below based on Swig_VargetToFunction()
			  SwigType *ty = Swig_wrapped_var_type(GetattrNew(n, "type"), use_naturalvar_mode(n));
			  Setattr(n, "wrap:action", NewStringf("result = (%s) %s;", SwigType_lstr(ty, 0), GetattrNew(n, "value")));
		  }

		  Setattr(n, "wrap:name", wname);

		  // Now write code to make the function call
		  if (!native_function_flag) {
			  String *actioncode = emit_action(n);

			  if (Cmp(nodeType(n), "constant") == 0) {
				  Swig_restore(n);
			  }

			  /* Return value if necessary  */
			  String *tm;
			  if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
				  addThrows(throws_hash, "out", n);
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Replaceall(tm, "$target", "cresult");	/* deprecated */
				  Replaceall(tm, "$result", "cresult");
				  Printf(f->code, "%s", tm);
				  if (hasContent(tm))
					  Printf(f->code, "\n");
			  } else {
				  Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), rawname);
			  }
			  emit_return_variable(n, t, f);
		  }

		  /* Output argument output code */
		  Printv(f->code, outarg, NIL);

		  /* Output cleanup code */
		  Printv(f->code, cleanup, NIL);

		  /* Look to see if there is any newfree cleanup code */
		  if (GetFlag(n, "feature:new")) {
			  String *tm = Swig_typemap_lookup("newfree", n, "result", 0);
			  if (tm != NIL) {
				  addThrows(throws_hash, "newfree", n);
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Printf(f->code, "%s\n", tm);
			  }
		  }

		  /* See if there is any return cleanup code */
		  if (!native_function_flag) {
			  String *tm = Swig_typemap_lookup("ret", n, "result", 0);
			  if (tm != NIL) {
				  Replaceall(tm, "$source", "result");	/* deprecated */
				  Printf(f->code, "%s\n", tm);
			  }
		  }

		  /* Finish C wrapper */
		  Printf(f->def, ") {");

		  if (!is_void_return)
			  Printv(f->code, "    return cresult;\n", NIL);
		  Printf(f->code, "}\n");

		  /* Substitute the cleanup code */
		  Replaceall(f->code, "$cleanup", cleanup);

		  /* Substitute the function name */
		  Replaceall(f->code, "$symname", symname);

		  if (!is_void_return) {
			  Replaceall(f->code, "$null", "0");
		  } else {
			  Replaceall(f->code, "$null", "");
		  }

		  /* Dump the function out */
		  if (!native_function_flag) {
			  Wrapper_print(f, f_wrappers);
		  }
#if 0
		  Delete(c_return_type);
		  Delete(cleanup);
		  Delete(outarg);
		  Delete(body);
		  Delete(throws_hash);
		  DelWrapper(f);
#endif
		  return SWIG_OK;
	  }



	  /* ----------------------------------------------------------------------
	  * emitPASRawPrototype()
	  *
	  * Generate an EXTERNAL procedure declaration in Pascal
	  * which is the interface to an existing C routine or a C wrapper.
	  * ---------------------------------------------------------------------- */


	  char * ChopCh(char * S, int ch)
	  {
		  int len = (int)strlen(S);
		  if (S[len-1] == ch)
			  S[len-1] = 0;
		  return S;

	  }

	  virtual int emitPASRawPrototype1(Node *n, const String *cname, const String *pasname, String  *f, char *_external, Hash *import, String *_storage) {

		  String * overloaded = GetattrNew(n,"sym:overloaded");
		  String * overloaded_name = GetattrNew(n,"sym:overname");
		  String *im_return_type = NewString("");
		  //String   *symname = GetattrNew(n,"sym:name");
		  ParmList *l = Getattr(n, "parms");

		  String *storage= 0;//= GetattrNew(n, "storage");

		  storage = NewStringf(callconv);

		  String *_pars = NewStringf("");

		  /* Attach the non-standard typemaps to the parameter list. */
		  Swig_typemap_attach_parms("pasrawinmode", l, NULL);
		  Swig_typemap_attach_parms("pasrawintype", l, NULL);


		  //		   if (strcmp(Char(cname), "Delete_gamma_lut_type") == 0) __asm { int 3};

		  /* Get return types */
		  bool has_return;
		  {
			  String *tm = getMappedTypeNew(n, "pasrawrettype", "");




			  if (tm != NIL) {
				  RemoveNamespace(tm);
				  Printf(im_return_type, "%s", tm);
			  }
			  has_return = hasContent(tm);
		  }

		  Setattr(n, "delphi:pasname", pasname);

		  /* cname is the original name if 'n' denotes a C function
		  and it is the relabeled name (sym:name) if 'n' denotes a C++ method or similar */
		  //f.enterBlock(no_block);
		  if (has_return) 
			  //Printf(f, "\nfunction %s (", cname, pasname);
			  Printf(f, "\nfunction %s (", pasname);
		  else 
			  //Printf(f, "\nprocedure %s (", cname, pasname);
			  Printf(f, "\nprocedure %s (", pasname);
		  // G
		  // Generate signature for raw interface
		  {
			  Parm *p;
			  writeArgState state;
			  attachParameterNames(n, "tmap:rawinname", "delphi:rawname", "arg%d");
			  for (p = skipIgnored(l, "pasrawintype"); p != NULL; p = skipIgnored(p, "pasrawintype")) {

				  /* Get argument passing mode, should be one of VALUE, VAR, CONST */
				  String *mode = GetattrNew(p, "tmap:pasrawinmode");
				  String *argname = GetattrNew(p, "delphi:rawname");
				  String *im_param_type = getMappedType(p, "pasrawintype");
				  //SwigType *type  = GetattrNew(p,"type");

				  RemoveNamespace(im_param_type);

				  Replace(im_param_type," const", "", DOH_REPLACE_FIRST);

				  if (import)
					  addImports(import, "pasrawintype", p);
				  if (argname != NULL)  // varargs skipped"
					  writeArg(_pars, state, mode, argname, im_param_type, NIL);
				  if (im_param_type != NIL) {
					  p = Getattr(p, "tmap:pasrawintype:next");
				  } 
				  else {
					  p = nextSibling(p);
				  }
			  }

			  writeArg(_pars, state, NIL, NIL, NIL, NIL);
		  }

		  /* Finish PAS raw prototype */
		  Chop(_pars);
		  Printf(f, "%s)", ChopCh(Char(_pars),';'));
		  // neither a C wrapper nor a plain C function may throw an exception
		  //generateThrowsClause(throws_hash, pasraw_intf.f);

		  if (has_return) {
			  Printf(f, ": %s", im_return_type);
		  }

		  Printf(f, "");

		  Printf(f, "; %s", _storage);

		  if ( hasContent(overloaded) )
			  Printf(f, "; overload" );


		  //char * ss = Char(storage);

		  if (_external != 0) {

			  if (hasContent(overloaded))
				  Printf(f, "; external %s name '%s%s'", _external, cname, overloaded_name);
			  else
				  Printf(f, "; external %s name '%s'", _external, cname);
		  }

		  Printf(f, ";\n");
#if 0
		  Delete(_pars);
		  Delete(im_return_type);
#endif

		  return SWIG_OK;

	  }

	  virtual int emitPASRawPrototype(Node *n, const String *cname, const String *pasname) {

		  String *lib = 0;
		  String *storage = 0;

		  if (variable_wrapper_flag) {
			  lib = NewString("__WRAPDLLNAME");
			  storage=NewString("stdcall");
		  }
		  else {
			  lib = NewString("__DLLNAME");
			  storage=Copy(callconv);
		  }

		  if (variable_wrapper_flag)
			  emitPASRawPrototype1(n, cname, pasname, interface_functions_wrapper, 0, pasraw_intf.import, storage);
		  else
			  emitPASRawPrototype1(n, cname, pasname, interface_functions, 0, pasraw_intf.import, storage);



		  if (variable_wrapper_flag)
			  return 	emitPASRawPrototype1(n, cname, pasname, implementation_functions_wrapper, Char(lib), pasraw_intf.import, storage);
		  else
			  return 	emitPASRawPrototype1(n, cname, pasname, implementation_functions, Char(lib), pasraw_intf.import, storage);

#if 0
		  Delete(lib);
		  Delete(storage);
#endif
	  }

	  /* -----------------------------------------------------------------------
	  * variableWrapper()
	  * ----------------------------------------------------------------------- */

	  virtual int variableWrapper(Node *n) {
		  Language::variableWrapper(n);
		  return SWIG_OK;
	  }

	  /* -----------------------------------------------------------------------
	  * globalvariableHandler()
	  * ----------------------------------------------------------------------- */

	  virtual int globalvariableHandler(Node *n) {
		  SwigType *t = GetattrNew(n, "type");
		  String *tm;

		  // Get the variable type
		  if ((tm = getMappedTypeNew(n, "paswraptype", ""))) {
			  substituteClassname(t, tm);
		  }

		  variable_name = GetattrNew(n, "sym:name");
		  variable_type = Copy(tm);

		  // Get the variable type expressed in terms of Pascal equivalents of C types
		  /*
		  if ((tm = getMappedTypeNew(n, "pasrawtype", ""))) {
		  pasraw_intf.enterBlock(no_block);
		  Printf(pasraw_intf.f, "\n<* EXTERNAL *> var %s: %s;\n", variable_name, tm);
		  }
		  */
		  // Output the property's accessor methods

		  global_variable_flag = true;
		  /*int ret = */Language::globalvariableHandler(n);
		  global_variable_flag = false;


		  Printf(paswrap_impl.f, "\n\n");

		  //return ret;
		  return 1;
	  }

	  long getConstNumeric(Node *n) {
		  String *constnumeric = Getfeature(n, "constnumeric");
		  String *name = GetattrNew(n, "name");
		  long numvalue;
		  if (constnumeric == NIL) {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Feature 'constnumeric' is necessary to obtain value of %s.\n", name);
			  return 0;
		  } else if (!strToL(constnumeric, numvalue)) {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number,
				  "The feature 'constnumeric' of %s specifies value <%s> which is not an integer constant.\n", name, constnumeric);
			  return 0;
		  } else {
			  return numvalue;
		  }
	  }

	  /* ------------------------------------------------------------------------
	  * generateIntConstant()
	  *
	  * Considers node as an integer constant definition
	  * and generate a Pascal constant definition.
	  * ------------------------------------------------------------------------ */
	  void generateIntConstant(Node *n, String *name) {
		  String *value = GetattrNew(n, "value");
		  String *type = Getfeature(n, "delphi:constint:type");
		  String *conv = Getfeature(n, "delphi:constint:conv");

		  if (name == NIL) {
			  name = GetattrNew(n, "sym:name");
		  }

		  long numvalue;
		  bool isSimpleNum = strToL(value, numvalue);
		  if (!isSimpleNum) {
			  numvalue = getConstNumeric(n);
		  }

		  String *pasvalue;
		  if ((conv == NIL) || ((Strcmp(conv, "set:int") != 0) && (Strcmp(conv, "int:set") != 0))) {
			  /* The original value of the constant has precedence over
			  'constnumeric' feature since we like to keep
			  the style (that is the base) of simple numeric constants */
			  if (isSimpleNum) {
				  if (hasPrefix(value, "0x")) {
					  pasvalue = NewStringf("16_%s", Char(value) + 2);
				  } else if ((Len(value) > 1) && (*Char(value) == '0')) {
					  pasvalue = NewStringf("8_%s", Char(value) + 1);
				  } else {
					  pasvalue = Copy(value);
				  }
				  /* If we cannot easily obtain the value of a numeric constant,
				  we use the results given by a C compiler. */
			  } else {
				  pasvalue = Copy(Getfeature(n, "constnumeric"));
			  }
		  } else {
			  // if the value can't be converted, it is ignored
			  if (convertInt(numvalue, numvalue, conv)) {
				  pasvalue = NewStringf("%d", numvalue);
			  } else {
				  pasvalue = NIL;
			  }
		  }

		  if (pasvalue != NIL) {
			  paswrap_intf.enterBlock(constant);
			  Printf(paswrap_intf.f, "%s", name);
			  if (hasContent(type)) {
				  Printf(paswrap_intf.f, ": %s", type);
			  }
			  Printf(paswrap_intf.f, " = %s;\n", pasvalue);
#if 0
			  Delete(pasvalue);
#endif
		  }
	  }

	  /* -----------------------------------------------------------------------
	  * generateSetConstant()
	  *
	  * Considers node as a set constant definition
	  * and generate a Pascal constant definition.
	  * ------------------------------------------------------------------------ */
	  void generateSetConstant(Node *n, String *name) {
		  String *value = GetattrNew(n, "value");
		  String *type = Getfeature(n, "delphi:constset:type");
		  String *setname = Getfeature(n, "delphi:constset:set");
		  String *basename = Getfeature(n, "delphi:constset:base");
		  String *conv = Getfeature(n, "delphi:constset:conv");

		  paswrap_intf.enterBlock(constant);

		  Printf(paswrap_intf.f, "%s", name);
		  if (type != NIL) {
			  Printf(paswrap_intf.f, ":%s ", type);
		  }
		  Printf(paswrap_intf.f, " = %s{", setname);

		  long numvalue = 0;
		  if (!strToL(value, numvalue)) {
			  numvalue = getConstNumeric(n);
		  }
		  convertInt(numvalue, numvalue, conv);

		  bool isIntType = Strcmp(basename, "CARDINAL") == 0;
		  Hash *items = NIL;
		  if (!isIntType) {
			  Hash *enumeration = Getattr(enumeration_coll, basename);
			  if (enumeration == NIL) {
				  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "There is no enumeration <%s> as needed for the set.\n", setname);
				  isIntType = true;
			  } else {
				  items = Getattr(enumeration, "items");
			  }
		  }

		  bool gencomma = false;
		  int bitpos = 0;
		  while (numvalue > 0) {
			  if ((numvalue & 1) != 0) {
				  if (isIntType) {
					  if (gencomma) {
						  Printv(paswrap_intf.f, ",", NIL);
					  }
					  gencomma = true;
					  Printf(paswrap_intf.f, "%d", bitpos);
				  } else {
					  char bitval[15];
					  sprintf(bitval, "%d", bitpos);
					  String *bitname = GetattrNew(items, bitval);
					  if (bitname == NIL) {
						  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Enumeration <%s> has no value <%s>.\n", setname, bitval);
					  } else {
						  if (gencomma) {
							  Printv(paswrap_intf.f, ",", NIL);
						  }
						  gencomma = true;
						  Printf(paswrap_intf.f, "%s.%s", basename, bitname);
					  }
				  }
			  }
			  numvalue >>= 1;
			  bitpos++; 
		  }
		  Printf(paswrap_intf.f, "};\n");
	  }


#if 0

	  void generateIntConstant(Node *n, String *name) {
		  String *value = GetattrNew(n, "value");
		  String *type = Getfeature(n, "delphi:constint:type");
		  String *conv = Getfeature(n, "delphi:constint:conv");

		  if (name == NIL) {
			  name = GetattrNew(n, "sym:name");
		  }

		  long numvalue;
		  bool isSimpleNum = strToL(value, numvalue);
		  if (!isSimpleNum) {
			  numvalue = getConstNumeric(n);
		  }

		  String *pasvalue;
		  if ((conv == NIL) || ((Strcmp(conv, "set:int") != 0) && (Strcmp(conv, "int:set") != 0))) {
			  /* The original value of the constant has precedence over
			  'constnumeric' feature since we like to keep
			  the style (that is the base) of simple numeric constants */
			  if (isSimpleNum) {
				  if (hasPrefix(value, "0x")) {
					  pasvalue = NewStringf("16_%s", Char(value) + 2);
				  } else if ((Len(value) > 1) && (*Char(value) == '0')) {
					  pasvalue = NewStringf("8_%s", Char(value) + 1);
				  } else {
					  pasvalue = Copy(value);
				  }
				  /* If we cannot easily obtain the value of a numeric constant,
				  we use the results given by a C compiler. */
			  } else {
				  pasvalue = Copy(Getfeature(n, "constnumeric"));
			  }
		  } else {
			  // if the value can't be converted, it is ignored
			  if (convertInt(numvalue, numvalue, conv)) {
				  pasvalue = NewStringf("%d", numvalue);
			  } else {
				  pasvalue = NIL;
			  }
		  }

		  if (pasvalue != NIL) {
			  paswrap_intf.enterBlock(constant);
			  Printf(paswrap_intf.f, "%s", name);
			  if (hasContent(type)) {
				  Printf(paswrap_intf.f, ": %s", type);
			  }
			  Printf(paswrap_intf.f, " = %s;\n", pasvalue);
			  Delete(pasvalue);
		  }
	  }


#endif

	  void generateConstant(Node *n) {
		  // any of the special interpretation disables the default behaviour
		  /*  String *enumitem = Getfeature(n, "delphi:enumitem:name");
		  String *constset = Getfeature(n, "delphi:constset:name");
		  String *constint = Getfeature(n, "delphi:constint:name");
		  if (hasContent(enumitem) || hasContent(constset) || hasContent(constint)) {
		  if (hasContent(constset)) {
		  generateSetConstant(n, constset);
		  }
		  if (hasContent(constint)) {
		  generateIntConstant(n, constint);
		  }
		  } else */{
			  String * value;
			  String * pasname;
			  int runtime_const_flag = (Getfeature(n, "delphi:runtime_const") != 0) || global_runtime_const_flag ;	

			  if (!enum_wrap_flag)
				  value = GetattrNew(n, "value");
			  else {
				  value = GetattrNew(n, "enumvalue");

				  if (hasContent(value) == 0) {
					  value = NewStringf("%d", enum_begin++);
				  }

			  }

			  Replace(value,"<<"," shl ",DOH_REPLACE_ANY);
			  Replace(value,">>"," shr ",DOH_REPLACE_ANY);

			  Replace(value,"||"," or ",DOH_REPLACE_ANY);
			  Replace(value,"&&"," and ",DOH_REPLACE_ANY);
			  Replace(value,"|"," or ",DOH_REPLACE_ANY);
			  Replace(value,"&"," and ",DOH_REPLACE_ANY);
			  Replace(value,"~"," not ",DOH_REPLACE_ANY);


			  if (hasPrefix(value, "0x")) {
				  value = NewStringf("$%s", Char(value) + 2);
			  }

			  if (hasPrefix(value, "0x")) {
				  value = NewStringf("$%s", Char(value) + 2);
			  } 
			  else /*if ((Len(value) > 1) && (*Char(value) == '0')) {
				   //value = NewStringf("8_%s", Char(value) + 1);

				   char *cc = Char(value); 

				   return Swig_error("octal value not implemented",0, "");
				   } else*/ {
					   value = Copy(value);
			  }


			  String *name = 0; 


			  if (enumeration_name)

				  name = NewStringf("%s_%s", enumeration_name, GetattrNew(n, "sym:name"));

			  else

				  name = Copy(GetattrNew(n, "sym:name"));
			  String *type = GetattrNew(n,"type");
			  if (name == NIL) {
				  name = GetattrNew(n, "name");
			  }

			  if (runtime_const_flag) {

				  variableWrapper(n);

				  pasname = GetattrNew(n, "delphi:pasname");

				  pasraw_intf.enterBlock(variable);	
				  String *pasct = getMappedTypeNew(n, "pasrawtype", "");
				  //Printf(constant_initialization, "   %s := %s_get;\n", name,name);
				  Printf(constant_initialization, "   %s := %s;\n", name,pasname);




				  Printf(pasraw_intf.f, "");
				  Printf(pasraw_intf.f, "   %s : %s ; // constant initialized at runtime\n", name,pasct);


			  }
			  else {

				  pasraw_intf.enterBlock(constant);	


				  //char * xx = Char(type);
				  //xx = Char(value);


				  if (Strcmp(type, "p.char") == 0) {

					  Printf(pasraw_intf.f, "   %s = '%s';\n", name,value);

				  }
				  else
					  Printf(pasraw_intf.f, "   %s = %s ;\n", name, value);

			  }
#if 0
			  Delete(value);
			  Delete(name);
#endif
	  }

	  }

/*#if 0
	  void generateEnumerationItem(const String *name, const String *value, int numvalue) {
		  String *oldsymname = GetattrNew(enumeration_items, (const char *)value);
		  if (oldsymname != NIL) {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "The value <%s> is already assigned to <%s>.\n", value, oldsymname);
		  }
		  Setattr(enumeration_items, value, name);
		  if (enumeration_max < numvalue) {
			  enumeration_max = numvalue;
		  }
	  }
#endif*/

	  void emitEnumeration(File *file, String *name, Node *n) {
		  Printf(file, "%s = {", name);
		  int i;
		  bool gencomma = false;
		  int max = aToL(Getattr(n, "max"));
		  Hash *items = Getattr(n, "items");
		  for (i = 0; i <= max; i++) {
			  if (gencomma) {
				  Printf(file, ",");
			  }
			  Printf(file, "\n");
			  gencomma = true;
			  char numstr[15];
			  sprintf(numstr, "%d", i);
			  String *name = GetattrNew(items, numstr);
			  if (name != NIL) {
				  Printv(file, name, NIL);
			  } else {
				  Printf(file, "Dummy%d", i);
			  }
		  }
		  Printf(file, "\n};\n");
	  }

	  /* -----------------------------------------------------------------------
	  * constantWrapper()
	  *
	  * Handles constants and enumeration items.
	  * ------------------------------------------------------------------------ */

	  virtual int constantWrapper(Node *n) {
		  generateConstant(n);
		  return SWIG_OK;
	  }

#if 1
	  // enumerations are handled like constant definitions
	  /* -----------------------------------------------------------------------------
	  * enumDeclaration()
	  * ----------------------------------------------------------------------------- */

	  void fixUnnamed(String *s)
	  {

		  Replace(s,"$","_", DOH_REPLACE_ANY);

	  }

	  virtual int enumDeclaration(Node *n) {
		  // String *symname = nameToDelphi(GetattrNew(n, "sym:name"), true);
		  String *symname = GetattrNew(n, "sym:name");
		  String *unnamed = GetattrNew(n, "unnamed");
		  String *name = GetattrNew(n, "name");
		  String *tdname = GetattrNew(n, "tdname");	
		  //    enumerationStart(symname);



		  enum_begin = 0;
		  //char * xx = Char(unnamed);
		  //xx = Char(name);
		  //xx = Char(tdname);

		  String * p = 0;

		  if (hasContent(name))
			  p = name;
		  else if (hasContent(symname))
			  p = symname;
		  else if (hasContent(tdname))
			  p = tdname;

		  Replace(p,"::","_", DOH_REPLACE_ANY);

		  fixUnnamed(p);

		  //	p = nameToDelphi(p, true);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration n : %s\n", n);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration symname : %s\n", symname);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration unnamed : %s\n", unnamed);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration name : %s\n", name);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration tdname : %s\n", tdname);
		  //Swig_error("My Debugging", 101010, "=============> enumDeclaration p : %s\n", p);

		  if (p) {
			  String * en = NewStringf("\n   T$enumname = (");


			  Replace(en,"$enumname", p, DOH_REPLACE_ANY);




			  pasraw_intf.enterBlock(blocktype);
			  Printf(pasraw_intf.f,"%s", en);

#if 0
			  Delete(en);
#endif
		  }

		  //enumeration_name = symname;
		  enumeration_name = p;
		  int result = Language::enumDeclaration(n);
		  enumeration_name = 0;

		  //    enumerationStop();
#if 0
		  Delete(symname);
#endif
		  return result;
	  }
#endif

	  /* -----------------------------------------------------------------------------
	  * enumvalueDeclaration()
	  * ----------------------------------------------------------------------------- */

	  virtual int enumvalueDeclaration(Node *n) {
		  //Swig_error("My Debugging", 101010, "=============> enumvalueDeclaration n : %s\n", n);

		  enum_wrap_flag = true;
///		  generateConstant(n);
		  //-------------------------------------------------------------------------
		  String * value;
		  String * pasname;
		  int runtime_const_flag = (Getfeature(n, "delphi:runtime_const") != 0) || global_runtime_const_flag;

		  if (!enum_wrap_flag)
			  value = GetattrNew(n, "value");
		  else {
			  value = GetattrNew(n, "enumvalue");

			  if (hasContent(value) == 0) {
				  value = NewStringf("%d", enum_begin++);
			  }

		  }

		  Replace(value, "<<", " shl ", DOH_REPLACE_ANY);
		  Replace(value, ">>", " shr ", DOH_REPLACE_ANY);

		  Replace(value, "||", " or ", DOH_REPLACE_ANY);
		  Replace(value, "&&", " and ", DOH_REPLACE_ANY);
		  Replace(value, "|", " or ", DOH_REPLACE_ANY);
		  Replace(value, "&", " and ", DOH_REPLACE_ANY);
		  Replace(value, "~", " not ", DOH_REPLACE_ANY);


		  if (hasPrefix(value, "0x")) {
			  value = NewStringf("$%s", Char(value) + 2);
		  }

		  if (hasPrefix(value, "0x")) {
			  value = NewStringf("$%s", Char(value) + 2);
		  }
		  else /*if ((Len(value) > 1) && (*Char(value) == '0')) {
			   //value = NewStringf("8_%s", Char(value) + 1);

			   char *cc = Char(value);

			   return Swig_error("octal value not implemented",0, "");
			   } else*/ {
				   value = Copy(value);
		  }


		  String *name = 0;


		  /*if (enumeration_name)

			  name = NewStringf("%s_%s", enumeration_name, GetattrNew(n, "sym:name"));

		  else*/

			  name = Copy(GetattrNew(n, "sym:name"));
		  String *type = GetattrNew(n, "type");
		  if (name == NIL) {
			  name = GetattrNew(n, "name");
		  }

		  if (runtime_const_flag) {

			  variableWrapper(n);

			  pasname = GetattrNew(n, "delphi:pasname");

			  pasraw_intf.enterBlock(variable);
			  String *pasct = getMappedTypeNew(n, "pasrawtype", "");
			  //Printf(constant_initialization, "   %s := %s_get;\n", name,name);
			  Printf(constant_initialization, "%s = %s, ", name, pasname);




			  Printf(pasraw_intf.f, "");
			  Printf(pasraw_intf.f, "%s : %s, ", name, pasct);


		  }
		  else {

//			  pasraw_intf.enterBlock(constant);


			  //char * xx = Char(type);
			  //xx = Char(value);

			  if (!Getattr(n, "nextSibling")) {
				  if (Strcmp(type, "p.char") == 0) {

					  Printf(pasraw_intf.f, "%s = '%s');\n", name, value);

				  }
				  else
					  Printf(pasraw_intf.f, "%s = %s);\n", name, value);

			  }
			  else {
				  if (Strcmp(type, "p.char") == 0) {

					  Printf(pasraw_intf.f, "%s = '%s', ", name, value);

				  }
				  else
					  Printf(pasraw_intf.f, "%s = %s, ", name, value);

			  }

		  }
#if 0
		  Delete(value);
		  Delete(name);
#endif
		  //-------------------------------------------------------------------------
		  enum_wrap_flag = false;




		  /*
		  This call would continue processing in the constantWrapper
		  which cannot handle values like "RED+1".
		  return Language::enumvalueDeclaration(n);
		  */
		  return SWIG_OK;
	  }

	  /* -----------------------------------------------------------------------------
	  * pragmaDirective()
	  *
	  * Valid Pragmas:
	  * imclassbase            - base (extends) for the intermediary class
	  * imclassclassmodifiers  - class modifiers for the intermediary class
	  * imclasscode            - text (Pascal code) is copied verbatim to the intermediary class
	  * imclassimports         - import statements for the intermediary class
	  * imclassinterfaces      - interface (implements) for the intermediary class
	  *
	  * modulebase              - base (extends) for the module cl
	  * moduleclassmodifiers    - class modifiers for the module class
	  * modulecode              - text (Pascal code) is copied verbatim to the module class
	  * moduleimports           - import statements for the module class
	  * moduleinterfaces        - interface (implements) for the module class
	  *
	  * ----------------------------------------------------------------------------- */

	  virtual int pragmaDirective(Node *n) {
		  if (!ImportMode) {
			  String *lang = GetattrNew(n, "lang");
			  String *code = GetattrNew(n, "name");
			  String *value = GetattrNew(n, "value");

			  if (Strcmp(lang, "delphi") == 0) {

				  String *strvalue = NewString(value);
				  Replaceall(strvalue, "\\\"", "\"");
				  /*
				  bool isEnumItem = Strcmp(code, "enumitem") == 0;
				  bool isSetItem  = Strcmp(code, "setitem")  == 0;
				  */
				  if (Strcmp(code, "imclassbase") == 0) {
					  Delete(pasraw_baseclass);
					  pasraw_baseclass = Copy(strvalue);
				  } else if (Strcmp(code, "imclassclassmodifiers") == 0) {
					  Delete(pasraw_class_modifiers);
					  pasraw_class_modifiers = Copy(strvalue);
				  } else if (Strcmp(code, "imclasscode") == 0) {
					  Printf(pasraw_intf.f, "%s\n", strvalue);
				  } else if (Strcmp(code, "imclassimports") == 0) {
					  Delete(pasraw_imports);
					  pasraw_imports = Copy(strvalue);
				  } else if (Strcmp(code, "imclassinterfaces") == 0) {
					  Delete(pasraw_interfaces);
					  pasraw_interfaces = Copy(strvalue);
				  } else if (Strcmp(code, "modulebase") == 0) {
					  Delete(module_baseclass);
					  module_baseclass = Copy(strvalue);
				  } else if (Strcmp(code, "moduleclassmodifiers") == 0) {
					  Delete(paswrap_modifiers);
					  paswrap_modifiers = Copy(strvalue);
				  } else if (Strcmp(code, "modulecode") == 0) {
					  Printf(paswrap_impl.f, "%s\n", strvalue);
				  } else if (Strcmp(code, "moduleimports") == 0) {
					  Delete(module_imports);
					  module_imports = Copy(strvalue);
				  } else if (Strcmp(code, "moduleinterfaces") == 0) {
					  Delete(module_interfaces);
					  module_interfaces = Copy(strvalue);
				  } else if (Strcmp(code, "unsafe") == 0) {
					  unsafe_module = true;
				  } else if (Strcmp(code, "library") == 0) {
					  if (targetlibrary != NULL) {
						  Delete(targetlibrary);
					  }
					  targetlibrary = Copy(strvalue);
				  } else if (Strcmp(code, "enumitem") == 0) {
				  } else if (Strcmp(code, "constset") == 0) {
				  } else if (Strcmp(code, "constint") == 0) {
				  } else if (Strcmp(code, "makesetofenum") == 0) {
					  paswrap_intf.enterBlock(blocktype);
					  Printf(paswrap_intf.f, "%sSet = SET OF %s;\n", value, value);

				  } else if (Strcmp(code, "WRAPDLLNAME") == 0 && value) {
					  //	wrapdllname = Copy(value);

				  } else if (Strcmp(code, "DLLNAME") == 0 && value) {
					  dllname = Copy(value);
				  } else if (Strcmp(code, "WRAPSOURCENAME") == 0 && value) {
					  //	wrapsourcename = Copy(value);	 
				  } else if (Strcmp(code, "CALLCONV") == 0 && value) {
					  callconv = Copy(value);	 
				  } else if (Strcmp(code, "USES") == 0 && value) {
					  intf_uses = Copy(value);	 
				  } else if (Strcmp(code, "NAMESPACE") == 0 && value) {
					  m_namespace = Copy(value);	 
				  }  else if (Strcmp(code, "nowrap_function") == 0) {
					  // todo

				  } else {
					  Swig_warning(WARN_DELPHI_UNKNOWN_PRAGMA, input_file, line_number, "Unrecognized pragma <%s>.\n", code);
				  }
				  Delete(strvalue);
			  }
		  }
		  return Language::pragmaDirective(n);
	  }

	  void Setfeature(Node *n, const char *feature, const String *value, bool warn = false) {
		  //printf("tag feature <%s> with value <%s>\n", feature, Char(value));
		  String *attr = NewStringf("feature:%s", feature);
		  if ((Setattr(n, attr, value) != 0) && warn) {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Feature <%s> of %s did already exist.\n", feature, GetattrNew(n, "name"));
		  }

		  Delete(attr);
	  }

	  String *Getfeature(Node *n, const char *feature) {
		  //printf("retrieve feature <%s> with value <%s>\n", feature, Char(value));
		  String *attr = NewStringf("feature:%s", feature);
		  String *result = GetattrNew(n, (const char *)attr);
		  Delete(attr);
		  return result;
	  }

	  bool convertInt(long in, long &out, const String *mode) {
		  if ((mode == NIL) || (Strcmp(mode, "int:int") == 0) || (Strcmp(mode, "set:set") == 0)) {
			  out = in;
			  return true;
		  } else if (Strcmp(mode, "set:int") == 0) {
			  return log2(in, out);
		  } else if (Strcmp(mode, "int:set") == 0) {
			  out = 1L << in;
			  return unsigned (in) < (sizeof(out) * 8);
		  } else {
			  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Unknown integer conversion method <%s>.\n", mode);
			  return false;
		  }
	  }

	  void collectEnumerations(Hash *enums, Node *n) {
		  Node *child = firstChild(n);
		  while (child != NIL) {
			  String *name = GetattrNew(child, "name");
			  const bool isConstant = Strcmp(nodeType(child), "constant") == 0;
			  const bool isEnumItem = Strcmp(nodeType(child), "enumitem") == 0;
			  if (isConstant || isEnumItem) {
				  //printf("%s%s name %s\n", isConstant?"constant":"", isEnumItem?"enumitem":"", Char(name));
				  {
					  String *pasname = Getfeature(child, "delphi:enumitem:name");
					  String *pasenum = Getfeature(child, "delphi:enumitem:enum");
					  String *conv = Getfeature(child, "delphi:enumitem:conv");

					  if (pasenum != NIL) {
						  //printf("pasenum %s\n", Char(pasenum));
						  if (pasname == NIL) {
							  pasname = name;
						  }

						  long max = -1;
						  Hash *items;
						  Hash *enumnode = Getattr(enums, pasenum);
						  if (enumnode == NIL) {
							  enumnode = NewHash();
							  items = NewHash();
							  Setattr(enumnode, "items", items);
							  Setattr(enums, pasenum, enumnode);
						  } else {
							  String *maxstr = GetattrNew(enumnode, "max");
							  if (maxstr != NIL) {
								  max = aToL(maxstr);
							  }
							  items = GetattrNew(enumnode, "items");
						  }
						  long numvalue;
						  String *value = GetattrNew(child, "value");
						  //printf("value: %s\n", Char(value));
						  if ((value == NIL) || (!strToL(value, numvalue))) {
							  value = GetattrNew(child, "enumvalue");
							  if ((value == NIL) || (!evalExpr(value, numvalue))) {
								  numvalue = getConstNumeric(child);
							  }
							  //printf("constnumeric: %s\n", Char(value));
						  }
						  Setattr(constant_values, name, NewStringf("%d", numvalue));
						  if (convertInt(numvalue, numvalue, conv)) {
							  String *newvalue = NewStringf("%d", numvalue);
							  String *oldname = GetattrNew(items, (const char *)newvalue);
							  if (oldname != NIL) {
								  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "The value <%s> is already assigned to <%s>.\n", value, oldname);
							  }
							  //printf("items %lx, set %s = %s\n", (long) items, Char(newvalue), Char(pasname));
							  Setattr(items, newvalue, pasname);
							  if (max < numvalue) {
								  max = numvalue;
							  }
							  Setattr(enumnode, "max", NewStringf("%d", max));
						  }
					  }
				  }
			  }

			  collectEnumerations(enums, child);
			  child = nextSibling(child);
		  }
	  }

	  enum const_pragma_type { cpt_none, cpt_constint, cpt_constset, cpt_enumitem };

	  struct const_id_pattern {
		  String *prefix, *parentEnum;
	  };

	  void tagConstants(Node *first, String *parentEnum, const const_id_pattern & pat, const String *pragma, List *convdesc) {
		  Node *n = first;
		  while (n != NIL) {
			  String *name = getQualifiedName(n);
			  bool isConstant = Strcmp(nodeType(n), "constant") == 0;
			  bool isEnumItem = Strcmp(nodeType(n), "enumitem") == 0;
			  if ((isConstant || isEnumItem) && ((pat.prefix == NIL) || (hasPrefix(name, pat.prefix))) && ((pat.parentEnum == NIL) || ((parentEnum != NIL)
				  &&
				  (Strcmp
				  (pat.parentEnum, parentEnum)
				  == 0)))) {
					  //printf("tag %s\n", Char(name));
					  String *srctype = Getitem(convdesc, 1);
					  String *relationstr = Getitem(convdesc, 3);
					  List *relationdesc = Split(relationstr, ',', 2);

					  // transform name from C to Delphi style
					  String *srcstyle = NIL;
					  String *newprefix = NIL;
					  {
						  //printf("name conversion <%s>\n", Char(Getitem(convdesc,2)));
						  List *namedesc = Split(Getitem(convdesc, 2), ',', INT_MAX);
						  Iterator nameit = First(namedesc);
						  for (; nameit.item != NIL; nameit = Next(nameit)) {
							  List *nameassign = Split(nameit.item, '=', 2);
							  String *tag = Getitem(nameassign, 0);
							  String *data = Getitem(nameassign, 1);
							  //printf("name conv <%s> = <%s>\n", Char(tag), Char(data));
							  if (Strcmp(tag, "srcstyle") == 0) {
								  srcstyle = Copy(data);
							  } else if (Strcmp(tag, "prefix") == 0) {
								  newprefix = Copy(data);
							  } else {
								  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Unknown name conversion tag <%s> with value <%s>.\n", tag, data);
							  }
							  Delete(nameassign);
						  };
						  Delete(namedesc);
					  }
					  const char *stem = Char(name);
					  if (pat.prefix != NIL) {
						  //printf("pat.prefix %s for %s\n", Char(pat.prefix), Char(name));
						  stem += Len(pat.prefix);
					  }
					  String *newname;
					  if (srcstyle && Strcmp(srcstyle, "underscore") == 0) {
						  if (newprefix != NIL) {
							  String *newstem = nameToDelphi(stem, true);
							  newname = NewStringf("%s%s", newprefix, newstem);
							  Delete(newstem);
						  } else {
							  newname = nameToDelphi(stem, true);
						  }
					  } else {
						  if (srcstyle != NIL) {
							  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Unknown C identifier style <%s>.\n", srcstyle);
						  }
						  newname = Copy(name);
					  }

					  if (Strcmp(pragma, "enumitem") == 0) {
						  if (Len(relationdesc) != 1) {
							  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Expected <enumeration>, got <%s>.\n", relationstr);
						  }
						  Setfeature(n, "delphi:enumitem:name", newname, true);
						  Setfeature(n, "delphi:enumitem:enum", relationstr, true);
						  Setfeature(n, "delphi:enumitem:conv", NewStringf("%s:int", srctype), true);
					  } else if (Strcmp(pragma, "constint") == 0) {
						  if (Len(relationdesc) != 1) {
							  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Expected <ordinal type>, got <%s>.\n", relationstr);
						  }
						  Setfeature(n, "delphi:constint:name", newname, true);
						  Setfeature(n, "delphi:constint:type", Getitem(relationdesc, 0), true);
						  Setfeature(n, "delphi:constint:conv", NewStringf("%s:int", srctype), true);
					  } else if (Strcmp(pragma, "constset") == 0) {
						  if (Len(relationdesc) != 2) {
							  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Expected <set type,base type>, got <%s>.\n", relationstr);
						  }
						  String *settype = Getitem(relationdesc, 0);
						  Setfeature(n, "delphi:constset:name", newname, true);
						  //Setfeature(n,"delphi:constset:type",settype,true);
						  Setfeature(n, "delphi:constset:set", settype, true);
						  Setfeature(n, "delphi:constset:base", Getitem(relationdesc, 1), true);
						  Setfeature(n, "delphi:constset:conv", NewStringf("%s:set", srctype), true);
					  }

					  Delete(newname);
					  Delete(relationdesc);
			  }

			  if (Strcmp(nodeType(n), "enum") == 0) {
				  //printf("explore enum %s, qualification %s\n", Char(name), Char(Swig_symbol_qualified(n)));
				  tagConstants(firstChild(n), name, pat, pragma, convdesc);
			  } else {
				  tagConstants(firstChild(n), NIL, pat, pragma, convdesc);
			  }
			  n = nextSibling(n);
		  }
	  }

	  void scanForConstPragmas(Node *n) {
		  Node *child = firstChild(n);
		  while (child != NIL) {
			  const String *type = nodeType(child);
			  if (Strcmp(type, "pragma") == 0) {
				  const String *lang = GetattrNew(child, "lang");
				  const String *code = GetattrNew(child, "name");
				  String *value = GetattrNew(child, "value");

				  if (Strcmp(lang, "delphi") == 0) {
					  const_pragma_type cpt = cpt_none;
					  if (Strcmp(code, "constint") == 0) {
						  cpt = cpt_constint;
					  } else if (Strcmp(code, "constset") == 0) {
						  cpt = cpt_constset;
					  } else if (Strcmp(code, "enumitem") == 0) {
						  cpt = cpt_enumitem;
					  }
					  if (cpt != cpt_none) {
						  const_id_pattern pat = { NIL, NIL };

						  List *convdesc = Split(value, ';', 4);
						  List *patterndesc = Split(Getitem(convdesc, 0), ',', INT_MAX);
						  Iterator patternit;
						  for (patternit = First(patterndesc); patternit.item != NIL; patternit = Next(patternit)) {
							  List *patternassign = Split(patternit.item, '=', 2);
							  String *tag = Getitem(patternassign, 0);
							  String *data = Getitem(patternassign, 1);
							  if (Strcmp(tag, "prefix") == 0) {
								  pat.prefix = Copy(data);
							  } else if (Strcmp(tag, "enum") == 0) {
								  pat.parentEnum = Copy(data);
							  } else {
								  Swig_warning(WARN_DELPHI_BAD_ENUMERATION, input_file, line_number, "Unknown identification tag <%s> with value <%s>.\n", tag, data);
							  }
							  Delete(patternassign);
						  }
						  tagConstants(child, NIL, pat, code, convdesc);

						  Delete(patterndesc);
					  }
				  }
			  }
			  scanForConstPragmas(child);
			  child = nextSibling(child);
		  }
	  }

	  void emitProxyClassMethods(Node * /*n*/) {
#if 0
		  enum access_privilege { acc_public, acc_protected, acc_private };
		  int max_acc = acc_public;

		  const char *acc_name[3] = { "public", "protected", "private" };
		  String *methods[3];
		  int acc;
		  for (acc = acc_public; acc <= acc_private; acc++) {
			  String *methodattr = NewStringf("delphi:method:%s", acc_name[acc]);
			  methods[acc] = GetattrNew(n, (const char *)methodattr);
			  Delete(methodattr);
			  max_acc = max_acc > acc ? max_acc : acc;
		  }
		  /* Determine the name of the base class */
		  String *baseclassname = NewString("");
		  {
			  List *baselist = Getattr(n, "bases");
			  if (baselist) {
				  /* Look for the first (principal?) base class -
				  Pascal does not support multiple inheritance */
				  Iterator base = First(baselist);
				  if (base.item) {
					  Append(baseclassname, GetattrNew(base.item, "sym:name"));
					  base = Next(base);
					  if (base.item) {
						  Swig_warning(WARN_DELPHI_MULTIPLE_INHERITANCE, input_file,
							  line_number,
							  "Warning for %s, base %s ignored. Multiple inheritance is not supported in Pascal.\n",
							  proxy_class_name, GetattrNew(base.item, "name"));
					  }
				  }
			  }
		  }

		  /* the private class of the base class and only this
		  need a pointer to the C++ object */
		  bool need_private = !hasContent(baseclassname);
		  max_acc = need_private ? acc_private : max_acc;

		  /* Declare C++ object as abstract pointer in Pascal */

		  if (hasContent(baseclassname)) {
			  pasraw_intf.enterBlock(blocktype);
			  Printf(pasraw_intf.f, "%s = %s;\n", proxy_class_name, baseclassname);
		  } else {
			  pasraw_intf.enterBlock(blocktype);
			  Printf(pasraw_intf.f, "%s <: ADDRESS;\n", proxy_class_name);
			  pasraw_impl.enterBlock(revelation);
			  Printf(pasraw_impl.f, "%s = UNTRACED BRANDED REF RECORD (*Dummy*) END;\n", proxy_class_name);
		  }

		  String *superclass;
		  paswrap_intf.enterBlock(blocktype);
		  if (hasContent(methods[acc_public])) {
			  superclass = NewStringf("%sPublic", proxy_class_name);
		  } else if (hasContent(baseclassname)) {
			  superclass = Copy(baseclassname);
		  } else {
			  superclass = NewString("TObject");
		  }
		  Printf(paswrap_intf.f, "%s <: %s;\n", proxy_class_name, superclass);
		  Delete(superclass);

		  {
			  static const char *acc_passuffix[] = { "Public", "Protected", "Private" };
			  int acc;
			  for (acc = acc_public; acc <= acc_private; acc++) {
				  bool process_private = (acc == acc_private) && need_private;
				  if (hasContent(methods[acc]) || process_private) {
					  String *subclass = NewStringf("%s%s", proxy_class_name, acc_passuffix[acc]);
					  /*
					  paswrap_intf.enterBlock(revelation);
					  Printf(paswrap_intf.f, "%s <: %s;\n", proxy_class_name, subclass);
					  */
					  if (acc == max_acc) {
						  paswrap_intf.enterBlock(revelation);
						  Printf(paswrap_intf.f, "%s =\n", proxy_class_name);
					  } else {
						  paswrap_intf.enterBlock(blocktype);
						  Printf(paswrap_intf.f, "%s =\n", subclass);
					  }
					  Printf(paswrap_intf.f, "%s BRANDED OBJECT\n", baseclassname);
					  if (process_private) {
						  Setattr(paswrap_intf.import, pasraw_name, "");
						  Printf(paswrap_intf.f, "cxxObj:%s.%s;\n", pasraw_name, proxy_class_name);
					  }
					  if (hasContent(methods[acc])) {
						  Printf(paswrap_intf.f, "METHODS\n%s", methods[acc]);
					  }
					  if (acc == max_acc) {
						  String *overrides = GetattrNew(n, "delphi:override");
						  Printf(paswrap_intf.f, "OVERRIDES\n%s", overrides);
					  }
					  Printf(paswrap_intf.f, "END;\n");
					  Delete(baseclassname);
					  baseclassname = subclass;

				  }
			  }
		  }

		  Delete(methods[acc_public]);
		  Delete(methods[acc_protected]);
		  Delete(methods[acc_private]);

#endif

	  }

	  /* -----------------------------------------------------------------------------
	  * emitProxyClassDefAndCPPCasts()
	  * ----------------------------------------------------------------------------- */

	  void emitProxyClassDefAndCPPCasts(Node *n) {
		  //Swig_error("My Debugging",  101010, "=============> emitProxyClassDefAndCPPCasts n : %s\n", n);
		  //String *c_classname = SwigType_namestr(GetattrNew(n, "name"));
		  String *c_baseclass = NULL;
		  String *baseclass = NULL;
		  String *c_baseclassname = NULL;
//		  String *classDeclarationName = GetattrNew(n, "classDeclaration:name");
		  String *classDeclarationName = GetattrNew(n, "sym:name");

		  /* Deal with inheritance */
		  List *baselist = Getattr(n, "bases");
		  if (baselist) {
			  Iterator base = First(baselist);
			  c_baseclassname = GetattrNew(base.item, "name");
			  baseclass = Copy(getProxyName(c_baseclassname));
			  if (baseclass) {
				  c_baseclass = SwigType_namestr(GetattrNew(base.item, "name"));
			  }
			  base = Next(base);
			  if (base.item != NIL) {
				  Swig_warning(WARN_DELPHI_MULTIPLE_INHERITANCE, input_file,
					  line_number,
					  "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in Pascal.\n",
					  classDeclarationName, GetattrNew(base.item, "name"));
			  }/**/
			  /*while (base.item) {
				  if (!GetFlag(base.item, "feature:ignore")) {
					  String *baseclassname = GetattrNew(base.item, "name");
					  if (!c_baseclassname) {
						  c_baseclassname = baseclassname;
						  baseclass = Copy(getProxyName(baseclassname));
						  if (baseclass)
							  c_baseclass = SwigType_namestr(baseclassname);
					  }
					  else {
					  /* Warn about multiple inheritance for additional base class(es) */
/*						  String *proxyclassname = GetattrNew(n, "classtypeobj");
						  Swig_warning(WARN_DELPHI_MULTIPLE_INHERITANCE, Getfile(n), Getline(n),
							  "Warning for %s, base %s ignored. Multiple inheritance is not supported in Pascal.\n", SwigType_namestr(proxyclassname), SwigType_namestr(baseclassname));
					  }
				  }
				  base = Next(base);
			  }*/

		  }

		  bool derived = baseclass && getProxyName(c_baseclassname);
		  if (!baseclass)
			  baseclass = NewString("");

		  // Inheritance from pure Pascal classes
		  const String *pure_baseclass = typemapLookup("pasbase", classDeclarationName, WARN_NONE);
		  if (hasContent(pure_baseclass) && hasContent(baseclass)) {
			  Swig_warning(WARN_DELPHI_MULTIPLE_INHERITANCE, input_file,
				  line_number,
				  "Warning for %s, base %s ignored. Multiple inheritance is not supported in Pascal.\n", classDeclarationName, pure_baseclass);
		  }
		  // Pure Pascal interfaces
		  const String *pure_interfaces = typemapLookup(derived ? "pasinterfaces_derived" : "pasinterfaces",
		  classDeclarationName, WARN_NONE);/**/



		  String *tag_kind = GetattrNew(n, "kind");
		  //Swig_error("My Debugging", 101010, "=============> tag_kind n : %s\n", tag_kind);
		  if (tag_kind == NIL) {
			  Printv(proxy_class_def, "",
				  derived ? typemapLookup("pasclassdef_derived", classDeclarationName, WARN_NONE) :
				  typemapLookup("pasclassdef_base", classDeclarationName, WARN_NONE),


				  NIL);

		  }
		  else {
			  if (Strcmp(tag_kind, "struct") == 0) {
				  Printv(proxy_class_def, "",
					  typemapLookup("pasclassdef_base_struct", classDeclarationName, WARN_NONE),


					  NIL);

			  }
			  else {
				  Printv(proxy_class_def, "",
					  derived ? typemapLookup("pasclassdef_derived", classDeclarationName, WARN_NONE) :
					  typemapLookup("pasclassdef_base", classDeclarationName, WARN_NONE),


					  NIL);


			  }

		  }
		  if (!derived)

			  Printv(proxy_class_code,"",
			  typemapLookup("pasclass_iunknown", classDeclarationName, WARN_NONE)
			  ,NIL);


		  //	   Replace(proxy_class_def,"$pasclassname", proxy_class_name, DOH_REPLACE_ANY);

#if 0
		  // Start writing the proxy class
		  Printv(proxy_class_def, 
			  //typemapLookup("pasimports", classDeclarationName, WARN_NONE),	// Import statements
			  "\n", 
			  typemapLookup("pasclassmodifiers", classDeclarationName, WARN_DELPHI_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers
			  " $pasclassname = class (TObject",	// Class name and bases
			  (derived || *Char(pure_baseclass) || *Char(pure_interfaces)) ? " " : "", baseclass, pure_baseclass, ((derived || *Char(pure_baseclass)) && *Char(pure_interfaces)) ?	// Interfaces
			  ", " : "", pure_interfaces, ")"
			  " \n", "  private \n"
			  "	IswigCPtr : pointer;\n",	// Member variables for memory handling
			  derived ? "" : "  protected bool swigCMemOwn;\n", "\n", "  ", typemapLookup("pasptrconstructormodifiers", classDeclarationName, WARN_DELPHI_TYPEMAP_PTRCONSTMOD_UNDEF),	// pointer constructor modifiers
			  " $pasclassname(IntPtr cPtr, bool cMemoryOwn) ",	// Constructor used for wrapping pointers
			  derived ?
			  ": base($imclassname.$pasclassnameTo$baseclass(cPtr), cMemoryOwn) {\n"
			  : "{\n    swigCMemOwn = cMemoryOwn;\n", "    swigCPtr = cPtr;\n", "  }\n", NIL);
#endif
		  if (!have_default_constructor_flag && !derived) {	// All proxy classes need a constructor
			  Printv(proxy_class_def, typemapLookup("pasdefault_constructor_def", classDeclarationName, WARN_NONE), NIL);
			  Printv(proxy_class_code, typemapLookup("pasdefault_constructor_code", classDeclarationName, WARN_NONE), NIL);
		  }
		  Printv(proxy_class_def, proxy_class_constructor_def, NIL);

		  // C++ destructor is wrapped by the Free method
		  // Note that the method name is specified in a typemap attribute called methodname
		  String *destruct = NewString("");
		  const String *tm_def = NULL;
		  const String *tm_code = NULL;
		  Node *attributes = NewHash();
		  String *destruct_methodname = NULL;
		  tm_def = typemapLookup("pasdestruct_def", classDeclarationName, WARN_NONE);
		  if (derived) {
			  tm_code = typemapLookup("pasdestruct_derived_code", classDeclarationName, WARN_NONE, attributes);
			  destruct_methodname = GetattrNew(attributes, "tmap:pasdestruct_derived_code:methodname");
		  } else {
			  tm_code = typemapLookup("pasdestruct_code", classDeclarationName, WARN_NONE, attributes);
			  destruct_methodname = GetattrNew(attributes, "tmap:pasdestruct_code:methodname");
		  }
		  if (!destruct_methodname) {
			  Swig_error(input_file, line_number, "No methodname attribute defined in pasdestruct%s typemap for %s\n", (derived ? "_derived" : ""), proxy_class_name);
		  }
		  // Emit the Finalize and Dispose methods
		  if (tm_code) {
			  // Finalize method
			  if (*Char(destructor_call)) {
				  //Printv(proxy_class_def, typemapLookup("pasfinalize", classDeclarationName, WARN_NONE), NIL);
			  }
			  // Dispose method
			  Printv(destruct, tm_code, NIL);
			  if (*Char(destructor_call))
				  Replaceall(destruct, "$imcall", destructor_call);
			  else
				  Replaceall(destruct, "$imcall", "throw new MethodAccessException(\"C++ destructor does not have public access\")");

			  if (*Char(destruct)) {
				  //Printv(proxy_class_def, "\n  public ", derived ? "override" : "virtual", " void ", destruct_methodname, "() ", destruct, "\n", NIL);
				  Printv(proxy_class_def, tm_def, NIL);
				  Printv(proxy_class_code, destruct, NIL);
			  }

		  }
		  Delete(attributes);
		  Delete(destruct);

		  // Emit various other methods
		  Printv(proxy_class_def, 
			  derived?"":typemapLookup("pasgetcptr_intf", classDeclarationName, WARN_DELPHI_TYPEMAP_GETCPTR_UNDEF),	// getCPtr method

			  typemapLookup("pascode", classDeclarationName, WARN_NONE),	// extra Pascal code
			  NIL);

		  emitProxyClassMethods(n);

		  Printv(proxy_class_def, 

			  typemapLookup("pasclassdef_end", classDeclarationName, WARN_NONE),			 
			  "\n", NIL);


		  // Substitute various strings into the above template
		  Replaceall(proxy_class_def, "$pasclassname", proxy_class_name);
		  Replaceall(proxy_class_code, "$pasclassname", proxy_class_name);

		  Replaceall(proxy_class_def, "$baseclass", baseclass);
		  Replaceall(proxy_class_code, "$baseclass", baseclass);

		  Replaceall(proxy_class_def, "$imclassname", pasraw_name);
		  Replaceall(proxy_class_code, "$imclassname", pasraw_name);
#if 0
		  // Add code to do C++ casting to base class (only for classes in an inheritance hierarchy)
		  if (derived) {
			  Printv(pasraw_cppcasts_code, "\n  [DllImport(\"", paswrap_name, "\", EntryPoint=\"Delphi_", proxy_class_name, "To", baseclass, "\")]\n", NIL);
			  Printv(pasraw_cppcasts_code, "  public static extern IntPtr ", "$pasclassnameTo$baseclass(IntPtr objectRef);\n", NIL);

			  Replaceall(pasraw_cppcasts_code, "$pasclassname", proxy_class_name);
			  Replaceall(pasraw_cppcasts_code, "$baseclass", baseclass);

			  Printv(upcasts_code,
				  "SWIGEXPORT long Delphi_$imclazznameTo$imbaseclass",
				  "(long objectRef) {\n",
				  "    long baseptr = 0;\n" "    *($cbaseclass **)&baseptr = *($cclass **)&objectRef;\n" "    return baseptr;\n" "}\n", "\n", NIL);

			  Replaceall(upcasts_code, "$imbaseclass", baseclass);
			  Replaceall(upcasts_code, "$cbaseclass", c_baseclass);
			  Replaceall(upcasts_code, "$imclazzname", proxy_class_name);
			  Replaceall(upcasts_code, "$cclass", c_classname);
		  }
#endif	
		  Delete(baseclass);
	  }

	  /* ----------------------------------------------------------------------
	  * getAttrString()
	  *
	  * If necessary create and return the string
	  * associated with a certain attribute of 'n'.
	  * ---------------------------------------------------------------------- */

	  String *getAttrString(Node *n, const char *attr) {
		  String *str = GetattrNew(n, attr);
		  if (str == NIL) {
			  str = NewString("");
			  Setattr(n, attr, str);
		  }
		  return str;
	  }

	  /* ----------------------------------------------------------------------
	  * getMethodDeclarations()
	  *
	  * If necessary create and return the handle
	  * where the methods of the current access can be written to.
	  * 'n' must be a member of a struct or a class.
	  * ---------------------------------------------------------------------- */

	  String *getMethodDeclarations(Node *n) {
		  String *acc_str = GetattrNew(n, "access");
		  String *methodattr;
		  if (acc_str == NIL) {
			  methodattr = NewString("delphi:method:public");
		  } else {
			  methodattr = NewStringf("delphi:method:%s", acc_str);
		  }
		  String *methods = getAttrString(parentNode(n), Char(methodattr));
		  Delete(methodattr);
		  return methods;
	  }

	  virtual int cDeclaration(Node *n) {


		  return Language::cDeclaration(n);
	  }

	  virtual int emitDelphiFunctionPointer(Node *n, const String *cname, const String * /*pasname*/, String  *f, char * /*_external*/, Hash *import, String *_storage) {

		  //String * overloaded = GetattrNew(n,"sym:overloaded");
		  //String * overloaded_name = GetattrNew(n,"sym:overname");
		  String *im_return_type = NewString("");
		  //String   *symname = GetattrNew(n,"sym:name");
		  ParmList *l = Getattr(n, "parms");

		  String *storage= 0;//= GetattrNew(n, "storage");

		  storage = NewStringf(callconv);

		  String *_pars = NewStringf("");
		  //String *tt = GetattrNew(n, "type");
		  //  attachMappedType(n, "pasrawrettype");

		  /* Attach the non-standard typemaps to the parameter list. */
		  Swig_typemap_attach_parms("pasrawinmode", l, NULL);
		  Swig_typemap_attach_parms("pasrawintype", l, NULL);

		  /* Get return types */
		  bool has_return=false;

		  {
			  String *tm = getMappedTypeNew(n, "pasrawrettype","");
			  if (tm != NIL) {
				  Printf(im_return_type, "%s", tm);
			  }
			  has_return = hasContent(tm);
		  }

		  Printf(f, "\ntype \n%s = ",cname);

		  /* cname is the original name if 'n' denotes a C function
		  and it is the relabeled name (sym:name) if 'n' denotes a C++ method or similar */
		  //f.enterBlock(no_block);
		  if (has_return) 
			  Printf(f, "function  (", cname);
		  else 
			  Printf(f, "procedure (", cname);
		  // Generate signature for raw interface
		  {
			  Parm *p;
			  writeArgState state;
			  attachParameterNames(n, "tmap:rawinname", "delphi:rawname", "arg%d");
			  for (p = skipIgnored(l, "pasrawintype"); p != NULL; p = skipIgnored(p, "pasrawintype")) {

				  /* Get argument passing mode, should be one of VALUE, VAR, CONST */
				  String *mode = GetattrNew(p, "tmap:pasrawinmode");
				  String *argname = GetattrNew(p, "delphi:rawname");
				  String *im_param_type = getMappedType(p, "pasrawintype");
				  //SwigType *type  = GetattrNew(p,"type");



				  Replace(im_param_type," const", "", DOH_REPLACE_FIRST);

				  if (import)
					  addImports(import, "pasrawintype", p);
				  if (argname != NULL)  // varargs skipped"
					  writeArg(_pars, state, mode, argname, im_param_type, NIL);
				  if (im_param_type != NIL) {
					  p = Getattr(p, "tmap:pasrawintype:next");
				  } 
				  else {
					  p = nextSibling(p);
				  }
			  }

			  writeArg(_pars, state, NIL, NIL, NIL, NIL);
		  }

		  /* Finish PAS raw prototype */
		  Chop(_pars);
		  Printf(f, "%s)", ChopCh(Char(_pars),';'));
		  // neither a C wrapper nor a plain C function may throw an exception
		  //generateThrowsClause(throws_hash, pasraw_intf.f);

		  if (has_return) {
			  Printf(f, ": %s", im_return_type);
		  }

		  Printf(f, "");

		  Printf(f, "; %s", _storage);



		  //char * ss = Char(storage);



		  Printf(f, ";\n");

		  Delete(_pars);
		  Delete(im_return_type);
		  return SWIG_OK;

	  }


	  virtual int typedefHandler(Node *n) {



		  String *tt = GetattrNew(n, "type");

		  int ret = 0;
		  ret = Language::typedefHandler(n);

		  // return ret;

		  //	char * xx;

		  SwigType *name = GetattrNew(n, "name");
		  SwigType *decl = GetattrNew(n, "decl");
		  /*
		  if (!SwigType_ispointer(decl) && !SwigType_isreference(decl)) {
		  SwigType *pname = Copy(name);
		  //	SwigType_add_pointer(pname);
		  //	SwigType_remember(pname);
		  Delete(pname);
		  }
		  */
		  if (SwigType_ispointer(decl)) {
			  // ret = Language::typedefHandler(n);
			  Swig_save("FPHandler",n,"type","kind","decl", NIL);

			  tt = GetattrNew(n, "type");

			  SwigType  *bb = SwigType_base(tt);

			  Setattr(n, "kind","function");
			  //	 Delattr(n, "storage");
			  SwigType_del_pointer(decl);
			  Setattr(n, "type",bb);

			  if (SwigType_isfunction(decl)) {
				  SwigType *pname = Copy(name);

				  emitDelphiFunctionPointer(n, pname, pname, interface_functions, 0, pasraw_intf.import, callconv);


				  Delete(pname);

				  Swig_restore(n);
			  }
			  else if (Cmp(bb, "void") == 0 ) { 

				  /* since this is a recurring issue, we are going to remember the
				  typedef pointer, if already it is not a pointer or reference, as
				  in

				  typedef void NT;
				  int func(NT *p); 

				  see director_basic.i for example.
				  */

				  String *record = NewString("");


				  Printf(record, 
					  "   $RecordName = type pointer;\n"
					  "   P$RecordNameArray = ^$RecordNameArray_;\n"
					  "   $RecordNameArray_=array[0..(MaxInt div sizeof($RecordName))-1] of $RecordName;\n"						
					  );
				  Replace(record,"$RecordName", name, DOH_REPLACE_ANY);


				  pasraw_intf.enterBlock(blocktype);
				  Printf(pasraw_intf.f, "%s", record);

				  Delete(record);


				  Swig_restore(n);

				  //Parm *pattern = NewParm(GetattrNew(n, "name"), NULL);
				  Parm *pattern = NewParm(NULL, GetattrNew(n, "name"), n);	

				  Swig_typemap_register("pasrawintype", pattern, name, NULL, NULL);
				  Swig_typemap_register("pasrawrettype", pattern, name, NULL, NULL);
				  Swig_typemap_register("pasrawouttype", pattern, name, NULL, NULL);


				  Delete(pattern);

			  }
			  else {				
				  Swig_restore(n);
				  //  ret = Language::typedefHandler(n);

			  }



			  // SwigType_add_pointer(decl);


			  // Add Function pointer declaration


		  }
		  //  else 	ret = Language::typedefHandler(n);


		  return ret;

	  }

	  String * replaceWithT(const string& input, const string& delimiter) {
		  const string& temp = "T_";
		  int pos = (int)input.find(temp, 0);
		  if (pos == 0) {
			  return NewString(input.c_str());
		  }
		  pos = (int)input.find(delimiter, 0);
		  if (pos == 0) {
			  string tmp;
			  tmp.append("_");
			  tmp.append(input);
			  return NewString(tmp.c_str());
		  }
		  return NewString(input.c_str());

	  }
	  String * checkTAndReplace_inHeader(String * input, const string& delimiter) {
		  if (input == NIL) {
			  return input;
		  }

		  char tmp[1024];
		  strcpy(tmp, Char(input));
		  return replaceWithT(tmp, delimiter);
		  //return input;

	  }
	  String * GetattrNew(String * input, const char * key) {
		  String * ret = Getattr(input, key);
		  if (ret == NIL) {
			  return ret;
		  }
		  ret = checkGrammarWithString(ret);

		  String * retTmp = Getattr(input, "type");
		  if (retTmp != NIL) {
			  if (Strcmp(retTmp, "class") == 0) {
				  return ret;
			  }
		  }

		  return checkTAndReplace_inHeader(ret, "TF"); 

	  }
	  String * checkGrammarWithString(String * strName) {
		  String * ret = strName;
		  if (ret == NIL) {
			  return ret;
		  }
		  if (Strcmp(ret, "Tvoid") == 0) {
			  ret = NewString("pointer");
		  }
		  if (Strcmp(ret, "size_t") == 0 || Strcmp(ret, "Tsize_t") == 0) {
			  ret = NewString("NativeUInt");
		  }
		  if (Strcmp(ret, "int64_t") == 0 || Strcmp(ret, "Tint64_t") == 0) {
			  ret = NewString("NativeUInt");
		  }
		  if (Strcmp(ret, "uint32_t") == 0 || Strcmp(ret, "Tuint32_t") == 0) {
			  ret = NewString("NativeUInt");
		  }
		  if (Strcmp(ret, "unsigned char") == 0 || Strcmp(ret, "Tunsigned char") == 0) {
			  ret = NewString("Byte");
		  }
		  return ret;
	  }

	  virtual int  classforwardDeclaration(Node *n)
	  {
		  proxy_class_name = Copy(GetattrNew(n, "sym:name"));

		  //String *rawname = GetattrNew(n,"name");
		  String *forward_declared = GetattrNew(n,"forward_declared");



		  /* This will invoke memberfunctionHandler, membervariableHandler ...
		  and finally it may invoke functionWrapper
		  for wrappers and member variable accessors.
		  It will invoke Language:constructorDeclaration
		  which decides whether to call DELPHI::constructorHandler */
		  // Language::classHandler(n);

		  {
			  String *kind = GetattrNew(n, "kind");
			  if (Cmp(kind, "struct") == 0) {

				  String *entries = NewString("");

				  if (forward_declared != 0) {


					  pasraw_intf.enterBlock(blocktype);
					  // Printf(pasraw_intf.f, "P%s = ^%s;\n", proxy_class_name, proxy_class_name);
					  // Printf(pasraw_intf.f, "%s = integer; (* opaque record*)\n", proxy_class_name);

					  Setattr(n,"forward_declared","1");	
					  Printf(pasraw_intf.f, "   %s = type pointer;\n", proxy_class_name);
				  }

				  Delete(entries);
			  } 
			  else if (Cmp(kind, "class") == 0) {
				  enum access_privilege { acc_public, acc_protected, acc_private };
				  //int max_acc = acc_public;

				  if (forward_declared != 0) {


					  pasraw_intf.enterBlock(blocktype);
					  // Printf(pasraw_intf.f, "P%s = ^%s;\n", proxy_class_name, proxy_class_name);
					  // Printf(pasraw_intf.f, "%s = integer; (* opaque record*)\n", proxy_class_name);

					  Setattr(n,"forward_declared","1");	
					  Printf(pasraw_intf.f, "   %s = type pointer;\n", proxy_class_name);
				  }



			  }	
		  }
		  return Language::classforwardDeclaration(n);
	  }

	  /* ----------------------------------------------------------------------
	  * classHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int classHandler(Node *n) {
		  //Swig_error("My Debugging", 101010, "=============> classHandler : n %s\n", n);

		  //File *f_proxy = NULL;
		  proxy_class_name = Copy(GetattrNew(n, "sym:name"));

		  PASFile output;


		  bool hasnested = false;

		  Node * LastNested = 0;
		  {
			  Node *child;
			  for (child = firstChild(n); child != NIL; child = nextSibling(child)) {
				  String *childType = nodeType(child);
				  if (Strcmp(childType, "cdecl") == 0) {
					  //String *member = GetattrNew(child, "sym:name");
					  String *type = GetattrNew(child, "type");
					  //				char *xx = Char(member);
					  char *nested = Char(GetattrNew(child, "nested"));

					  if (nested != 0) {
						  hasnested = true;

						  Node * sib;
						  for (sib = nextSibling(n); sib != NIL; sib = nextSibling(sib)) {
							  String *tn = GetattrNew(sib, "sym:name");

							  if (Strcmp(tn, type) == 0) {
								  //	Setattr(sib, "porca put","1");
								  LastNested = sib;

							  }

						  }


					  }

				  }
			  }

			  /*	if (hasnested)
			  output = NewStringf("");
			  else
			  output = NewStringf("");
			  */
		  }
		  if (proxy_flag) {
			  if (!addSymbol(proxy_class_name, n))
				  return SWIG_ERROR;

			  if (Cmp(proxy_class_name, pasraw_name) == 0) {
				  Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
				  SWIG_exit(EXIT_FAILURE);
			  }

			  if (Cmp(proxy_class_name, paswrap_name) == 0) {
				  Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
				  SWIG_exit(EXIT_FAILURE);
			  }


			  //  emitBanner(paswrap_intf.f);

			  Clear(proxy_class_def);
			  Clear(proxy_class_code);
			  Clear(proxy_class_constructor_def);

			  have_default_constructor_flag = false;
			  destructor_call = NewString("");
		  }

		  /* This will invoke memberfunctionHandler, membervariableHandler ...
		  and finally it may invoke functionWrapper
		  for wrappers and member variable accessors.
		  It will invoke Language:constructorDeclaration
		  which decides whether to call DELPHI::constructorHandler */
		  Language::classHandler(n);
		  {
			  String *kind = GetattrNew(n, "kind");
			  if (Cmp(kind, "struct") == 0 && !opaque_record) {

				  String *entries = NewString("");
				  String *record = NewString("");

				  Node *child;
				  writeArgState state;
				  for (child = firstChild(n); child != NIL; child = nextSibling(child)) {
					  String *childType = nodeType(child);
					  //Swig_error("My Debugging", 101010, "=============> classHandler/struct/child : child %s\n", child);
					  if (Strcmp(childType, "cdecl") == 0) {
						  String *member = GetattrNew(child, "sym:name");
						  //				char *xx = Char(member);

						  ParmList *pl = Getattr(child, "parms");
						  //Swig_error("My Debugging", 101010, "=============> classHandler/struct/child/cdecl : pl %s\n", pl);
						  if (pl == NIL) {
							  // Get the variable type in Pascal type equivalents
							  String *pasct = getMappedTypeNew(child, "pasrawtype", "");
							  writeArg(entries, state, NIL, member, pasct, NIL);
						  }
					  }
				  }
				  writeArg(entries, state, NIL, NIL, NIL, NIL);

				  //	pasraw_intf.enterBlock(blocktype);
				  output.enterBlock(blocktype);
				  /*Printf(record, "P%s = ^%s;\n", proxy_class_name, proxy_class_name);
				  Printf(record, "%s = record\n"
				  "%s"
				  "end;\n", proxy_class_name, entries);
				  */

				  //char * xx;

				  //xx = Char(proxy_class_name);


				  String * pt = NewString("P$RecordName");
				  String * pat = NewString("P$RecordNameArray");

				  Replace(pt,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);
				  Replace(pat,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);



				  Setattr(types_hash,proxy_class_name,"1");
				  Setattr(types_hash,pt,"1");
				  Setattr(types_hash,pat,"2");

				  Delete(pt);
				  Delete(pat);

				  Printf(record, "P$RecordName = ^$RecordName;\n"
					  "$RecordName = record\n"
					  "$fields\n"
					  "end;\n"
					  "P$RecordNameArray = ^$RecordNameArray_;\n"
					  "$RecordNameArray_=array[0..(MaxInt div sizeof($RecordName))-1] of 	$RecordName;\n"						
					  );
				  Replace(record,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);
				  Replace(record,"$fields", entries, DOH_REPLACE_ANY);

				  //Printf(pasraw_intf.f, "%s", record);
				  Printf(output.f, "%s", record);

				  //		Printf(types_decl, "%s", record);


				  Delete(entries);
				  Delete(record);


			  }
			  else if (Cmp(kind, "union") == 0 && !opaque_record) {


				  String *entries = NewString("");
				  String *record = NewString("");
				  String *fields = NewString("");
				  //String *fields1 = NewString("");


				  int cc = 0;

				  Node *child;
				  writeArgState state;
				  for (child = firstChild(n); child != NIL; child = nextSibling(child)) {
					  String *childType = nodeType(child);
					  if (Strcmp(childType, "cdecl") == 0) {
						  String *member = GetattrNew(child, "sym:name");
						  //				char *xx = Char(member);

						  ParmList *pl = Getattr(child, "parms");
						  if (pl == NIL) {
							  // Get the variable type in Pascal type equivalents
							  String *pasct = getMappedTypeNew(child, "pasrawtype", "");
							  fields = NewStringf("");		
							  //					writeArg(entries, state, NIL, member, pasct, NIL);
							  writeArg(fields, state, NIL, member, pasct, NIL); 

							  if (hasContent(fields))
								  Printf(entries,"%d:(%s);\n", cc++, fields);

						  }
					  }
				  }
				  fields = NewStringf("");
				  //		writeArg(entries, state, NIL, NIL, NIL, NIL);

				  writeArg(fields, state, NIL, NIL, NIL, NIL); 
				  Printf(entries,"%d:(%s);\n", cc++, fields);

				  //pasraw_intf.enterBlock(blocktype);
				  output.enterBlock(blocktype);
				  /*Printf(record, "P%s = ^%s;\n", proxy_class_name, proxy_class_name);
				  Printf(record, "%s = record\n"
				  "%s"
				  "end;\n", proxy_class_name, entries);
				  */

				  //char * xx;

				  //xx = Char(proxy_class_name);


				  String * pt = NewString("P$RecordName");
				  String * pat = NewString("P$RecordNameArray");

				  Replace(pt,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);
				  Replace(pat,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);



				  Setattr(types_hash,proxy_class_name,"1");
				  Setattr(types_hash,pt,"1");
				  Setattr(types_hash,pat,"2");

				  Delete(pt);
				  Delete(pat);
				  Printf(record, "P$RecordName = ^$RecordName;\n"
					  "$RecordName = record case integer of\n"
					  "$fields\n"
					  "end;\n"
					  "P$RecordNameArray = ^$RecordNameArray_;\n"
					  "$RecordNameArray_=array[0..(MaxInt div sizeof($RecordName))-1] of 	$RecordName;\n"						
					  );
				  Replace(record,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);
				  Replace(record,"$fields", entries, DOH_REPLACE_ANY);

				  //Printf(pasraw_intf.f, "%s", record);
				  Printf(output.f, "%s", record);


				  //		Printf(types_decl, "%s", record);


				  Delete(entries);
				  Delete(record);


			  }
			  else if (Cmp(kind, "class") == 0 || opaque_record) {


				  String *record = NewString("");
				  String *forward_declared = GetattrNew(n,"forward_declared");

				  if (forward_declared != 0) {

					  Printf(record, 
						  //"\n$RecordName = type pointer;\n"
						  "\nP$RecordNameArray = ^$RecordNameArray_;\n"
						  "$RecordNameArray_=array[0..(MaxInt div sizeof($RecordName))-1] of $RecordName;\n"						
						  );

				  }else {


					  Printf(record, 
						  "\n$RecordName = type pointer;\n"
						  "P$RecordNameArray = ^$RecordNameArray_;\n"
						  "$RecordNameArray_=array[0..(MaxInt div sizeof($RecordName))-1] of $RecordName;\n"						
						  );
					  Setattr(n,"forward_declared","1");
				  }
				  Replace(record,"$RecordName", proxy_class_name, DOH_REPLACE_ANY);


				  pasraw_intf.enterBlock(blocktype);
				  Printf(pasraw_intf.f, "%s", record);

				  Delete(record);

			  } else {
				  Swig_warning(WARN_DELPHI_TYPECONSTRUCTOR_UNKNOWN, input_file, line_number, "Unknown type constructor %s\n", kind);
			  }
		  }

		  //	 Language::classHandler(n);
		  /*	if (hasnested)
		  output = NewStringf("");
		  else
		  output = NewStringf("");
		  */

		  if (proxy_flag) {
			  //Swig_error("My Debugging",  101010, "=============> emitProxyClassDefAndCPPCasts : %s\n", "Called");

			  emitProxyClassDefAndCPPCasts(n);
			  paswrap_intf.enterBlock(blocktype);
			  Printv(paswrap_intf.f, proxy_class_def, NIL);
			  Printv(paswrap_impl.f, proxy_class_code, NIL);	
			  //Swig_error("My Debugging", 101010, "=============> proxy_class_def : %s\n", proxy_class_def);
			  //Swig_error("My Debugging", 101010, "=============> proxy_class_code : %s\n", proxy_class_code);

			  //Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

			  //  Printf(f_proxy, "}\n");
			  //Close(f_proxy);
			  //f_proxy = NULL;

			  Delete(proxy_class_name);
			  proxy_class_name = NULL;
			  Delete(destructor_call);
			  destructor_call = NULL;
		  }

		  if (hasnested) {
			  assert(LastNested != 0);
			  Setattr(LastNested, "Container", NewStringf(output.f));

		  }
		  else {	

			  Printf(pasraw_intf.f, "%s", output.f);
			  String * container = GetattrNew(n,"Container");

			  if (container != 0) {

				  Printf(pasraw_intf.f,"\n%s\n", container);
				  Delete(container);

			  }


		  }

		  pasraw_intf.enterBlock(no_block);
		  //Swig_error("My Debugging",  101010, "=============> SWIG_OK : \n");

		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * memberfunctionHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int memberfunctionHandler(Node *n) {
		  //printf("begin memberfunctionHandler(%s)\n", Char(GetattrNew(n,"name")));
		  Setattr(n, "delphi:functype", "method");
		  Language::memberfunctionHandler(n);

		  {
			  /* Language::memberfunctionHandler will remove the mapped types
			  that emitPASWrapper may attach */
			  ParmList *pl = Getattr(n, "parms");
			  Swig_typemap_attach_parms("paswrapinmode", pl, NULL);
			  Swig_typemap_attach_parms("paswrapinname", pl, NULL);
			  Swig_typemap_attach_parms("paswrapintype", pl, NULL);
			  Swig_typemap_attach_parms("paswrapindefault", pl, NULL);
			  attachParameterNames(n, "tmap:paswrapinname", "autoname", "arg%d");
			  String *rettype = getMappedTypeNew(n, "paswrapouttype", "");

			  String *methodname = GetattrNew(n, "sym:name");
			  /*
			  if (methodname==NIL) {
			  methodname = GetattrNew(n,"name");
			  }
			  */
			  String *arguments = createPASSignature(n);
			  String *storage = GetattrNew(n, "storage");
			  String *overridden = GetattrNew(n, "override");
			  bool isVirtual = (storage != NIL) && (Strcmp(storage, "virtual") == 0);
			  bool isOverridden = (overridden != NIL)
				  && (Strcmp(overridden, "1") == 0);
			  //Swig_error("My Debugging",  101010, "=============> isVirtual : %d\n", isVirtual);
			  if ((!isVirtual) || (!isOverridden)) {
				  {
					  String *methods = getMethodDeclarations(n);
					  //Swig_error("My Debugging",  101010, "=============> (checking func model) :>> %s(%s)%s%s;%s\n",methodname, arguments, hasContent(rettype) ? ": " : "", hasContent(rettype) ? (const String *)rettype : "", isVirtual ? "  (* base method *)" : "");
					  Printf(methods, "%s(%s)%s%s;%s\n",
						  methodname, arguments,
						  hasContent(rettype) ? ": " : "", hasContent(rettype) ? (const String *) rettype : "", isVirtual ? "  (* base method *)" : "");
				  }
				  {
					  /* this was attached by functionWrapper
					  invoked by Language::memberfunctionHandler */
					  String *fname = GetattrNew(n, "delphi:funcname");
					  //Swig_error("My Debugging",  101010, "=============> fname : %s\n", fname);
					  String *overrides = getAttrString(parentNode(n), "delphi:override");
					  //Swig_error("My Debugging",  101010, "=============> overrides : %s\n", overrides);
					  Printf(overrides, "%s := %s;\n", methodname, fname);
				  }
			  }
		  }

		  if (proxy_flag) {
			  String *overloaded_name = getOverloadedName(n);
			  //String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
			  String *intermediary_function_name = Swig_name_member(0, proxy_class_name, overloaded_name);
			  Setattr(n, "proxyfuncname", GetattrNew(n, "sym:name"));
			  Setattr(n, "imfuncname", intermediary_function_name);
			  proxyClassFunctionHandler(n);
			  Delete(overloaded_name);
		  }
		  //printf("end memberfunctionHandler(%s)\n", Char(GetattrNew(n,"name")));
		  //Swig_error("My Debugging",  101010, "=============> memberfunctionHandler : %s\n", "OK");
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * staticmemberfunctionHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int staticmemberfunctionHandler(Node *n) {

		  static_flag = true;

		  Language::staticmemberfunctionHandler(n);

		  if (proxy_flag) {


			  String *overloaded_name = getOverloadedName(n);
			  //String *intermediary_function_name = Swig_name_member(proxy_class_name, overloaded_name);
			  String *intermediary_function_name = Swig_name_member(0, proxy_class_name, overloaded_name);
			  Setattr(n, "proxyfuncname", GetattrNew(n, "sym:name"));
			  Setattr(n, "imfuncname", intermediary_function_name);
			  proxyClassFunctionHandler(n);
			  Delete(overloaded_name);
		  }
		  static_flag = false;

		  return SWIG_OK;
	  }

	  /* -----------------------------------------------------------------------------
	  * proxyClassFunctionHandler()
	  *
	  * Function called for creating a Pascal wrapper function around a c++ function in the 
	  * proxy class. Used for both static and non-static C++ class functions.
	  * C++ class static functions map to Pascal static functions.
	  * Two extra attributes in the Node must be available. These are "proxyfuncname" - 
	  * the name of the Pascal class proxy function, which in turn will call "imfuncname" - 
	  * the intermediary (PInvoke) function name in the intermediary class.
	  * ----------------------------------------------------------------------------- */

#if 0

	  String * overloaded = GetattrNew(n,"sym:overloaded");
	  String * overloaded_name = GetattrNew(n,"sym:overname");
	  String *im_return_type = NewString("");
	  //String   *symname = GetattrNew(n,"sym:name");
	  ParmList *l = Getattr(n, "parms");

	  String *storage= 0;//= GetattrNew(n, "storage");

	  storage = NewStringf(callconv);

	  String *_pars = NewStringf("");

	  /* Attach the non-standard typemaps to the parameter list. */
	  Swig_typemap_attach_parms("pasrawinmode", l, NULL);
	  Swig_typemap_attach_parms("pasrawintype", l, NULL);


	  //		   if (strcmp(Char(cname), "Delete_gamma_lut_type") == 0) __asm { int 3};

	  /* Get return types */
	  bool has_return;
	  {
		  String *tm = getMappedTypeNew(n, "pasrawrettype", "");



		  if (tm != NIL) {
			  Printf(im_return_type, "%s", tm);
		  }
		  has_return = hasContent(tm);
	  }

	  /* cname is the original name if 'n' denotes a C function
	  and it is the relabeled name (sym:name) if 'n' denotes a C++ method or similar */
	  //f.enterBlock(no_block);
	  if (has_return) 
		  //Printf(f, "\nfunction %s (", cname, pasname);
		  Printf(f, "\nfunction %s (", pasname);
	  else 
		  //Printf(f, "\nprocedure %s (", cname, pasname);
		  Printf(f, "\nprocedure %s (", pasname);
	  // G
	  // Generate signature for raw interface
	  {
		  Parm *p;
		  writeArgState state;
		  attachParameterNames(n, "tmap:rawinname", "delphi:rawname", "arg%d");
		  for (p = skipIgnored(l, "pasrawintype"); p != NULL; p = skipIgnored(p, "pasrawintype")) {

			  /* Get argument passing mode, should be one of VALUE, VAR, CONST */
			  String *mode = GetattrNew(p, "tmap:pasrawinmode");
			  String *argname = GetattrNew(p, "delphi:rawname");
			  String *im_param_type = getMappedType(p, "pasrawintype");
			  SwigType *type  = GetattrNew(p,"type");

			  Replace(im_param_type," const", "", DOH_REPLACE_FIRST);

			  if (import)
				  addImports(import, "pasrawintype", p);
			  if (argname != NULL)  // varargs skipped"
				  writeArg(_pars, state, mode, argname, im_param_type, NIL);
			  if (im_param_type != NIL) {
				  p = Getattr(p, "tmap:pasrawintype:next");
			  } 
			  else {
				  p = nextSibling(p);
			  }
		  }

		  writeArg(_pars, state, NIL, NIL, NIL, NIL);
	  }

	  /* Finish PAS raw prototype */
	  Chop(_pars);
	  Printf(f, "%s)", ChopCh(Char(_pars),';'));
	  // neither a C wrapper nor a plain C function may throw an exception
	  //generateThrowsClause(throws_hash, pasraw_intf.f);

	  if (has_return) {
		  Printf(f, ": %s", im_return_type);
	  }

	  Printf(f, "");

	  Printf(f, "; %s", _storage);

	  if ( hasContent(overloaded) )
		  Printf(f, "; overload" );


	  char * ss = Char(storage);

	  if (_external != 0) {

		  if (hasContent(overloaded))
			  Printf(f, "; external %s name '%s%s'", _external, cname, overloaded_name);
		  else
			  Printf(f, "; external %s name '%s'", _external, cname);
	  }

	  Printf(f, ";\n");

	  Delete(_pars);
	  Delete(im_return_type);
	  return SWIG_OK;


#endif

	  /*
	  function_declaration;
	  function_locals;
	  begin
	  function_code;
	  end;

	  */

	  void proxyClassFunctionHandler(Node *n) {
		  SwigType *t = GetattrNew(n, "type");
		  ParmList *l = Getattr(n, "parms");
		  Hash *throws_hash = NewHash();
		  String *intermediary_function_name = 0; /* = GetattrNew(n, "imfuncname");*/

		  String *pasname_function_name = GetattrNew(n, "delphi:pasname" );
		  // In order to use delphi side overloaded functions name
		  if (pasname_function_name != 0)
			  intermediary_function_name = pasname_function_name;
		  else 
			  intermediary_function_name = GetattrNew(n, "imfuncname");


		  String *proxy_function_name = GetattrNew(n, "proxyfuncname");
		  //String *overloaded = GetattrNew(n,"sym:overloaded");
		  //String *name = GetattrNew(n,"sym:name");
		  String *tm;
		  Parm *p;
		  int i;
		  String *pre_code = NewString("");
		  String *post_code = NewString("");
		  String *imcall = NewString("");
		  String *return_type = NewString("");
		  String *function_declaration = NewString("");
		  String *function_locals = NewString("");
		  String *function_code = NewString("");
		  String *pasname = NewString("");
		  bool setter_flag = false;
		  bool has_return = false;
		  String *method_kind = NewString("");
		  // SM  return;

		  if (!proxy_flag)
			  return;

		  if (l) {
			  if (SwigType_type(Getattr(l, "type")) == T_VOID) {
				  l = nextSibling(l);
			  }
		  }

		  /* Attach the non-standard typemaps to the parameter list */
		  Swig_typemap_attach_parms("in", l, NULL);
		  Swig_typemap_attach_parms("paswraptype", l, NULL);
		  Swig_typemap_attach_parms("paswrapinmode", l, NULL);
		  Swig_typemap_attach_parms("paswrapintype", l, NULL);

		  Swig_typemap_attach_parms("pasin_locals", l, NULL);
		  Swig_typemap_attach_parms("pasin_pre", l, NULL);
		  Swig_typemap_attach_parms("pasin_post", l, NULL);


		  Swig_typemap_attach_parms("pasin", l, NULL);



		  /* Get return types */
		  if (!wrapping_constructor_flag && (tm = getMappedTypeNew(n, "paswraptype", ""))) {
			  substituteClassname(t, tm);
			  RemoveNamespace(tm);
			  Printf(return_type, "%s", tm);
			  has_return = hasContent(tm);
		  }
		  else 
			  has_return = false;

		  if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
			  // Properties
			  pasname = capitalizeFirst(variable_name);
			  //setter_flag = (Cmp(GetattrNew(n, "sym:name"), Swig_name_set(Swig_name_member(proxy_class_name, variable_name)))
			  setter_flag = (Cmp(GetattrNew(n, "sym:name"), Swig_name_set(getNSpace(), Swig_name_member(0, proxy_class_name, variable_name)))
				  == 0);
			  if (setter_flag) 
				  proxy_function_name = NewStringf("Set%s", pasname);
			  else
				  proxy_function_name = NewStringf("Get%s", pasname);




		  }


		  if (wrapping_constructor_flag) 
			  Printf(method_kind, "%s", "constructor");
		  else {

			  if (has_return)
				  Printf(method_kind, "%s", "function");
			  else
				  Printf(method_kind, "%s", "procedure");
		  }

		  /* Start generating the proxy function */
		  //Printf(function_code, "  %s ", GetattrNew(n, "feature:delphi:methodmodifiers"));

		  Printf(proxy_class_constructor_def, "\n");


		  if (static_flag) {
			  Printf(function_declaration, "class ");
			  Printf(proxy_class_constructor_def, "    class ");
		  }
		  else {
			  Printf(function_declaration, "");
			  Printf(proxy_class_constructor_def, "    ");
		  }

		  Printf(proxy_class_constructor_def, "%s %s (", method_kind, proxy_function_name);
		  Printf(function_declaration, "%s T%s.%s (", method_kind, proxy_class_name, proxy_function_name);

		  // Begin parameters list


		  if (wrapping_constructor_flag) {


			  Printv(pre_code, 
				  "\n",
				  "  inherited Create;\n",
				  "  FOwnCObjPtr := true;\n",
				  NIL);

			  Printv(imcall, 
				  "  FCObjPtr := ", pasraw_name, ".", intermediary_function_name, "(",
				  NIL);

		  }
		  else {
			  Printv(pre_code, !static_flag ? "\n  assert(FCObjPtr <> nil);\n" : "\n", NIL);

			  Printv(imcall,"",
				  pasraw_name, ".", intermediary_function_name, "(", NIL);
		  }
		  if (!static_flag && !wrapping_constructor_flag)
			  Printv(imcall, "Self.FCObjPtr", NIL);

		  emit_mark_varargs(l);

		  int gencomma = !static_flag && !wrapping_constructor_flag;

		  /* Output each parameter */
		  writeArgState state;
		  for (i = 0, p = l; p; i++) {

			  /* Ignored varargs */
			  if (checkAttribute(p, "varargs:ignore", "1")) {
				  p = nextSibling(p);
				  continue;
			  }

			  /* Ignored parameters */
			  if (checkAttribute(p, "tmap:in:numinputs", "0")) {
				  p = Getattr(p, "tmap:in:next");
				  continue;
			  }

			  /* Ignore the 'this' argument for variable wrappers */
			  if (!(variable_wrapper_flag && i == 0)) {
				  SwigType *pt = GetattrNew(p, "type");
				  String *param_type = NewString("");

				  String *param_mode = NewString("");
				  if ((tm = GetattrNew(p, "tmap:paswrapinmode"))) {
					  substituteClassname(pt, tm);
					  Printf(param_mode, "%s", tm);
				  }



				  /* Get the Pascal parameter type */
				  if ((tm = getMappedType(p, "paswrapintype"))) {
					  substituteClassname(pt, tm);
					  Printf(param_type, "%s", tm);
				  }

				  if (gencomma)
					  Printf(imcall, ", ");

				  String *arg = variable_wrapper_flag ? NewString("value") : makeParameterName(n,
					  p,
					  i);
				  Replaceall(arg,"::","_");

				  // Use typemaps to transform type used in Pascal wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
				  if ((tm = getMappedType(p, "pasin"))) {
					  addThrows(throws_hash, "pasin", p);
					  substituteClassname(pt, tm);
					  Replaceall(tm, "$input", arg);
					  Printv(imcall, tm, NIL);

					  String *pre = getMappedType(p, "pasin_pre",false);
					  if (pre) {
						  substituteClassname(pt, pre);
						  Replaceall(pre, "$input", arg);
						  Printv(pre_code, pre, NIL);
						  Printf(pre_code, "\n");
					  }

					  String *post = getMappedType(p, "pasin_post",false);
					  if (post) {
						  substituteClassname(pt, post);
						  Replaceall(post, "$input", arg);
						  //if (Len(p_code) > 0)
						  Printv(post_code, post, NIL);
						  Printf(post_code, "\n");						
					  }

					  String *locals = getMappedType(p, "pasin_locals",false);
					  if (locals) {
						  substituteClassname(pt, locals);
						  Replaceall(locals, "$input", arg);
						  //if (Len(p_code) > 0)
						  Printv(function_locals, locals, NIL);
						  Printf(function_locals, "\n");						
					  }

#if 0
					  String *pre = GetattrNew(p, "tmap:pasin:pre");
					  if (pre) {
						  substituteClassname(pt, pre);
						  Replaceall(pre, "$input", arg);
						  Printv(pre_code, pre, NIL);
						  Printf(pre_code, "\n");
					  }

					  String *post = GetattrNew(p, "tmap:pasin:post");
					  if (post) {
						  substituteClassname(pt, post);
						  Replaceall(post, "$input", arg);
						  //if (Len(p_code) > 0)
						  Printv(post_code, post, NIL);
						  Printf(post_code, "\n");						
					  }

					  String *locals = GetattrNew(p, "tmap:pasin:locals");
					  if (locals) {
						  substituteClassname(pt, locals);
						  Replaceall(locals, "$input", arg);
						  //if (Len(p_code) > 0)
						  Printv(function_locals, locals, NIL);
						  Printf(function_locals, "\n");						
					  }
#endif

				  }

				  /* Add parameter to proxy function */
				  if (gencomma >= 2) {
					  Printf(proxy_class_constructor_def, "; ");
					  Printf(function_declaration, "; ");
				  }
				  gencomma = 2;

				  RemoveNamespace(param_type);

				  Printf(proxy_class_constructor_def, "%s %s: %s", param_mode, arg, param_type);
				  Printf(function_declaration, "%s %s: %s", param_mode, arg, param_type);

				  Delete(arg);
				  Delete(param_type);
				  Delete(param_mode);
			  }
			  p = Getattr(p, "tmap:in:next");
		  }

		  Printf(imcall, ")");
		  //Printf(imcall, ";");


		  // end parameter list

		  if (!gencomma && wrapping_constructor_flag)		// We must have a default constructor
			  have_default_constructor_flag = true;

		  Printf(proxy_class_constructor_def,")", method_kind, proxy_function_name);
		  Printf(function_declaration, ")", method_kind, proxy_function_name);

		  if (has_return) {
			  Printf(proxy_class_constructor_def,": %s;", return_type);
			  Printf(function_declaration, ": %s;", return_type);
		  }
		  else {
			  Printf(proxy_class_constructor_def, ";");
			  Printf(function_declaration, ";");
		  }

		  if (Getattr(n, "sym:overloaded") || wrapping_constructor_flag) {
			  Printf(proxy_class_constructor_def, "overload; ");
		  }

		  if (Getattr(n, "override")) {
			  //Swig_error("My Debugging",  101010, "=============> checking : %s\n", "override");
			  Printf(proxy_class_constructor_def, "override; ");
		  }
		  else if (checkAttribute(n, "storage", "virtual")) {
			  //Swig_error("My Debugging",  101010, "=============> checking : %s\n", "virtual");
			  Printf(proxy_class_constructor_def, "virtual; ");
		  }

		  // Transform return type used in PInvoke function (in intermediary class) to type used in Pascal wrapper function (in proxy class)
		  if (!wrapping_constructor_flag && (tm = getMappedTypeNew(n, "pasout", ""))) {

			  if (has_return) {

				  //String *tm1 = getMappedTypeNew(n, "ctype", "");

				  /*
				  String *pre = getMappedTypeNew(n, "pasout_locals", "");
				  if (pre) {
				  substituteClassname(pt, pre);
				  Replaceall(pre, "$input", arg);
				  //if (Len(pre_code) > 0)
				  //  Printf(pre_code, "\n");
				  Printv(pre_code, pre, NIL);
				  Printf(pre_code, "\n");
				  }

				  String *post = GetattrNew(p, "tmap:pasin:post");
				  if (post) {
				  substituteClassname(pt, post);
				  Replaceall(post, "$input", arg);
				  //if (Len(p_code) > 0)
				  Printv(post_code, post, NIL);
				  Printf(post_code, "\n");						
				  }
				  */
				  //const String *locals = typemapLookup("pasout_locals",  tm1, WARN_NONE);	
				  const String *locals = GetattrNew(n, "tmap:pasout:locals");
				  if (locals) {
					  //					substituteClassname(pt, locals);
					  //Replaceall(locals, "$input", arg);
					  //if (Len(p_code) > 0)
					  Printv(function_locals, locals, NIL);
					  Printf(function_locals, "\n");						
				  }

			  }

			  addThrows(throws_hash, "pasout", n);
			  if (GetFlag(n, "feature:new"))
				  Replaceall(tm, "$owner", "true");
			  else
				  Replaceall(tm, "$owner", "false");

			  substituteClassname(t, tm);
			  Replaceall(tm, "$imcall", imcall);
			  Replaceall(tm, "$result", "Result");
		  } 

		  if (wrapping_constructor_flag)
		  {
			  tm = imcall;
		  };

		  Printf(function_code,"%s",pre_code);
		  generateThrowsClause(throws_hash, function_code);
		  Printf(function_code, " %s;\n\n", tm ? (const String *) tm : empty_string);
		  Printf(function_code,"%s",post_code);
		  Printf(proxy_class_constructor_def, "\n");


		  if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
			  Printv(proxy_class_code, 
				  "\n",
				  function_declaration, 
				  "\n",
				  function_locals,
				  "\nbegin\n",
				  function_code,
				  "end;\n",
				  NIL);
		  } 
		  else {
			  // Normal function call
			  Printv(proxy_class_code, 
				  "\n",
				  function_declaration, 
				  "\n",
				  function_locals,
				  "\nbegin\n",
				  function_code,
				  "end;\n",
				  NIL);
			  //Printv(proxy_class_code, function_code, NIL);
		  }

		  if (proxy_flag && wrapping_member_flag && !enum_constant_flag) 
			  Delete(proxy_function_name);
		  Delete(pasname);
		  Delete(pre_code);
		  Delete(post_code);
		  Delete(function_declaration);
		  Delete(function_locals);
		  Delete(method_kind);
		  Delete(function_code);
		  Delete(return_type);
		  Delete(imcall);
		  Delete(throws_hash);
	  }

	  /* ----------------------------------------------------------------------
	  * constructorHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int constructorHandler(Node *n) {
		  // this invokes functionWrapper
		  wrapping_constructor_flag = true;
		  Language::constructorHandler(n);

		  if (proxy_flag) {

			  String *overloaded_name = getOverloadedName(n);
			  Setattr(n, "proxyfuncname", "Create");
			  Setattr(n, "imfuncname",Swig_name_construct(getNSpace(), overloaded_name));
			  proxyClassFunctionHandler(n);

#if 0

			  ParmList *l = Getattr(n, "parms");

			  Hash *throws_hash = NewHash();

			  String *imcall = NewString("");
			  String *function_code = NewString("");
			  String *helper_code = NewString(""); // Holds code for the constructor helper method generated only when the csin typemap has code in the pre or post attributes
			  String *helper_args = NewString("");
			  String *pre_code = NewString("");
			  String *post_code = NewString("");
			  String *im_return_type = NewString("");
			  bool feature_director = (parentNode(n) && Swig_directorclass(n));

			  //	  Printf(proxy_class_def, "    >-constructor Create(", GetattrNew(n, "feature:delphi:methodmodifiers"), proxy_class_name);

			  Printf(proxy_class_constructor_def, "  constructor Create(");

			  Printf(proxy_class_code, "\nconstructor T%s.Create(",  proxy_class_name);

			  //Printf(proxy_class_code, "  %s %s(", GetattrNew(n, "feature:delphi:methodmodifiers"), proxy_class_name);
			  //Printv(imcall, " : this(", pasraw_name, ".", Swig_name_construct(overloaded_name), "(", NIL);

			  Printv(imcall, 
				  "begin\n"
				  "  inherited Create;\n"
				  "  FOwnCObjPtr := true;\n"
				  "  FCObjPtr := ", pasraw_name, ".", Swig_name_construct(overloaded_name), "(",
				  NIL);


			  /* Attach the non-standard typemaps to the parameter list */
			  Swig_typemap_attach_parms("in", l, NULL);
			  Swig_typemap_attach_parms("paswraptype", l, NULL);
			  Swig_typemap_attach_parms("paswrapinmode", l, NULL);
			  Swig_typemap_attach_parms("paswrapintype", l, NULL);
			  Swig_typemap_attach_parms("pasin", l, NULL);

			  emit_mark_varargs(l);

			  int gencomma = 0;

			  String *tm;
			  Parm *p = l;
			  int i;

			  /* Output each parameter */
			  for (i = 0; p; i++) {

				  /* Ignored varargs */
				  if (checkAttribute(p, "varargs:ignore", "1")) {
					  p = nextSibling(p);
					  continue;
				  }

				  /* Ignored parameters */
				  if (checkAttribute(p, "tmap:in:numinputs", "0")) {
					  p = Getattr(p, "tmap:in:next");
					  continue;
				  }

				  SwigType *pt = GetattrNew(p, "type");
				  String *param_type = NewString("");
				  String *param_mode = NewString("");

				  /* Get the Pascal parameter type */
				  if ((tm = getMappedType(p, "paswrapintype"))) {
					  substituteClassname(pt, tm);
					  Printf(param_type, "%s", tm);
				  }

				  if ((tm = GetattrNew(p, "tmap:paswrapinmode"))) {
					  substituteClassname(pt, tm);
					  Printf(param_mode, "%s", tm);
				  }


				  if (gencomma)
					  Printf(imcall, "\n\t ");

				  String *arg = makeParameterName(n, p, i);

				  // Use typemaps to transform type used in Pascal wrapper function (in proxy class) to type used in PInvoke function (in intermediary class)
				  if ((tm = getMappedType(p, "in"))) {
					  addThrows(throws_hash, "in", p);
					  substituteClassname(pt, tm);
					  Replaceall(tm, "$input", arg);
					  Printv(imcall, tm, NIL);
				  }

				  /* Add parameter to proxy function */
				  if (gencomma) {
					  Printf(proxy_class_code, ", ");
					  Printf(proxy_class_constructor_def, ", ");
				  }
				  //	  Printf(proxy_class_code, "%s : %s",  arg, param_type);
				  Printf(proxy_class_code, "%s %s : %s", param_mode, arg , param_type);

				  gencomma = 1;

				  Delete(arg);
				  Delete(param_type);
				  Delete(param_mode);
				  p = Getattr(p, "tmap:in:next");
			  }

			  Printf(imcall, ")\n",
				  "end;",NIL);

			  Printf(proxy_class_constructor_def, "); overloaded;\n");
			  Printf(proxy_class_code, ");");
			  Printf(proxy_class_code, "\n%s", imcall);
			  //generateThrowsClause(throws_hash, proxy_class_code);
			  Printf(proxy_class_code, "end;", NIL);

			  if (!gencomma)		// We must have a default constructor
				  have_default_constructor_flag = true;


			  Delete(helper_args);
			  Delete(im_return_type);
			  Delete(pre_code);
			  Delete(post_code);
			  //   Delete(construct_tm);
			  //  Delete(attributes);
			  Delete(imcall);
#endif
#if 0
			  Delete(overloaded_name);
#endif		
		  }
		  wrapping_constructor_flag = false;
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * destructorHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int destructorHandler(Node *n) {
		  Language::destructorHandler(n);
		  String *symname = GetattrNew(n, "sym:name");

		  if (proxy_flag) {
			  Printv(destructor_call, pasraw_name, ".", Swig_name_destroy(getNSpace(), symname), "(FCObjPtr)", NIL);
		  }
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * membervariableHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int membervariableHandler(Node *n) {
		  //printf("begin membervariableHandler(%s)\n", Char(GetattrNew(n,"name")));
		  SwigType *t = GetattrNew(n, "type");
		  String *tm;

		  // Get the variable type
		  if ((tm = getMappedTypeNew(n, "paswraptype", ""))) {
			  substituteClassname(t, tm);
		  }

		  variable_name = GetattrNew(n, "sym:name");
		  //printf("member variable: %s\n", Char(variable_name));

		  // Output the property's field declaration and accessor methods
		  //SM	Printf(proxy_class_code, "  public %s %s {", tm, variable_name);

		  // SM: produces bugs in functionwrapper
		  Setattr(n, "delphi:functype", "accessor");
		  wrapping_member_flag = true;
		  variable_wrapper_flag = true;
		  Language::membervariableHandler(n);
		  wrapping_member_flag = false;
		  variable_wrapper_flag = false;

		  {
			  //String *methods = getMethodDeclarations(n);
			  //String *overrides = getAttrString(parentNode(n), "delphi:override");
			  SwigType *type = GetattrNew(n, "type");
			  String *pasname = capitalizeFirst(variable_name);

			  const String * prw;

			  if (!SwigType_isconst(type)) {

				  prw = typemapLookup("pasvarrw", type, WARN_NONE);			

			  }
			  else {

				  prw = typemapLookup("pasvarro", type, WARN_NONE);
			  }

			  Printv(proxy_class_constructor_def, prw, NIL);
			  Replaceall(proxy_class_constructor_def,"$varname",pasname);
			  Replaceall(proxy_class_constructor_def,"$vartype",tm);


			  Delete(pasname);

		  }

#if 0
		  // SM Printf(proxy_class_code, "\n  }\n\n");

		  {
			  String *methods = getMethodDeclarations(n);
			  String *overrides = getAttrString(parentNode(n), "delphi:override");
			  SwigType *type = GetattrNew(n, "type");
			  String *pasname = capitalizeFirst(variable_name);
			  //String *pasname    = nameToDelphi(variable_name,true);
			  if (!SwigType_isconst(type)) {
				  {
					  String *inmode = getMappedTypeNew(n, "paswrapinmode", "", false);
					  String *intype = getMappedTypeNew(n, "paswrapintype", "");
					  Printf(methods, "set%s(%s val:%s);\n", pasname, (inmode != NIL) ? (const String *) inmode : "", intype);
				  }
				  {
					  /* this was attached by functionWrapper
					  invoked by Language::memberfunctionHandler */
					  String *fname = GetattrNew(n, "delphi:setname");
					  Printf(overrides, "set%s := %s;\n", pasname, fname);
				  }
			  }
			  {
				  {
					  String *outtype = getMappedTypeNew(n, "paswrapouttype", "");
					  Printf(methods, "get%s():%s;\n", pasname, outtype);
				  }
				  {
					  /* this was attached by functionWrapper
					  invoked by Language::memberfunctionHandler */
					  String *fname = GetattrNew(n, "delphi:getname");
					  Printf(overrides, "get%s := %s;\n", pasname, fname);
				  }
			  }
			  Delete(pasname);
		  }
		  //printf("end membervariableHandler(%s)\n", Char(GetattrNew(n,"name")));
#endif
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * staticmembervariableHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int staticmembervariableHandler(Node *n) {

		  bool static_const_member_flag = (Getattr(n, "value") == 0);

		  Setattr(n, "delphi:functype", "accessor");

		  if (static_const_member_flag) {
			  SwigType *t = GetattrNew(n, "type");
			  String *tm;

			  // Get the variable type
			  if ((tm = getMappedTypeNew(n, "paswraptype", ""))) {
				  substituteClassname(t, tm);
			  }
			  // Output the property's field declaration and accessor methods
			  //	Printf(proxy_class_code, "  public static %s %s {", tm, GetattrNew(n, "sym:name"));
		  }

		  variable_name =GetattrNew(n, "sym:name");

		  wrapping_member_flag = true;
		  static_flag = true;
		  Language::staticmembervariableHandler(n);
		  wrapping_member_flag = false;
		  static_flag = false;
		  /*
		  if (static_const_member_flag)
		  Printf(proxy_class_code, "\n  }\n\n");
		  */
		  return SWIG_OK;
	  }

	  /* ----------------------------------------------------------------------
	  * memberconstantHandler()
	  * ---------------------------------------------------------------------- */

	  virtual int memberconstantHandler(Node *n) {
		  variable_name =GetattrNew(n, "sym:name");
		  wrapping_member_flag = true;
		  Language::memberconstantHandler(n);
		  wrapping_member_flag = false;
		  return SWIG_OK;
	  }

	  /* -----------------------------------------------------------------------------
	  * getOverloadedName()
	  * ----------------------------------------------------------------------------- */

	  String *getOverloadedName(Node *n) {
		  String *overloaded_name = Copy(GetattrNew(n, "sym:name"));

		  if (Getattr(n, "sym:overloaded")) {
			  Printv(overloaded_name, GetattrNew(n, "sym:overname"), NIL);
		  }

		  return overloaded_name;
	  }

	  /* -----------------------------------------------------------------------------
	  * emitPASWrapper()
	  * It is also used for set and get methods of global variables.
	  * ----------------------------------------------------------------------------- */

	  void emitPASWrapper(Node *n, const String *func_name) {


		  SwigType *t = GetattrNew(n, "type");
		  ParmList *l = Getattr(n, "parms");
		  Hash *throws_hash = NewHash();
		  int num_exceptions = 0;
		  int num_returns = 0;
		  String *rawcall = NewString("");
		  String *reccall = NewString("");
		  String *local_variables = NewString("");
		  String *local_constants = NewString("");
		  String *incheck = NewString("");
		  String *outcheck = NewString("");
		  String *setup = NewString("");
		  String *cleanup = NewString("");
		  String *outarg = NewString("");	/* don't mix up with 'autark' :-] */
		  String *storeout = NewString("");
		  String *result_name = NewString("");
		  String *return_variables = NewString("");
		  const char *result_return = "ret";
		  String *function_code = NewString("");
		  /*several names for the same function */
		  String *raw_name = GetattrNew(n, "name");	/*original C function name */
		  //String     *func_name = GetattrNew(n,"sym:name");  /*final Delphi name chosen by the user*/
		  bool setter_flag = false;
		  int multiretval = GetFlag(n, "feature:delphi:multiretval");

		  if (l) {
			  if (SwigType_type(Getattr(l, "type")) == T_VOID) {
				  l = nextSibling(l);
			  }
		  }

		  /* Attach the non-standard typemaps to the parameter list */
		  Swig_typemap_attach_parms("paswrapargvar", l, NULL);
		  Swig_typemap_attach_parms("paswrapargconst", l, NULL);
		  Swig_typemap_attach_parms("paswrapargraw", l, NULL);
		  Swig_typemap_attach_parms("paswrapargdir", l, NULL);
		  Swig_typemap_attach_parms("paswrapinmode", l, NULL);
		  Swig_typemap_attach_parms("paswrapinname", l, NULL);
		  Swig_typemap_attach_parms("paswrapintype", l, NULL);
		  Swig_typemap_attach_parms("paswrapindefault", l, NULL);
		  Swig_typemap_attach_parms("paswrapinconv", l, NULL);
		  Swig_typemap_attach_parms("paswrapincheck", l, NULL);
		  Swig_typemap_attach_parms("paswrapoutname", l, NULL);
		  Swig_typemap_attach_parms("paswrapouttype", l, NULL);
		  Swig_typemap_attach_parms("paswrapoutconv", l, NULL);
		  Swig_typemap_attach_parms("paswrapoutcheck", l, NULL);

		  attachMappedType(n, "paswrapretraw");
		  attachMappedType(n, "paswrapretname");
		  attachMappedType(n, "paswraprettype");
		  attachMappedType(n, "paswrapretvar");
		  attachMappedType(n, "paswrapretconv");
		  attachMappedType(n, "paswrapretcheck");

		  Swig_typemap_attach_parms("paswrapfreearg", l, NULL);

		  /*
		  Swig_typemap_attach_parms("paswrapargvar:throws", l, NULL);
		  Swig_typemap_attach_parms("paswrapargraw:throws", l, NULL);
		  Swig_typemap_attach_parms("paswrapinconv:throws", l, NULL);
		  Swig_typemap_attach_parms("paswrapincheck:throws", l, NULL);
		  Swig_typemap_attach_parms("paswrapoutconv:throws", l, NULL);
		  Swig_typemap_attach_parms("paswrapoutcheck:throws", l, NULL);

		  attachMappedType(n, "paswrapretvar:throws");
		  attachMappedType(n, "paswrapretconv:throws");
		  attachMappedType(n, "paswrapretcheck:throws");

		  Swig_typemap_attach_parms("paswrapfreearg:throws", l, NULL);
		  */

		  /* Attach argument names to the parameter list */
		  /* should be a separate procedure making use of hashes */
		  attachParameterNames(n, "tmap:paswrapinname", "autoname", "arg%d");

		  /* Get return types */
		  String *result_pasrawtype = Copy(getMappedTypeNew(n, "pasrawrettype", ""));
		  String *result_paswraptype = Copy(getMappedTypeNew(n, "paswraprettype", ""));
		  bool has_return_raw = hasContent(result_pasrawtype);
		  bool has_return_pas = hasContent(result_paswraptype);
		  if (has_return_pas) {
			  num_returns++;
			  //printf("%s: %s\n", Char(func_name),Char(result_paswraptype));
		  }

		  String *arguments = createPASSignature(n);

		  /* Create local variables or RECORD fields for return values
		  and determine return type that might result from a converted VAR argument. */
		  {
			  writeArgState state;
			  if (multiretval && has_return_pas) {
				  writeArg(return_variables, state, NIL, NewString(result_return), result_paswraptype, NIL);
			  }

			  Parm *p = skipIgnored(l, "paswrapouttype");
			  while (p != NIL) {

				  String *arg = GetattrNew(p, "tmap:paswrapoutname");
				  if (arg == NIL) {
					  arg = GetattrNew(p, "name");
				  }

				  String *tm = GetattrNew(p, "tmap:paswrapouttype");
				  if (tm != NIL) {
					  if (isOutParam(p)) {
						  if (!multiretval) {
							  if (num_returns == 0) {
								  Printv(result_name, arg, NIL);
								  Clear(result_paswraptype);
								  Printv(result_paswraptype, tm, NIL);
							  } else {
								  Swig_warning(WARN_DELPHI_TYPEMAP_MULTIPLE_RETURN,
									  input_file, line_number,
									  "Typemap paswrapargdir set to 'out' for %s implies a RETURN value, but the routine %s has already one.\nUse %%multiretval feature.\n",
									  SwigType_str(GetattrNew(p, "type"), 0), raw_name);
							  }
						  }
						  num_returns++;
						  addImports(paswrap_intf.import, "paswrapouttype", p);
						  writeArg(return_variables, state, NIL, arg, tm, NIL);
					  }
					  p = skipIgnored(Getattr(p, "tmap:paswrapouttype:next"), "paswrapouttype");
				  } else {
					  p = nextSibling(p);
				  }
			  }
			  writeArg(return_variables, state, NIL, NIL, NIL, NIL);

			  if (multiretval) {
				  Printv(result_name, "result", NIL);
				  Printf(result_paswraptype, "%sResult", func_name);
				  paswrap_intf.enterBlock(blocktype);
				  Printf(paswrap_intf.f, "%s =\nRECORD\n%sEND;\n", result_paswraptype, return_variables);
				  Printf(local_variables, "%s: %s;\n", result_name, result_paswraptype);
			  } else {
				  Append(local_variables, return_variables);
			  }
		  }

		  /* Declare local constants e.g. for storing argument names. */
		  {
			  Parm *p = l;
			  while (p != NIL) {

				  String *arg = GetattrNew(p, "autoname");

				  String *tm = GetattrNew(p, "tmap:paswrapargconst");
				  if (tm != NIL) {
					  addImports(paswrap_impl.import, "paswrapargconst", p);
					  Replaceall(tm, "$input", arg);
					  Printv(local_constants, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapargconst:next");
				  } else {
					  p = nextSibling(p);
				  }

			  }
		  }

		  /* Declare local variables e.g. for converted input values. */
		  {
			  String *tm = getMappedTypeNew(n, "paswrapretvar", "", false);
			  if (tm != NIL) {
				  addImports(paswrap_impl.import, "paswrapretvar", n);
				  addThrows(throws_hash, "paswrapretvar", n);
				  Printv(local_variables, tm, "\n", NIL);
			  }

			  Parm *p = l;
			  while (p != NIL) {

				  String *arg = GetattrNew(p, "autoname");

				  tm = GetattrNew(p, "tmap:paswrapargvar");
				  if (tm != NIL) {
					  /* exceptions that may be raised but can't be catched,
					  thus we won't count them in num_exceptions */
					  addImports(paswrap_impl.import, "paswrapargvar", p);
					  addThrows(throws_hash, "paswrapargvar", p);
					  Replaceall(tm, "$input", arg);
					  Printv(local_variables, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapargvar:next");
				  } else {
					  p = nextSibling(p);
				  }

			  }
		  }

		  /* Convert input values from Pascal to C. */
		  {
			  Parm *p = l;
			  while (p != NIL) {

				  String *arg = GetattrNew(p, "autoname");

				  String *tm = GetattrNew(p, "tmap:paswrapinconv");
				  if (tm != NIL) {
					  addImports(paswrap_impl.import, "paswrapinconv", p);
					  num_exceptions += addThrows(throws_hash, "paswrapinconv", p);
					  Replaceall(tm, "$input", arg);
					  Printv(setup, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapinconv:next");
				  } else {
					  p = nextSibling(p);
				  }

			  }
		  }

		  /* Generate checks for input value integrity. */
		  {
			  Parm *p = l;
			  while (p != NIL) {

				  String *arg = GetattrNew(p, "autoname");

				  String *tm = GetattrNew(p, "tmap:paswrapincheck");
				  if (tm != NIL) {
					  addImports(paswrap_impl.import, "paswrapincheck", p);
					  num_exceptions += addThrows(throws_hash, "paswrapincheck", p);
					  Replaceall(tm, "$input", arg);
					  Printv(incheck, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapincheck:next");
				  } else {
					  p = nextSibling(p);
				  }

			  }
		  }

		  Printv(rawcall, pasraw_name, ".", func_name, "(", NIL);
		  /* Arguments to the raw C function */
		  {
			  bool gencomma = false;
			  Parm *p = l;
			  while (p != NIL) {
				  if (gencomma) {
					  Printf(rawcall, ", ");
				  }
				  gencomma = true;
				  addImports(paswrap_impl.import, "paswrapargraw", p);
				  num_exceptions += addThrows(throws_hash, "paswrapargraw", p);

				  String *arg = GetattrNew(p, "autoname");
				  String *qualarg = NewString("");
				  if (!isInParam(p)) {
					  String *tmparg = GetattrNew(p, "tmap:paswrapoutname");
					  if (tmparg != NIL) {
						  arg = tmparg;
					  }
					  if (multiretval /*&& isOutParam(p) - automatically fulfilled */ ) {
						  Printf(qualarg, "%s.", result_name);
					  }
				  }
				  Append(qualarg, arg);
				  Setattr(p, "pasoutarg", qualarg);

				  String *tm = GetattrNew(p, "tmap:paswrapargraw");
				  if (tm != NIL) {
					  Replaceall(tm, "$input", arg);
					  Replaceall(tm, "$output", qualarg);
					  Printv(rawcall, tm, NIL);
					  p = Getattr(p, "tmap:paswrapargraw:next");
				  } else {
					  //Printv(rawcall, GetattrNew(p,"lname"), NIL);
					  Printv(rawcall, qualarg, NIL);
					  p = nextSibling(p);
				  }
				  Delete(qualarg);
			  }
		  }
		  Printf(rawcall, ")");

		  /* Check for error codes and integrity of results */
		  {
			  String *tm = getMappedTypeNew(n, "paswrapretcheck", "", false);
			  if (tm != NIL) {
				  addImports(paswrap_impl.import, "paswrapretcheck", n);
				  num_exceptions += addThrows(throws_hash, "paswrapretcheck", n);
				  Printv(outcheck, tm, "\n", NIL);
			  }

			  Parm *p = l;
			  while (p != NIL) {
				  tm = GetattrNew(p, "tmap:paswrapoutcheck");
				  if (tm != NIL) {
					  String *arg = GetattrNew(p, "autoname");
					  String *outarg = GetattrNew(p, "pasoutarg");
					  addImports(paswrap_impl.import, "paswrapoutcheck", p);
					  num_exceptions += addThrows(throws_hash, "paswrapoutcheck", p);
					  //substituteClassname(GetattrNew(p,"type"), tm);
					  Replaceall(tm, "$input", arg);
					  Replaceall(tm, "$output", outarg);
					  Printv(outcheck, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapoutcheck:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Convert the results to Pascal data structures and
		  put them in the record prepared for returning */
		  {
			  /* paswrapretconv is processed
			  when it is clear if there is some output conversion and checking code */
			  Parm *p = l;
			  while (p != NIL) {
				  String *tm = GetattrNew(p, "tmap:paswrapoutconv");
				  if (tm != NIL) {
					  String *arg = GetattrNew(p, "autoname");
					  String *outarg = GetattrNew(p, "pasoutarg");
					  addImports(paswrap_impl.import, "paswrapoutconv", n);
					  num_exceptions += addThrows(throws_hash, "paswrapoutconv", p);
					  //substituteClassname(GetattrNew(p,"type"), tm);
					  Replaceall(tm, "$input", arg);
					  Replaceall(tm, "$output", outarg);
					  Printf(storeout, "%s := %s;\n", outarg, tm);
					  p = Getattr(p, "tmap:paswrapoutconv:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  /* Generate cleanup code */
		  {
			  Parm *p = l;
			  while (p != NIL) {
				  String *tm = GetattrNew(p, "tmap:paswrapfreearg");
				  if (tm != NIL) {
					  String *arg = GetattrNew(p, "autoname");
					  String *outarg = GetattrNew(p, "pasoutarg");
					  addImports(paswrap_impl.import, "paswrapfreearg", p);
					  num_exceptions += addThrows(throws_hash, "paswrapfreearg", p);
					  //substituteClassname(GetattrNew(p,"type"), tm);
					  Replaceall(tm, "$input", arg);
					  Replaceall(tm, "$output", outarg);
					  Printv(cleanup, tm, "\n", NIL);
					  p = Getattr(p, "tmap:paswrapfreearg:next");
				  } else {
					  p = nextSibling(p);
				  }
			  }
		  }

		  {
			  /* Currently I don't know how a typemap similar to the original 'out' typemap
			  could help returning the return value. */
			  /* Receive result from call to raw library function */
			  if (!has_return_raw) {
				  /*
				  rawcall(arg1);
				  result.val := arg1;
				  RETURN result;
				  */
				  /*
				  rawcall(arg1);
				  RETURN arg1;
				  */
				  Printf(reccall, "%s;\n", rawcall);

				  if (hasContent(result_name)) {
					  Printf(outarg, "RETURN %s;\n", result_name);
				  }
			  } else {
				  /*
				  arg0 := rawcall(arg1);
				  result.ret := Convert(arg0);
				  result.val := arg1;
				  RETURN result;
				  */
				  /*
				  arg0 := rawcall();
				  RETURN Convert(arg0);
				  */
				  /*
				  RETURN rawcall();
				  */
				  String *return_raw = getMappedTypeNew(n, "paswrapretraw", "", false);
				  String *return_conv = getMappedTypeNew(n, "paswrapretconv", "", false);

				  /* immediate RETURN would skip result checking */
				  if ((hasContent(outcheck) || hasContent(storeout)
					  || hasContent(cleanup)) && (!hasContent(result_name))
					  && (return_raw == NIL)) {
						  Printv(result_name, "result", NIL);
						  Printf(local_variables, "%s: %s;\n", result_name, result_paswraptype);
				  }

				  String *result_lvalue = Copy(result_name);
				  if (multiretval) {
					  Printf(result_lvalue, ".%s", result_return);
				  }
				  if (return_raw != NIL) {
					  Printf(reccall, "%s := %s;\n", return_raw, rawcall);
				  } else if (hasContent(result_name)) {
					  Printf(reccall, "%s := %s;\n", result_lvalue, rawcall);
				  } else {
					  Printf(outarg, "RETURN %s;\n", rawcall);
				  }
				  if (return_conv != NIL) {
					  addImports(paswrap_impl.import, "paswrapretconv", n);
					  num_exceptions += addThrows(throws_hash, "paswrapretconv", n);
					  if (hasContent(result_name)) {
						  Printf(reccall, "%s := %s;\n", result_lvalue, return_conv);
						  Printf(outarg, "RETURN %s;\n", result_name);
					  } else {
						  Printf(outarg, "RETURN %s;\n", return_conv);
					  }
				  } else {
					  if (hasContent(result_name)) {
						  Printf(outarg, "RETURN %s;\n", result_name);
					  }
				  }
			  }
		  }

		  /* Create procedure header */
		  {
			  String *header = NewStringf("PROCEDURE %s (%s)",
				  func_name, arguments);

			  if ((num_returns > 0) || multiretval) {
				  Printf(header, ": %s", result_paswraptype);
			  }
			  generateThrowsClause(throws_hash, header);

			  Append(function_code, header);

			  paswrap_intf.enterBlock(no_block);
			  Printf(paswrap_intf.f, "%s;\n\n", header, NIL);
		  }

		  {
			  String *body = NewStringf("%s%s%s%s%s",
				  incheck,
				  setup,
				  reccall,
				  outcheck,
				  storeout);

			  String *exc_handler;
			  if (hasContent(cleanup) && (num_exceptions > 0)) {
				  exc_handler = NewStringf("TRY\n%sFINALLY\n%sEND;\n", body, cleanup);
			  } else {
				  exc_handler = NewStringf("%s%s", body, cleanup);
			  }

			  Printf(function_code, " =\n%s%s%s%sBEGIN\n%s%sEND %s;\n\n",
				  hasContent(local_constants) ? "CONST\n" : "", local_constants,
				  hasContent(local_variables) ? "VAR\n" : "", local_variables, exc_handler, outarg, func_name);

			  Delete(exc_handler);
			  Delete(body);
		  }

		  paswrap_impl.enterBlock(no_block);
		  if (proxy_flag && global_variable_flag) {
			  setter_flag = (Cmp(GetattrNew(n, "sym:name"), Swig_name_set(NSPACE_TODO, variable_name)) == 0);
			  // Properties
			  if (setter_flag) {
				  // Setter method
				  String *tm = getMappedTypeNew(n, "pasvarin", "");
				  if (tm != NIL) {
					  if (GetFlag(n, "feature:new")) {
						  Replaceall(tm, "$owner", "true");
					  } else {
						  Replaceall(tm, "$owner", "false");
					  }
					  substituteClassname(t, tm);
					  Replaceall(tm, "$rawcall", rawcall);
					  Replaceall(tm, "$vartype", variable_type);	/* $type is already replaced by some super class */
					  Replaceall(tm, "$var", variable_name);
					  Printf(paswrap_impl.f, "%s", tm);
				  }
			  } else {
				  // Getter method
				  String *tm = getMappedTypeNew(n, "pasvarout", "");
				  if (tm != NIL) {
					  if (GetFlag(n, "feature:new"))
						  Replaceall(tm, "$owner", "true");
					  else
						  Replaceall(tm, "$owner", "false");
					  substituteClassname(t, tm);
					  Replaceall(tm, "$rawcall", rawcall);
					  Replaceall(tm, "$vartype", variable_type);
					  Replaceall(tm, "$var", variable_name);
					  Printf(paswrap_impl.f, "%s", tm);
				  }
			  }
		  } else {
			  // Normal function call
			  Printv(paswrap_impl.f, function_code, NIL);
		  }

		  Delete(arguments);
		  Delete(return_variables);
		  Delete(local_variables);
		  Delete(local_constants);
		  Delete(outarg);
		  Delete(incheck);
		  Delete(outcheck);
		  Delete(setup);
		  Delete(cleanup);
		  Delete(storeout);
		  Delete(function_code);
		  Delete(result_name);
		  Delete(result_paswraptype);
		  Delete(reccall);
		  Delete(rawcall);
		  Delete(throws_hash);
	  }

	  /* -----------------------------------------------------------------------------
	  * substituteClassname()
	  *
	  * Substitute $pasclassname with the proxy class name for classes/structs/unions that SWIG knows about.
	  * Otherwise use the $descriptor name for the Pascal class name. Note that the $&pasclassname substitution
	  * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
	  * Inputs:
	  *   pt - parameter type
	  *   tm - paswraptype typemap
	  * Outputs:
	  *   tm - paswraptype typemap with $pasclassname substitution
	  * Return:
	  *   substitution_performed - flag indicating if a substitution was performed
	  * ----------------------------------------------------------------------------- */

	  bool substituteClassname(SwigType *pt, String *tm) {
		  bool substitution_performed = false;

		  //char * xx;

		  //xx = Char(tm);

		  if (Strstr(tm, "$pasclassname") || Strstr(tm, "$&pasclassname")) {
			  String *classname = getProxyName(pt);
			  if (classname) {
				  Replaceall(tm, "$&pasclassname", classname);	// getProxyName() works for pointers to classes too
				  Replaceall(tm, "$pasclassname", classname);
			  } else {			// use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
				  String *descriptor = NULL;
				  SwigType *type = Copy(SwigType_typedef_resolve_all(pt));

				  if (Strstr(tm, "$&pasclassname")) {
					  SwigType_add_pointer(type);
					  descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
					  Replaceall(tm, "$&pasclassname", descriptor);
				  } else {		// $pasclassname
					  descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(type));
					  Replaceall(tm, "$pasclassname", descriptor);
				  }

				  // Add to hash table so that the type wrapper classes can be created later
				  Setattr(swig_types_hash, descriptor, type);
				  Delete(descriptor);
				  Delete(type);
			  }
			  substitution_performed = true;
		  }
		  return substitution_performed;
	  }


	  /* -----------------------------------------------------------------------------
	  * attachParameterNames()
	  *
	  * Inputs: 
	  *   n      - Node of a function declaration
	  *   tmid   - attribute name for overriding C argument names,
	  *              e.g. "tmap:paswrapinname",
	  *              don't forget to attach the mapped types before
	  *   nameid - attribute for attaching the names,
	  *              e.g. "delphi:inname"
	  *   fmt    - format for the argument name containing %d
	  *              e.g. "arg%d"
	  * ----------------------------------------------------------------------------- */

	  void attachParameterNames(Node *n, const char *tmid, const char *nameid, const char *fmt) {
		  /* Use C parameter name if present and unique,
		  otherwise create an 'arg%d' name */
		  Hash *hash = NewHash();
		  Parm *p = Getattr(n, "parms");
		  int count = 0;
		  while (p != NIL) {
			  String *name = GetattrNew(p, tmid);
			  if (name == NIL) {
				  name = GetattrNew(p, "name");
			  }
			  String *newname;
			  if ((!hasContent(name)) || (Getattr(hash, name) != NIL) || Cmp("c:wrapname", nameid) == 0) {
				  newname = NewStringf(fmt, count);
			  } else {
				  newname = Copy(name);
			  }

			  Replace(newname,"::","_", DOH_REPLACE_ANY);	

			  String * _name = NewStringf(Swig_string_lower(newname) );

			  if (_name && Getattr(reserved_keyword, _name) != 0) {
				  String *tmp = newname;
				  newname = NewStringf("_%s", tmp);
				  Delete(tmp);
			  }

			  Delete(_name);

			  if (1 == Setattr(hash, newname, "1")) {
				  Swig_warning(WARN_DELPHI_DOUBLE_ID, input_file, line_number, "Argument '%s' twice.\n", newname);
			  }
			  Setattr(p, nameid, newname);
			  //      Delete(newname);
			  p = nextSibling(p);
			  count++;
		  }
		  Delete(hash);
	  }

	  /* -----------------------------------------------------------------------------
	  * createPASSignature()
	  *
	  * Create signature of PAS wrapper procedure
	  * Call attachParameterNames and attach mapped types before!
	  *   paswrapintype, paswrapinmode, paswrapindefault
	  * ----------------------------------------------------------------------------- */

	  String *createPASSignature(Node *n) {
		  String *arguments = NewString("");
		  Parm *p = skipIgnored(Getattr(n, "parms"), "paswrapintype");
		  writeArgState state;
		  while (p != NIL) {

			  /* Get the PAS parameter type */
			  String *tm = getMappedType(p, "paswrapintype");
			  if (tm != NIL) {
				  if (isInParam(p)) {
					  addImports(paswrap_intf.import, "paswrapintype", p);
					  addImports(paswrap_impl.import, "paswrapintype", p);
					  String *mode = GetattrNew(p, "tmap:paswrapinmode");
					  String *deflt = GetattrNew(p, "tmap:paswrapindefault");
					  String *arg = GetattrNew(p, "autoname");
					  SwigType *pt = GetattrNew(p, "type");
					  substituteClassname(pt, tm);	/* do we need this ? */

					  writeArg(arguments, state, mode, arg, tm, deflt);
				  }
				  p = skipIgnored(Getattr(p, "tmap:paswrapintype:next"), "paswrapintype");
			  } else {
				  p = nextSibling(p);
			  }
		  }
		  writeArg(arguments, state, NIL, NIL, NIL, NIL);
		  return (arguments);
	  }

	  /* not used any longer
	  - try SwigType_str if required again */
#if 0
	  /* -----------------------------------------------------------------------------
	  * createCSignature()
	  *
	  * Create signature of C function
	  * ----------------------------------------------------------------------------- */

	  String *createCSignature(Node *n) {
		  String *arguments = NewString("");
		  bool gencomma = false;
		  Node *p;
		  for (p = Getattr(n, "parms"); p != NIL; p = nextSibling(p)) {
			  if (gencomma) {
				  Append(arguments, ",");
			  }
			  gencomma = true;
			  String *type = GetattrNew(p, "type");
			  String *ctype = getMappedTypeNew(type, "ctype");
			  Append(arguments, ctype);
		  }
		  return arguments;
	  }
#endif

	  /* -----------------------------------------------------------------------------
	  * emitTypeWrapperClass()
	  * ----------------------------------------------------------------------------- */

	  void emitTypeWrapperClass(String *classname, SwigType *type) {
		  String *filen = NewStringf("%s%s.pas", SWIG_output_directory(), classname);
		  File *f_swigtype = NewFile(filen, "w", SWIG_output_files());
		  if (!f_swigtype) {
			  FileErrorDisplay(filen);
			  SWIG_exit(EXIT_FAILURE);
		  }
		  String *swigtype = NewString("");

		  // Emit banner name
		  emitBanner(f_swigtype);

		  // Pure Pascal baseclass and interfaces
		  const String *pure_baseclass = typemapLookup("pasbase", type, WARN_NONE);
		  const String *pure_interfaces = typemapLookup("pasinterfaces", type, WARN_NONE);

		  // Emit the class
		  Printv(swigtype, typemapLookup("pasimports", type, WARN_NONE),	// Import statements
			  "\n", typemapLookup("pasclassmodifiers", type, WARN_DELPHI_TYPEMAP_CLASSMOD_UNDEF),	// Class modifiers
			  " class $pasclassname",	// Class name and bases
			  *Char(pure_baseclass) ? " : " : "", pure_baseclass, *Char(pure_interfaces) ?	// Interfaces
			  " : " : "", pure_interfaces, " {\n", "  private IntPtr swigCPtr;\n", "\n", "  ", typemapLookup("pasptrconstructormodifiers", type, WARN_DELPHI_TYPEMAP_PTRCONSTMOD_UNDEF),	// pointer constructor modifiers
			  " $pasclassname(IntPtr cPtr, bool bFutureUse) {\n",	// Constructor used for wrapping pointers
			  "    swigCPtr = cPtr;\n", "  }\n", "\n", "  protected $pasclassname() {\n",	// Default constructor
			  "    swigCPtr = IntPtr.Zero;\n", "  }\n", typemapLookup("pasgetcptr", type, WARN_DELPHI_TYPEMAP_GETCPTR_UNDEF),	// getCPtr method
			  typemapLookup("pascode", type, WARN_NONE),	// extra Pascal code
			  "}\n", "\n", NIL);

		  Replaceall(swigtype, "$pasclassname", classname);
		  Printv(f_swigtype, swigtype, NIL);

//		  Close(f_swigtype);
		  Delete(filen);
		  Delete(swigtype);
	  }

	  /* -----------------------------------------------------------------------------
	  * typemapLookup()
	  * ----------------------------------------------------------------------------- */

	  const String *typemapLookup(const String *op, String *type, int warning, Node *typemap_attributes = NULL) {
	    /*
		  String *tm = NULL;
		  const String *code = NULL;

		  //if ((tm = Swig_typemap_search(op, type, NULL, NULL))) {
		    if ((tm = Swig_typemap_lookup(op, type, NULL, NULL))) {
			  code = GetattrNew(tm, "code");
			  if (typemap_attributes)
				  Swig_typemap_attach_kwargs(tm, op, typemap_attributes);
		  }

		  if (!code) {
			  code = empty_string;
			  if (warning != WARN_NONE)
				  Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
		  }

		  return code ? code : empty_string;
	    */
	    Node *node = !typemap_attributes ? NewHash() : typemap_attributes;
	    Setattr(node, "type", type);
	    Setfile(node, input_file);
	    Setline(node, line_number);
	    const String *tm = Swig_typemap_lookup(op, node, "", 0);
	    if (!tm) {
	      tm = empty_string;
	      if (warning != WARN_NONE)
		      Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
	    }
	    
	    if (!typemap_attributes) Delete(node);
	    
	    return tm;
	  }

	  /* -----------------------------------------------------------------------------
	  * addThrows()
	  *
	  * Add all exceptions to a hash that are associated with the 'typemap'.
	  * Return number the number of these exceptions.
	  * ----------------------------------------------------------------------------- */

	  int addThrows(Hash *throws_hash, const String *typemap, Node *parameter) {
		  // Get the comma separated throws clause - held in "throws" attribute in the typemap passed in
		  int len = 0;
		  String *throws_attribute = NewStringf("%s:throws", typemap);

		  addImports(paswrap_intf.import, throws_attribute, parameter);
		  addImports(paswrap_impl.import, throws_attribute, parameter);

		  String *throws = getMappedTypeNew(parameter, Char(throws_attribute), "", false);
		  //printf("got exceptions %s for %s\n", Char(throws), Char(throws_attribute));

		  if (throws) {
			  // Put the exception classes in the throws clause into a temporary List
			  List *temp_classes_list = Split(throws, ',', INT_MAX);
			  len = Len(temp_classes_list);

			  // Add the exception classes to the node throws list, but don't duplicate if already in list
			  if (temp_classes_list /*&& hasContent(temp_classes_list) */ ) {
				  for (Iterator cls = First(temp_classes_list); cls.item != NIL; cls = Next(cls)) {
					  String *exception_class = NewString(cls.item);
					  Replaceall(exception_class, " ", "");	// remove spaces
					  Replaceall(exception_class, "\t", "");	// remove tabs
					  if (hasContent(exception_class)) {
						  // $pasclassname substitution
						  SwigType *pt = GetattrNew(parameter, "type");
						  substituteClassname(pt, exception_class);
						  // Don't duplicate the exception class in the throws clause
						  //printf("add exception %s\n", Char(exception_class));
						  Setattr(throws_hash, exception_class, "1");
					  }
					  Delete(exception_class);
				  }
			  }
			  Delete(temp_classes_list);
		  }
		  Delete(throws_attribute);
		  return len;
	  }

	  /* -----------------------------------------------------------------------------
	  * generateThrowsClause()
	  * ----------------------------------------------------------------------------- */

	  void generateThrowsClause(Hash *throws_hash, String *code) {
		  // Add the throws clause into code
		  if (Len(throws_hash) > 0) {
			  Iterator cls = First(throws_hash);
			  Printf(code, " RAISES {%s", cls.key);
			  for (cls = Next(cls); cls.key != NIL; cls = Next(cls)) {
				  Printf(code, ", %s", cls.key);
			  }
			  Printf(code, "}");
		  }
	  }

	  /* -----------------------------------------------------------------------------
	  * addImports()
	  *
	  * Add all imports that are needed for contents of 'typemap'.
	  * ----------------------------------------------------------------------------- */

	  void addImports(Hash *imports_hash, const String *typemap, Node *node) {
		  // Get the comma separated throws clause - held in "throws" attribute in the typemap passed in
		  String *imports_attribute = NewStringf("%s:import", typemap);
		  String *imports = getMappedTypeNew(node, Char(imports_attribute), "", false);
		  //printf("got imports %s for %s\n", Char(imports), Char(imports_attribute));

		  if (imports != NIL) {
			  List *import_list = Split(imports, ',', INT_MAX);

			  // Add the exception classes to the node imports list, but don't duplicate if already in list
			  if (import_list != NIL) {
				  for (Iterator imp = First(import_list); imp.item != NIL; imp = Next(imp)) {
					  List *import_pair = Split(imp.item, ' ', 3);
					  if (Len(import_pair) == 1) {
						  Setattr(imports_hash, Getitem(import_pair, 0), "");
					  } else if ((Len(import_pair) == 3)
						  && Strcmp(Getitem(import_pair, 1), "AS") == 0) {
							  Setattr(imports_hash, Getitem(import_pair, 0), Getitem(import_pair, 2));
					  } else {
						  Swig_warning(WARN_DELPHI_BAD_IMPORT, input_file, line_number,
							  "Malformed import '%s' for typemap '%s' defined for type '%s'\n", imp, typemap, SwigType_str(GetattrNew(node, "type"), 0));
					  }
					  Delete(import_pair);
				  }
			  }
			  Delete(import_list);
		  }
		  Delete(imports_attribute);
	  }

	  /* -----------------------------------------------------------------------------
	  * emitImportStatements()
	  * ----------------------------------------------------------------------------- */

	  void emitImportStatements(Hash *imports_hash, String *code) {
		  // Add the imports statements into code
		  Iterator imp = First(imports_hash);

		  bool first = true;
		  int c = 0;

		  if (intf_uses != 0) {

			  Printf(code, "uses \n");
			  Printv(code, intf_uses, NIL);
			  Printv(code, interface_uses, NIL);
			  first = false;
			  c++;
		  }

		  while (imp.key != NIL) {

			  if (first) {
				  Printf(code, "uses \n");
				  Printv(code, interface_uses, NIL);
				  Printf(code, "     %s", imp.key);
				  first = false;
			  }	
			  else {
				  Printf(code, ",\n");
				  Printf(code, "     %s", imp.key);
			  }
			  c++;

			  //String *imp_as = imp.item;
			  /* if (hasContent(imp_as)) {
			  Printf(code, " AS %s", imp_as);
			  }*/
			  imp = Next(imp);
		  }

		  if (c)
			  Printf(code, ";\n");

	  }
	  /*----------------------------------------------------------------------
	  * Java_director_declaration()
	  *
	  * Generate the director class's declaration
	  * e.g. "class SwigDirector_myclass : public myclass, public Swig::Director {"
	  *--------------------------------------------------------------------*/

	  void Pas_director_declaration(Node *n) {

		  String *base = GetattrNew(n, "classtype");
		  String *class_ctor = NewString("Swig::Director()");

		  String *classname = Swig_class_name(n);
		  String *directorname = NewStringf("SwigDirector_%s", classname);
		  String *declaration = Swig_class_declaration(n, directorname);

		  Printf(declaration, " : public %s, public Swig::Director", base);

		  // Stash stuff for later.
		  Setattr(n, "director:decl", declaration);
		  Setattr(n, "director:ctor", class_ctor);
	  }
	  /* C++ director class generation */
	  virtual int classDirector(Node *n)
	  {
		  return Language::classDirector(n);
	  }

	  virtual int classDirectorInit(Node *n)
	  {
		  Delete(none_comparison);
		  none_comparison = NewString("");	// not used

		  Delete(director_ctor_code);
		  director_ctor_code = NewString("$director_new");

		  Pas_director_declaration(n);

		  Printf(f_directors_h, "%s {\n", GetattrNew(n, "director:decl"));
		  Printf(f_directors_h, "\npublic:\n");

		  /* Keep track of the director methods for this class */

		  first_class_dmethod = curr_class_dmethod = n_dmethods;

		  director_callback_typedefs = NewString("");
		  director_callbacks = NewString("");
		  director_delegate_callback = NewString("");
		  director_delegate_definitions = NewString("");
		  director_delegate_instances = NewString("");
		  director_method_types = NewString("");
		  director_connect_parms = NewString("");

		  return Language::classDirectorInit(n);

		  return Language::classDirectorInit(n);
	  }

	  /* -----------------------------------------------------------------------------
	  * directorClassName()
	  * ----------------------------------------------------------------------------- */

	  String *directorClassName(Node *n) {
		  String *dirclassname;
		  const char *attrib = "director:classname";

		  if (!(dirclassname = GetattrNew(n, attrib))) {
			  String *classname =GetattrNew(n, "sym:name");

			  dirclassname = NewStringf("SwigDirector_%s", classname);
			  Setattr(n, attrib, dirclassname);
		  }

		  return dirclassname;
	  }

	  virtual int classDirectorEnd(Node *n)
	  {

		  int i;
		  String *director_classname = directorClassName(n);

		  Wrapper *w = NewWrapper();

		  if (Len(director_callback_typedefs) > 0) {
			  Printf(f_directors_h, "\n%s", director_callback_typedefs);
		  }

		  Printf(f_directors_h, "    void swig_connect_director(");

		  Printf(w->def, "void %s::swig_connect_director(", director_classname);

		  for (i = first_class_dmethod; i < curr_class_dmethod; ++i) {
			  UpcallData *udata = Getitem(dmethods_seq, i);
			  String *methid = GetattrNew(udata, "class_methodidx");
			  String *overname = GetattrNew(udata, "overname");

			  Printf(f_directors_h, "SWIG_Callback%s_t callback%s", methid, overname);
			  Printf(w->def, "SWIG_Callback%s_t callback%s", methid, overname);
			  Printf(w->code, "swig_callback%s = callback%s;\n", overname, overname);
			  if (i != curr_class_dmethod - 1) {
				  Printf(f_directors_h, ", ");
				  Printf(w->def, ", ");
			  }
		  }

		  Printf(f_directors_h, ");\n");
		  Printf(w->def, ") {");


		  if (Len(director_callback_typedefs) > 0) {
			  Printf(f_directors_h, "\nprivate:\n%s", director_callbacks);
		  }
		  Printf(f_directors_h, "    void swig_init_callbacks();\n");
		  Printf(f_directors_h, "};\n\n");
		  Printf(w->code, "}\n\n");

		  Printf(w->code, "void %s::swig_init_callbacks() {\n", director_classname);
		  for (i = first_class_dmethod; i < curr_class_dmethod; ++i) {
			  UpcallData *udata = Getitem(dmethods_seq, i);
			  String *overname = GetattrNew(udata, "overname");
			  Printf(w->code, "swig_callback%s = 0;\n", overname);
		  }
		  Printf(w->code, "}");

		  Wrapper_print(w, f_directors);

		  DelWrapper(w);


		  return Language::classDirectorEnd(n);
	  }

	  virtual int unrollVirtualMethods(Node *n, Node *parent, List *vm, int default_director, int &virtual_destructor, int protectedbase = 0)
	  {
		  return Language::unrollVirtualMethods(n,parent, vm,  default_director, virtual_destructor, protectedbase);
	  }
	  virtual int classDirectorConstructor(Node *n)
	  {
		  return Language::classDirectorConstructor(n);
	  }

	  virtual int classDirectorDefaultConstructor(Node *n)
	  {
		  return Language::classDirectorDefaultConstructor(n);
	  }

	  virtual int classDirectorMethod(Node *n, Node *parent, String *super)

	  {
		  return Language::classDirectorMethod(n, parent, super);
	  }

	  virtual int classDirectorConstructors(Node *n)

	  {
		  return Language::classDirectorConstructors(n);
	  }

	  virtual int classDirectorDestructor(Node * /*n*/)
	  {
		  //return Language::classDirectorDestructor(n);
		  return SWIG_OK;
	  }
	  virtual int classDirectorMethods(Node *n)
	  {
		  return Language::classDirectorMethods(n);
	  }
	  virtual int classDirectorDisown(Node * /*n*/)
	  {
		  //  return Language::classDirectorDisown(n);
		  return SWIG_OK;
	  }
};				/* class DELPHI */

/* -----------------------------------------------------------------------------
* swig_delphi()    - Instantiate module
* ----------------------------------------------------------------------------- */
#if 1
extern "C" Language *swig_delphi(void) {
	return new DELPHI();
}

/* -----------------------------------------------------------------------------
* Static member variables
* ----------------------------------------------------------------------------- */

const char *DELPHI::usage =  "\
									 Delphi Options (available with -delphi)\n\
									 -generateconst <file>   - generate code for computing numeric values of constants\n\
									 -generaterename <file>  - generate suggestions for %rename\n\
									 -generatetypemap <file> - generate templates for some basic typemaps\n\
									 -oldvarnames    - old intermediary method names for variable wrappers\n\
									 \n";

/*
-generateconst <file> - stem of the .c source file for computing the numeric values of constants\n\
-generaterename <file> - stem of the .i source file containing %rename suggestions\n\
-generatetypemap <file> - stem of the .i source file containing typemap patterns\n\
*/

#endif 

