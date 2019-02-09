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
%fragment("SwigMemState", "header") %{
enum SwigMemState {
    SWIG_NULL,
    SWIG_OWN,
    SWIG_MOVE,
    SWIG_REF,
    SWIG_CREF
};
%}
#else
%fragment("SwigMemState", "header") %{
typedef enum {
    SWIG_NULL,
    SWIG_OWN,
    SWIG_MOVE,
    SWIG_REF,
    SWIG_CREF
} SwigMemState;
%}
#endif

%fragment("SwigMemState_f", "fdecl", noblock=1)
{ enum, bind(c)
  enumerator :: SWIG_NULL = 0
  enumerator :: SWIG_OWN
  enumerator :: SWIG_MOVE
  enumerator :: SWIG_REF
  enumerator :: SWIG_CREF
 end enum
 integer, parameter :: SwigMemState = kind(SWIG_NULL)}

/* -------------------------------------------------------------------------
 * Wrapper struct that holds a C pointer and memory state
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
%fragment("SwigClassWrapper_decl", "header",
          fragment="SwigMemState") %{
struct SwigClassWrapper {
    void* cptr;
    SwigMemState mem;
};
%}
#else
%fragment("SwigClassWrapper_decl", "header",
          fragment="SwigMemState") %{
typedef struct {
    void* cptr;
    SwigMemState mem;
} SwigClassWrapper;
%}
#endif

%fragment("SwigClassWrapper", "header",
          fragment="SwigClassWrapper_decl") %{
SWIGINTERN SwigClassWrapper SwigClassWrapper_uninitialized() {
    SwigClassWrapper result;
    result.cptr = NULL;
    result.mem = SWIG_NULL;
    return result;
}
%}

// Fortran declaration of the class wrapper above. Note that we declare the
// enum as a C_INT instead of `integer(SwigMemState)` to avoid a warning
// in GCC. The types will still be interoperable.
%fragment("SwigClassWrapper_f", "fdecl",
          fragment="SwigMemState_f", noblock=1)
{ type, bind(C) :: SwigClassWrapper
  type(C_PTR), public :: cptr = C_NULL_PTR
  integer(C_INT), public :: mem = SWIG_NULL
 end type}

/* -------------------------------------------------------------------------
 * Runtime check for mutable argument
 * ------------------------------------------------------------------------- */

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_mutable", "runtime") %{
#define SWIG_check_mutable(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
    if ((SWIG_CLASS_WRAPPER).mem == SWIG_CREF) { \
        SWIG_exception_impl(FUNCNAME, SWIG_TypeError, \
            "Cannot pass const " TYPENAME " (class " FNAME ") " \
            "as a mutable reference", \
            RETURNNULL); \
    }
%}

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_nonnull", "runtime") %{
#define SWIG_check_nonnull(SWIG_CLASS_WRAPPER, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
  if ((SWIG_CLASS_WRAPPER).mem == SWIG_NULL) { \
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
 * Assignment: C++ and C++11 implementation
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
%fragment("swig::AssignmentFlags", "runtime") %{
namespace swig {

enum AssignmentFlags {
  IS_DESTR       = 0x01,
  IS_COPY_CONSTR = 0x02,
  IS_COPY_ASSIGN = 0x04,
  IS_MOVE_CONSTR = 0x08,
  IS_MOVE_ASSIGN = 0x10
};

template<class T, int Flags>
struct assignment_flags;
}
%}

// Optional "std::move" support if using C++11
%fragment("swig::AssignmentTraits", "header", fragment="<utility>", fragment="swig::AssignmentFlags") %{
namespace swig {

// Define our own switching struct to support pre-c++11 builds
template<bool Val>
struct bool_constant {};
typedef bool_constant<true>  true_type;
typedef bool_constant<false> false_type;

// Deletion
template<class T>
SWIGINTERN void destruct_impl(T* self, true_type) {
  delete self;
}
template<class T>
SWIGINTERN T* destruct_impl(T* , false_type) {
  SWIG_exception_impl("assignment", SWIG_TypeError,
                      "Invalid assignment: class type has no destructor",
                      return NULL);
}

// Copy construction and assignment
template<class T, class U>
SWIGINTERN T* copy_construct_impl(const U* other, true_type) {
  return new T(*other);
}
template<class T, class U>
SWIGINTERN void copy_assign_impl(T* self, const U* other, true_type) {
  *self = *other;
}

// Disabled construction and assignment
template<class T, class U>
SWIGINTERN T* copy_construct_impl(const U* , false_type) {
  SWIG_exception_impl("assignment", SWIG_TypeError,
                      "Invalid assignment: class type has no copy constructor",
                      return NULL);
}
template<class T, class U>
SWIGINTERN void copy_assign_impl(T* , const U* , false_type) {
  SWIG_exception_impl("assignment", SWIG_TypeError,
                      "Invalid assignment: class type has no copy assignment",
                      return);
}

#if __cplusplus >= 201103L
#include <utility>
#include <type_traits>

// Move construction and assignment
template<class T, class U>
SWIGINTERN T* move_construct_impl(U* other, true_type) {
  return new T(std::move(*other));
}
template<class T, class U>
SWIGINTERN void move_assign_impl(T* self, U* other, true_type) {
  *self = std::move(*other);
}

// Disabled move construction and assignment
template<class T, class U>
SWIGINTERN T* move_construct_impl(U*, false_type) {
  SWIG_exception_impl("assignment", SWIG_TypeError,
                      "Invalid assignment: class type has no move constructor",
                      return NULL);
}
template<class T, class U>
SWIGINTERN void move_assign_impl(T*, U*, false_type) {
  SWIG_exception_impl("assignment", SWIG_TypeError,
                      "Invalid assignment: class type has no move assignment",
                      return);
}

template<class T, int Flags>
struct assignment_flags {
  constexpr static int value =
             (std::is_destructible<T>::value       ? IS_DESTR       : 0)
           | (std::is_copy_constructible<T>::value ? IS_COPY_CONSTR : 0)
           | (std::is_copy_assignable<T>::value    ? IS_COPY_ASSIGN : 0)
           | (std::is_move_constructible<T>::value ? IS_MOVE_CONSTR : 0)
           | (std::is_move_assignable<T>::value    ? IS_MOVE_ASSIGN : 0);
};

#else

template<class T, int Flags>
struct assignment_flags {
  enum { value = Flags };
};

#endif

template<class T, int Flags>
struct AssignmentTraits {
  static void destruct(T* self) {
    destruct_impl<T>(self, bool_constant<Flags & IS_DESTR>());
  }

  template<class U>
  static T* copy_construct(const U* other) {
    return copy_construct_impl<T,U>(other, bool_constant<bool(Flags & IS_COPY_CONSTR)>());
  }

  template<class U>
  static void copy_assign(T* self, const U* other) {
    copy_assign_impl<T,U>(self, other, bool_constant<bool(Flags & IS_COPY_ASSIGN)>());
  }

#if __cplusplus >= 201103L
  template<class U>
  static T* move_construct(U* other) {
    return move_construct_impl<T,U>(other, bool_constant<bool(Flags & IS_MOVE_CONSTR)>());
  }
  template<class U>
  static void move_assign(T* self, U* other) {
    move_assign_impl<T,U>(self, other, bool_constant<bool(Flags & IS_MOVE_ASSIGN)>());
  }
#else
  template<class U>
  static T* move_construct(U* other) {
    return copy_construct_impl<T,U>(other, bool_constant<bool(Flags & IS_COPY_CONSTR)>());
  }
  template<class U>
  static void move_assign(T* self, U* other) {
    copy_assign_impl<T,U>(self, other, bool_constant<bool(Flags & IS_COPY_ASSIGN)>());
  }
#endif
};

} // end namespace swig
%}

%fragment("SWIG_assign_impl", "header", fragment="SwigClassWrapper", fragment="swig::AssignmentTraits") %{
template<class T1, class T2, int AFlags>
SWIGINTERN void SWIG_assign_impl(SwigClassWrapper* self, SwigClassWrapper* other) {
  typedef swig::AssignmentTraits<T1, AFlags> Traits_t;
  T1* pself  = static_cast<T1*>(self->cptr);
  T2* pother = static_cast<T2*>(other->cptr);

  switch (self->mem) {
    case SWIG_NULL:
      /* LHS is unassigned */
      switch (other->mem) {
        case SWIG_NULL: /* null op */
          break;
        case SWIG_MOVE: /* capture pointer from RHS */
          self->cptr = other->cptr;
          other->cptr = NULL;
          self->mem = SWIG_OWN;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN: /* copy from RHS */
          self->cptr = Traits_t::copy_construct(pother);
          self->mem = SWIG_OWN;
          break;
        case SWIG_REF: /* pointer to RHS */
        case SWIG_CREF:
          self->cptr = other->cptr;
          self->mem = other->mem;
          break;
      }
      break;
    case SWIG_OWN:
      /* LHS owns memory */
      switch (other->mem) {
        case SWIG_NULL:
          /* Delete LHS */
          Traits_t::destruct(pself);
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        case SWIG_MOVE:
          /* Move RHS into LHS; delete RHS */
          Traits_t::move_assign(pself, pother);
          Traits_t::destruct(pother);
          other->cptr = NULL;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN:
        case SWIG_REF:
        case SWIG_CREF:
          /* Copy RHS to LHS */
          Traits_t::copy_assign(pself, pother);
          break;
      }
      break;
    case SWIG_MOVE:
      SWIG_exception_impl("assignment", SWIG_RuntimeError,
        "Left-hand side of assignment should never be in a 'MOVE' state",
        return);
      break;
    case SWIG_REF:
      /* LHS is a reference */
      switch (other->mem) {
        case SWIG_NULL:
          /* Remove LHS reference */
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        case SWIG_MOVE:
          /* Move RHS into LHS; delete RHS. The original ownership stays the
           * same. */
          Traits_t::move_assign(pself, pother);
          Traits_t::destruct(pother);
          other->cptr = NULL;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN:
        case SWIG_REF:
        case SWIG_CREF:
          /* Copy RHS to LHS */
          Traits_t::copy_assign(pself, pother);
          break;
      }
      break;
    case SWIG_CREF:
      switch (other->mem) {
        case SWIG_NULL:
          /* Remove LHS reference */
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        default:
          SWIG_exception_impl("assignment", SWIG_RuntimeError,
              "Cannot assign to a const reference", return);
          break;
      }
      break;
  }
}
%}

// Assignment: left = right
%fragment("SWIG_assign", "runtime",
          fragment="SWIG_assign_impl") %{
#define SWIG_assign(LEFTTYPE, LEFT, RIGHTTYPE, RIGHT, FLAGS) \
    SWIG_assign_impl<LEFTTYPE , RIGHTTYPE, swig::assignment_flags<LEFTTYPE, FLAGS >::value >(LEFT, RIGHT);
%}

/* -------------------------------------------------------------------------
 * Assignment: C implementation
 * ------------------------------------------------------------------------- */
#else

%fragment("SWIG_assign_impl", "header",
          fragment="SwigClassWrapper", fragment="<stdlib.h>",
          fragment="<string.h>") %{
SWIGINTERN void SWIG_assign_impl(SwigClassWrapper* self, SwigClassWrapper* other, size_t size) {
  void* pself  = self->cptr;
  void* pother = other->cptr;

  switch (self->mem) {
    case SWIG_NULL:
      /* LHS is unassigned */
      switch (other->mem) {
        case SWIG_NULL: /* null op */
          break;
        case SWIG_MOVE: /* capture pointer from RHS */
          self->cptr = other->cptr;
          other->cptr = NULL;
          self->mem = SWIG_OWN;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN: /* copy from RHS */
          pself = malloc(size);
          memcpy(pself, pother, size);
          self->cptr = pself;
          self->mem = SWIG_OWN;
          break;
        case SWIG_REF: /* pointer to RHS */
        case SWIG_CREF:
          self->cptr = other->cptr;
          self->mem = other->mem;
          break;
      }
      break;
    case SWIG_OWN:
      /* LHS owns memory */
      switch (other->mem) {
        case SWIG_NULL:
          /* Delete LHS */
          free(pself);
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        case SWIG_MOVE:
          /* Move RHS into LHS; delete RHS */
          memcpy(pself, pother, size);
          free(pother);
          other->cptr = NULL;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN:
        case SWIG_REF:
        case SWIG_CREF:
          /* Copy RHS to LHS */
          memcpy(pself, pother, size);
          break;
      }
      break;
    case SWIG_MOVE:
      SWIG_exception_impl("assignment", SWIG_RuntimeError,
        "Left-hand side of assignment should never be in a 'MOVE' state",
        return);
      break;
    case SWIG_REF:
      /* LHS is a reference */
      switch (other->mem) {
        case SWIG_NULL:
          /* Remove LHS reference */
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        case SWIG_MOVE:
          /* Move RHS into LHS; delete RHS. The original ownership stays the
           * same. */
          memcpy(pself, pother, size);
          free(pother);
          other->cptr = NULL;
          other->mem = SWIG_NULL;
          break;
        case SWIG_OWN:
        case SWIG_REF:
        case SWIG_CREF:
          /* Copy RHS to LHS */
          memcpy(pself, pother, size);
          break;
      }
      break;
    case SWIG_CREF:
      switch (other->mem) {
        case SWIG_NULL:
          /* Remove LHS reference */
          self->cptr = NULL;
          self->mem = SWIG_NULL;
          break;
        default:
          SWIG_exception_impl("assignment", SWIG_RuntimeError,
              "Cannot assign to a const reference", return);
          break;
      }
      break;
  }
}
%}

/* Assignment: left = right */
%fragment("SWIG_assign", "runtime",
          fragment="SWIG_assign_impl") %{
#define SWIG_assign(LEFTTYPE, LEFT, RIGHTTYPE, RIGHT, FLAGS) \
    SWIG_assign_impl(LEFT, RIGHT, sizeof(LEFTTYPE));
%}

#endif

/* -------------------------------------------------------------------------
 * CLASS DEFINITION
 * ------------------------------------------------------------------------- */

// Data owned by the base class instance
%typemap(fdata, fragment="SwigClassWrapper_f") SWIGTYPE
  "type(SwigClassWrapper), public :: swigdata"

// Call destructor if the data is owned; then clear the pointer
%typemap(fdestructor, noblock=1) SWIGTYPE {
  if ($input%swigdata%mem == SWIG_OWN) then
    $action
  end if
  $input%swigdata%cptr = C_NULL_PTR
  $input%swigdata%mem = SWIG_NULL
}

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
%typemap(ftype) SWIGTYPE
  "type($fclassname)"

%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE {
  SWIG_check_nonnull(*$input, "$1_ltype", "$fclassname", "$decl", return $null);
  $1 = *%static_cast($input->cptr, $&1_ltype);
}
%typemap(out, noblock=1) SWIGTYPE {
  $result.cptr = %new_copy($1, $1_ltype);
  $result.mem = SWIG_MOVE;
}
%typemap(fin) SWIGTYPE
  "$1 = $input%swigdata"
%typemap(findecl, match="fin") SWIGTYPE ""
%typemap(fout) SWIGTYPE
  "$result%swigdata = $1"
%typemap(foutdecl, match="fout") SWIGTYPE ""

// Raw pointers act mostly like value types, but they don't have to accept the exact type (polymorphic input, non-polymorphic output)
%apply SWIGTYPE { SWIGTYPE* };
%typemap(ftype, in="class($fclassname), intent(inout)") SWIGTYPE*
  "type($fclassname)"

// Use C pointers as placeholders for class pointers by default; this will
// propagate to const pointers and arrays
%typemap(bindc) SWIGTYPE* = void*;

// Convert mutable pointers
%typemap(in, noblock=1, fragment="SWIG_check_mutable") SWIGTYPE* {
  SWIG_check_mutable(*$input, "$1_ltype", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}
%typemap(out, noblock=1) SWIGTYPE* {
  $result.cptr = $1;
  $result.mem = ($owner ? SWIG_MOVE : SWIG_REF);
}

// Immutable pointers to mutable classes
%apply SWIGTYPE* { SWIGTYPE* const };

// Const pointers don't require mutability check; and their intent changes
%apply SWIGTYPE* { const SWIGTYPE* };
%typemap(ftype, in="class($fclassname), intent(in)") const SWIGTYPE*
  "type($fclassname)"
%typemap(in, noblock=1) const SWIGTYPE*
  {$1 = %static_cast($input->cptr, $1_ltype);}
%typemap(out, noblock=1) const SWIGTYPE*
  {$result.cptr = (void*)$1;
   $result.mem = SWIG_CREF;}

// Mutable references are treated as mutable pointers, but check for non-null reference inputs
%apply SWIGTYPE* { SWIGTYPE& };
%typemap(in, noblock=1, fragment="SWIG_check_mutable_nonnull") SWIGTYPE& {
  SWIG_check_mutable_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

// Const references are like const pointers; use more restrictive check though
%apply const SWIGTYPE* { const SWIGTYPE& };
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") const SWIGTYPE& {
  SWIG_check_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

// Check for non-null, mutable class input "self"
%typemap(in, noblock=1, fragment="SWIG_check_mutable_nonnull") SWIGTYPE *self {
  SWIG_check_mutable_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}
// Check for non-null class input "self"
%typemap(in, noblock=1, fragment="SWIG_check_nonnull") const SWIGTYPE *self {
  SWIG_check_nonnull(*$input, "$1_type", "$fclassname", "$decl", return $null);
  $1 = %static_cast($input->cptr, $1_ltype);
}

// Treat arrays of classes as opaque pointers
%apply void * { SWIGTYPE [], SWIGTYPE [ANY] };
%apply const void * { const SWIGTYPE [], const SWIGTYPE [ANY] };

// Treat const-references-to-pointers as pointers
%apply SWIGTYPE * { const SWIGTYPE *const& };
%typemap(in, noblock=1) SWIGTYPE *const & ($*1_ltype temp)
  {temp = %static_cast($input->cptr, $*1_ltype);
   $1 = &temp;}

// Treat const references to const pointers the same way
%apply SWIGTYPE *const& { const SWIGTYPE *const& };
   
// C binding for opaque classes for advanced users
%typemap(bindc, in="type(SwigClassWrapper), value", fragment="SwigClassWrapper_f") SwigClassWrapper
  "type(SwigClassWrapper)"
%typemap(bindc, in="type(SwigClassWrapper)", fragment="SwigClassWrapper_f") SwigClassWrapper*
  "type(C_PTR)"

