/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

/*
 * Follow main(int argc, char *argv[]) function
 * Note: SWIGCSHARP_ARGCARGV_PARAM_IDX set the 'argc' parameter location.
 * The C# Marshaling use the argc parameter to determin the array size.
 * See: https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshalasattribute.sizeparamindex
 */

#ifndef SWIGCSHARP_ARGCARGV_PARAM_IDX
#define SWIGCSHARP_ARGCARGV_PARAM_IDX "0"
#endif SWIGCSHARP_ARGCARGV_PARAM_IDX

%typemap(csin) char **ARGV "$csinput"
%typemap(cstype) char **ARGV "string[]"
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.In,global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPArray, ArraySubType=global::System.Runtime.InteropServices.UnmanagedType.LPStr, SizeParamIndex="SWIGCSHARP_ARGCARGV_PARAM_IDX")]") char **ARGV "string[]"
