//
// octrundecl.swg - Declarations of Octave runtime code
//

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <octave/oct.h>
#include <octave/Cell.h>
#include <octave/dynamic-ld.h>
#include <octave/oct-env.h>
#include <octave/oct-map.h>
#include <octave/ov-fcn-handle.h>
#include <octave/parse.h>
#include <octave/toplev.h>
#include <octave/unwind-prot.h>
#include <octave/version.h>

////////// Determine Octave version //////////

// Macro for enabling features which require Octave version >= major.minor.patch
#define SWIG_OCTAVE_PREREQ(major, minor, patch) \
  ( (OCTAVE_MAJOR_VERSION<<16) + (OCTAVE_MINOR_VERSION<<8) + OCTAVE_PATCH_VERSION >= ((major)<<16) + ((minor)<<8) + (patch) )

// Reconstruct Octave major, minor, and patch versions for releases prior to 3.8.1
#if !defined(OCTAVE_MAJOR_VERSION)

# if !defined(OCTAVE_API_VERSION_NUMBER)

// Hack to distinguish between Octave 3.8.0, which removed OCTAVE_API_VERSION_NUMBER but did not yet
// introduce OCTAVE_MAJOR_VERSION, and Octave <= 3.2, which did not define OCTAVE_API_VERSION_NUMBER
#  include <octave/ov.h>
#  if defined(octave_ov_h)
#   define OCTAVE_MAJOR_VERSION 3
#   define OCTAVE_MINOR_VERSION 8
#   define OCTAVE_PATCH_VERSION 0
#  else

// Hack to distinguish between Octave 3.2 and earlier versions, before OCTAVE_API_VERSION_NUMBER existed
#   define ComplexLU __ignore
#   include <octave/CmplxLU.h>
#   undef ComplexLU
#   if defined(octave_Complex_LU_h)

// We know only that this version is prior to Octave 3.2, i.e. OCTAVE_API_VERSION_NUMBER < 37
#    define OCTAVE_MAJOR_VERSION 3
#    define OCTAVE_MINOR_VERSION 1
#    define OCTAVE_PATCH_VERSION 99

#   else

// OCTAVE_API_VERSION_NUMBER == 37
#    define OCTAVE_MAJOR_VERSION 3
#    define OCTAVE_MINOR_VERSION 2
#    define OCTAVE_PATCH_VERSION 0

#   endif // defined(octave_Complex_LU_h)

#  endif // defined(octave_ov_h)

// Correlation between Octave API and version numbers extracted from Octave's
// ChangeLogs; version is the *earliest* released Octave with that API number
# elif OCTAVE_API_VERSION_NUMBER >= 48
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 6
#  define OCTAVE_PATCH_VERSION 0

# elif OCTAVE_API_VERSION_NUMBER >= 45
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 4
#  define OCTAVE_PATCH_VERSION 1

# elif OCTAVE_API_VERSION_NUMBER >= 42
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 54

# elif OCTAVE_API_VERSION_NUMBER >= 41
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 53

# elif OCTAVE_API_VERSION_NUMBER >= 40
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 52

# elif OCTAVE_API_VERSION_NUMBER >= 39
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 51

# else // OCTAVE_API_VERSION_NUMBER == 38
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 50

# endif // !defined(OCTAVE_API_VERSION_NUMBER)

#endif // !defined(OCTAVE_MAJOR_VERSION)

// Set minimum supported Octave version
#if !SWIG_OCTAVE_PREREQ(3,2,0)
#error This version of SWIG supports only Octave version 3.2.0 or later
#endif

// Octave_map was renamed to octave_map in v3.3.52
#if !SWIG_OCTAVE_PREREQ(3,3,52)
#define octave_map Octave_map
#endif

////////// Declare/define SWIG interface function loadable by Octave //////////

#define SWIG_DEFUN(cname, wname, doc) DEFUNX_DLD(#cname, wname, G ## cname, args, nargout, doc)

////////// Define visibility of Octave runtime functions //////////

#define SWIGOCTRT SWIGRUNTIME
#define SWIGOCTRTINLINE SWIGOCTRT SWIGINLINE

////////// Octave implementations of SWIG runtime functions //////////

#define SWIG_fail					goto fail
#define swig_owntype					int
#define SWIG_MODULE_CLIENTDATA_TYPE			void*

#define SWIG_ConvertFunctionPtr(obj, pptr, type)	SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_ConvertMember(obj, ptr, sz, ty)		SWIG_Octave_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_ConvertPacked(obj, ptr, sz, ty)		SWIG_Octave_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_ConvertPtr(obj, pptr, type, flags)		SWIG_Octave_ConvertPtr(obj, pptr, type, flags)
#define SWIG_ConvertPtr(obj, pptr, type, flags)		SWIG_Octave_ConvertPtr(obj, pptr, type, flags)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)	SWIG_Octave_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_GetModule(clientdata)			SWIG_Octave_GetModule(clientdata)
#define SWIG_NewFunctionPtrObj(ptr, type)		SWIG_NewPointerObj(ptr, type, 0)
#define SWIG_NewMemberObj(ptr, sz, type)		SWIG_Octave_NewPackedObj(ptr, sz, type)
#define SWIG_NewPackedObj(ptr, sz, type)		SWIG_Octave_NewPackedObj(ptr, sz, type)
#define SWIG_NewPointerObj(ptr, type, flags)		SWIG_Octave_NewPointerObj(ptr, type, flags)
#define SWIG_Octave_AddErrorMsg(msg)			{;}
#define SWIG_Octave_ConvertPtr(obj, pptr, type, flags)	SWIG_Octave_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_Octave_ErrorOccurred()			0
#define SWIG_SetModule(clientdata, pointer)		SWIG_Octave_SetModule(clientdata,pointer);

#define SWIG_DIRECTOR_CAST(ARG)				dynamic_cast<Swig::Director *>(ARG)

// For backward compatibility only
#define SWIG_POINTER_EXCEPTION				0
#define SWIG_arg_fail(arg)				0

////////// Forward declarations of Octave runtime classes and types //////////

class SwigOctPacked;
class SwigOctRef;
class SwigOctType;
struct SwigOctClass;
struct SwigOctMember;
struct SwigOctValueRef;
typedef octave_value_list(*SwigOctFuncPtr)(const octave_value_list&, int);

#ifdef SWIG_DIRECTORS
namespace Swig
{
  class Director;
  typedef std::map < void* , Director* > rtdir_map;
}
#endif

////////// Declarations of Octave runtime functions //////////

SWIGOCTRT octave_value			SWIG_Error(int code, const char* msg);
SWIGOCTRT octave_value			SWIG_ErrorType(int code);
SWIGOCTRT octave_value_list*		SWIG_Octave_AppendOutput(octave_value_list* ovl, const octave_value& ov);
SWIGOCTRT bool				SWIG_Octave_CheckNumArgs(const char* func_name, int num_args, int max_args, int min_args, int varargs);
SWIGOCTRT int				SWIG_Octave_ConvertPacked(const octave_value& ov, void* ptr, size_t sz, swig_type_info* type);
SWIGOCTRT int				SWIG_Octave_ConvertPtrAndOwn(octave_value ov, void** ptr, swig_type_info* type, int flags, int* own);
SWIGOCTRTINLINE octave_value		SWIG_Octave_GetGlobalValue(std::string name);
SWIGOCTRT swig_module_info*		SWIG_Octave_GetModule(void* clientdata);
SWIGOCTRT swig_module_info*		SWIG_Octave_GetModule(void* clientdata);
SWIGOCTRT void				SWIG_Octave_LinkGlobalValue(std::string name);
SWIGOCTRT octave_value			SWIG_Octave_NewPackedObj(void* ptr, size_t sz, swig_type_info* type);
SWIGOCTRT octave_value			SWIG_Octave_NewPointerObj(void* ptr, swig_type_info* type, int flags);
SWIGOCTRTINLINE void			SWIG_Octave_SetConstant(SwigOctType* module_ns, const std::string& name, const octave_value& ov);
SWIGOCTRT void				SWIG_Octave_SetGlobalValue(std::string name, const octave_value& value);
SWIGOCTRT octave_value_list		SWIG_Octave_SetImmutable(const octave_value_list& args, int nargout);
SWIGOCTRT void				SWIG_Octave_SetModule(void* clientdata, swig_module_info* pointer);
SWIGOCTRT void				SWIG_Octave_SetModule(void* clientdata, swig_module_info* pointer);
SWIGOCTRT SwigOctType*			SWIG_Octave_ValueDeref(const octave_base_value& ov);
SWIGOCTRT SwigOctType*			SWIG_Octave_ValueDeref(octave_value ov);
SWIGOCTRT octave_base_value*		SWIG_Octave_ValueRef(SwigOctType* ost);

#ifdef SWIG_DIRECTORS
namespace Swig
{
  SWIGOCTRTINLINE void			erase_rtdir(void* vptr);
  SWIGOCTRTINLINE Director*		get_rtdir(void* vptr);
  SWIGOCTRT rtdir_map*			get_rtdir_map();
  SWIGOCTRTINLINE void			set_rtdir(void* vptr, Director* d);
  SWIGOCTRT void			swig_director_destroyed(SwigOctType* self, Director* d);
  SWIGOCTRT SwigOctType*		swig_director_get_self(Director* d);
  SWIGOCTRT void			swig_director_set_self(Director* d, SwigOctType* self);
}
SWIGOCTRT void				swig_acquire_ownership(void* vptr);
SWIGOCTRT void				swig_acquire_ownership_array(void* vptr);
SWIGOCTRT void				swig_acquire_ownership_obj(void* vptr, int own);
#endif

////////// Declare Octave class: SwigOctMember //////////

struct SwigOctMember {
  const char* name;
  SwigOctFuncPtr method;
  SwigOctFuncPtr get_method;
  SwigOctFuncPtr set_method;
  int flags;                            // 1=static, 2=global
  const char* doc;
  bool is_static() const {
    return flags & 1;
  }
  bool is_global() const {
    return flags & 2;
  }
};

////////// Declare Octave class: SwigOctClass //////////

struct SwigOctClass {
  const char* name;
  swig_type_info** type;
  int director;
  SwigOctFuncPtr constructor;
  const char* constructor_doc;
  SwigOctFuncPtr destructor;
  const SwigOctMember* members;
  const char** base_names;
  const swig_type_info** base;
};

////////// Declare Octave class: SwigOctValueRef //////////

struct SwigOctValueRef {
  const octave_value_list& ovl;
  int j;
  SwigOctValueRef(const octave_value_list& _ovl, int _j)
    : ovl(_ovl), j(_j) {
  }
  operator  octave_value() const {
    return ovl(j);
  }
  octave_value operator*() const {
    return ovl(j);
  }
};

////////// Declare Octave class: SwigOctType //////////

// SwigOctType plays the role of both the shadow class and the class
// representation within Octave, since there is no support for classes.
//
// These should really be decoupled, with the class support added to Octave
// and the shadow class given by an m-file script. That would dramatically
// reduce the runtime complexity, and be more in line w/ other modules.

class SwigOctType: public octave_base_value
{

  struct cpp_ptr {
    void* ptr;
    bool destroyed;
    cpp_ptr(void* _ptr) : ptr(_ptr), destroyed(false) {
    }
  };

  typedef std::pair < const swig_type_info* , cpp_ptr > type_ptr_pair;
  typedef std::pair < const SwigOctMember* , octave_value > member_value_pair;
  typedef std::map < std::string, member_value_pair > member_map;

  mutable swig_module_info* module;
  const swig_type_info* construct_type; // type of special type object
  std::vector < type_ptr_pair > types;  // our c++ base classes
  int own;                              // whether we call c++ destructors when we die
  member_map members;
  bool always_static;

  SwigOctType(const SwigOctType& x);
  SwigOctType& operator= (const SwigOctType& rhs);

  bool					dispatch_binary_op(const std::string& symbol, const octave_base_value& rhs, octave_value& ret);
  bool					dispatch_index_op(const std::string& symbol, const octave_value_list& rhs, octave_value_list& ret);
  bool					dispatch_unary_op(const std::string& symbol, octave_value& ret);
  const swig_type_info*			find_base(const std::string& name, const swig_type_info* base);
  member_value_pair*			find_member(const std::string& name, bool insert_if_not_found);
  const SwigOctMember*			find_member(const swig_type_info* type, const std::string& name);
  void					load_members(const SwigOctClass* c, member_map& out) const;
  void					load_members(member_map& out) const;
  static octave_value			make_value_hack(const octave_base_value& x);
  octave_value_list			member_deref(member_value_pair* m, const octave_value_list& args);
  octave_value_list			member_invoke(member_value_pair* m, const octave_value_list& args, int nargout);

public:

  typedef member_map::const_iterator swig_member_const_iterator;

  SwigOctType(void* _ptr = 0, const swig_type_info* _type = 0, int _own = 0, bool _always_static = false);
  ~SwigOctType();

  octave_value				as_value();
  void					assign(const std::string& name, const octave_value& ov);
  void					assign(const std::string& name, const SwigOctMember* m);
  void*					cast(swig_type_info* type, int* _own, int flags);
  octave_base_value*			clone() const;
  virtual octave_value			convert_to_str(bool pad = false, bool force = false, char type = '"') const;
  virtual octave_value			convert_to_str_internal(bool pad, bool force, char type) const;
  void					decref();
  dim_vector				dims(void) const;
  static octave_value			dispatch_binary_op(const octave_base_value& lhs, const octave_base_value& rhs, const char* op_name);
  static bool				dispatch_global_op(const std::string& symbol, const octave_value_list& args, octave_value& ret);
  static octave_value			dispatch_unary_op(const octave_base_value& x, const char* op_name);
  octave_base_value*			empty_clone() const;
  void					incref();
  bool					is_defined() const;
  virtual bool				is_map() const;
  virtual bool				is_object() const;
  bool					is_owned() const;
  virtual bool				is_string() const;
  virtual bool				load_ascii(std::istream& is);
  virtual bool				load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt);
  virtual string_vector			map_keys() const;
  virtual octave_map			map_value() const;
  void					merge(SwigOctType& rhs);
  void					print(std::ostream& os, bool pr_as_read_syntax = false) const;
  virtual bool				save_ascii(std::ostream& os);
  virtual bool				save_binary(std::ostream& os, bool& save_as_floats);
  virtual std::string			string_value(bool force = false) const;
  octave_value				subsasgn(const std::string& ops, const std::list < octave_value_list > &idx, const octave_value& rhs);
  virtual octave_value			subsref(const std::string& ops, const std::list < octave_value_list > &idx);
  virtual octave_value_list		subsref(const std::string& ops, const std::list < octave_value_list > &idx, int nargout);
  swig_member_const_iterator		swig_members_begin();
  swig_member_const_iterator		swig_members_end();
  long					swig_this() const;
  std::string				swig_type_name() const;

#ifdef HAVE_HDF5
  virtual bool				load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug);
  virtual bool				save_hdf5(hid_t loc_id, const char* name, bool save_as_floats);
#endif

#ifdef SWIG_DIRECTORS
  void					director_destroyed(Swig::Director* d);
#endif

};

////////// Declare Octave class: SwigOctType //////////

// Octave tries hard to preserve pass-by-value semantics. Eg, assignments
// will call clone() via make_unique() if there is more than one outstanding
// reference to the lhs, and forces the clone's reference count to 1
// (so you can't just increment your own count and return this).
//
// One way to fix this (without modifying Octave) is to add a level of
// indirection such that clone copies ref-counted pointer and we keep
// pass-by-ref semantics (which are more natural/expected for C++ bindings).
//
// Supporting both pass-by-{ref,value} and toggling via %feature/option
// might be nice.

class SwigOctRef: public octave_base_value
{

  DECLARE_OCTAVE_ALLOCATOR;
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA;

  SwigOctType* ptr;

public:

  SwigOctRef(SwigOctType* _ptr = 0);
  ~SwigOctRef();

  octave_base_value*			clone() const;
  virtual octave_value			convert_to_str(bool pad = false, bool force = false, char type = '"') const;
  virtual octave_value			convert_to_str_internal(bool pad, bool force, char type) const;
  dim_vector				dims(void) const;
  octave_base_value*			empty_clone() const;
  SwigOctType*				get_ptr() const;
  bool					is_defined() const;
  virtual bool				is_map() const;
  virtual bool				is_object() const;
  virtual bool				is_string() const;
  virtual bool				load_ascii(std::istream& is);
  virtual bool				load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt);
  virtual string_vector			map_keys() const;
  virtual octave_map			map_value() const;
  void					print(std::ostream& os, bool pr_as_read_syntax = false) const;
  virtual bool				save_ascii(std::ostream& os);
  virtual bool				save_binary(std::ostream& os, bool& save_as_floats);
  virtual std::string			string_value(bool force = false) const;
  octave_value				subsasgn(const std::string& ops, const std::list < octave_value_list > &idx, const octave_value& rhs);
  virtual octave_value			subsref(const std::string& ops, const std::list < octave_value_list > &idx);
  virtual octave_value_list		subsref(const std::string& ops, const std::list < octave_value_list > &idx, int nargout);

#ifdef HAVE_HDF5
  virtual bool				load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug);
  virtual bool				save_hdf5(hid_t loc_id, const char* name, bool save_as_floats);
#endif

};

////////// Declare Octave class: SwigOctPacked //////////

class SwigOctPacked: public octave_base_value
{

  DECLARE_OCTAVE_ALLOCATOR;
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA;

  swig_type_info* type;
  std::vector < char > buf;

public:

  SwigOctPacked(swig_type_info* _type = 0, const void* _buf = 0, size_t _buf_len = 0);

  octave_base_value*			clone() const;
  bool					copy(swig_type_info* outtype, void* ptr, size_t sz) const;
  octave_base_value*			empty_clone() const;
  bool					is_defined() const;
  virtual bool				load_ascii(std::istream& is);
  virtual bool				load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt);
  void					print(std::ostream& os, bool pr_as_read_syntax = false) const;
  virtual bool				save_ascii(std::ostream& os);
  virtual bool				save_binary(std::ostream& os, bool& save_as_floats);

#ifdef HAVE_HDF5
  virtual bool				load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug);
  virtual bool				save_hdf5(hid_t loc_id, const char* name, bool save_as_floats);
#endif

};

////////// Declare Octave class: Swig::Director and related classes //////////

#ifdef SWIG_DIRECTORS
namespace Swig
{

  class Director
  {

    SwigOctType* self;
    bool swig_disowned;

    Director(const Director& x);
    Director& operator= (const Director& rhs);

  public:

    Director(void* vptr);
    ~Director();

    void                                swig_disown();
    SwigOctType*                        swig_get_self() const;
    void                                swig_set_self(SwigOctType* new_self);

  };

  struct DirectorTypeMismatchException {
    static void raise(const char* msg);
    static void raise(const octave_value& ov, const char* msg);
  };

  struct DirectorPureVirtualException {
    static void raise(const char* msg);
    static void raise(const octave_value& ov, const char* msg);
  };

}
#endif
