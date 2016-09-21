/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------
 * 
 * This file is kept around because it could provide a useful hook,
 * but it may end up just being a vestige of the JSCore heritage.
 */  

%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
%}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
%}