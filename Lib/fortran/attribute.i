/* -------------------------------------------------------------------------
 * attribute.i
 *
 * Fortran doesn't have a way of treating function calls as attributes; so we
 * ignore all %attribute directives.
 *
 * Warning 507 is "WARN_LANG_NATIVE_UNIMPL"
 * ------------------------------------------------------------------------- */



%define %attribute(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef

%define %attribute2(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef

%define %attributeref(Class, AttributeType, AttributeName, AccessorMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef

%define %attribute2ref(Class, AttributeType, AttributeName, AccessorMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef

// deprecated (same as %attributeref, but there is an argument order inconsistency)
%define %attribute_ref(Class, AttributeType, AccessorMethod, AttributeName...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef

%define %attributeval(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef


%define %attributestring(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
%warn "507:%attribute directives are ignored by Fortran"
%enddef


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
