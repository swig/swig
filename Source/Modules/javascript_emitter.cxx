#include "javascript_emitter.h"

#include "swigmod.h"

/* -----------------------------------------------------------------------------
 * JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::JSEmitter()
    : empty_string(NewString(""))
{
    templates = NewHash();
}

/* -----------------------------------------------------------------------------
 * ~JSEmitter()
 * ----------------------------------------------------------------------------- */

JSEmitter::~JSEmitter()
{
    Delete(empty_string);
    Delete(templates);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::RegisterTemplate() :  Registers a code template
 * ----------------------------------------------------------------------------- */

int JSEmitter::RegisterTemplate(const String *name, const String *code) 
{
    return Setattr(templates, name, code);
}

/* -----------------------------------------------------------------------------
 * JSEmitter::GetTemplate() :  Retrieves a registered a code template
 * ----------------------------------------------------------------------------- */

const String* JSEmitter::GetTemplate(const String *name)
{
    String* templ = Getattr(templates, name);
    
    if(!templ) {
        Printf(stderr, "Could not find template %s\n.", name);
        SWIG_exit(EXIT_FAILURE);
    }
    
    return templ;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::typemapLookup()
 * n - for input only and must contain info for Getfile(n) and Getline(n) to work
 * tmap_method - typemap method name
 * type - typemap type to lookup
 * warning - warning number to issue if no typemaps found
 * typemap_attributes - the typemap attributes are attached to this node and will 
 *   also be used for temporary storage if non null
 * return is never NULL, unlike Swig_typemap_lookup()
 * ----------------------------------------------------------------------------- */

const String *JSEmitter::typemapLookup(Node *n, const_String_or_char_ptr tmap_method, 
                                    SwigType *type, int warning, Node *typemap_attributes) {
    Node *node = !typemap_attributes ? NewHash() : typemap_attributes;
    Setattr(node, "type", type);
    Setfile(node, Getfile(n));
    Setline(node, Getline(n));
    const String *tm = Swig_typemap_lookup(tmap_method, node, "", 0);
    if (!tm) {
        tm = empty_string;
        if (warning != WARN_NONE) {
            Swig_warning(warning, Getfile(n), Getline(n), 
                         "No %s typemap defined for %s\n", tmap_method, SwigType_str(type, 0));
        }
    }
    if (!typemap_attributes) {
        Delete(node);
    }
    return tm;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::GetBaseClass() :  the node of the base class or NULL
 * ----------------------------------------------------------------------------- */

Node* JSEmitter::GetBaseClass(Node* n)
{
    // retrieve the first base class that is not %ignored
    List *baselist = Getattr(n, "bases");
    if (baselist) {
        Iterator base = First(baselist);
        while (base.item && GetFlag(base.item, "feature:ignore")) {
          base = Next(base);
        }
        
        return base.item;
    }

    return NULL;
}

/* -----------------------------------------------------------------------------
 * JSEmitter::EmitWrapperFunction() :  dispatches emitter functions
 * ----------------------------------------------------------------------------- */

int JSEmitter::EmitWrapperFunction(Node* n)
{
    int ret = SWIG_OK;

    current_wrapper = NewWrapper();
    Setattr(n, "wrap:name", Getattr(n, "sym:name"));
    
    String* kind = Getattr(n, "kind");
    
    if(kind) {
        bool is_member = GetFlag(n, "ismember");
        if( Cmp(kind, "function") == 0 ) {
            ret = EmitFunction(n, is_member);
        } else if (Cmp(kind, "variable") == 0) {
            if(IsSetterMethod(n)) {
                ret = EmitSetter(n, is_member);
            } else {
                ret = EmitGetter(n, is_member);
            }
        } else {
            Printf(stderr, "Warning: unsupported wrapper function type\n");
            Swig_print_node(n);
        }
    } else {
        String *view = Getattr(n, "view");
        
        if( Cmp(view, "constructorHandler") == 0 ) {
            ret = EmitCtor(n);
            
        } else if( Cmp(view, "destructorHandler") == 0 ) {
            ret = EmitDtor(n);

        } else {
            Printf(stderr, "Warning: unsupported wrapper function type");
            Swig_print_node(n);
        }        
    }
    
    DelWrapper(current_wrapper);
    current_wrapper = 0;
    
    return ret;
}

/* -----------------------------------------------------------------------------
 * str_ends_with() :  c string helper to check suffix match
 * ----------------------------------------------------------------------------- */

// TODO: shift this to DOH string API
int str_ends_with(const char * str, const char * suffix) {

  if( str == NULL || suffix == NULL )
    return 0;

  size_t str_len = strlen(str);
  size_t suffix_len = strlen(suffix);

  if(suffix_len > str_len)
    return 0;

  return 0 == strncmp( str + str_len - suffix_len, suffix, suffix_len );
}

/* -----------------------------------------------------------------------------
 * JSEmitter::IsSetterMethod() :  helper to check if a method is a setter function
 * ----------------------------------------------------------------------------- */

bool JSEmitter::IsSetterMethod(Node *n) {
    String* symname = Getattr(n, "sym:name");
    return ( str_ends_with( (char*) Data(symname), "_set") != 0 );
}

Template::Template(const String* code)
{
    if(!code) {
        Printf(stdout, "Template code was null. Illegal input for template.");
        SWIG_exit(EXIT_FAILURE);
    }
    
    m_code = NewString(code);
}
    
Template::~Template() {
    Delete(m_code);
}
        
String* Template::str() {
    return m_code;
}
    
Template& Template::Replace(const String* pattern, const String* repl) {
    ::Replaceall(m_code, pattern, repl);
    return *this;
}
