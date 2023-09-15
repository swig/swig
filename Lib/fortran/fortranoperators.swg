/* -----------------------------------------------------------------------------
 * fortranoperators.swg
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
%define %fortran_operator(FSYMNAME, GENERIC_SPEC, OPERATOR)
%rename(FSYMNAME) OPERATOR;
%feature("fortran:generic", GENERIC_SPEC) OPERATOR;
%enddef

// Rename *operators* to *generics*
%fortran_operator(op_add__,    "operator(+)",        *::operator+)
%fortran_operator(op_sub__,    "operator(-)",        *::operator-)
%fortran_operator(op_mul__,    "operator(*)",        *::operator*)
%fortran_operator(op_mod__,    "operator(.mod.)",    *::operator%)
%fortran_operator(op_lshift__, "operator(.lshift.)", *::operator<<)
%fortran_operator(op_rshift__, "operator(.rshift.)", *::operator>>)
%fortran_operator(op_and__,    "operator(.and.)",    *::operator&)
%fortran_operator(op_or__,     "operator(.or.)",     *::operator|)
%fortran_operator(op_xor__,    "operator(.xor.)",    *::operator^)
%fortran_operator(op_lt__,     "operator(.lt.)",     *::operator<)
%fortran_operator(op_le__,     "operator(.le.)",     *::operator<=)
%fortran_operator(op_gt__,     "operator(.gt.)",     *::operator>)
%fortran_operator(op_ge__,     "operator(.ge.)",     *::operator>=)
%fortran_operator(op_eq__,     "operator(.eq.)",     *::operator==)
%fortran_operator(op_ne__,     "operator(.ne.)",     *::operator!=)
%fortran_operator(op_ptr__,    "operator(.ptr.)",    *::operator->)
%fortran_operator(op_deref__,  "operator(.deref.)",  *::operator*())

// Do *not* rename assignment by default
// %fortran_operator(op_assign__, "assignment(=)",      *::operator=)

/* Always treat return values from assignment as optional, since it's usually
 * idiomatic to `return *this;` as a reference that is often ignored by the
 * calling code. Making the function a subroutine means being able to use "call" 
 * instead of having to capture the result into a dummy variable.
 */
%fortransubroutine *::operator=;

#endif
