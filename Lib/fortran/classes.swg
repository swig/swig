/* -------------------------------------------------------------------------
 * classes.swg
 *
 * This defines generic SWIGTYPE typemaps for classes.
 * ------------------------------------------------------------------------- */
%include <typemaps/fragments.swg>
%include <typemaps/swigmacros.swg>

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_autofree_rvalue
 *
 * When an instance of this CLASS is passed to an argument, check whether it
 * needs to be deallocated at the end of the function. Without this check,
 * memory will be leaked when passing a newly constructed object directly into
 * another function.
 *
 * The only reason this isn't done by default is that there are too many edge
 * cases to ensure the result compiles and works in all cases. (For example,
 * forward-declared classes, typedef'd classes, SWIG carray.i "classes", ...)
 */
%define %fortran_autofree_rvalue(CLASS...)

%typemap(in) CLASS = SWIGTYPE;
%typemap(argout, noblock=1, fragment="SWIG_assign", match="in") CLASS {
  SWIG_free_rvalue< $1_ltype, SWIGPOLICY_ ## %mangle(CLASS) >(*$input);
}

%typemap(in) CLASS* = SWIGTYPE*;
%typemap(argout, noblock=1, fragment="SWIG_assign", match="in") CLASS* {
  SWIG_free_rvalue< $*1_ltype, SWIGPOLICY_ ## %mangle(CLASS) >(*$input);
}

%typemap(in) CLASS[] = SWIGTYPE*;
%typemap(argout, match="in") CLASS[] = CLASS*;

%typemap(in) CLASS& = SWIGTYPE&;
%typemap(argout, match="in") CLASS& = CLASS*;

// Restore special assignment/destruct typemaps...
%typemap(in) CLASS *self = SWIGTYPE *self;
%typemap(in) CLASS *ASSIGNMENT_SELF = SWIGTYPE *ASSIGNMENT_SELF;
%typemap(in) CLASS &ASSIGNMENT_OTHER = SWIGTYPE &ASSIGNMENT_OTHER;
%typemap(in) CLASS *DESTRUCTOR_SELF = SWIGTYPE *DESTRUCTOR_SELF;

%enddef

/* -------------------------------------------------------------------------
 * Memory state enumeration
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus
%fragment("SwigMemState", "runtime") %{
enum SwigMemFlags {
    SWIG_MEM_OWN = 0x01,
    SWIG_MEM_RVALUE = 0x02,
};
%}
#else
%fragment("SwigMemState", "runtime") %{
enum {
    SWIG_MEM_OWN = 0x01,
    SWIG_MEM_RVALUE = 0x02,
};
%}
#endif

%fragment("SwigMemState_f", "fdecl", noblock=1) {
 integer, parameter :: swig_cmem_own_bit = 0
 integer, parameter :: swig_cmem_rvalue_bit = 1}

/* -------------------------------------------------------------------------
 * Wrapper struct that holds a C pointer and memory state
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
%fragment("SwigClassWrapper_decl", "header",
          fragment="SwigMemState") %{
struct SwigClassWrapper {
    void* cptr;
    int cmemflags;
};
%}
#else
%fragment("SwigClassWrapper_decl", "header",
          fragment="SwigMemState") %{
typedef struct {
    void* cptr;
    int cmemflags;
} SwigClassWrapper;
%}
#endif

%fragment("SwigClassWrapper", "header",
          fragment="SwigClassWrapper_decl") %{
SWIGINTERN SwigClassWrapper SwigClassWrapper_uninitialized() {
    SwigClassWrapper result;
    result.cptr = NULL;
    result.cmemflags = 0;
    return result;
}
%}

// Fortran declaration of the class wrapper above. Note that we declare the
// enum as a C_INT instead of `integer(SwigMemState)` to avoid a warning
// in GCC. The types will still be interoperable.
%fragment("SwigClassWrapper_f", "fdecl", fragment="SwigMemState_f", noblock=1)
{ type, bind(C) :: SwigClassWrapper
  type(C_PTR), public :: cptr = C_NULL_PTR
  integer(C_INT), public :: cmemflags = 0
 end type}

/* -------------------------------------------------------------------------
 * Runtime check for null argument
 * ------------------------------------------------------------------------- */

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_nonnull", "runtime") %{
#define SWIG_check_nonnull(PTR, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
  if (!(PTR)) { \
    SWIG_exception_impl(FUNCNAME, SWIG_NullReferenceError, \
                        "Cannot pass null " TYPENAME " (class " FNAME ") " \
                        "as a reference", RETURNNULL); \
  }
%}

/* -------------------------------------------------------------------------
 * Assignment: C++ implementation
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
%fragment("SWIG_assignment_type", "runtime") %{
namespace swig {
enum AssignmentType {
  ASSIGNMENT_DEFAULT,
  ASSIGNMENT_NODESTRUCT,
  ASSIGNMENT_SMARTPTR
};
}
%}

%fragment("SWIG_destructor_policy", "header", fragment="SwigClassWrapper", fragment="SWIG_assignment_type") %{
namespace swig {

template<class T, AssignmentType A>
struct DestructorPolicy {
  static SwigClassWrapper destroy(SwigClassWrapper self) {
    delete static_cast<T*>(self.cptr);
    return SwigClassWrapper_uninitialized();
  }
};
template<class T>
struct DestructorPolicy<T, ASSIGNMENT_NODESTRUCT> {
  static SwigClassWrapper destroy(SwigClassWrapper) {
    SWIG_exception_impl("assignment", SWIG_TypeError, "Invalid assignment: class type has private destructor", return SwigClassWrapper_uninitialized());
  }
};
}
%}

%fragment("SWIG_assign", "header", fragment="SWIG_destructor_policy") %{
namespace swig {

SWIGINTERN SwigClassWrapper capture(SwigClassWrapper other) {
  other.cmemflags &= ~SWIG_MEM_RVALUE;
  return other;
}

template<class T, AssignmentType A>
struct AssignmentPolicy {
  static SwigClassWrapper destroy(SwigClassWrapper self) {
    return DestructorPolicy<T, A>::destroy(self);
  }
  static SwigClassWrapper alias(SwigClassWrapper other) {
    SwigClassWrapper self = other;
    self.cmemflags &= ~SWIG_MEM_OWN;
    return self;
  }
  static SwigClassWrapper move_alias(SwigClassWrapper self, SwigClassWrapper other) {
    if (self.cmemflags & SWIG_MEM_OWN) {
      destroy(self);
    }
    return capture(other);
  }
  static SwigClassWrapper copy_alias(SwigClassWrapper self, SwigClassWrapper other) {
    if (self.cmemflags & SWIG_MEM_OWN) {
      destroy(self);
    }
    return capture(other);
  }
};

template<class T>
struct AssignmentPolicy<T, ASSIGNMENT_SMARTPTR> {
  static SwigClassWrapper destroy(SwigClassWrapper self) {
    return DestructorPolicy<T, ASSIGNMENT_SMARTPTR>::destroy(self);
  }
  static SwigClassWrapper alias(SwigClassWrapper other) {
    SwigClassWrapper self;
    self.cptr = new T(*static_cast<T*>(other.cptr));
    self.cmemflags = other.cmemflags | SWIG_MEM_OWN;
    return self;
  }
  static SwigClassWrapper move_alias(SwigClassWrapper self, SwigClassWrapper other) {
    self = copy_alias(self, other);
    self.cmemflags = other.cmemflags & ~SWIG_MEM_RVALUE;
    destroy(other);
    return self;
  }
  static SwigClassWrapper copy_alias(SwigClassWrapper self, SwigClassWrapper other) {
    // LHS and RHS should both 'own' their shared pointers
    T *pself = static_cast<T*>(self.cptr);
    T *pother = static_cast<T*>(other.cptr);
    *pself = *pother;
    return self;
  }
};

} // end namespace swig

template<class T, swig::AssignmentType A>
SWIGINTERN void SWIG_assign(SwigClassWrapper* self, SwigClassWrapper other) {
  typedef swig::AssignmentPolicy<T, A> Policy_t;

  if (self->cptr == NULL) {
    /* LHS is unassigned */
    if (other.cmemflags & SWIG_MEM_RVALUE) {
      /* Capture pointer from RHS, clear 'moving' flag */
      *self = swig::capture(other);
    } else {
      /* Aliasing another class; clear ownership or copy smart pointer */
      *self = Policy_t::alias(other);
    }
  } else if (other.cptr == NULL) {
    /* Replace LHS with a null pointer */
    *self = Policy_t::destroy(*self);
  } else if (self->cptr == other.cptr) {
    /* Self-assignment: ignore */
  } else if (other.cmemflags & SWIG_MEM_RVALUE) {
    /* Transferred ownership from a variable that's about to be lost.
     * Move-assign and delete the transient data */
    *self = Policy_t::move_alias(*self, other);
  } else {
    /* RHS shouldn't be deleted, alias to LHS */
    *self = Policy_t::copy_alias(*self, other);
  }
}

template<class T, swig::AssignmentType A>
SWIGINTERN void SWIG_free_rvalue(SwigClassWrapper other) {
  typedef swig::AssignmentPolicy<T, A> Policy_t;
  if (other.cmemflags & SWIG_MEM_RVALUE 
      && other.cmemflags & SWIG_MEM_OWN) {
    /* We own *and* are being passed an expiring value */
    Policy_t::destroy(other);
  }
}

%}

/* -------------------------------------------------------------------------
 * Assignment: C implementation
 * ------------------------------------------------------------------------- */
#else

%fragment("SWIG_assign", "header",
          fragment="SwigClassWrapper", fragment="<stdlib.h>",
          fragment="<string.h>") %{
SWIGINTERN void SWIG_assign(SwigClassWrapper* self, SwigClassWrapper other) {
  if (self->cptr == NULL) {
    /* LHS is unassigned */
    if (other.cmemflags & SWIG_MEM_RVALUE) {
      /* Capture pointer from RHS, clear 'moving' flag */
      self->cptr = other.cptr;
      self->cmemflags = other.cmemflags & (~SWIG_MEM_RVALUE);
    } else {
      /* Become a reference to the other object */
      self->cptr = other.cptr;
      self->cmemflags = other.cmemflags & (~SWIG_MEM_OWN);
    }
  } else if (other.cptr == NULL) {
    /* Replace LHS with a null pointer */
    free(self->cptr);
    *self = SwigClassWrapper_uninitialized();
  } else if (self->cptr == other.cptr) {
    /* Self-assignment: ignore */
  } else {
    if (self->cmemflags & SWIG_MEM_OWN) {
      free(self->cptr);
    }
    self->cptr = other.cptr;
    if (other.cmemflags & SWIG_MEM_RVALUE) {
      /* Capture RHS */
      self->cmemflags = other.cmemflags & ~SWIG_MEM_RVALUE;
    } else {
      /* Point to RHS */
      self->cmemflags = other.cmemflags & ~SWIG_MEM_OWN;
    }
  }
}
%}

/* Assignment: left = right */
%fragment("SWIG_assign", "runtime",
          fragment="SWIG_assign_impl") %{
#define SWIG_assign(TYPE, POLICY, LEFT, RIGHT) \
    SWIG_assign_impl(LEFT, RIGHT);
%}

#endif

/* -------------------------------------------------------------------------
 * CLASS TYPEMAPS
 *
 * Classes accepted by value are passed as const reference.
 * They're copy-assigned when they're passed
 * Returning a class by value is copy-constructed as a new'd pointer
 */
%typemap(ctype, in="SwigClassWrapper *", null="SwigClassWrapper_uninitialized()", noblock=1, fragment="SwigClassWrapper")
    SWIGTYPE
  "SwigClassWrapper"
%typemap(imtype, in="type(SwigClassWrapper), intent(in)", fragment="SwigClassWrapper_f")
    SWIGTYPE
  "type(SwigClassWrapper)"
%typemap(ftype, in="type($&fortranclassname), intent(in)", nofortransubroutine=1) SWIGTYPE
  "type($&fortranclassname)"

%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE {
  SWIG_check_nonnull($input->cptr, "$1_ltype", "$&fortranclassname", "$decl", return $null);
  $1 = *(($&1_ltype)($input->cptr));
}

#ifdef __cplusplus
%typemap(out, noblock=1) SWIGTYPE {
  $result.cptr = new ($1_ltype)($1);
  $result.cmemflags = SWIG_MEM_RVALUE | SWIG_MEM_OWN;
}
#else
%typemap(out, noblock=1, fragment="<string.h>") SWIGTYPE {
  $result.cptr = %new_copy($1, $1_ltype);
  $result.cmemflags = SWIG_MEM_RVALUE | SWIG_MEM_OWN;
}
#endif
%typemap(fin) SWIGTYPE
  "$1 = $input%swigdata"
%typemap(fout) SWIGTYPE
  "$result%swigdata = $1"

// >>> POINTER

// Raw pointers act mostly like value types, but they don't have to accept the exact type (polymorphic input, non-polymorphic output). Intent is 'in' because
// we're not modifying the pointer or memory status.
%apply SWIGTYPE { SWIGTYPE* };
%typemap(ftype, in="class($fortranclassname), intent(in)", nofortransubroutine=1) SWIGTYPE*
  "type($fortranclassname)"
%typemap(in, noblock=1) SWIGTYPE* {
  $1 = ($1_ltype)$input->cptr;
}
%typemap(out, noblock=1) SWIGTYPE* {
  $result.cptr = (void*)$1;
  $result.cmemflags = SWIG_MEM_RVALUE | ($owner ? SWIG_MEM_OWN : 0);
}
%typemap(bindc, in="type(C_PTR), value") SWIGTYPE*
  "type(C_PTR)";

// >>> ARRAY

%apply SWIGTYPE* { SWIGTYPE[] };

// >>> REFERENCE

// Check for non-null reference inputs
%apply SWIGTYPE* { SWIGTYPE& };
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE& {
  SWIG_check_nonnull($input->cptr, "$1_type", "$fortranclassname", "$decl", return $null);
  $1 = ($1_ltype)$input->cptr;
}

// >>> OTHERS

// Treat const-references-to-pointers as pointers
%apply SWIGTYPE * { SWIGTYPE *const& };
%typemap(in, noblock=1) SWIGTYPE *const & ($*1_ltype temp)
  {temp = ($*1_ltype)$input->cptr;
   $1 = &temp;}

// C binding for opaque classes for advanced users
%typemap(bindc, in="type(SwigClassWrapper), value", fragment="SwigClassWrapper_f") SwigClassWrapper
  "type(SwigClassWrapper)"
%typemap(bindc, in="type(SwigClassWrapper)", fragment="SwigClassWrapper_f") SwigClassWrapper*
  "type(C_PTR)"

/*---------------------------------------------------------------------------
 * Special class typedefs for self, assignment, destruction
 */

// Check for non-null class input "self"
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE *self {
  SWIG_check_nonnull($input->cptr, "$1_type", "$*fortranclassname", "$decl", return $null);
  $1 = ($1_ltype)$input->cptr;
}

// On assignment, copy pointer to input wrapper class
%typemap(imtype, in="type(SwigClassWrapper), intent(inout)", fragment="SwigClassWrapper_f") SWIGTYPE *ASSIGNMENT_SELF
  "type(SwigClassWrapper)"
%typemap(ftype, in="class($fortranclassname), intent(inout)", nofortransubroutine=1) SWIGTYPE *ASSIGNMENT_SELF
  "type($fortranclassname)"

// Assignment operates directly on $input, not $1
%typemap(in) SWIGTYPE *ASSIGNMENT_SELF "(void)sizeof($1);";
%typemap(fargout, noblock=1) SWIGTYPE *ASSIGNMENT_SELF {
  $input%swigdata = $1
}

// Prevent ambiguous overloads by requiring the RHS to be the exact type
%typemap(ftype, in="type($fortranclassname), intent(in)", nofortransubroutine=1) SWIGTYPE &ASSIGNMENT_OTHER
  "type($fortranclassname)"
%typemap(in) SWIGTYPE &ASSIGNMENT_OTHER = SWIGTYPE *ASSIGNMENT_SELF;

%apply SWIGTYPE *ASSIGNMENT_SELF { SWIGTYPE *DESTRUCTOR_SELF };
%typemap(in) SWIGTYPE *DESTRUCTOR_SELF = SWIGTYPE *;

/*---------------------------------------------------------------------------
 * Special class typedefs for directors
 */
%typemap(ftype, in="type($fortranclassname), pointer") SWIGTYPE *swigfhandle
  "type($fortranclassname), pointer"
%typemap(fin) SWIGTYPE *swigfhandle
  "$1 = c_loc($input)"
%typemap(fout, noblock=1) SWIGTYPE *swigfhandle
{if (c_associated($1)) then
  call c_f_pointer($1, $result)
else
  $result => NULL()
endif}

%typemap(imtype, in="type(C_PTR), intent(in), value") SWIGTYPE *swigfhandle
  "type(C_PTR)"
%typemap(ctype, noblock=1) SWIGTYPE *swigfhandle
  "void *"
%typemap(in, noblock=1) SWIGTYPE *swigfhandle
  "$1 = ($1_ltype)$input;"
%typemap(out, noblock=1) SWIGTYPE *swigfhandle
  "$result = (void*)$1;"

// Convert from C++ to ctype
%typemap(directorin) SWIGTYPE* (SwigClassWrapper temp)
%{temp.cptr = (void*)$1;
temp.cmemflags = 0;
$input = &temp;%}

// Convert from im code to ftype
%typemap(ftype) SWIGTYPE *DIRECTOR_SELF
  "class($fortranclassname), pointer"
%typemap(fdirectorin, temp="type($fortranclassname)", noblock=1) SWIGTYPE *DIRECTOR_SELF {$1_temp%swigdata = $input
  $1 => swig_dyncast($1_temp)}

