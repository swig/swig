/* -------------------------------------------------------------------------
 * classes.swg
 *
 * This defines generic SWIGTYPE typemaps for classes.
 * ------------------------------------------------------------------------- */
%include <typemaps/fragments.swg>
%include <typemaps/swigmacros.swg>

/* -------------------------------------------------------------------------
 * Memory state enumeration
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus
%fragment("SwigMemState", "runtime") %{
enum SwigMemFlags {
    SWIG_MEM_OWN = 0x01,
    SWIG_MEM_RVALUE = 0x02,
    SWIG_MEM_CONST = 0x04
};
%}
#else
%fragment("SwigMemState", "runtime") %{
enum {
    SWIG_MEM_OWN = 0x01,
    SWIG_MEM_RVALUE = 0x02,
    SWIG_MEM_CONST = 0x04
};
%}
#endif

%fragment("SwigMemState_f", "fdecl", noblock=1) {
 integer, parameter :: swig_cmem_own_bit = 0
 integer, parameter :: swig_cmem_rvalue_bit = 1
 integer, parameter :: swig_cmem_const_bit = 2}

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
 * Runtime check for mutable argument
 * ------------------------------------------------------------------------- */

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_mutable", "runtime") %{
#define SWIG_check_mutable(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
    if ((SWIG_CLASS_WRAPPER).cmemflags & SWIG_MEM_CONST) { \
        SWIG_exception_impl(FUNCNAME, SWIG_TypeError, \
            "Cannot pass const " TYPENAME " (class " FNAME ") " \
            "as a mutable reference", \
            RETURNNULL); \
    }
%}

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_nonnull", "runtime") %{
#define SWIG_check_nonnull(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
  if (!(SWIG_CLASS_WRAPPER).cptr) { \
    SWIG_exception_impl(FUNCNAME, SWIG_TypeError, \
                        "Cannot pass null " TYPENAME " (class " FNAME ") " \
                        "as a reference", RETURNNULL); \
  }
%}

%fragment("SWIG_check_mutable_nonnull", "runtime", fragment="SWIG_check_mutable", fragment="SWIG_check_nonnull") %{
#define SWIG_check_mutable_nonnull(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
    SWIG_check_nonnull(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL); \
    SWIG_check_mutable(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL);
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
  static SwigClassWrapper destruct(SwigClassWrapper self) {
    delete static_cast<T*>(self.cptr);
    return SwigClassWrapper_uninitialized();
  }
};
template<class T>
struct DestructorPolicy<T, ASSIGNMENT_NODESTRUCT> {
  static SwigClassWrapper destruct(SwigClassWrapper self) {
    SWIG_exception_impl("assignment", SWIG_TypeError, "Invalid assignment: class type has private destructor", return SwigClassWrapper_uninitialized());
  }
};
}
%}

%fragment("SWIG_assign", "header", fragment="SWIG_destructor_policy") %{
namespace swig {

template<class T, AssignmentType A>
struct AssignmentPolicy {
  static SwigClassWrapper destruct(SwigClassWrapper self) {
    return DestructorPolicy<T, A>::destruct(self);
  }
  static SwigClassWrapper alias(SwigClassWrapper other) {
    SwigClassWrapper self;
    self.cptr = other.cptr;
    self.cmemflags = other.cmemflags & ~SWIG_MEM_OWN;
    return self;
  }
  static SwigClassWrapper move_alias(SwigClassWrapper self, SwigClassWrapper other) {
    if (self.cmemflags & SWIG_MEM_OWN) {
      destruct(self);
    }
    self.cptr = other.cptr;
    self.cmemflags = other.cmemflags & ~SWIG_MEM_RVALUE;
    return self;
  }
  static SwigClassWrapper copy_alias(SwigClassWrapper self, SwigClassWrapper other) {
    if (self.cmemflags & SWIG_MEM_OWN) {
      destruct(self);
    }
    self.cptr = other.cptr;
    self.cmemflags = other.cmemflags & ~SWIG_MEM_OWN;
    return self;
  }
};

template<class T>
struct AssignmentPolicy<T, ASSIGNMENT_SMARTPTR> {
  static SwigClassWrapper destruct(SwigClassWrapper self) {
    return DestructorPolicy<T, ASSIGNMENT_SMARTPTR>::destruct(self);
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
    destruct(other);
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
      self->cptr = other.cptr;
      self->cmemflags = other.cmemflags & (~SWIG_MEM_RVALUE);
    } else {
      /* Aliasing another class; clear ownership or copy smart pointer */
      *self = Policy_t::alias(other);
    }
  } else if (other.cptr == NULL) {
    /* Replace LHS with a null pointer */
    *self = Policy_t::destruct(*self);
  } else if (other.cmemflags & SWIG_MEM_RVALUE) {
    /* Transferred ownership from a variable that's about to be lost.
     * Move-assign and delete the transient data */
    *self = Policy_t::move_alias(*self, other);
  } else {
    /* RHS shouldn't be deleted, alias to LHS */
    *self = Policy_t::copy_alias(*self, other);
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
%typemap(ctype, in="const SwigClassWrapper *", null="SwigClassWrapper_uninitialized()", noblock=1, fragment="SwigClassWrapper")
    SWIGTYPE
  "SwigClassWrapper"
%typemap(imtype, fragment="SwigClassWrapper_f")
    SWIGTYPE
  "type(SwigClassWrapper)"
%typemap(ftype, in="type($&fclassname), intent(in)", nofortransubroutine=1) SWIGTYPE
  "type($&fclassname)"

%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE {
  SWIG_check_nonnull(*$input, "$1_ltype", "$&fclassname", "$decl", return $null);
  $1 = *%static_cast($input->cptr, $&1_ltype);
}
%typemap(out, noblock=1) SWIGTYPE {
  $result.cptr = %new_copy($1, $1_ltype);
  $result.cmemflags = SWIG_MEM_RVALUE | SWIG_MEM_OWN;
}
%typemap(fin) SWIGTYPE
  "$1 = $input%swigdata"
%typemap(findecl, match="fin") SWIGTYPE ""
%typemap(fout) SWIGTYPE
  "$result%swigdata = $1"
%typemap(foutdecl, match="fout") SWIGTYPE ""

// >>> POINTER

// Raw pointers act mostly like value types, but they don't have to accept the exact type (polymorphic input, non-polymorphic output). Intent is 'in' because
// we're not modifying the pointer or memory status.
%apply SWIGTYPE { SWIGTYPE* };
%typemap(ftype, in="class($fclassname), intent(in)", nofortransubroutine=1) SWIGTYPE*
  "type($fclassname)"
%typemap(in, noblock=1, fragment="SWIG_check_mutable") SWIGTYPE* {
  SWIG_check_mutable(*$input, "$1_ltype", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}
%typemap(out, noblock=1) SWIGTYPE* {
  $result.cptr = $1;
  $result.cmemflags = SWIG_MEM_RVALUE | ($owner ? SWIG_MEM_OWN : 0);
}
%typemap(bindc) SWIGTYPE* "type(C_PTR)";

// >>> CONST POINTER

// Immutable pointers to mutable classes
%apply SWIGTYPE* { SWIGTYPE* const };

// Const pointers don't require mutability check; and their intent changes
%apply SWIGTYPE* { const SWIGTYPE* };
%typemap(in, noblock=1) const SWIGTYPE*
  {$1 = %static_cast($input->cptr, $1_ltype);}
%typemap(out, noblock=1) const SWIGTYPE* {
  $result.cptr = (void*)$1;
  $result.cmemflags = SWIG_MEM_RVALUE | ($owner ? SWIG_MEM_OWN : 0) | SWIG_MEM_CONST;
}

// >>> REFERENCE

// Mutable references are treated as mutable pointers, but check for non-null reference inputs
%apply SWIGTYPE* { SWIGTYPE& };
%typemap(in, noblock=1, fragment="SWIG_check_mutable_nonnull") SWIGTYPE& {
  SWIG_check_mutable_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

// >>> CONST REFERENCE

// Const references are like const pointers; use more restrictive check though
%apply const SWIGTYPE* { const SWIGTYPE& };
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") const SWIGTYPE& {
  SWIG_check_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

// >>> OTHERS

// Treat arrays of classes as opaque pointers
%apply SWIGTYPE* { SWIGTYPE [], SWIGTYPE [ANY] };
%apply SWIGTYPE* { const SWIGTYPE [], const SWIGTYPE [ANY] };

// Treat const-references-to-pointers as pointers
%typemap(ftype, in="class($*fclassname), intent(inout)", nofortransubroutine=1) SWIGTYPE *MUTABLE_SELF
  "type($*fclassname)"
%apply SWIGTYPE * { const SWIGTYPE *const& };
%typemap(in, noblock=1) SWIGTYPE *const & ($*1_ltype temp)
  {temp = %static_cast($input->cptr, $*1_ltype);
   $1 = &temp;}

// C binding for opaque classes for advanced users
%typemap(bindc, in="type(SwigClassWrapper), value", fragment="SwigClassWrapper_f") SwigClassWrapper
  "type(SwigClassWrapper)"
%typemap(bindc, in="type(SwigClassWrapper)", fragment="SwigClassWrapper_f") SwigClassWrapper*
  "type(C_PTR)"

/*---------------------------------------------------------------------------
 * Special class typedefs for self, assignment, destruction
 */

// Check for non-null, mutable class input "self"
%typemap(in, noblock=1, fragment="SWIG_check_mutable_nonnull") SWIGTYPE *self {
  SWIG_check_mutable_nonnull(*$input, "$1_type", "$*fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}
// Check for non-null class input "self"
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") const SWIGTYPE *self {
  SWIG_check_nonnull(*$input, "$1_type", "$*fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

%typemap(ftype, in="class($fclassname), intent(inout)", nofortransubroutine=1) SWIGTYPE *MUTABLE_SELF
  "type($fclassname)"
%typemap(ctype, fragment="SwigClassWrapper") SWIGTYPE *MUTABLE_SELF
  "SwigClassWrapper *"
%typemap(imtype, in="type(SwigClassWrapper), intent(inout)", fragment="SwigClassWrapper_f") SWIGTYPE *MUTABLE_SELF
  "type(SwigClassWrapper)"
%typemap(fargout, noblock=1) SWIGTYPE *MUTABLE_SELF {
  $input%swigdata = $1
}

%apply SWIGTYPE *MUTABLE_SELF { SWIGTYPE *ASSIGNMENT_SELF };
%typemap(in) SWIGTYPE *ASSIGNMENT_SELF "(void)sizeof($1);";

%typemap(ftype, in="type($fclassname), intent(in)", nofortransubroutine=1) SWIGTYPE &ASSIGNMENT_OTHER
  "type($fclassname)"
%typemap(in) SWIGTYPE &ASSIGNMENT_OTHER = SWIGTYPE *ASSIGNMENT_SELF;

%apply SWIGTYPE *MUTABLE_SELF { SWIGTYPE *DESTRUCTOR_SELF };

