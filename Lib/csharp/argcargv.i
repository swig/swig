/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

/*
 * Follow main(int argc, char *argv[]) function
 * Note: 'int argc' must be first parameter!
 * By setting 'SizeParamIndex=0'.
 * The C# Marshaling use the argc parameter to determin the array size.
 * See: https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshalasattribute.sizeparamindex
 */

%typemap(csin) char **ARGV "$csinput"
%typemap(cstype) char **ARGV "string[]"
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.In,global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPArray, ArraySubType=global::System.Runtime.InteropServices.UnmanagedType.LPStr, SizeParamIndex=0)]") char **ARGV "string[]"
