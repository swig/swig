;; -*- buffer-read-only: t -*- vi: set ro:
;; This file was created automatically by SWIG.
;; Don't modify this file, modify the SWIG interface instead.
(declare (unit vtk))

(declare (foreign-declare "extern vtk_swig_init(int,C_word,C_word);"))
(define init-vtk (##core#primitive "vtk_swig_init"))
(init-vtk)

(declare (foreign-declare "extern vtk_wrap_VTK_CXX_COMPILER(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-cxx-compiler (##core#primitive "vtk_wrap_VTK_CXX_COMPILER"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIndent_Delete(int,C_word,C_word,C_word);"))
(define vtk-vtk-indent-delete (##core#primitive "vtk_wrap_vtkIndent_Delete"))

(declare (foreign-declare "extern C_word vtk_wrap_new_vtkIndent(int,C_word,C_word,C_word);"))
(define vtk-new-vtk-indent (##core#primitive "vtk_wrap_new_vtkIndent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIndent_New(int,C_word,C_word);"))
(define vtk-vtk-indent-new (##core#primitive "vtk_wrap_vtkIndent_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIndent_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-indent-get-class-name (##core#primitive "vtk_wrap_vtkIndent_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIndent_GetNextIndent(int,C_word,C_word,C_word);"))
(define vtk-vtk-indent-get-next-indent (##core#primitive "vtk_wrap_vtkIndent_GetNextIndent"))

(declare (foreign-declare "extern C_word vtk_wrap_delete_vtkIndent(int,C_word,C_word,C_word);"))
(define vtk-delete-vtk-indent (##core#primitive "vtk_wrap_delete_vtkIndent"))

(declare (foreign-declare "extern C_word vtk_wrap_new_vtkTimeStamp(int,C_word,C_word);"))
(define vtk-new-vtk-time-stamp (##core#primitive "vtk_wrap_new_vtkTimeStamp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp_New(int,C_word,C_word);"))
(define vtk-vtk-time-stamp-new (##core#primitive "vtk_wrap_vtkTimeStamp_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp_Delete(int,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp-delete (##core#primitive "vtk_wrap_vtkTimeStamp_Delete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp-get-class-name (##core#primitive "vtk_wrap_vtkTimeStamp_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp_Modified(int,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp-modified (##core#primitive "vtk_wrap_vtkTimeStamp_Modified"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp-get-m-time (##core#primitive "vtk_wrap_vtkTimeStamp_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp___gt__(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp---gt-- (##core#primitive "vtk_wrap_vtkTimeStamp___gt__"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimeStamp___lt__(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-time-stamp---lt-- (##core#primitive "vtk_wrap_vtkTimeStamp___lt__"))

(declare (foreign-declare "extern C_word vtk_wrap_delete_vtkTimeStamp(int,C_word,C_word,C_word);"))
(define vtk-delete-vtk-time-stamp (##core#primitive "vtk_wrap_delete_vtkTimeStamp"))

(declare (foreign-declare "extern vtk_wrap_VTK_LARGE_FLOAT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-large-float (##core#primitive "vtk_wrap_VTK_LARGE_FLOAT"))

(declare (foreign-declare "extern vtk_wrap_VTK_LARGE_ID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-large-id (##core#primitive "vtk_wrap_VTK_LARGE_ID"))

(declare (foreign-declare "extern vtk_wrap_VTK_LARGE_INTEGER(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-large-integer (##core#primitive "vtk_wrap_VTK_LARGE_INTEGER"))

(declare (foreign-declare "extern vtk_wrap_VTK_VOID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-void (##core#primitive "vtk_wrap_VTK_VOID"))

(declare (foreign-declare "extern vtk_wrap_VTK_BIT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-bit (##core#primitive "vtk_wrap_VTK_BIT"))

(declare (foreign-declare "extern vtk_wrap_VTK_CHAR(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-char (##core#primitive "vtk_wrap_VTK_CHAR"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_CHAR(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-char (##core#primitive "vtk_wrap_VTK_UNSIGNED_CHAR"))

(declare (foreign-declare "extern vtk_wrap_VTK_SHORT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-short (##core#primitive "vtk_wrap_VTK_SHORT"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_SHORT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-short (##core#primitive "vtk_wrap_VTK_UNSIGNED_SHORT"))

(declare (foreign-declare "extern vtk_wrap_VTK_INT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-int (##core#primitive "vtk_wrap_VTK_INT"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_INT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-int (##core#primitive "vtk_wrap_VTK_UNSIGNED_INT"))

(declare (foreign-declare "extern vtk_wrap_VTK_LONG(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-long (##core#primitive "vtk_wrap_VTK_LONG"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_LONG(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-long (##core#primitive "vtk_wrap_VTK_UNSIGNED_LONG"))

(declare (foreign-declare "extern vtk_wrap_VTK_FLOAT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-float (##core#primitive "vtk_wrap_VTK_FLOAT"))

(declare (foreign-declare "extern vtk_wrap_VTK_DOUBLE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-double (##core#primitive "vtk_wrap_VTK_DOUBLE"))

(declare (foreign-declare "extern vtk_wrap_VTK_ID_TYPE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-id-type (##core#primitive "vtk_wrap_VTK_ID_TYPE"))

(declare (foreign-declare "extern vtk_wrap_VTK_BIT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-bit-min (##core#primitive "vtk_wrap_VTK_BIT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_BIT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-bit-max (##core#primitive "vtk_wrap_VTK_BIT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_CHAR_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-char-min (##core#primitive "vtk_wrap_VTK_CHAR_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_CHAR_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-char-max (##core#primitive "vtk_wrap_VTK_CHAR_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_CHAR_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-char-min (##core#primitive "vtk_wrap_VTK_UNSIGNED_CHAR_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_CHAR_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-char-max (##core#primitive "vtk_wrap_VTK_UNSIGNED_CHAR_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_SHORT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-short-min (##core#primitive "vtk_wrap_VTK_SHORT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_SHORT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-short-max (##core#primitive "vtk_wrap_VTK_SHORT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_SHORT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-short-min (##core#primitive "vtk_wrap_VTK_UNSIGNED_SHORT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_SHORT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-short-max (##core#primitive "vtk_wrap_VTK_UNSIGNED_SHORT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_INT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-int-min (##core#primitive "vtk_wrap_VTK_INT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_INT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-int-max (##core#primitive "vtk_wrap_VTK_INT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_INT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-int-min (##core#primitive "vtk_wrap_VTK_UNSIGNED_INT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_INT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-int-max (##core#primitive "vtk_wrap_VTK_UNSIGNED_INT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_LONG_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-long-min (##core#primitive "vtk_wrap_VTK_LONG_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_LONG_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-long-max (##core#primitive "vtk_wrap_VTK_LONG_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_LONG_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-long-min (##core#primitive "vtk_wrap_VTK_UNSIGNED_LONG_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSIGNED_LONG_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unsigned-long-max (##core#primitive "vtk_wrap_VTK_UNSIGNED_LONG_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_FLOAT_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-float-min (##core#primitive "vtk_wrap_VTK_FLOAT_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_FLOAT_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-float-max (##core#primitive "vtk_wrap_VTK_FLOAT_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_DOUBLE_MIN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-double-min (##core#primitive "vtk_wrap_VTK_DOUBLE_MIN"))

(declare (foreign-declare "extern vtk_wrap_VTK_DOUBLE_MAX(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-double-max (##core#primitive "vtk_wrap_VTK_DOUBLE_MAX"))

(declare (foreign-declare "extern vtk_wrap_VTK_POLY_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-poly-data (##core#primitive "vtk_wrap_VTK_POLY_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_STRUCTURED_POINTS(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-structured-points (##core#primitive "vtk_wrap_VTK_STRUCTURED_POINTS"))

(declare (foreign-declare "extern vtk_wrap_VTK_STRUCTURED_GRID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-structured-grid (##core#primitive "vtk_wrap_VTK_STRUCTURED_GRID"))

(declare (foreign-declare "extern vtk_wrap_VTK_RECTILINEAR_GRID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-rectilinear-grid (##core#primitive "vtk_wrap_VTK_RECTILINEAR_GRID"))

(declare (foreign-declare "extern vtk_wrap_VTK_UNSTRUCTURED_GRID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-unstructured-grid (##core#primitive "vtk_wrap_VTK_UNSTRUCTURED_GRID"))

(declare (foreign-declare "extern vtk_wrap_VTK_PIECEWISE_FUNCTION(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-piecewise-function (##core#primitive "vtk_wrap_VTK_PIECEWISE_FUNCTION"))

(declare (foreign-declare "extern vtk_wrap_VTK_IMAGE_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-image-data (##core#primitive "vtk_wrap_VTK_IMAGE_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_DATA_OBJECT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-data-object (##core#primitive "vtk_wrap_VTK_DATA_OBJECT"))

(declare (foreign-declare "extern vtk_wrap_VTK_DATA_SET(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-data-set (##core#primitive "vtk_wrap_VTK_DATA_SET"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkOutputWindowDisplayText(int,C_word,C_word,C_word);"))
(define vtk-vtk-output-window-display-text (##core#primitive "vtk_wrap_vtkOutputWindowDisplayText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkOutputWindowDisplayErrorText(int,C_word,C_word,C_word);"))
(define vtk-vtk-output-window-display-error-text (##core#primitive "vtk_wrap_vtkOutputWindowDisplayErrorText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkOutputWindowDisplayWarningText(int,C_word,C_word,C_word);"))
(define vtk-vtk-output-window-display-warning-text (##core#primitive "vtk_wrap_vtkOutputWindowDisplayWarningText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkOutputWindowDisplayGenericWarningText(int,C_word,C_word,C_word);"))
(define vtk-vtk-output-window-display-generic-warning-text (##core#primitive "vtk_wrap_vtkOutputWindowDisplayGenericWarningText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkOutputWindowDisplayDebugText(int,C_word,C_word,C_word);"))
(define vtk-vtk-output-window-display-debug-text (##core#primitive "vtk_wrap_vtkOutputWindowDisplayDebugText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-get-class-name (##core#primitive "vtk_wrap_vtkObject_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-is-type-of (##core#primitive "vtk_wrap_vtkObject_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-is-a (##core#primitive "vtk_wrap_vtkObject_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-safe-down-cast (##core#primitive "vtk_wrap_vtkObject_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_Delete(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-delete (##core#primitive "vtk_wrap_vtkObject_Delete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_New(int,C_word,C_word);"))
(define vtk-vtk-object-new (##core#primitive "vtk_wrap_vtkObject_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_DebugOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-debug-on (##core#primitive "vtk_wrap_vtkObject_DebugOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_DebugOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-debug-off (##core#primitive "vtk_wrap_vtkObject_DebugOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GetDebug(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-get-debug (##core#primitive "vtk_wrap_vtkObject_GetDebug"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_SetDebug(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-set-debug (##core#primitive "vtk_wrap_vtkObject_SetDebug"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_BreakOnError(int,C_word,C_word);"))
(define vtk-vtk-object-break-on-error (##core#primitive "vtk_wrap_vtkObject_BreakOnError"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_Modified(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-modified (##core#primitive "vtk_wrap_vtkObject_Modified"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-get-m-time (##core#primitive "vtk_wrap_vtkObject_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_Print(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-print (##core#primitive "vtk_wrap_vtkObject_Print"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-print-self (##core#primitive "vtk_wrap_vtkObject_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_PrintHeader(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-print-header (##core#primitive "vtk_wrap_vtkObject_PrintHeader"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_PrintTrailer(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-print-trailer (##core#primitive "vtk_wrap_vtkObject_PrintTrailer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_SetGlobalWarningDisplay(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-set-global-warning-display (##core#primitive "vtk_wrap_vtkObject_SetGlobalWarningDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GlobalWarningDisplayOn(int,C_word,C_word);"))
(define vtk-vtk-object-global-warning-display-on (##core#primitive "vtk_wrap_vtkObject_GlobalWarningDisplayOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GlobalWarningDisplayOff(int,C_word,C_word);"))
(define vtk-vtk-object-global-warning-display-off (##core#primitive "vtk_wrap_vtkObject_GlobalWarningDisplayOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GetGlobalWarningDisplay(int,C_word,C_word);"))
(define vtk-vtk-object-get-global-warning-display (##core#primitive "vtk_wrap_vtkObject_GetGlobalWarningDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_Register(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-register (##core#primitive "vtk_wrap_vtkObject_Register"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-un-register (##core#primitive "vtk_wrap_vtkObject_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GetReferenceCount(int,C_word,C_word,C_word);"))
(define vtk-vtk-object-get-reference-count (##core#primitive "vtk_wrap_vtkObject_GetReferenceCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_SetReferenceCount(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-set-reference-count (##core#primitive "vtk_wrap_vtkObject_SetReferenceCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_GetCommand(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-get-command (##core#primitive "vtk_wrap_vtkObject_GetCommand"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkObject_RemoveObserver(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-object-remove-observer (##core#primitive "vtk_wrap_vtkObject_RemoveObserver"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-class-name (##core#primitive "vtk_wrap_vtkDataArray_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-is-type-of (##core#primitive "vtk_wrap_vtkDataArray_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-is-a (##core#primitive "vtk_wrap_vtkDataArray_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-safe-down-cast (##core#primitive "vtk_wrap_vtkDataArray_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-print-self (##core#primitive "vtk_wrap_vtkDataArray_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-allocate (##core#primitive "vtk_wrap_vtkDataArray_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-initialize (##core#primitive "vtk_wrap_vtkDataArray_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-make-object (##core#primitive "vtk_wrap_vtkDataArray_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetDataType(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-data-type (##core#primitive "vtk_wrap_vtkDataArray_GetDataType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetNumberOfComponents(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-number-of-components (##core#primitive "vtk_wrap_vtkDataArray_SetNumberOfComponents"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetNumberOfComponentsMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-number-of-components-min-value (##core#primitive "vtk_wrap_vtkDataArray_GetNumberOfComponentsMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetNumberOfComponentsMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-number-of-components-max-value (##core#primitive "vtk_wrap_vtkDataArray_GetNumberOfComponentsMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetNumberOfComponents(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-number-of-components (##core#primitive "vtk_wrap_vtkDataArray_GetNumberOfComponents"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetNumberOfTuples(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-number-of-tuples (##core#primitive "vtk_wrap_vtkDataArray_SetNumberOfTuples"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetNumberOfTuples(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-number-of-tuples (##core#primitive "vtk_wrap_vtkDataArray_GetNumberOfTuples"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetTuple1(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-tuple1 (##core#primitive "vtk_wrap_vtkDataArray_GetTuple1"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetTuple2(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-tuple2 (##core#primitive "vtk_wrap_vtkDataArray_GetTuple2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetTuple3(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-tuple3 (##core#primitive "vtk_wrap_vtkDataArray_GetTuple3"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetTuple4(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-tuple4 (##core#primitive "vtk_wrap_vtkDataArray_GetTuple4"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetTuple9(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-tuple9 (##core#primitive "vtk_wrap_vtkDataArray_GetTuple9"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetTuple1(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-tuple1 (##core#primitive "vtk_wrap_vtkDataArray_SetTuple1"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetTuple2(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-tuple2 (##core#primitive "vtk_wrap_vtkDataArray_SetTuple2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetTuple3(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-tuple3 (##core#primitive "vtk_wrap_vtkDataArray_SetTuple3"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetTuple4(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-tuple4 (##core#primitive "vtk_wrap_vtkDataArray_SetTuple4"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetTuple9(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-tuple9 (##core#primitive "vtk_wrap_vtkDataArray_SetTuple9"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertTuple1(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-tuple1 (##core#primitive "vtk_wrap_vtkDataArray_InsertTuple1"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertTuple2(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-tuple2 (##core#primitive "vtk_wrap_vtkDataArray_InsertTuple2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertTuple3(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-tuple3 (##core#primitive "vtk_wrap_vtkDataArray_InsertTuple3"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertTuple4(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-tuple4 (##core#primitive "vtk_wrap_vtkDataArray_InsertTuple4"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertTuple9(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-tuple9 (##core#primitive "vtk_wrap_vtkDataArray_InsertTuple9"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertNextTuple1(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-next-tuple1 (##core#primitive "vtk_wrap_vtkDataArray_InsertNextTuple1"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertNextTuple2(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-next-tuple2 (##core#primitive "vtk_wrap_vtkDataArray_InsertNextTuple2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertNextTuple3(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-next-tuple3 (##core#primitive "vtk_wrap_vtkDataArray_InsertNextTuple3"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertNextTuple4(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-next-tuple4 (##core#primitive "vtk_wrap_vtkDataArray_InsertNextTuple4"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertNextTuple9(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-next-tuple9 (##core#primitive "vtk_wrap_vtkDataArray_InsertNextTuple9"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetComponent(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-component (##core#primitive "vtk_wrap_vtkDataArray_GetComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetComponent(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-component (##core#primitive "vtk_wrap_vtkDataArray_SetComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_InsertComponent(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-insert-component (##core#primitive "vtk_wrap_vtkDataArray_InsertComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetData(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-data (##core#primitive "vtk_wrap_vtkDataArray_GetData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-deep-copy (##core#primitive "vtk_wrap_vtkDataArray_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_FillComponent(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-fill-component (##core#primitive "vtk_wrap_vtkDataArray_FillComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_CopyComponent(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-copy-component (##core#primitive "vtk_wrap_vtkDataArray_CopyComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetVoidPointer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-void-pointer (##core#primitive "vtk_wrap_vtkDataArray_GetVoidPointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-squeeze (##core#primitive "vtk_wrap_vtkDataArray_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_Resize(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-resize (##core#primitive "vtk_wrap_vtkDataArray_Resize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-reset (##core#primitive "vtk_wrap_vtkDataArray_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-size (##core#primitive "vtk_wrap_vtkDataArray_GetSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetMaxId(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-max-id (##core#primitive "vtk_wrap_vtkDataArray_GetMaxId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetVoidArray(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-void-array (##core#primitive "vtk_wrap_vtkDataArray_SetVoidArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-actual-memory-size (##core#primitive "vtk_wrap_vtkDataArray_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_CreateDefaultLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-create-default-lookup-table (##core#primitive "vtk_wrap_vtkDataArray_CreateDefaultLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetLookupTable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-lookup-table (##core#primitive "vtk_wrap_vtkDataArray_SetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-lookup-table (##core#primitive "vtk_wrap_vtkDataArray_GetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_SetName(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-set-name (##core#primitive "vtk_wrap_vtkDataArray_SetName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetName(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-name (##core#primitive "vtk_wrap_vtkDataArray_GetName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_ComputeRange(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-compute-range (##core#primitive "vtk_wrap_vtkDataArray_ComputeRange"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetDataTypeRange(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-data-type-range (##core#primitive "vtk_wrap_vtkDataArray_GetDataTypeRange"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetDataTypeMin(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-data-type-min (##core#primitive "vtk_wrap_vtkDataArray_GetDataTypeMin"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetDataTypeMax(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-data-type-max (##core#primitive "vtk_wrap_vtkDataArray_GetDataTypeMax"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_GetMaxNorm(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-get-max-norm (##core#primitive "vtk_wrap_vtkDataArray_GetMaxNorm"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataArray_CreateDataArray(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-array-create-data-array (##core#primitive "vtk_wrap_vtkDataArray_CreateDataArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_New(int,C_word,C_word);"))
(define vtk-vtk-id-list-new (##core#primitive "vtk_wrap_vtkIdList_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-initialize (##core#primitive "vtk_wrap_vtkIdList_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-allocate (##core#primitive "vtk_wrap_vtkIdList_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-get-class-name (##core#primitive "vtk_wrap_vtkIdList_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-is-type-of (##core#primitive "vtk_wrap_vtkIdList_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-is-a (##core#primitive "vtk_wrap_vtkIdList_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-safe-down-cast (##core#primitive "vtk_wrap_vtkIdList_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-print-self (##core#primitive "vtk_wrap_vtkIdList_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_GetNumberOfIds(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-get-number-of-ids (##core#primitive "vtk_wrap_vtkIdList_GetNumberOfIds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_GetId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-get-id (##core#primitive "vtk_wrap_vtkIdList_GetId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_SetNumberOfIds(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-set-number-of-ids (##core#primitive "vtk_wrap_vtkIdList_SetNumberOfIds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_SetId(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-set-id (##core#primitive "vtk_wrap_vtkIdList_SetId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_InsertId(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-insert-id (##core#primitive "vtk_wrap_vtkIdList_InsertId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_InsertNextId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-insert-next-id (##core#primitive "vtk_wrap_vtkIdList_InsertNextId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_InsertUniqueId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-insert-unique-id (##core#primitive "vtk_wrap_vtkIdList_InsertUniqueId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_GetPointer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-get-pointer (##core#primitive "vtk_wrap_vtkIdList_GetPointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_WritePointer(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-write-pointer (##core#primitive "vtk_wrap_vtkIdList_WritePointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-reset (##core#primitive "vtk_wrap_vtkIdList_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-squeeze (##core#primitive "vtk_wrap_vtkIdList_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-deep-copy (##core#primitive "vtk_wrap_vtkIdList_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_DeleteId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-delete-id (##core#primitive "vtk_wrap_vtkIdList_DeleteId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_IsId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-is-id (##core#primitive "vtk_wrap_vtkIdList_IsId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkIdList_IntersectWith(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-id-list-intersect-with (##core#primitive "vtk_wrap_vtkIdList_IntersectWith"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_New(int,C_word,C_word);"))
(define vtk-vtk-field-data-new (##core#primitive "vtk_wrap_vtkFieldData_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-class-name (##core#primitive "vtk_wrap_vtkFieldData_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-is-type-of (##core#primitive "vtk_wrap_vtkFieldData_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-is-a (##core#primitive "vtk_wrap_vtkFieldData_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-safe-down-cast (##core#primitive "vtk_wrap_vtkFieldData_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-print-self (##core#primitive "vtk_wrap_vtkFieldData_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-initialize (##core#primitive "vtk_wrap_vtkFieldData_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-allocate (##core#primitive "vtk_wrap_vtkFieldData_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-make-object (##core#primitive "vtk_wrap_vtkFieldData_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_AllocateArrays(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-allocate-arrays (##core#primitive "vtk_wrap_vtkFieldData_AllocateArrays"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_SetNumberOfArrays(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-set-number-of-arrays (##core#primitive "vtk_wrap_vtkFieldData_SetNumberOfArrays"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetNumberOfArrays(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-number-of-arrays (##core#primitive "vtk_wrap_vtkFieldData_GetNumberOfArrays"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_AddArray(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-add-array (##core#primitive "vtk_wrap_vtkFieldData_AddArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_RemoveArray(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-remove-array (##core#primitive "vtk_wrap_vtkFieldData_RemoveArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetArrayName(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-array-name (##core#primitive "vtk_wrap_vtkFieldData_GetArrayName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_PassData(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-pass-data (##core#primitive "vtk_wrap_vtkFieldData_PassData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_CopyFieldOn(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-copy-field-on (##core#primitive "vtk_wrap_vtkFieldData_CopyFieldOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_CopyFieldOff(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-copy-field-off (##core#primitive "vtk_wrap_vtkFieldData_CopyFieldOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_CopyAllOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-copy-all-on (##core#primitive "vtk_wrap_vtkFieldData_CopyAllOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_CopyAllOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-copy-all-off (##core#primitive "vtk_wrap_vtkFieldData_CopyAllOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-deep-copy (##core#primitive "vtk_wrap_vtkFieldData_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-shallow-copy (##core#primitive "vtk_wrap_vtkFieldData_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-squeeze (##core#primitive "vtk_wrap_vtkFieldData_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-reset (##core#primitive "vtk_wrap_vtkFieldData_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-actual-memory-size (##core#primitive "vtk_wrap_vtkFieldData_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-m-time (##core#primitive "vtk_wrap_vtkFieldData_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetField(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-field (##core#primitive "vtk_wrap_vtkFieldData_GetField"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetArrayContainingComponent(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-array-containing-component (##core#primitive "vtk_wrap_vtkFieldData_GetArrayContainingComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetNumberOfComponents(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-number-of-components (##core#primitive "vtk_wrap_vtkFieldData_GetNumberOfComponents"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetNumberOfTuples(int,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-number-of-tuples (##core#primitive "vtk_wrap_vtkFieldData_GetNumberOfTuples"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_SetNumberOfTuples(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-set-number-of-tuples (##core#primitive "vtk_wrap_vtkFieldData_SetNumberOfTuples"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_SetTuple(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-set-tuple (##core#primitive "vtk_wrap_vtkFieldData_SetTuple"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_InsertTuple(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-insert-tuple (##core#primitive "vtk_wrap_vtkFieldData_InsertTuple"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_InsertNextTuple(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-insert-next-tuple (##core#primitive "vtk_wrap_vtkFieldData_InsertNextTuple"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_GetComponent(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-get-component (##core#primitive "vtk_wrap_vtkFieldData_GetComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_SetComponent(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-set-component (##core#primitive "vtk_wrap_vtkFieldData_SetComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkFieldData_InsertComponent(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-field-data-insert-component (##core#primitive "vtk_wrap_vtkFieldData_InsertComponent"))

(declare (foreign-declare "extern vtk_wrap_VTK_PIECES_EXTENT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-pieces-extent (##core#primitive "vtk_wrap_VTK_PIECES_EXTENT"))

(declare (foreign-declare "extern vtk_wrap_VTK_3D_EXTENT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-3d-extent (##core#primitive "vtk_wrap_VTK_3D_EXTENT"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_New(int,C_word,C_word);"))
(define vtk-vtk-data-object-new (##core#primitive "vtk_wrap_vtkDataObject_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-class-name (##core#primitive "vtk_wrap_vtkDataObject_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-is-type-of (##core#primitive "vtk_wrap_vtkDataObject_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-is-a (##core#primitive "vtk_wrap_vtkDataObject_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-safe-down-cast (##core#primitive "vtk_wrap_vtkDataObject_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-print-self (##core#primitive "vtk_wrap_vtkDataObject_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-make-object (##core#primitive "vtk_wrap_vtkDataObject_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetSource(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-source (##core#primitive "vtk_wrap_vtkDataObject_GetSource"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetSource(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-source (##core#primitive "vtk_wrap_vtkDataObject_SetSource"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-m-time (##core#primitive "vtk_wrap_vtkDataObject_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-initialize (##core#primitive "vtk_wrap_vtkDataObject_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_ReleaseData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-release-data (##core#primitive "vtk_wrap_vtkDataObject_ReleaseData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Should_I_Release_Data(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-should-i-release-data (##core#primitive "vtk_wrap_vtkDataObject_Should_I_Release_Data"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetDataReleased(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-data-released (##core#primitive "vtk_wrap_vtkDataObject_GetDataReleased"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetReleaseDataFlag(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-release-data-flag (##core#primitive "vtk_wrap_vtkDataObject_SetReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetReleaseDataFlag(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-release-data-flag (##core#primitive "vtk_wrap_vtkDataObject_GetReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_ReleaseDataFlagOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-release-data-flag-on (##core#primitive "vtk_wrap_vtkDataObject_ReleaseDataFlagOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_ReleaseDataFlagOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-release-data-flag-off (##core#primitive "vtk_wrap_vtkDataObject_ReleaseDataFlagOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetGlobalReleaseDataFlag(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-global-release-data-flag (##core#primitive "vtk_wrap_vtkDataObject_SetGlobalReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GlobalReleaseDataFlagOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-global-release-data-flag-on (##core#primitive "vtk_wrap_vtkDataObject_GlobalReleaseDataFlagOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GlobalReleaseDataFlagOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-global-release-data-flag-off (##core#primitive "vtk_wrap_vtkDataObject_GlobalReleaseDataFlagOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetGlobalReleaseDataFlag(int,C_word,C_word);"))
(define vtk-vtk-data-object-get-global-release-data-flag (##core#primitive "vtk_wrap_vtkDataObject_GetGlobalReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetFieldData(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-field-data (##core#primitive "vtk_wrap_vtkDataObject_SetFieldData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetFieldData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-field-data (##core#primitive "vtk_wrap_vtkDataObject_GetFieldData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-un-register (##core#primitive "vtk_wrap_vtkDataObject_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetNetReferenceCount(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-net-reference-count (##core#primitive "vtk_wrap_vtkDataObject_GetNetReferenceCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-update (##core#primitive "vtk_wrap_vtkDataObject_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_UpdateInformation(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-update-information (##core#primitive "vtk_wrap_vtkDataObject_UpdateInformation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_PropagateUpdateExtent(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-propagate-update-extent (##core#primitive "vtk_wrap_vtkDataObject_PropagateUpdateExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_TriggerAsynchronousUpdate(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-trigger-asynchronous-update (##core#primitive "vtk_wrap_vtkDataObject_TriggerAsynchronousUpdate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_UpdateData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-update-data (##core#primitive "vtk_wrap_vtkDataObject_UpdateData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetEstimatedMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-estimated-memory-size (##core#primitive "vtk_wrap_vtkDataObject_GetEstimatedMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetDataObjectType(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-data-object-type (##core#primitive "vtk_wrap_vtkDataObject_GetDataObjectType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetUpdateTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-update-time (##core#primitive "vtk_wrap_vtkDataObject_GetUpdateTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetUpdateExtentToWholeExtent(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-update-extent-to-whole-extent (##core#primitive "vtk_wrap_vtkDataObject_SetUpdateExtentToWholeExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Set_Pipeline_M_Time(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-pipeline-m-time (##core#primitive "vtk_wrap_vtkDataObject_Set_Pipeline_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_Get_Pipeline_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-pipeline-m-time (##core#primitive "vtk_wrap_vtkDataObject_Get_Pipeline_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-actual-memory-size (##core#primitive "vtk_wrap_vtkDataObject_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_CopyInformation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-copy-information (##core#primitive "vtk_wrap_vtkDataObject_CopyInformation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_CopyTypeSpecificInformation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-copy-type-specific-information (##core#primitive "vtk_wrap_vtkDataObject_CopyTypeSpecificInformation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetUpdatePiece(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-update-piece (##core#primitive "vtk_wrap_vtkDataObject_SetUpdatePiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetUpdateNumberOfPieces(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-update-number-of-pieces (##core#primitive "vtk_wrap_vtkDataObject_SetUpdateNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetUpdatePiece(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-update-piece (##core#primitive "vtk_wrap_vtkDataObject_GetUpdatePiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetUpdateNumberOfPieces(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-update-number-of-pieces (##core#primitive "vtk_wrap_vtkDataObject_GetUpdateNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetUpdateGhostLevel(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-update-ghost-level (##core#primitive "vtk_wrap_vtkDataObject_SetUpdateGhostLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetUpdateGhostLevel(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-update-ghost-level (##core#primitive "vtk_wrap_vtkDataObject_GetUpdateGhostLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetRequestExactExtent(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-request-exact-extent (##core#primitive "vtk_wrap_vtkDataObject_SetRequestExactExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetRequestExactExtent(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-request-exact-extent (##core#primitive "vtk_wrap_vtkDataObject_GetRequestExactExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_RequestExactExtentOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-request-exact-extent-on (##core#primitive "vtk_wrap_vtkDataObject_RequestExactExtentOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_RequestExactExtentOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-request-exact-extent-off (##core#primitive "vtk_wrap_vtkDataObject_RequestExactExtentOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetMaximumNumberOfPieces(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-maximum-number-of-pieces (##core#primitive "vtk_wrap_vtkDataObject_SetMaximumNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetMaximumNumberOfPieces(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-maximum-number-of-pieces (##core#primitive "vtk_wrap_vtkDataObject_GetMaximumNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_DataHasBeenGenerated(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-data-has-been-generated (##core#primitive "vtk_wrap_vtkDataObject_DataHasBeenGenerated"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_PrepareForNewData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-prepare-for-new-data (##core#primitive "vtk_wrap_vtkDataObject_PrepareForNewData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-shallow-copy (##core#primitive "vtk_wrap_vtkDataObject_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-deep-copy (##core#primitive "vtk_wrap_vtkDataObject_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetLocality(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-locality (##core#primitive "vtk_wrap_vtkDataObject_SetLocality"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetLocality(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-locality (##core#primitive "vtk_wrap_vtkDataObject_GetLocality"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_SetExtentTranslator(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-set-extent-translator (##core#primitive "vtk_wrap_vtkDataObject_SetExtentTranslator"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetExtentTranslator(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-extent-translator (##core#primitive "vtk_wrap_vtkDataObject_GetExtentTranslator"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetNumberOfConsumers(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-number-of-consumers (##core#primitive "vtk_wrap_vtkDataObject_GetNumberOfConsumers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_AddConsumer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-add-consumer (##core#primitive "vtk_wrap_vtkDataObject_AddConsumer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_RemoveConsumer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-remove-consumer (##core#primitive "vtk_wrap_vtkDataObject_RemoveConsumer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_GetConsumer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-get-consumer (##core#primitive "vtk_wrap_vtkDataObject_GetConsumer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataObject_IsConsumer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-object-is-consumer (##core#primitive "vtk_wrap_vtkDataObject_IsConsumer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_New(int,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-new (##core#primitive "vtk_wrap_vtkDataSetAttributes_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-class-name (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-is-type-of (##core#primitive "vtk_wrap_vtkDataSetAttributes_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-is-a (##core#primitive "vtk_wrap_vtkDataSetAttributes_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-safe-down-cast (##core#primitive "vtk_wrap_vtkDataSetAttributes_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-print-self (##core#primitive "vtk_wrap_vtkDataSetAttributes_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-initialize (##core#primitive "vtk_wrap_vtkDataSetAttributes_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-update (##core#primitive "vtk_wrap_vtkDataSetAttributes_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_PassData(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-pass-data (##core#primitive "vtk_wrap_vtkDataSetAttributes_PassData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyAllocate(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-allocate (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyAllocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyData(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-data (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_InterpolateAllocate(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-interpolate-allocate (##core#primitive "vtk_wrap_vtkDataSetAttributes_InterpolateAllocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_InterpolatePoint(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-interpolate-point (##core#primitive "vtk_wrap_vtkDataSetAttributes_InterpolatePoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_InterpolateEdge(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-interpolate-edge (##core#primitive "vtk_wrap_vtkDataSetAttributes_InterpolateEdge"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_InterpolateTime(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-interpolate-time (##core#primitive "vtk_wrap_vtkDataSetAttributes_InterpolateTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-deep-copy (##core#primitive "vtk_wrap_vtkDataSetAttributes_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-shallow-copy (##core#primitive "vtk_wrap_vtkDataSetAttributes_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetScalars(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-scalars (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetActiveScalars(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-active-scalars (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetActiveScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetScalars(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-scalars (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetVectors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-vectors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetVectors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetActiveVectors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-active-vectors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetActiveVectors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetVectors(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-vectors (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetVectors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetNormals(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-normals (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetActiveNormals(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-active-normals (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetActiveNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetNormals(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-normals (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Set_T_Coords(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-t-coords (##core#primitive "vtk_wrap_vtkDataSetAttributes_Set_T_Coords"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Set_Active_T_Coords(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-active-t-coords (##core#primitive "vtk_wrap_vtkDataSetAttributes_Set_Active_T_Coords"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Get_T_Coords(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-t-coords (##core#primitive "vtk_wrap_vtkDataSetAttributes_Get_T_Coords"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetTensors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-tensors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetTensors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetActiveTensors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-active-tensors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetActiveTensors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetTensors(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-tensors (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetTensors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetCopyAttribute(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-attribute (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetCopyAttribute"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetCopyScalars(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-scalars (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetCopyScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetCopyScalars(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-copy-scalars (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetCopyScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyScalarsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-scalars-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyScalarsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyScalarsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-scalars-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyScalarsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetCopyVectors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-vectors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetCopyVectors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetCopyVectors(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-copy-vectors (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetCopyVectors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyVectorsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-vectors-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyVectorsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyVectorsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-vectors-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyVectorsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetCopyNormals(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-normals (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetCopyNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetCopyNormals(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-copy-normals (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetCopyNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyNormalsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-normals-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyNormalsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyNormalsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-normals-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyNormalsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Set_Copy_T_Coords(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-t-coords (##core#primitive "vtk_wrap_vtkDataSetAttributes_Set_Copy_T_Coords"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_Get_Copy_T_Coords(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-copy-t-coords (##core#primitive "vtk_wrap_vtkDataSetAttributes_Get_Copy_T_Coords"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyTCoordsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-tc-oords-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyTCoordsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyTCoordsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-tc-oords-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyTCoordsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_SetCopyTensors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-set-copy-tensors (##core#primitive "vtk_wrap_vtkDataSetAttributes_SetCopyTensors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetCopyTensors(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-copy-tensors (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetCopyTensors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyTensorsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-tensors-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyTensorsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyTensorsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-tensors-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyTensorsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyAllOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-all-on (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyAllOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyAllOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-all-off (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyAllOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_CopyTuple(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-copy-tuple (##core#primitive "vtk_wrap_vtkDataSetAttributes_CopyTuple"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetAttributeIndices(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-attribute-indices (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetAttributeIndices"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_IsArrayAnAttribute(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-is-array-an-attribute (##core#primitive "vtk_wrap_vtkDataSetAttributes_IsArrayAnAttribute"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_GetAttribute(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-get-attribute (##core#primitive "vtk_wrap_vtkDataSetAttributes_GetAttribute"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSetAttributes_RemoveArray(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-attributes-remove-array (##core#primitive "vtk_wrap_vtkDataSetAttributes_RemoveArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_New(int,C_word,C_word);"))
(define vtk-vtk-cell-data-new (##core#primitive "vtk_wrap_vtkCellData_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-data-get-class-name (##core#primitive "vtk_wrap_vtkCellData_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-data-is-type-of (##core#primitive "vtk_wrap_vtkCellData_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-data-is-a (##core#primitive "vtk_wrap_vtkCellData_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-data-safe-down-cast (##core#primitive "vtk_wrap_vtkCellData_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellData_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-data-print-self (##core#primitive "vtk_wrap_vtkCellData_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_New(int,C_word,C_word);"))
(define vtk-vtk-point-data-new (##core#primitive "vtk_wrap_vtkPointData_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-get-class-name (##core#primitive "vtk_wrap_vtkPointData_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-is-type-of (##core#primitive "vtk_wrap_vtkPointData_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-is-a (##core#primitive "vtk_wrap_vtkPointData_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-safe-down-cast (##core#primitive "vtk_wrap_vtkPointData_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-print-self (##core#primitive "vtk_wrap_vtkPointData_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointData_NullPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-data-null-point (##core#primitive "vtk_wrap_vtkPointData_NullPoint"))

(declare (foreign-declare "extern vtk_wrap_VTK_CELL_SIZE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-cell-size (##core#primitive "vtk_wrap_VTK_CELL_SIZE"))

(declare (foreign-declare "extern vtk_wrap_VTK_TOL(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-tol (##core#primitive "vtk_wrap_VTK_TOL"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-class-name (##core#primitive "vtk_wrap_vtkCell_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-is-type-of (##core#primitive "vtk_wrap_vtkCell_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-is-a (##core#primitive "vtk_wrap_vtkCell_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-safe-down-cast (##core#primitive "vtk_wrap_vtkCell_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-print-self (##core#primitive "vtk_wrap_vtkCell_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Initialize(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-initialize (##core#primitive "vtk_wrap_vtkCell_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-make-object (##core#primitive "vtk_wrap_vtkCell_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-shallow-copy (##core#primitive "vtk_wrap_vtkCell_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-deep-copy (##core#primitive "vtk_wrap_vtkCell_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetCellType(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-cell-type (##core#primitive "vtk_wrap_vtkCell_GetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetCellDimension(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-cell-dimension (##core#primitive "vtk_wrap_vtkCell_GetCellDimension"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetInterpolationOrder(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-interpolation-order (##core#primitive "vtk_wrap_vtkCell_GetInterpolationOrder"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-points (##core#primitive "vtk_wrap_vtkCell_GetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetNumberOfPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-number-of-points (##core#primitive "vtk_wrap_vtkCell_GetNumberOfPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetNumberOfEdges(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-number-of-edges (##core#primitive "vtk_wrap_vtkCell_GetNumberOfEdges"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetNumberOfFaces(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-number-of-faces (##core#primitive "vtk_wrap_vtkCell_GetNumberOfFaces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetPointIds(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-point-ids (##core#primitive "vtk_wrap_vtkCell_GetPointIds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetPointId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-point-id (##core#primitive "vtk_wrap_vtkCell_GetPointId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetEdge(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-edge (##core#primitive "vtk_wrap_vtkCell_GetEdge"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetFace(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-face (##core#primitive "vtk_wrap_vtkCell_GetFace"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_CellBoundary(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-cell-boundary (##core#primitive "vtk_wrap_vtkCell_CellBoundary"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_EvaluatePosition(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-evaluate-position (##core#primitive "vtk_wrap_vtkCell_EvaluatePosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_EvaluateLocation(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-evaluate-location (##core#primitive "vtk_wrap_vtkCell_EvaluateLocation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Contour(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-contour (##core#primitive "vtk_wrap_vtkCell_Contour"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Clip(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-clip (##core#primitive "vtk_wrap_vtkCell_Clip"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_IntersectWithLine(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-intersect-with-line (##core#primitive "vtk_wrap_vtkCell_IntersectWithLine"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Triangulate(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-triangulate (##core#primitive "vtk_wrap_vtkCell_Triangulate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Derivatives(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-derivatives (##core#primitive "vtk_wrap_vtkCell_Derivatives"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetLength2(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-length2 (##core#primitive "vtk_wrap_vtkCell_GetLength2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_GetParametricCenter(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-get-parametric-center (##core#primitive "vtk_wrap_vtkCell_GetParametricCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Hit_B_Box(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-hit-b-box (##core#primitive "vtk_wrap_vtkCell_Hit_B_Box"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Points_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-points-set (##core#primitive "vtk_wrap_vtkCell_Points_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_Points_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-points-get (##core#primitive "vtk_wrap_vtkCell_Points_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_PointIds_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-point-ids-set (##core#primitive "vtk_wrap_vtkCell_PointIds_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCell_PointIds_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-point-ids-get (##core#primitive "vtk_wrap_vtkCell_PointIds_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_New(int,C_word,C_word);"))
(define vtk-vtk-generic-cell-new (##core#primitive "vtk_wrap_vtkGenericCell_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-class-name (##core#primitive "vtk_wrap_vtkGenericCell_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-is-type-of (##core#primitive "vtk_wrap_vtkGenericCell_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-is-a (##core#primitive "vtk_wrap_vtkGenericCell_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-safe-down-cast (##core#primitive "vtk_wrap_vtkGenericCell_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-make-object (##core#primitive "vtk_wrap_vtkGenericCell_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-shallow-copy (##core#primitive "vtk_wrap_vtkGenericCell_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-deep-copy (##core#primitive "vtk_wrap_vtkGenericCell_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetCellType(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-cell-type (##core#primitive "vtk_wrap_vtkGenericCell_GetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetCellDimension(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-cell-dimension (##core#primitive "vtk_wrap_vtkGenericCell_GetCellDimension"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetInterpolationOrder(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-interpolation-order (##core#primitive "vtk_wrap_vtkGenericCell_GetInterpolationOrder"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetNumberOfEdges(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-number-of-edges (##core#primitive "vtk_wrap_vtkGenericCell_GetNumberOfEdges"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetNumberOfFaces(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-number-of-faces (##core#primitive "vtk_wrap_vtkGenericCell_GetNumberOfFaces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetEdge(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-edge (##core#primitive "vtk_wrap_vtkGenericCell_GetEdge"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetFace(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-face (##core#primitive "vtk_wrap_vtkGenericCell_GetFace"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_CellBoundary(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-cell-boundary (##core#primitive "vtk_wrap_vtkGenericCell_CellBoundary"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_EvaluatePosition(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-evaluate-position (##core#primitive "vtk_wrap_vtkGenericCell_EvaluatePosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_EvaluateLocation(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-evaluate-location (##core#primitive "vtk_wrap_vtkGenericCell_EvaluateLocation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_Contour(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-contour (##core#primitive "vtk_wrap_vtkGenericCell_Contour"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_Clip(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-clip (##core#primitive "vtk_wrap_vtkGenericCell_Clip"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_IntersectWithLine(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-intersect-with-line (##core#primitive "vtk_wrap_vtkGenericCell_IntersectWithLine"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_Triangulate(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-triangulate (##core#primitive "vtk_wrap_vtkGenericCell_Triangulate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_Derivatives(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-derivatives (##core#primitive "vtk_wrap_vtkGenericCell_Derivatives"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_GetParametricCenter(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-get-parametric-center (##core#primitive "vtk_wrap_vtkGenericCell_GetParametricCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type (##core#primitive "vtk_wrap_vtkGenericCell_SetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToEmptyCell(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-empty-cell (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToEmptyCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToVertex(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-vertex (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToVertex"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToPolyVertex(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-poly-vertex (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToPolyVertex"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToLine(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-line (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToLine"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToPolyLine(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-poly-line (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToPolyLine"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToTriangle(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-triangle (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToTriangle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToTriangleStrip(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-triangle-strip (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToTriangleStrip"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToPolygon(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-polygon (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToPolygon"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToPixel(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-pixel (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToPixel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToQuad(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-quad (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToQuad"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToTetra(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-tetra (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToTetra"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToVoxel(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-voxel (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToVoxel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToHexahedron(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-hexahedron (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToHexahedron"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToWedge(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-wedge (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToWedge"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGenericCell_SetCellTypeToPyramid(int,C_word,C_word,C_word);"))
(define vtk-vtk-generic-cell-set-cell-type-to-pyramid (##core#primitive "vtk_wrap_vtkGenericCell_SetCellTypeToPyramid"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_New(int,C_word,C_word);"))
(define vtk-vtk-cell-types-new (##core#primitive "vtk_wrap_vtkCellTypes_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-get-class-name (##core#primitive "vtk_wrap_vtkCellTypes_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-is-type-of (##core#primitive "vtk_wrap_vtkCellTypes_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-is-a (##core#primitive "vtk_wrap_vtkCellTypes_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-safe-down-cast (##core#primitive "vtk_wrap_vtkCellTypes_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-allocate (##core#primitive "vtk_wrap_vtkCellTypes_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_InsertCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-insert-cell (##core#primitive "vtk_wrap_vtkCellTypes_InsertCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_InsertNextCell(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-insert-next-cell (##core#primitive "vtk_wrap_vtkCellTypes_InsertNextCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_SetCellTypes(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-set-cell-types (##core#primitive "vtk_wrap_vtkCellTypes_SetCellTypes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_GetCellLocation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-get-cell-location (##core#primitive "vtk_wrap_vtkCellTypes_GetCellLocation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_DeleteCell(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-delete-cell (##core#primitive "vtk_wrap_vtkCellTypes_DeleteCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_GetNumberOfTypes(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-get-number-of-types (##core#primitive "vtk_wrap_vtkCellTypes_GetNumberOfTypes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_IsType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-is-type (##core#primitive "vtk_wrap_vtkCellTypes_IsType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_InsertNextType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-insert-next-type (##core#primitive "vtk_wrap_vtkCellTypes_InsertNextType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_GetCellType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-get-cell-type (##core#primitive "vtk_wrap_vtkCellTypes_GetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-squeeze (##core#primitive "vtk_wrap_vtkCellTypes_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-reset (##core#primitive "vtk_wrap_vtkCellTypes_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-get-actual-memory-size (##core#primitive "vtk_wrap_vtkCellTypes_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellTypes_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-types-deep-copy (##core#primitive "vtk_wrap_vtkCellTypes_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-class-name (##core#primitive "vtk_wrap_vtkDataSet_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-is-type-of (##core#primitive "vtk_wrap_vtkDataSet_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-is-a (##core#primitive "vtk_wrap_vtkDataSet_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-safe-down-cast (##core#primitive "vtk_wrap_vtkDataSet_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-print-self (##core#primitive "vtk_wrap_vtkDataSet_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_CopyStructure(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-copy-structure (##core#primitive "vtk_wrap_vtkDataSet_CopyStructure"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetNumberOfPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-number-of-points (##core#primitive "vtk_wrap_vtkDataSet_GetNumberOfPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetNumberOfCells(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-number-of-cells (##core#primitive "vtk_wrap_vtkDataSet_GetNumberOfCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellBounds(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-bounds (##core#primitive "vtk_wrap_vtkDataSet_GetCellBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-type (##core#primitive "vtk_wrap_vtkDataSet_GetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellTypes(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-types (##core#primitive "vtk_wrap_vtkDataSet_GetCellTypes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellPoints(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-points (##core#primitive "vtk_wrap_vtkDataSet_GetCellPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetPointCells(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-point-cells (##core#primitive "vtk_wrap_vtkDataSet_GetPointCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellNeighbors(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-neighbors (##core#primitive "vtk_wrap_vtkDataSet_GetCellNeighbors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_FindAndGetCell(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-find-and-get-cell (##core#primitive "vtk_wrap_vtkDataSet_FindAndGetCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-m-time (##core#primitive "vtk_wrap_vtkDataSet_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetCellData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-cell-data (##core#primitive "vtk_wrap_vtkDataSet_GetCellData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetPointData(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-point-data (##core#primitive "vtk_wrap_vtkDataSet_GetPointData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-squeeze (##core#primitive "vtk_wrap_vtkDataSet_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_ComputeBounds(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-compute-bounds (##core#primitive "vtk_wrap_vtkDataSet_ComputeBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetLength(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-length (##core#primitive "vtk_wrap_vtkDataSet_GetLength"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-initialize (##core#primitive "vtk_wrap_vtkDataSet_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetMaxCellSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-max-cell-size (##core#primitive "vtk_wrap_vtkDataSet_GetMaxCellSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-actual-memory-size (##core#primitive "vtk_wrap_vtkDataSet_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_GetDataObjectType(int,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-get-data-object-type (##core#primitive "vtk_wrap_vtkDataSet_GetDataObjectType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-shallow-copy (##core#primitive "vtk_wrap_vtkDataSet_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkDataSet_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-data-set-deep-copy (##core#primitive "vtk_wrap_vtkDataSet_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-class-name (##core#primitive "vtk_wrap_vtkLocator_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-is-type-of (##core#primitive "vtk_wrap_vtkLocator_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-is-a (##core#primitive "vtk_wrap_vtkLocator_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-safe-down-cast (##core#primitive "vtk_wrap_vtkLocator_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-print-self (##core#primitive "vtk_wrap_vtkLocator_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SetDataSet(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-set-data-set (##core#primitive "vtk_wrap_vtkLocator_SetDataSet"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetDataSet(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-data-set (##core#primitive "vtk_wrap_vtkLocator_GetDataSet"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SetMaxLevel(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-set-max-level (##core#primitive "vtk_wrap_vtkLocator_SetMaxLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetMaxLevelMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-max-level-min-value (##core#primitive "vtk_wrap_vtkLocator_GetMaxLevelMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetMaxLevelMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-max-level-max-value (##core#primitive "vtk_wrap_vtkLocator_GetMaxLevelMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetMaxLevel(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-max-level (##core#primitive "vtk_wrap_vtkLocator_GetMaxLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetLevel(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-level (##core#primitive "vtk_wrap_vtkLocator_GetLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SetAutomatic(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-set-automatic (##core#primitive "vtk_wrap_vtkLocator_SetAutomatic"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetAutomatic(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-automatic (##core#primitive "vtk_wrap_vtkLocator_GetAutomatic"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_AutomaticOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-automatic-on (##core#primitive "vtk_wrap_vtkLocator_AutomaticOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_AutomaticOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-automatic-off (##core#primitive "vtk_wrap_vtkLocator_AutomaticOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SetTolerance(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-set-tolerance (##core#primitive "vtk_wrap_vtkLocator_SetTolerance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetToleranceMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-tolerance-min-value (##core#primitive "vtk_wrap_vtkLocator_GetToleranceMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetToleranceMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-tolerance-max-value (##core#primitive "vtk_wrap_vtkLocator_GetToleranceMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetTolerance(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-tolerance (##core#primitive "vtk_wrap_vtkLocator_GetTolerance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_SetRetainCellLists(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-set-retain-cell-lists (##core#primitive "vtk_wrap_vtkLocator_SetRetainCellLists"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetRetainCellLists(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-retain-cell-lists (##core#primitive "vtk_wrap_vtkLocator_GetRetainCellLists"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_RetainCellListsOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-retain-cell-lists-on (##core#primitive "vtk_wrap_vtkLocator_RetainCellListsOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_RetainCellListsOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-retain-cell-lists-off (##core#primitive "vtk_wrap_vtkLocator_RetainCellListsOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-update (##core#primitive "vtk_wrap_vtkLocator_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-initialize (##core#primitive "vtk_wrap_vtkLocator_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_BuildLocator(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-build-locator (##core#primitive "vtk_wrap_vtkLocator_BuildLocator"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_FreeSearchStructure(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-free-search-structure (##core#primitive "vtk_wrap_vtkLocator_FreeSearchStructure"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GenerateRepresentation(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-locator-generate-representation (##core#primitive "vtk_wrap_vtkLocator_GenerateRepresentation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLocator_GetBuildTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-locator-get-build-time (##core#primitive "vtk_wrap_vtkLocator_GetBuildTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-class-name (##core#primitive "vtk_wrap_vtkPoints_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-is-type-of (##core#primitive "vtk_wrap_vtkPoints_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-is-a (##core#primitive "vtk_wrap_vtkPoints_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-safe-down-cast (##core#primitive "vtk_wrap_vtkPoints_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-print-self (##core#primitive "vtk_wrap_vtkPoints_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-allocate (##core#primitive "vtk_wrap_vtkPoints_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-initialize (##core#primitive "vtk_wrap_vtkPoints_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-make-object (##core#primitive "vtk_wrap_vtkPoints_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetData(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data (##core#primitive "vtk_wrap_vtkPoints_SetData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetData(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-data (##core#primitive "vtk_wrap_vtkPoints_GetData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetDataType(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-data-type (##core#primitive "vtk_wrap_vtkPoints_GetDataType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type (##core#primitive "vtk_wrap_vtkPoints_SetDataType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToBit(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-bit (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToBit"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToChar(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-char (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToChar"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToUnsignedChar(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-unsigned-char (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToUnsignedChar"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToShort(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-short (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToShort"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToUnsignedShort(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-unsigned-short (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToUnsignedShort"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToInt(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-int (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToInt"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToUnsignedInt(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-unsigned-int (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToUnsignedInt"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToLong(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-long (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToLong"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToUnsignedLong(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-unsigned-long (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToUnsignedLong"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToFloat(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-float (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToFloat"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetDataTypeToDouble(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-data-type-to-double (##core#primitive "vtk_wrap_vtkPoints_SetDataTypeToDouble"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetVoidPointer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-void-pointer (##core#primitive "vtk_wrap_vtkPoints_GetVoidPointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-squeeze (##core#primitive "vtk_wrap_vtkPoints_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-reset (##core#primitive "vtk_wrap_vtkPoints_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-deep-copy (##core#primitive "vtk_wrap_vtkPoints_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-shallow-copy (##core#primitive "vtk_wrap_vtkPoints_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-actual-memory-size (##core#primitive "vtk_wrap_vtkPoints_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetNumberOfPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-number-of-points (##core#primitive "vtk_wrap_vtkPoints_GetNumberOfPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_SetNumberOfPoints(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-set-number-of-points (##core#primitive "vtk_wrap_vtkPoints_SetNumberOfPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_GetPoints(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-points-get-points (##core#primitive "vtk_wrap_vtkPoints_GetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPoints_ComputeBounds(int,C_word,C_word,C_word);"))
(define vtk-vtk-points-compute-bounds (##core#primitive "vtk_wrap_vtkPoints_ComputeBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_New(int,C_word,C_word);"))
(define vtk-vtk-point-locator-new (##core#primitive "vtk_wrap_vtkPointLocator_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-get-class-name (##core#primitive "vtk_wrap_vtkPointLocator_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-is-type-of (##core#primitive "vtk_wrap_vtkPointLocator_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-is-a (##core#primitive "vtk_wrap_vtkPointLocator_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-safe-down-cast (##core#primitive "vtk_wrap_vtkPointLocator_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-print-self (##core#primitive "vtk_wrap_vtkPointLocator_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_SetNumberOfPointsPerBucket(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-set-number-of-points-per-bucket (##core#primitive "vtk_wrap_vtkPointLocator_SetNumberOfPointsPerBucket"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucketMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-get-number-of-points-per-bucket-min-value (##core#primitive "vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucketMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucketMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-get-number-of-points-per-bucket-max-value (##core#primitive "vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucketMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucket(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-get-number-of-points-per-bucket (##core#primitive "vtk_wrap_vtkPointLocator_GetNumberOfPointsPerBucket"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_InsertPoint(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-insert-point (##core#primitive "vtk_wrap_vtkPointLocator_InsertPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_InsertNextPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-insert-next-point (##core#primitive "vtk_wrap_vtkPointLocator_InsertNextPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_InsertUniquePoint(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-insert-unique-point (##core#primitive "vtk_wrap_vtkPointLocator_InsertUniquePoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_FindClosestInsertedPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-find-closest-inserted-point (##core#primitive "vtk_wrap_vtkPointLocator_FindClosestInsertedPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GetPointsInBucket(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-get-points-in-bucket (##core#primitive "vtk_wrap_vtkPointLocator_GetPointsInBucket"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-initialize (##core#primitive "vtk_wrap_vtkPointLocator_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_FreeSearchStructure(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-free-search-structure (##core#primitive "vtk_wrap_vtkPointLocator_FreeSearchStructure"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_BuildLocator(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-build-locator (##core#primitive "vtk_wrap_vtkPointLocator_BuildLocator"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointLocator_GenerateRepresentation(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-locator-generate-representation (##core#primitive "vtk_wrap_vtkPointLocator_GenerateRepresentation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-class-name (##core#primitive "vtk_wrap_vtkPointSet_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-is-type-of (##core#primitive "vtk_wrap_vtkPointSet_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-is-a (##core#primitive "vtk_wrap_vtkPointSet_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-safe-down-cast (##core#primitive "vtk_wrap_vtkPointSet_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-print-self (##core#primitive "vtk_wrap_vtkPointSet_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-initialize (##core#primitive "vtk_wrap_vtkPointSet_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_CopyStructure(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-copy-structure (##core#primitive "vtk_wrap_vtkPointSet_CopyStructure"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_GetNumberOfPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-number-of-points (##core#primitive "vtk_wrap_vtkPointSet_GetNumberOfPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-m-time (##core#primitive "vtk_wrap_vtkPointSet_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_ComputeBounds(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-compute-bounds (##core#primitive "vtk_wrap_vtkPointSet_ComputeBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-squeeze (##core#primitive "vtk_wrap_vtkPointSet_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_SetPoints(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-set-points (##core#primitive "vtk_wrap_vtkPointSet_SetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_GetPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-points (##core#primitive "vtk_wrap_vtkPointSet_GetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-un-register (##core#primitive "vtk_wrap_vtkPointSet_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_GetNetReferenceCount(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-net-reference-count (##core#primitive "vtk_wrap_vtkPointSet_GetNetReferenceCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-get-actual-memory-size (##core#primitive "vtk_wrap_vtkPointSet_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-shallow-copy (##core#primitive "vtk_wrap_vtkPointSet_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPointSet_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-point-set-deep-copy (##core#primitive "vtk_wrap_vtkPointSet_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-class-name (##core#primitive "vtk_wrap_vtkCellArray_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-is-type-of (##core#primitive "vtk_wrap_vtkCellArray_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-is-a (##core#primitive "vtk_wrap_vtkCellArray_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-safe-down-cast (##core#primitive "vtk_wrap_vtkCellArray_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_New(int,C_word,C_word);"))
(define vtk-vtk-cell-array-new (##core#primitive "vtk_wrap_vtkCellArray_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-allocate (##core#primitive "vtk_wrap_vtkCellArray_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-initialize (##core#primitive "vtk_wrap_vtkCellArray_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetNumberOfCells(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-number-of-cells (##core#primitive "vtk_wrap_vtkCellArray_GetNumberOfCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_EstimateSize(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-estimate-size (##core#primitive "vtk_wrap_vtkCellArray_EstimateSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_InitTraversal(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-init-traversal (##core#primitive "vtk_wrap_vtkCellArray_InitTraversal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetNextCell(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-next-cell (##core#primitive "vtk_wrap_vtkCellArray_GetNextCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-size (##core#primitive "vtk_wrap_vtkCellArray_GetSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetNumberOfConnectivityEntries(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-number-of-connectivity-entries (##core#primitive "vtk_wrap_vtkCellArray_GetNumberOfConnectivityEntries"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-cell (##core#primitive "vtk_wrap_vtkCellArray_GetCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_InsertCellPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-insert-cell-point (##core#primitive "vtk_wrap_vtkCellArray_InsertCellPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_UpdateCellCount(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-update-cell-count (##core#primitive "vtk_wrap_vtkCellArray_UpdateCellCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetInsertLocation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-insert-location (##core#primitive "vtk_wrap_vtkCellArray_GetInsertLocation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_SetTraversalLocation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-set-traversal-location (##core#primitive "vtk_wrap_vtkCellArray_SetTraversalLocation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_ReverseCell(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-reverse-cell (##core#primitive "vtk_wrap_vtkCellArray_ReverseCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_ReplaceCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-replace-cell (##core#primitive "vtk_wrap_vtkCellArray_ReplaceCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetMaxCellSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-max-cell-size (##core#primitive "vtk_wrap_vtkCellArray_GetMaxCellSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetPointer(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-pointer (##core#primitive "vtk_wrap_vtkCellArray_GetPointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_WritePointer(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-write-pointer (##core#primitive "vtk_wrap_vtkCellArray_WritePointer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_SetCells(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-set-cells (##core#primitive "vtk_wrap_vtkCellArray_SetCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-deep-copy (##core#primitive "vtk_wrap_vtkCellArray_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetData(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-data (##core#primitive "vtk_wrap_vtkCellArray_GetData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-reset (##core#primitive "vtk_wrap_vtkCellArray_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-squeeze (##core#primitive "vtk_wrap_vtkCellArray_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellArray_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-array-get-actual-memory-size (##core#primitive "vtk_wrap_vtkCellArray_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap__vtkLink_s_ncells_set(int,C_word,C_word,C_word,C_word);"))
(define vtk--vtk-link-s-ncells-set (##core#primitive "vtk_wrap__vtkLink_s_ncells_set"))

(declare (foreign-declare "extern C_word vtk_wrap__vtkLink_s_ncells_get(int,C_word,C_word,C_word);"))
(define vtk--vtk-link-s-ncells-get (##core#primitive "vtk_wrap__vtkLink_s_ncells_get"))

(declare (foreign-declare "extern C_word vtk_wrap__vtkLink_s_cells_set(int,C_word,C_word,C_word,C_word);"))
(define vtk--vtk-link-s-cells-set (##core#primitive "vtk_wrap__vtkLink_s_cells_set"))

(declare (foreign-declare "extern C_word vtk_wrap__vtkLink_s_cells_get(int,C_word,C_word,C_word);"))
(define vtk--vtk-link-s-cells-get (##core#primitive "vtk_wrap__vtkLink_s_cells_get"))

(declare (foreign-declare "extern C_word vtk_wrap_new__vtkLink_s(int,C_word,C_word);"))
(define vtk-new--vtk-link-s (##core#primitive "vtk_wrap_new__vtkLink_s"))

(declare (foreign-declare "extern C_word vtk_wrap_delete__vtkLink_s(int,C_word,C_word,C_word);"))
(define vtk-delete--vtk-link-s (##core#primitive "vtk_wrap_delete__vtkLink_s"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_New(int,C_word,C_word);"))
(define vtk-vtk-cell-links-new (##core#primitive "vtk_wrap_vtkCellLinks_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-get-class-name (##core#primitive "vtk_wrap_vtkCellLinks_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-is-type-of (##core#primitive "vtk_wrap_vtkCellLinks_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-is-a (##core#primitive "vtk_wrap_vtkCellLinks_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-safe-down-cast (##core#primitive "vtk_wrap_vtkCellLinks_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_Allocate(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-allocate (##core#primitive "vtk_wrap_vtkCellLinks_Allocate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_GetLink(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-get-link (##core#primitive "vtk_wrap_vtkCellLinks_GetLink"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_GetNcells(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-get-ncells (##core#primitive "vtk_wrap_vtkCellLinks_GetNcells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_GetCells(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-get-cells (##core#primitive "vtk_wrap_vtkCellLinks_GetCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_InsertNextPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-insert-next-point (##core#primitive "vtk_wrap_vtkCellLinks_InsertNextPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_InsertNextCellReference(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-insert-next-cell-reference (##core#primitive "vtk_wrap_vtkCellLinks_InsertNextCellReference"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_DeletePoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-delete-point (##core#primitive "vtk_wrap_vtkCellLinks_DeletePoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_RemoveCellReference(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-remove-cell-reference (##core#primitive "vtk_wrap_vtkCellLinks_RemoveCellReference"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_AddCellReference(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-add-cell-reference (##core#primitive "vtk_wrap_vtkCellLinks_AddCellReference"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_ResizeCellList(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-resize-cell-list (##core#primitive "vtk_wrap_vtkCellLinks_ResizeCellList"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-squeeze (##core#primitive "vtk_wrap_vtkCellLinks_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-reset (##core#primitive "vtk_wrap_vtkCellLinks_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-get-actual-memory-size (##core#primitive "vtk_wrap_vtkCellLinks_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCellLinks_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-cell-links-deep-copy (##core#primitive "vtk_wrap_vtkCellLinks_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_New(int,C_word,C_word);"))
(define vtk-vtk-process-object-new (##core#primitive "vtk_wrap_vtkProcessObject_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-class-name (##core#primitive "vtk_wrap_vtkProcessObject_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-is-type-of (##core#primitive "vtk_wrap_vtkProcessObject_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-is-a (##core#primitive "vtk_wrap_vtkProcessObject_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-safe-down-cast (##core#primitive "vtk_wrap_vtkProcessObject_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-print-self (##core#primitive "vtk_wrap_vtkProcessObject_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetStartMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-start-method (##core#primitive "vtk_wrap_vtkProcessObject_SetStartMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetProgressMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-progress-method (##core#primitive "vtk_wrap_vtkProcessObject_SetProgressMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetEndMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-end-method (##core#primitive "vtk_wrap_vtkProcessObject_SetEndMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetStartMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-start-method-arg-delete (##core#primitive "vtk_wrap_vtkProcessObject_SetStartMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetProgressMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-progress-method-arg-delete (##core#primitive "vtk_wrap_vtkProcessObject_SetProgressMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetEndMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-end-method-arg-delete (##core#primitive "vtk_wrap_vtkProcessObject_SetEndMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetAbortExecute(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-abort-execute (##core#primitive "vtk_wrap_vtkProcessObject_SetAbortExecute"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetAbortExecute(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-abort-execute (##core#primitive "vtk_wrap_vtkProcessObject_GetAbortExecute"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_AbortExecuteOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-abort-execute-on (##core#primitive "vtk_wrap_vtkProcessObject_AbortExecuteOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_AbortExecuteOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-abort-execute-off (##core#primitive "vtk_wrap_vtkProcessObject_AbortExecuteOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetProgress(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-progress (##core#primitive "vtk_wrap_vtkProcessObject_SetProgress"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetProgressMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-progress-min-value (##core#primitive "vtk_wrap_vtkProcessObject_GetProgressMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetProgressMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-progress-max-value (##core#primitive "vtk_wrap_vtkProcessObject_GetProgressMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetProgress(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-progress (##core#primitive "vtk_wrap_vtkProcessObject_GetProgress"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_UpdateProgress(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-update-progress (##core#primitive "vtk_wrap_vtkProcessObject_UpdateProgress"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SetProgressText(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-set-progress-text (##core#primitive "vtk_wrap_vtkProcessObject_SetProgressText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetProgressText(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-progress-text (##core#primitive "vtk_wrap_vtkProcessObject_GetProgressText"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_AbortExecute_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-abort-execute-set (##core#primitive "vtk_wrap_vtkProcessObject_AbortExecute_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_AbortExecute_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-abort-execute-get (##core#primitive "vtk_wrap_vtkProcessObject_AbortExecute_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetInputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-inputs (##core#primitive "vtk_wrap_vtkProcessObject_GetInputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_GetNumberOfInputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-get-number-of-inputs (##core#primitive "vtk_wrap_vtkProcessObject_GetNumberOfInputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_SqueezeInputArray(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-squeeze-input-array (##core#primitive "vtk_wrap_vtkProcessObject_SqueezeInputArray"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProcessObject_RemoveAllInputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-process-object-remove-all-inputs (##core#primitive "vtk_wrap_vtkProcessObject_RemoveAllInputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_New(int,C_word,C_word);"))
(define vtk-vtk-source-new (##core#primitive "vtk_wrap_vtkSource_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-get-class-name (##core#primitive "vtk_wrap_vtkSource_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-is-type-of (##core#primitive "vtk_wrap_vtkSource_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-is-a (##core#primitive "vtk_wrap_vtkSource_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-safe-down-cast (##core#primitive "vtk_wrap_vtkSource_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-print-self (##core#primitive "vtk_wrap_vtkSource_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-update (##core#primitive "vtk_wrap_vtkSource_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_UpdateWholeExtent(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-update-whole-extent (##core#primitive "vtk_wrap_vtkSource_UpdateWholeExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_UpdateInformation(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-update-information (##core#primitive "vtk_wrap_vtkSource_UpdateInformation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_PropagateUpdateExtent(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-propagate-update-extent (##core#primitive "vtk_wrap_vtkSource_PropagateUpdateExtent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_TriggerAsynchronousUpdate(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-trigger-asynchronous-update (##core#primitive "vtk_wrap_vtkSource_TriggerAsynchronousUpdate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_UpdateData(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-update-data (##core#primitive "vtk_wrap_vtkSource_UpdateData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_ComputeInputUpdateExtents(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-compute-input-update-extents (##core#primitive "vtk_wrap_vtkSource_ComputeInputUpdateExtents"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_SetReleaseDataFlag(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-set-release-data-flag (##core#primitive "vtk_wrap_vtkSource_SetReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_GetReleaseDataFlag(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-get-release-data-flag (##core#primitive "vtk_wrap_vtkSource_GetReleaseDataFlag"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_ReleaseDataFlagOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-release-data-flag-on (##core#primitive "vtk_wrap_vtkSource_ReleaseDataFlagOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_ReleaseDataFlagOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-release-data-flag-off (##core#primitive "vtk_wrap_vtkSource_ReleaseDataFlagOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-un-register (##core#primitive "vtk_wrap_vtkSource_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_InRegisterLoop(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-in-register-loop (##core#primitive "vtk_wrap_vtkSource_InRegisterLoop"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_GetOutputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-get-outputs (##core#primitive "vtk_wrap_vtkSource_GetOutputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_GetNumberOfOutputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-get-number-of-outputs (##core#primitive "vtk_wrap_vtkSource_GetNumberOfOutputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_UnRegisterAllOutputs(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-un-register-all-outputs (##core#primitive "vtk_wrap_vtkSource_UnRegisterAllOutputs"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_GetOutputIndex(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-get-output-index (##core#primitive "vtk_wrap_vtkSource_GetOutputIndex"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_EnlargeOutputUpdateExtents(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-enlarge-output-update-extents (##core#primitive "vtk_wrap_vtkSource_EnlargeOutputUpdateExtents"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_LegacyHack_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-source-legacy-hack-set (##core#primitive "vtk_wrap_vtkSource_LegacyHack_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSource_LegacyHack_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-source-legacy-hack-get (##core#primitive "vtk_wrap_vtkSource_LegacyHack_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_New(int,C_word,C_word);"))
(define vtk-vtk-poly-data-new (##core#primitive "vtk_wrap_vtkPolyData_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-class-name (##core#primitive "vtk_wrap_vtkPolyData_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-is-type-of (##core#primitive "vtk_wrap_vtkPolyData_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-is-a (##core#primitive "vtk_wrap_vtkPolyData_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-safe-down-cast (##core#primitive "vtk_wrap_vtkPolyData_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-print-self (##core#primitive "vtk_wrap_vtkPolyData_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_MakeObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-make-object (##core#primitive "vtk_wrap_vtkPolyData_MakeObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetDataObjectType(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-data-object-type (##core#primitive "vtk_wrap_vtkPolyData_GetDataObjectType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_CopyStructure(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-copy-structure (##core#primitive "vtk_wrap_vtkPolyData_CopyStructure"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfCells(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-cells (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetCellType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-cell-type (##core#primitive "vtk_wrap_vtkPolyData_GetCellType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetCellBounds(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-cell-bounds (##core#primitive "vtk_wrap_vtkPolyData_GetCellBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetCellNeighbors(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-cell-neighbors (##core#primitive "vtk_wrap_vtkPolyData_GetCellNeighbors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_CopyCells(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-copy-cells (##core#primitive "vtk_wrap_vtkPolyData_CopyCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ComputeBounds(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-compute-bounds (##core#primitive "vtk_wrap_vtkPolyData_ComputeBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_Squeeze(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-squeeze (##core#primitive "vtk_wrap_vtkPolyData_Squeeze"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetMaxCellSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-max-cell-size (##core#primitive "vtk_wrap_vtkPolyData_GetMaxCellSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_SetVerts(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-set-verts (##core#primitive "vtk_wrap_vtkPolyData_SetVerts"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetVerts(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-verts (##core#primitive "vtk_wrap_vtkPolyData_GetVerts"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_SetLines(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-set-lines (##core#primitive "vtk_wrap_vtkPolyData_SetLines"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetLines(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-lines (##core#primitive "vtk_wrap_vtkPolyData_GetLines"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_SetPolys(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-set-polys (##core#primitive "vtk_wrap_vtkPolyData_SetPolys"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetPolys(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-polys (##core#primitive "vtk_wrap_vtkPolyData_GetPolys"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_SetStrips(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-set-strips (##core#primitive "vtk_wrap_vtkPolyData_SetStrips"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetStrips(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-strips (##core#primitive "vtk_wrap_vtkPolyData_GetStrips"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfVerts(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-verts (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfVerts"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfLines(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-lines (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfLines"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfPolys(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-polys (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfPolys"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfStrips(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-strips (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfStrips"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_Reset(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-reset (##core#primitive "vtk_wrap_vtkPolyData_Reset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_BuildCells(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-build-cells (##core#primitive "vtk_wrap_vtkPolyData_BuildCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_BuildLinks(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-build-links (##core#primitive "vtk_wrap_vtkPolyData_BuildLinks"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_DeleteCells(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-delete-cells (##core#primitive "vtk_wrap_vtkPolyData_DeleteCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_DeleteLinks(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-delete-links (##core#primitive "vtk_wrap_vtkPolyData_DeleteLinks"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetCellEdgeNeighbors(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-cell-edge-neighbors (##core#primitive "vtk_wrap_vtkPolyData_GetCellEdgeNeighbors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_IsTriangle(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-is-triangle (##core#primitive "vtk_wrap_vtkPolyData_IsTriangle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_IsEdge(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-is-edge (##core#primitive "vtk_wrap_vtkPolyData_IsEdge"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_IsPointUsedByCell(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-is-point-used-by-cell (##core#primitive "vtk_wrap_vtkPolyData_IsPointUsedByCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ReplaceCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-replace-cell (##core#primitive "vtk_wrap_vtkPolyData_ReplaceCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ReplaceCellPoint(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-replace-cell-point (##core#primitive "vtk_wrap_vtkPolyData_ReplaceCellPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ReverseCell(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-reverse-cell (##core#primitive "vtk_wrap_vtkPolyData_ReverseCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_DeletePoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-delete-point (##core#primitive "vtk_wrap_vtkPolyData_DeletePoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_DeleteCell(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-delete-cell (##core#primitive "vtk_wrap_vtkPolyData_DeleteCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_InsertNextLinkedPoint(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-insert-next-linked-point (##core#primitive "vtk_wrap_vtkPolyData_InsertNextLinkedPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_InsertNextLinkedCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-insert-next-linked-cell (##core#primitive "vtk_wrap_vtkPolyData_InsertNextLinkedCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ReplaceLinkedCell(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-replace-linked-cell (##core#primitive "vtk_wrap_vtkPolyData_ReplaceLinkedCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_RemoveCellReference(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-remove-cell-reference (##core#primitive "vtk_wrap_vtkPolyData_RemoveCellReference"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_AddCellReference(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-add-cell-reference (##core#primitive "vtk_wrap_vtkPolyData_AddCellReference"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_RemoveReferenceToCell(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-remove-reference-to-cell (##core#primitive "vtk_wrap_vtkPolyData_RemoveReferenceToCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_AddReferenceToCell(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-add-reference-to-cell (##core#primitive "vtk_wrap_vtkPolyData_AddReferenceToCell"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ResizeCellList(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-resize-cell-list (##core#primitive "vtk_wrap_vtkPolyData_ResizeCellList"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-initialize (##core#primitive "vtk_wrap_vtkPolyData_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetPiece(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-piece (##core#primitive "vtk_wrap_vtkPolyData_GetPiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetNumberOfPieces(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-number-of-pieces (##core#primitive "vtk_wrap_vtkPolyData_GetNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetGhostLevel(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-ghost-level (##core#primitive "vtk_wrap_vtkPolyData_GetGhostLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_GetActualMemorySize(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-get-actual-memory-size (##core#primitive "vtk_wrap_vtkPolyData_GetActualMemorySize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-shallow-copy (##core#primitive "vtk_wrap_vtkPolyData_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-deep-copy (##core#primitive "vtk_wrap_vtkPolyData_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyData_RemoveGhostCells(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-remove-ghost-cells (##core#primitive "vtk_wrap_vtkPolyData_RemoveGhostCells"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_New(int,C_word,C_word);"))
(define vtk-vtk-poly-data-source-new (##core#primitive "vtk_wrap_vtkPolyDataSource_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-source-get-class-name (##core#primitive "vtk_wrap_vtkPolyDataSource_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-source-is-type-of (##core#primitive "vtk_wrap_vtkPolyDataSource_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-source-is-a (##core#primitive "vtk_wrap_vtkPolyDataSource_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-source-safe-down-cast (##core#primitive "vtk_wrap_vtkPolyDataSource_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataSource_SetOutput(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-source-set-output (##core#primitive "vtk_wrap_vtkPolyDataSource_SetOutput"))

(declare (foreign-declare "extern vtk_wrap_VTK_MAX_SPHERE_RESOLUTION(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-max-sphere-resolution (##core#primitive "vtk_wrap_VTK_MAX_SPHERE_RESOLUTION"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-class-name (##core#primitive "vtk_wrap_vtkSphereSource_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-is-type-of (##core#primitive "vtk_wrap_vtkSphereSource_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-is-a (##core#primitive "vtk_wrap_vtkSphereSource_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-safe-down-cast (##core#primitive "vtk_wrap_vtkSphereSource_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-print-self (##core#primitive "vtk_wrap_vtkSphereSource_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_New(int,C_word,C_word);"))
(define vtk-vtk-sphere-source-new (##core#primitive "vtk_wrap_vtkSphereSource_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetRadius(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-radius (##core#primitive "vtk_wrap_vtkSphereSource_SetRadius"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetRadiusMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-radius-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetRadiusMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetRadiusMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-radius-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetRadiusMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetRadius(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-radius (##core#primitive "vtk_wrap_vtkSphereSource_GetRadius"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetThetaResolution(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-theta-resolution (##core#primitive "vtk_wrap_vtkSphereSource_SetThetaResolution"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetThetaResolutionMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-theta-resolution-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetThetaResolutionMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetThetaResolutionMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-theta-resolution-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetThetaResolutionMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetThetaResolution(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-theta-resolution (##core#primitive "vtk_wrap_vtkSphereSource_GetThetaResolution"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetPhiResolution(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-phi-resolution (##core#primitive "vtk_wrap_vtkSphereSource_SetPhiResolution"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetPhiResolutionMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-phi-resolution-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetPhiResolutionMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetPhiResolutionMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-phi-resolution-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetPhiResolutionMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetPhiResolution(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-phi-resolution (##core#primitive "vtk_wrap_vtkSphereSource_GetPhiResolution"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetStartTheta(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-start-theta (##core#primitive "vtk_wrap_vtkSphereSource_SetStartTheta"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartThetaMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-theta-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetStartThetaMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartThetaMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-theta-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetStartThetaMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartTheta(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-theta (##core#primitive "vtk_wrap_vtkSphereSource_GetStartTheta"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetEndTheta(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-end-theta (##core#primitive "vtk_wrap_vtkSphereSource_SetEndTheta"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndThetaMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-theta-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetEndThetaMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndThetaMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-theta-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetEndThetaMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndTheta(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-theta (##core#primitive "vtk_wrap_vtkSphereSource_GetEndTheta"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetStartPhi(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-start-phi (##core#primitive "vtk_wrap_vtkSphereSource_SetStartPhi"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartPhiMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-phi-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetStartPhiMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartPhiMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-phi-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetStartPhiMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetStartPhi(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-start-phi (##core#primitive "vtk_wrap_vtkSphereSource_GetStartPhi"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetEndPhi(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-end-phi (##core#primitive "vtk_wrap_vtkSphereSource_SetEndPhi"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndPhiMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-phi-min-value (##core#primitive "vtk_wrap_vtkSphereSource_GetEndPhiMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndPhiMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-phi-max-value (##core#primitive "vtk_wrap_vtkSphereSource_GetEndPhiMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetEndPhi(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-end-phi (##core#primitive "vtk_wrap_vtkSphereSource_GetEndPhi"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_SetLatLongTessellation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-set-lat-long-tessellation (##core#primitive "vtk_wrap_vtkSphereSource_SetLatLongTessellation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_GetLatLongTessellation(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-get-lat-long-tessellation (##core#primitive "vtk_wrap_vtkSphereSource_GetLatLongTessellation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_LatLongTessellationOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-lat-long-tessellation-on (##core#primitive "vtk_wrap_vtkSphereSource_LatLongTessellationOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkSphereSource_LatLongTessellationOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-sphere-source-lat-long-tessellation-off (##core#primitive "vtk_wrap_vtkSphereSource_LatLongTessellationOff"))

(declare (foreign-declare "extern C_word vtk_wrap_new_vtkCollectionElement(int,C_word,C_word);"))
(define vtk-new-vtk-collection-element (##core#primitive "vtk_wrap_new_vtkCollectionElement"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollectionElement_Item_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-element-item-set (##core#primitive "vtk_wrap_vtkCollectionElement_Item_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollectionElement_Item_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-element-item-get (##core#primitive "vtk_wrap_vtkCollectionElement_Item_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollectionElement_Next_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-element-next-set (##core#primitive "vtk_wrap_vtkCollectionElement_Next_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollectionElement_Next_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-element-next-get (##core#primitive "vtk_wrap_vtkCollectionElement_Next_get"))

(declare (foreign-declare "extern C_word vtk_wrap_delete_vtkCollectionElement(int,C_word,C_word,C_word);"))
(define vtk-delete-vtk-collection-element (##core#primitive "vtk_wrap_delete_vtkCollectionElement"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-get-class-name (##core#primitive "vtk_wrap_vtkCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-is-type-of (##core#primitive "vtk_wrap_vtkCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-is-a (##core#primitive "vtk_wrap_vtkCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-print-self (##core#primitive "vtk_wrap_vtkCollection_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_New(int,C_word,C_word);"))
(define vtk-vtk-collection-new (##core#primitive "vtk_wrap_vtkCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-add-item (##core#primitive "vtk_wrap_vtkCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_ReplaceItem(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-replace-item (##core#primitive "vtk_wrap_vtkCollection_ReplaceItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_RemoveAllItems(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-remove-all-items (##core#primitive "vtk_wrap_vtkCollection_RemoveAllItems"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_IsItemPresent(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-is-item-present (##core#primitive "vtk_wrap_vtkCollection_IsItemPresent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_GetNumberOfItems(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-get-number-of-items (##core#primitive "vtk_wrap_vtkCollection_GetNumberOfItems"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_InitTraversal(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-init-traversal (##core#primitive "vtk_wrap_vtkCollection_InitTraversal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_GetNextItemAsObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-collection-get-next-item-as-object (##core#primitive "vtk_wrap_vtkCollection_GetNextItemAsObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCollection_GetItemAsObject(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-collection-get-item-as-object (##core#primitive "vtk_wrap_vtkCollection_GetItemAsObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-get-class-name (##core#primitive "vtk_wrap_vtkImplicitFunction_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-is-type-of (##core#primitive "vtk_wrap_vtkImplicitFunction_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-is-a (##core#primitive "vtk_wrap_vtkImplicitFunction_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-safe-down-cast (##core#primitive "vtk_wrap_vtkImplicitFunction_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-print-self (##core#primitive "vtk_wrap_vtkImplicitFunction_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-get-m-time (##core#primitive "vtk_wrap_vtkImplicitFunction_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_SetTransform(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-set-transform (##core#primitive "vtk_wrap_vtkImplicitFunction_SetTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_GetTransform(int,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-get-transform (##core#primitive "vtk_wrap_vtkImplicitFunction_GetTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkImplicitFunction_EvaluateGradient(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-implicit-function-evaluate-gradient (##core#primitive "vtk_wrap_vtkImplicitFunction_EvaluateGradient"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_New(int,C_word,C_word);"))
(define vtk-vtk-plane-new (##core#primitive "vtk_wrap_vtkPlane_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-get-class-name (##core#primitive "vtk_wrap_vtkPlane_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-is-type-of (##core#primitive "vtk_wrap_vtkPlane_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-is-a (##core#primitive "vtk_wrap_vtkPlane_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-safe-down-cast (##core#primitive "vtk_wrap_vtkPlane_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-print-self (##core#primitive "vtk_wrap_vtkPlane_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_EvaluateGradient(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-evaluate-gradient (##core#primitive "vtk_wrap_vtkPlane_EvaluateGradient"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_GeneralizedProjectPoint(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-generalized-project-point (##core#primitive "vtk_wrap_vtkPlane_GeneralizedProjectPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_DistanceToPlane(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-distance-to-plane (##core#primitive "vtk_wrap_vtkPlane_DistanceToPlane"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlane_IntersectWithLine(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-intersect-with-line (##core#primitive "vtk_wrap_vtkPlane_IntersectWithLine"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-get-class-name (##core#primitive "vtk_wrap_vtkPlaneCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-is-type-of (##core#primitive "vtk_wrap_vtkPlaneCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-is-a (##core#primitive "vtk_wrap_vtkPlaneCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkPlaneCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_New(int,C_word,C_word);"))
(define vtk-vtk-plane-collection-new (##core#primitive "vtk_wrap_vtkPlaneCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-add-item (##core#primitive "vtk_wrap_vtkPlaneCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlaneCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-plane-collection-get-next-item (##core#primitive "vtk_wrap_vtkPlaneCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_New(int,C_word,C_word);"))
(define vtk-vtk-planes-new (##core#primitive "vtk_wrap_vtkPlanes_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-get-class-name (##core#primitive "vtk_wrap_vtkPlanes_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-is-type-of (##core#primitive "vtk_wrap_vtkPlanes_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-is-a (##core#primitive "vtk_wrap_vtkPlanes_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-safe-down-cast (##core#primitive "vtk_wrap_vtkPlanes_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-print-self (##core#primitive "vtk_wrap_vtkPlanes_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_EvaluateGradient(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-evaluate-gradient (##core#primitive "vtk_wrap_vtkPlanes_EvaluateGradient"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_SetPoints(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-set-points (##core#primitive "vtk_wrap_vtkPlanes_SetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_GetPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-get-points (##core#primitive "vtk_wrap_vtkPlanes_GetPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_SetNormals(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-set-normals (##core#primitive "vtk_wrap_vtkPlanes_SetNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_GetNormals(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-get-normals (##core#primitive "vtk_wrap_vtkPlanes_GetNormals"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_SetFrustumPlanes(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-set-frustum-planes (##core#primitive "vtk_wrap_vtkPlanes_SetFrustumPlanes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_GetNumberOfPlanes(int,C_word,C_word,C_word);"))
(define vtk-vtk-planes-get-number-of-planes (##core#primitive "vtk_wrap_vtkPlanes_GetNumberOfPlanes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPlanes_GetPlane(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-planes-get-plane (##core#primitive "vtk_wrap_vtkPlanes_GetPlane"))

(declare (foreign-declare "extern vtk_wrap_VTK_LOG_EVENT_LENGTH(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-log-event-length (##core#primitive "vtk_wrap_VTK_LOG_EVENT_LENGTH"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_WallTime_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-wall-time-set (##core#primitive "vtk_wrap_vtkTimerLogEntry_WallTime_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_WallTime_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-wall-time-get (##core#primitive "vtk_wrap_vtkTimerLogEntry_WallTime_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_CpuTicks_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-cpu-ticks-set (##core#primitive "vtk_wrap_vtkTimerLogEntry_CpuTicks_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_CpuTicks_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-cpu-ticks-get (##core#primitive "vtk_wrap_vtkTimerLogEntry_CpuTicks_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_Event_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-event-set (##core#primitive "vtk_wrap_vtkTimerLogEntry_Event_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLogEntry_Event_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-entry-event-get (##core#primitive "vtk_wrap_vtkTimerLogEntry_Event_get"))

(declare (foreign-declare "extern C_word vtk_wrap_new_vtkTimerLogEntry(int,C_word,C_word);"))
(define vtk-new-vtk-timer-log-entry (##core#primitive "vtk_wrap_new_vtkTimerLogEntry"))

(declare (foreign-declare "extern C_word vtk_wrap_delete_vtkTimerLogEntry(int,C_word,C_word,C_word);"))
(define vtk-delete-vtk-timer-log-entry (##core#primitive "vtk_wrap_delete_vtkTimerLogEntry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_New(int,C_word,C_word);"))
(define vtk-vtk-timer-log-new (##core#primitive "vtk_wrap_vtkTimerLog_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-get-class-name (##core#primitive "vtk_wrap_vtkTimerLog_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-is-type-of (##core#primitive "vtk_wrap_vtkTimerLog_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-is-a (##core#primitive "vtk_wrap_vtkTimerLog_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-safe-down-cast (##core#primitive "vtk_wrap_vtkTimerLog_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-print-self (##core#primitive "vtk_wrap_vtkTimerLog_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_SetMaxEntries(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-set-max-entries (##core#primitive "vtk_wrap_vtkTimerLog_SetMaxEntries"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_GetMaxEntries(int,C_word,C_word);"))
(define vtk-vtk-timer-log-get-max-entries (##core#primitive "vtk_wrap_vtkTimerLog_GetMaxEntries"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_FormatAndMarkEvent(int,C_word,C_word);"))
(define vtk-vtk-timer-log-format-and-mark-event (##core#primitive "vtk_wrap_vtkTimerLog_FormatAndMarkEvent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_DumpLog(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-dump-log (##core#primitive "vtk_wrap_vtkTimerLog_DumpLog"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_MarkEvent(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-mark-event (##core#primitive "vtk_wrap_vtkTimerLog_MarkEvent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_ResetLog(int,C_word,C_word);"))
(define vtk-vtk-timer-log-reset-log (##core#primitive "vtk_wrap_vtkTimerLog_ResetLog"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_AllocateLog(int,C_word,C_word);"))
(define vtk-vtk-timer-log-allocate-log (##core#primitive "vtk_wrap_vtkTimerLog_AllocateLog"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_GetCurrentTime(int,C_word,C_word);"))
(define vtk-vtk-timer-log-get-current-time (##core#primitive "vtk_wrap_vtkTimerLog_GetCurrentTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_GetCPUTime(int,C_word,C_word);"))
(define vtk-vtk-timer-log-get-cput-ime (##core#primitive "vtk_wrap_vtkTimerLog_GetCPUTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_StartTimer(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-start-timer (##core#primitive "vtk_wrap_vtkTimerLog_StartTimer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_StopTimer(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-stop-timer (##core#primitive "vtk_wrap_vtkTimerLog_StopTimer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTimerLog_GetElapsedTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-timer-log-get-elapsed-time (##core#primitive "vtk_wrap_vtkTimerLog_GetElapsedTime"))

(declare (foreign-declare "extern vtk_wrap_VTK_SCALAR_MODE_DEFAULT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-scalar-mode-default (##core#primitive "vtk_wrap_VTK_SCALAR_MODE_DEFAULT"))

(declare (foreign-declare "extern vtk_wrap_VTK_SCALAR_MODE_USE_POINT_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-scalar-mode-use-point-data (##core#primitive "vtk_wrap_VTK_SCALAR_MODE_USE_POINT_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_SCALAR_MODE_USE_CELL_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-scalar-mode-use-cell-data (##core#primitive "vtk_wrap_VTK_SCALAR_MODE_USE_CELL_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_SCALAR_MODE_USE_POINT_FIELD_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-scalar-mode-use-point-field-data (##core#primitive "vtk_wrap_VTK_SCALAR_MODE_USE_POINT_FIELD_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_SCALAR_MODE_USE_CELL_FIELD_DATA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-scalar-mode-use-cell-field-data (##core#primitive "vtk_wrap_VTK_SCALAR_MODE_USE_CELL_FIELD_DATA"))

(declare (foreign-declare "extern vtk_wrap_VTK_GET_ARRAY_BY_ID(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-get-array-by-id (##core#primitive "vtk_wrap_VTK_GET_ARRAY_BY_ID"))

(declare (foreign-declare "extern vtk_wrap_VTK_GET_ARRAY_BY_NAME(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-get-array-by-name (##core#primitive "vtk_wrap_VTK_GET_ARRAY_BY_NAME"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-get-class-name (##core#primitive "vtk_wrap_vtkAbstractMapper_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-is-type-of (##core#primitive "vtk_wrap_vtkAbstractMapper_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-is-a (##core#primitive "vtk_wrap_vtkAbstractMapper_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-safe-down-cast (##core#primitive "vtk_wrap_vtkAbstractMapper_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-print-self (##core#primitive "vtk_wrap_vtkAbstractMapper_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-get-m-time (##core#primitive "vtk_wrap_vtkAbstractMapper_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-release-graphics-resources (##core#primitive "vtk_wrap_vtkAbstractMapper_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_GetTimeToDraw(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-get-time-to-draw (##core#primitive "vtk_wrap_vtkAbstractMapper_GetTimeToDraw"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_AddClippingPlane(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-add-clipping-plane (##core#primitive "vtk_wrap_vtkAbstractMapper_AddClippingPlane"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_RemoveClippingPlane(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-remove-clipping-plane (##core#primitive "vtk_wrap_vtkAbstractMapper_RemoveClippingPlane"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_RemoveAllClippingPlanes(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-remove-all-clipping-planes (##core#primitive "vtk_wrap_vtkAbstractMapper_RemoveAllClippingPlanes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_GetClippingPlanes(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-get-clipping-planes (##core#primitive "vtk_wrap_vtkAbstractMapper_GetClippingPlanes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-shallow-copy (##core#primitive "vtk_wrap_vtkAbstractMapper_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper_GetScalars(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper-get-scalars (##core#primitive "vtk_wrap_vtkAbstractMapper_GetScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-get-class-name (##core#primitive "vtk_wrap_vtkAbstractMapper3D_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-is-type-of (##core#primitive "vtk_wrap_vtkAbstractMapper3D_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-is-a (##core#primitive "vtk_wrap_vtkAbstractMapper3D_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-safe-down-cast (##core#primitive "vtk_wrap_vtkAbstractMapper3D_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-print-self (##core#primitive "vtk_wrap_vtkAbstractMapper3D_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_GetCenter(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-get-center (##core#primitive "vtk_wrap_vtkAbstractMapper3D_GetCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_GetLength(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-get-length (##core#primitive "vtk_wrap_vtkAbstractMapper3D_GetLength"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_Is_A_Ray_Cast_Mapper(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-is-a-ray-cast-mapper (##core#primitive "vtk_wrap_vtkAbstractMapper3D_Is_A_Ray_Cast_Mapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_Is_A_Render_Into_Image_Mapper(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-is-a-render-into-image-mapper (##core#primitive "vtk_wrap_vtkAbstractMapper3D_Is_A_Render_Into_Image_Mapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkAbstractMapper3D_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-abstract-mapper3d-update (##core#primitive "vtk_wrap_vtkAbstractMapper3D_Update"))

(declare (foreign-declare "extern vtk_wrap_VTK_LUMINANCE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-luminance (##core#primitive "vtk_wrap_VTK_LUMINANCE"))

(declare (foreign-declare "extern vtk_wrap_VTK_LUMINANCE_ALPHA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-luminance-alpha (##core#primitive "vtk_wrap_VTK_LUMINANCE_ALPHA"))

(declare (foreign-declare "extern vtk_wrap_VTK_RGB(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-rgb (##core#primitive "vtk_wrap_VTK_RGB"))

(declare (foreign-declare "extern vtk_wrap_VTK_RGBA(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-rgba (##core#primitive "vtk_wrap_VTK_RGBA"))

(declare (foreign-declare "extern vtk_wrap_VTK_COLOR_MODE_DEFAULT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-color-mode-default (##core#primitive "vtk_wrap_VTK_COLOR_MODE_DEFAULT"))

(declare (foreign-declare "extern vtk_wrap_VTK_COLOR_MODE_MAP_SCALARS(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-color-mode-map-scalars (##core#primitive "vtk_wrap_VTK_COLOR_MODE_MAP_SCALARS"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-get-class-name (##core#primitive "vtk_wrap_vtkScalarsToColors_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-is-type-of (##core#primitive "vtk_wrap_vtkScalarsToColors_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-is-a (##core#primitive "vtk_wrap_vtkScalarsToColors_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-safe-down-cast (##core#primitive "vtk_wrap_vtkScalarsToColors_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-print-self (##core#primitive "vtk_wrap_vtkScalarsToColors_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_Build(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-build (##core#primitive "vtk_wrap_vtkScalarsToColors_Build"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_GetRange(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-get-range (##core#primitive "vtk_wrap_vtkScalarsToColors_GetRange"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_MapValue(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-map-value (##core#primitive "vtk_wrap_vtkScalarsToColors_MapValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_GetOpacity(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-get-opacity (##core#primitive "vtk_wrap_vtkScalarsToColors_GetOpacity"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_GetLuminance(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-get-luminance (##core#primitive "vtk_wrap_vtkScalarsToColors_GetLuminance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_SetAlpha(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-set-alpha (##core#primitive "vtk_wrap_vtkScalarsToColors_SetAlpha"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_GetAlpha(int,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-get-alpha (##core#primitive "vtk_wrap_vtkScalarsToColors_GetAlpha"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_MapScalars(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-map-scalars (##core#primitive "vtk_wrap_vtkScalarsToColors_MapScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_MapScalarsThroughTable2(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-map-scalars-through-table2 (##core#primitive "vtk_wrap_vtkScalarsToColors_MapScalarsThroughTable2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkScalarsToColors_ConvertUnsignedCharToRGBA(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-scalars-to-colors-convert-unsigned-char-to-rgba (##core#primitive "vtk_wrap_vtkScalarsToColors_ConvertUnsignedCharToRGBA"))

(declare (foreign-declare "extern vtk_wrap_VTK_RESOLVE_OFF(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-resolve-off (##core#primitive "vtk_wrap_VTK_RESOLVE_OFF"))

(declare (foreign-declare "extern vtk_wrap_VTK_RESOLVE_POLYGON_OFFSET(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-resolve-polygon-offset (##core#primitive "vtk_wrap_VTK_RESOLVE_POLYGON_OFFSET"))

(declare (foreign-declare "extern vtk_wrap_VTK_RESOLVE_SHIFT_ZBUFFER(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-resolve-shift-zbuffer (##core#primitive "vtk_wrap_VTK_RESOLVE_SHIFT_ZBUFFER"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-class-name (##core#primitive "vtk_wrap_vtkMapper_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-is-type-of (##core#primitive "vtk_wrap_vtkMapper_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-is-a (##core#primitive "vtk_wrap_vtkMapper_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-safe-down-cast (##core#primitive "vtk_wrap_vtkMapper_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-print-self (##core#primitive "vtk_wrap_vtkMapper_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-shallow-copy (##core#primitive "vtk_wrap_vtkMapper_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-m-time (##core#primitive "vtk_wrap_vtkMapper_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_Render(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-render (##core#primitive "vtk_wrap_vtkMapper_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-release-graphics-resources (##core#primitive "vtk_wrap_vtkMapper_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetLookupTable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-lookup-table (##core#primitive "vtk_wrap_vtkMapper_SetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-lookup-table (##core#primitive "vtk_wrap_vtkMapper_GetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_CreateDefaultLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-create-default-lookup-table (##core#primitive "vtk_wrap_vtkMapper_CreateDefaultLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarVisibility(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-visibility (##core#primitive "vtk_wrap_vtkMapper_SetScalarVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetScalarVisibility(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-scalar-visibility (##core#primitive "vtk_wrap_vtkMapper_GetScalarVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ScalarVisibilityOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-scalar-visibility-on (##core#primitive "vtk_wrap_vtkMapper_ScalarVisibilityOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ScalarVisibilityOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-scalar-visibility-off (##core#primitive "vtk_wrap_vtkMapper_ScalarVisibilityOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetColorMode(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-color-mode (##core#primitive "vtk_wrap_vtkMapper_SetColorMode"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetColorMode(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-color-mode (##core#primitive "vtk_wrap_vtkMapper_GetColorMode"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetColorModeToDefault(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-color-mode-to-default (##core#primitive "vtk_wrap_vtkMapper_SetColorModeToDefault"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetColorModeToMapScalars(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-color-mode-to-map-scalars (##core#primitive "vtk_wrap_vtkMapper_SetColorModeToMapScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetColorModeAsString(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-color-mode-as-string (##core#primitive "vtk_wrap_vtkMapper_GetColorModeAsString"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetUseLookupTableScalarRange(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-use-lookup-table-scalar-range (##core#primitive "vtk_wrap_vtkMapper_SetUseLookupTableScalarRange"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetUseLookupTableScalarRange(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-use-lookup-table-scalar-range (##core#primitive "vtk_wrap_vtkMapper_GetUseLookupTableScalarRange"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_UseLookupTableScalarRangeOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-use-lookup-table-scalar-range-on (##core#primitive "vtk_wrap_vtkMapper_UseLookupTableScalarRangeOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_UseLookupTableScalarRangeOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-use-lookup-table-scalar-range-off (##core#primitive "vtk_wrap_vtkMapper_UseLookupTableScalarRangeOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetImmediateModeRendering(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-immediate-mode-rendering (##core#primitive "vtk_wrap_vtkMapper_SetImmediateModeRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetImmediateModeRendering(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-immediate-mode-rendering (##core#primitive "vtk_wrap_vtkMapper_GetImmediateModeRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ImmediateModeRenderingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-immediate-mode-rendering-on (##core#primitive "vtk_wrap_vtkMapper_ImmediateModeRenderingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_ImmediateModeRenderingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-immediate-mode-rendering-off (##core#primitive "vtk_wrap_vtkMapper_ImmediateModeRenderingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetGlobalImmediateModeRendering(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-global-immediate-mode-rendering (##core#primitive "vtk_wrap_vtkMapper_SetGlobalImmediateModeRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GlobalImmediateModeRenderingOn(int,C_word,C_word);"))
(define vtk-vtk-mapper-global-immediate-mode-rendering-on (##core#primitive "vtk_wrap_vtkMapper_GlobalImmediateModeRenderingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GlobalImmediateModeRenderingOff(int,C_word,C_word);"))
(define vtk-vtk-mapper-global-immediate-mode-rendering-off (##core#primitive "vtk_wrap_vtkMapper_GlobalImmediateModeRenderingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetGlobalImmediateModeRendering(int,C_word,C_word);"))
(define vtk-vtk-mapper-get-global-immediate-mode-rendering (##core#primitive "vtk_wrap_vtkMapper_GetGlobalImmediateModeRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarMode(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode (##core#primitive "vtk_wrap_vtkMapper_SetScalarMode"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetScalarMode(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-scalar-mode (##core#primitive "vtk_wrap_vtkMapper_GetScalarMode"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarModeToDefault(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode-to-default (##core#primitive "vtk_wrap_vtkMapper_SetScalarModeToDefault"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarModeToUsePointData(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode-to-use-point-data (##core#primitive "vtk_wrap_vtkMapper_SetScalarModeToUsePointData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarModeToUseCellData(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode-to-use-cell-data (##core#primitive "vtk_wrap_vtkMapper_SetScalarModeToUseCellData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarModeToUsePointFieldData(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode-to-use-point-field-data (##core#primitive "vtk_wrap_vtkMapper_SetScalarModeToUsePointFieldData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetScalarModeToUseCellFieldData(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-scalar-mode-to-use-cell-field-data (##core#primitive "vtk_wrap_vtkMapper_SetScalarModeToUseCellFieldData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetArrayName(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-array-name (##core#primitive "vtk_wrap_vtkMapper_GetArrayName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetArrayId(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-array-id (##core#primitive "vtk_wrap_vtkMapper_GetArrayId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetArrayAccessMode(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-array-access-mode (##core#primitive "vtk_wrap_vtkMapper_GetArrayAccessMode"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetArrayComponent(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-array-component (##core#primitive "vtk_wrap_vtkMapper_GetArrayComponent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetScalarModeAsString(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-scalar-mode-as-string (##core#primitive "vtk_wrap_vtkMapper_GetScalarModeAsString"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopology(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopology"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetResolveCoincidentTopology(int,C_word,C_word);"))
(define vtk-vtk-mapper-get-resolve-coincident-topology (##core#primitive "vtk_wrap_vtkMapper_GetResolveCoincidentTopology"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToDefault(int,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-to-default (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToDefault"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToOff(int,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-to-off (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToPolygonOffset(int,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-to-polygon-offset (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToPolygonOffset"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToShiftZBuffer(int,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-to-shift-zb-uffer (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyToShiftZBuffer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyPolygonOffsetParameters(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-polygon-offset-parameters (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyPolygonOffsetParameters"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetResolveCoincidentTopologyPolygonOffsetParameters(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-resolve-coincident-topology-polygon-offset-parameters (##core#primitive "vtk_wrap_vtkMapper_GetResolveCoincidentTopologyPolygonOffsetParameters"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetResolveCoincidentTopologyZShift(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-resolve-coincident-topology-zs-hift (##core#primitive "vtk_wrap_vtkMapper_SetResolveCoincidentTopologyZShift"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetResolveCoincidentTopologyZShift(int,C_word,C_word);"))
(define vtk-vtk-mapper-get-resolve-coincident-topology-zs-hift (##core#primitive "vtk_wrap_vtkMapper_GetResolveCoincidentTopologyZShift"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_SetRenderTime(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-set-render-time (##core#primitive "vtk_wrap_vtkMapper_SetRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetRenderTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-render-time (##core#primitive "vtk_wrap_vtkMapper_GetRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetInput(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-input (##core#primitive "vtk_wrap_vtkMapper_GetInput"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_GetInputAsDataSet(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-get-input-as-data-set (##core#primitive "vtk_wrap_vtkMapper_GetInputAsDataSet"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_MapScalars(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-map-scalars (##core#primitive "vtk_wrap_vtkMapper_MapScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMapper_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-mapper-update (##core#primitive "vtk_wrap_vtkMapper_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_New(int,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-new (##core#primitive "vtk_wrap_vtkPolyDataMapper_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-class-name (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-is-type-of (##core#primitive "vtk_wrap_vtkPolyDataMapper_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-is-a (##core#primitive "vtk_wrap_vtkPolyDataMapper_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-safe-down-cast (##core#primitive "vtk_wrap_vtkPolyDataMapper_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-print-self (##core#primitive "vtk_wrap_vtkPolyDataMapper_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_RenderPiece(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-render-piece (##core#primitive "vtk_wrap_vtkPolyDataMapper_RenderPiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_Render(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-render (##core#primitive "vtk_wrap_vtkPolyDataMapper_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SetInput(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-set-input (##core#primitive "vtk_wrap_vtkPolyDataMapper_SetInput"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetInput(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-input (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetInput"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_Update(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-update (##core#primitive "vtk_wrap_vtkPolyDataMapper_Update"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SetPiece(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-set-piece (##core#primitive "vtk_wrap_vtkPolyDataMapper_SetPiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetPiece(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-piece (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetPiece"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SetNumberOfPieces(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-set-number-of-pieces (##core#primitive "vtk_wrap_vtkPolyDataMapper_SetNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetNumberOfPieces(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-number-of-pieces (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetNumberOfPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SetNumberOfSubPieces(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-set-number-of-sub-pieces (##core#primitive "vtk_wrap_vtkPolyDataMapper_SetNumberOfSubPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetNumberOfSubPieces(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-number-of-sub-pieces (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetNumberOfSubPieces"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_SetGhostLevel(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-set-ghost-level (##core#primitive "vtk_wrap_vtkPolyDataMapper_SetGhostLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_GetGhostLevel(int,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-get-ghost-level (##core#primitive "vtk_wrap_vtkPolyDataMapper_GetGhostLevel"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPolyDataMapper_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-poly-data-mapper-shallow-copy (##core#primitive "vtk_wrap_vtkPolyDataMapper_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_New(int,C_word,C_word);"))
(define vtk-vtk-prop-new (##core#primitive "vtk_wrap_vtkProp_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-class-name (##core#primitive "vtk_wrap_vtkProp_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-is-type-of (##core#primitive "vtk_wrap_vtkProp_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-is-a (##core#primitive "vtk_wrap_vtkProp_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-safe-down-cast (##core#primitive "vtk_wrap_vtkProp_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-print-self (##core#primitive "vtk_wrap_vtkProp_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetActors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-actors (##core#primitive "vtk_wrap_vtkProp_GetActors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetActors2D(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-actors2d (##core#primitive "vtk_wrap_vtkProp_GetActors2D"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetVolumes(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-volumes (##core#primitive "vtk_wrap_vtkProp_GetVolumes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetVisibility(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-visibility (##core#primitive "vtk_wrap_vtkProp_SetVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetVisibility(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-visibility (##core#primitive "vtk_wrap_vtkProp_GetVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_VisibilityOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-visibility-on (##core#primitive "vtk_wrap_vtkProp_VisibilityOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_VisibilityOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-visibility-off (##core#primitive "vtk_wrap_vtkProp_VisibilityOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetPickable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-pickable (##core#primitive "vtk_wrap_vtkProp_SetPickable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetPickable(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-pickable (##core#primitive "vtk_wrap_vtkProp_GetPickable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_PickableOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-pickable-on (##core#primitive "vtk_wrap_vtkProp_PickableOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_PickableOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-pickable-off (##core#primitive "vtk_wrap_vtkProp_PickableOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetPickMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-pick-method (##core#primitive "vtk_wrap_vtkProp_SetPickMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetPickMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-pick-method-arg-delete (##core#primitive "vtk_wrap_vtkProp_SetPickMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_Pick(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-pick (##core#primitive "vtk_wrap_vtkProp_Pick"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetDragable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-dragable (##core#primitive "vtk_wrap_vtkProp_SetDragable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetDragable(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-dragable (##core#primitive "vtk_wrap_vtkProp_GetDragable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_DragableOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-dragable-on (##core#primitive "vtk_wrap_vtkProp_DragableOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_DragableOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-dragable-off (##core#primitive "vtk_wrap_vtkProp_DragableOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_Get_Redraw_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-redraw-m-time (##core#primitive "vtk_wrap_vtkProp_Get_Redraw_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetBounds(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-bounds (##core#primitive "vtk_wrap_vtkProp_GetBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-shallow-copy (##core#primitive "vtk_wrap_vtkProp_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_InitPathTraversal(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-init-path-traversal (##core#primitive "vtk_wrap_vtkProp_InitPathTraversal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetNextPath(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-next-path (##core#primitive "vtk_wrap_vtkProp_GetNextPath"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetNumberOfPaths(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-number-of-paths (##core#primitive "vtk_wrap_vtkProp_GetNumberOfPaths"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_PokeMatrix(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-poke-matrix (##core#primitive "vtk_wrap_vtkProp_PokeMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetMatrix(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-matrix (##core#primitive "vtk_wrap_vtkProp_GetMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_RenderOpaqueGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-render-opaque-geometry (##core#primitive "vtk_wrap_vtkProp_RenderOpaqueGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_RenderTranslucentGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-render-translucent-geometry (##core#primitive "vtk_wrap_vtkProp_RenderTranslucentGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_RenderOverlay(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-render-overlay (##core#primitive "vtk_wrap_vtkProp_RenderOverlay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-release-graphics-resources (##core#primitive "vtk_wrap_vtkProp_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetEstimatedRenderTime(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-estimated-render-time (##core#primitive "vtk_wrap_vtkProp_SetEstimatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_RestoreEstimatedRenderTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-restore-estimated-render-time (##core#primitive "vtk_wrap_vtkProp_RestoreEstimatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_AddEstimatedRenderTime(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-add-estimated-render-time (##core#primitive "vtk_wrap_vtkProp_AddEstimatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetAllocatedRenderTime(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-allocated-render-time (##core#primitive "vtk_wrap_vtkProp_SetAllocatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetAllocatedRenderTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-allocated-render-time (##core#primitive "vtk_wrap_vtkProp_GetAllocatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_SetRenderTimeMultiplier(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-set-render-time-multiplier (##core#primitive "vtk_wrap_vtkProp_SetRenderTimeMultiplier"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_GetRenderTimeMultiplier(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-get-render-time-multiplier (##core#primitive "vtk_wrap_vtkProp_GetRenderTimeMultiplier"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp_BuildPaths(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-build-paths (##core#primitive "vtk_wrap_vtkProp_BuildPaths"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-class-name (##core#primitive "vtk_wrap_vtkProp3D_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-is-type-of (##core#primitive "vtk_wrap_vtkProp3D_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-is-a (##core#primitive "vtk_wrap_vtkProp3D_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-safe-down-cast (##core#primitive "vtk_wrap_vtkProp3D_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-print-self (##core#primitive "vtk_wrap_vtkProp3D_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-shallow-copy (##core#primitive "vtk_wrap_vtkProp3D_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_SetUserTransform(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-set-user-transform (##core#primitive "vtk_wrap_vtkProp3D_SetUserTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetUserTransform(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-user-transform (##core#primitive "vtk_wrap_vtkProp3D_GetUserTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_SetUserMatrix(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-set-user-matrix (##core#primitive "vtk_wrap_vtkProp3D_SetUserMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetUserMatrix(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-user-matrix (##core#primitive "vtk_wrap_vtkProp3D_GetUserMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetCenter(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-center (##core#primitive "vtk_wrap_vtkProp3D_GetCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_Get_X_Range(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-x-range (##core#primitive "vtk_wrap_vtkProp3D_Get_X_Range"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_Get_Y_Range(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-y-range (##core#primitive "vtk_wrap_vtkProp3D_Get_Y_Range"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_Get_Z_Range(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-z-range (##core#primitive "vtk_wrap_vtkProp3D_Get_Z_Range"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetLength(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-length (##core#primitive "vtk_wrap_vtkProp3D_GetLength"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_RotateX(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-rotate-x (##core#primitive "vtk_wrap_vtkProp3D_RotateX"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_RotateY(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-rotate-y (##core#primitive "vtk_wrap_vtkProp3D_RotateY"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_RotateZ(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-rotate-z (##core#primitive "vtk_wrap_vtkProp3D_RotateZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_RotateWXYZ(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-rotate-wxyz (##core#primitive "vtk_wrap_vtkProp3D_RotateWXYZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetOrientationWXYZ(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-orientation-wxyz (##core#primitive "vtk_wrap_vtkProp3D_GetOrientationWXYZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_PokeMatrix(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-poke-matrix (##core#primitive "vtk_wrap_vtkProp3D_PokeMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_InitPathTraversal(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-init-path-traversal (##core#primitive "vtk_wrap_vtkProp3D_InitPathTraversal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_ComputeMatrix(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-compute-matrix (##core#primitive "vtk_wrap_vtkProp3D_ComputeMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProp3D_GetIsIdentity(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop3d-get-is-identity (##core#primitive "vtk_wrap_vtkProp3D_GetIsIdentity"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-class-name (##core#primitive "vtk_wrap_vtkProperty_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-is-type-of (##core#primitive "vtk_wrap_vtkProperty_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-is-a (##core#primitive "vtk_wrap_vtkProperty_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-safe-down-cast (##core#primitive "vtk_wrap_vtkProperty_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-print-self (##core#primitive "vtk_wrap_vtkProperty_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_New(int,C_word,C_word);"))
(define vtk-vtk-property-new (##core#primitive "vtk_wrap_vtkProperty_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_DeepCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-deep-copy (##core#primitive "vtk_wrap_vtkProperty_DeepCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_Render(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-render (##core#primitive "vtk_wrap_vtkProperty_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_BackfaceRender(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-backface-render (##core#primitive "vtk_wrap_vtkProperty_BackfaceRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetInterpolation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-interpolation (##core#primitive "vtk_wrap_vtkProperty_SetInterpolation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetInterpolationMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-interpolation-min-value (##core#primitive "vtk_wrap_vtkProperty_GetInterpolationMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetInterpolationMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-interpolation-max-value (##core#primitive "vtk_wrap_vtkProperty_GetInterpolationMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetInterpolation(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-interpolation (##core#primitive "vtk_wrap_vtkProperty_GetInterpolation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetInterpolationToFlat(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-interpolation-to-flat (##core#primitive "vtk_wrap_vtkProperty_SetInterpolationToFlat"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetInterpolationToGouraud(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-interpolation-to-gouraud (##core#primitive "vtk_wrap_vtkProperty_SetInterpolationToGouraud"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetInterpolationToPhong(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-interpolation-to-phong (##core#primitive "vtk_wrap_vtkProperty_SetInterpolationToPhong"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetInterpolationAsString(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-interpolation-as-string (##core#primitive "vtk_wrap_vtkProperty_GetInterpolationAsString"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetRepresentation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-representation (##core#primitive "vtk_wrap_vtkProperty_SetRepresentation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetRepresentationMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-representation-min-value (##core#primitive "vtk_wrap_vtkProperty_GetRepresentationMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetRepresentationMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-representation-max-value (##core#primitive "vtk_wrap_vtkProperty_GetRepresentationMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetRepresentation(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-representation (##core#primitive "vtk_wrap_vtkProperty_GetRepresentation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetRepresentationToPoints(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-representation-to-points (##core#primitive "vtk_wrap_vtkProperty_SetRepresentationToPoints"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetRepresentationToWireframe(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-representation-to-wireframe (##core#primitive "vtk_wrap_vtkProperty_SetRepresentationToWireframe"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetRepresentationToSurface(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-representation-to-surface (##core#primitive "vtk_wrap_vtkProperty_SetRepresentationToSurface"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetRepresentationAsString(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-representation-as-string (##core#primitive "vtk_wrap_vtkProperty_GetRepresentationAsString"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetAmbient(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-ambient (##core#primitive "vtk_wrap_vtkProperty_SetAmbient"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetAmbientMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-ambient-min-value (##core#primitive "vtk_wrap_vtkProperty_GetAmbientMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetAmbientMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-ambient-max-value (##core#primitive "vtk_wrap_vtkProperty_GetAmbientMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetAmbient(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-ambient (##core#primitive "vtk_wrap_vtkProperty_GetAmbient"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetDiffuse(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-diffuse (##core#primitive "vtk_wrap_vtkProperty_SetDiffuse"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetDiffuseMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-diffuse-min-value (##core#primitive "vtk_wrap_vtkProperty_GetDiffuseMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetDiffuseMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-diffuse-max-value (##core#primitive "vtk_wrap_vtkProperty_GetDiffuseMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetDiffuse(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-diffuse (##core#primitive "vtk_wrap_vtkProperty_GetDiffuse"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetSpecular(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-specular (##core#primitive "vtk_wrap_vtkProperty_SetSpecular"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecularMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular-min-value (##core#primitive "vtk_wrap_vtkProperty_GetSpecularMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecularMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular-max-value (##core#primitive "vtk_wrap_vtkProperty_GetSpecularMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecular(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular (##core#primitive "vtk_wrap_vtkProperty_GetSpecular"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetSpecularPower(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-specular-power (##core#primitive "vtk_wrap_vtkProperty_SetSpecularPower"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecularPowerMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular-power-min-value (##core#primitive "vtk_wrap_vtkProperty_GetSpecularPowerMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecularPowerMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular-power-max-value (##core#primitive "vtk_wrap_vtkProperty_GetSpecularPowerMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetSpecularPower(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-specular-power (##core#primitive "vtk_wrap_vtkProperty_GetSpecularPower"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetOpacity(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-opacity (##core#primitive "vtk_wrap_vtkProperty_SetOpacity"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetOpacityMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-opacity-min-value (##core#primitive "vtk_wrap_vtkProperty_GetOpacityMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetOpacityMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-opacity-max-value (##core#primitive "vtk_wrap_vtkProperty_GetOpacityMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetOpacity(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-opacity (##core#primitive "vtk_wrap_vtkProperty_GetOpacity"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetEdgeVisibility(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-edge-visibility (##core#primitive "vtk_wrap_vtkProperty_GetEdgeVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetEdgeVisibility(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-edge-visibility (##core#primitive "vtk_wrap_vtkProperty_SetEdgeVisibility"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_EdgeVisibilityOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-edge-visibility-on (##core#primitive "vtk_wrap_vtkProperty_EdgeVisibilityOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_EdgeVisibilityOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-edge-visibility-off (##core#primitive "vtk_wrap_vtkProperty_EdgeVisibilityOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetLineWidth(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-line-width (##core#primitive "vtk_wrap_vtkProperty_SetLineWidth"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineWidthMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-width-min-value (##core#primitive "vtk_wrap_vtkProperty_GetLineWidthMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineWidthMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-width-max-value (##core#primitive "vtk_wrap_vtkProperty_GetLineWidthMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineWidth(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-width (##core#primitive "vtk_wrap_vtkProperty_GetLineWidth"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetLineStipplePattern(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-line-stipple-pattern (##core#primitive "vtk_wrap_vtkProperty_SetLineStipplePattern"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineStipplePattern(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-stipple-pattern (##core#primitive "vtk_wrap_vtkProperty_GetLineStipplePattern"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetLineStippleRepeatFactor(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-line-stipple-repeat-factor (##core#primitive "vtk_wrap_vtkProperty_SetLineStippleRepeatFactor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineStippleRepeatFactorMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-stipple-repeat-factor-min-value (##core#primitive "vtk_wrap_vtkProperty_GetLineStippleRepeatFactorMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineStippleRepeatFactorMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-stipple-repeat-factor-max-value (##core#primitive "vtk_wrap_vtkProperty_GetLineStippleRepeatFactorMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetLineStippleRepeatFactor(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-line-stipple-repeat-factor (##core#primitive "vtk_wrap_vtkProperty_GetLineStippleRepeatFactor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetPointSize(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-point-size (##core#primitive "vtk_wrap_vtkProperty_SetPointSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetPointSizeMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-point-size-min-value (##core#primitive "vtk_wrap_vtkProperty_GetPointSizeMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetPointSizeMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-point-size-max-value (##core#primitive "vtk_wrap_vtkProperty_GetPointSizeMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetPointSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-point-size (##core#primitive "vtk_wrap_vtkProperty_GetPointSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetBackfaceCulling(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-backface-culling (##core#primitive "vtk_wrap_vtkProperty_GetBackfaceCulling"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetBackfaceCulling(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-backface-culling (##core#primitive "vtk_wrap_vtkProperty_SetBackfaceCulling"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_BackfaceCullingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-backface-culling-on (##core#primitive "vtk_wrap_vtkProperty_BackfaceCullingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_BackfaceCullingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-backface-culling-off (##core#primitive "vtk_wrap_vtkProperty_BackfaceCullingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_GetFrontfaceCulling(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-get-frontface-culling (##core#primitive "vtk_wrap_vtkProperty_GetFrontfaceCulling"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_SetFrontfaceCulling(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-property-set-frontface-culling (##core#primitive "vtk_wrap_vtkProperty_SetFrontfaceCulling"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_FrontfaceCullingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-frontface-culling-on (##core#primitive "vtk_wrap_vtkProperty_FrontfaceCullingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkProperty_FrontfaceCullingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-property-frontface-culling-off (##core#primitive "vtk_wrap_vtkProperty_FrontfaceCullingOff"))

(declare (foreign-declare "extern vtk_wrap_VTK_TEXTURE_QUALITY_DEFAULT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-texture-quality-default (##core#primitive "vtk_wrap_VTK_TEXTURE_QUALITY_DEFAULT"))

(declare (foreign-declare "extern vtk_wrap_VTK_TEXTURE_QUALITY_16BIT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-texture-quality-16bit (##core#primitive "vtk_wrap_VTK_TEXTURE_QUALITY_16BIT"))

(declare (foreign-declare "extern vtk_wrap_VTK_TEXTURE_QUALITY_32BIT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-texture-quality-32bit (##core#primitive "vtk_wrap_VTK_TEXTURE_QUALITY_32BIT"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_New(int,C_word,C_word);"))
(define vtk-vtk-texture-new (##core#primitive "vtk_wrap_vtkTexture_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-class-name (##core#primitive "vtk_wrap_vtkTexture_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-is-type-of (##core#primitive "vtk_wrap_vtkTexture_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-is-a (##core#primitive "vtk_wrap_vtkTexture_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-safe-down-cast (##core#primitive "vtk_wrap_vtkTexture_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-print-self (##core#primitive "vtk_wrap_vtkTexture_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_Render(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-render (##core#primitive "vtk_wrap_vtkTexture_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-release-graphics-resources (##core#primitive "vtk_wrap_vtkTexture_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_Load(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-load (##core#primitive "vtk_wrap_vtkTexture_Load"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetRepeat(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-repeat (##core#primitive "vtk_wrap_vtkTexture_GetRepeat"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetRepeat(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-repeat (##core#primitive "vtk_wrap_vtkTexture_SetRepeat"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_RepeatOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-repeat-on (##core#primitive "vtk_wrap_vtkTexture_RepeatOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_RepeatOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-repeat-off (##core#primitive "vtk_wrap_vtkTexture_RepeatOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetInterpolate(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-interpolate (##core#primitive "vtk_wrap_vtkTexture_GetInterpolate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetInterpolate(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-interpolate (##core#primitive "vtk_wrap_vtkTexture_SetInterpolate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_InterpolateOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-interpolate-on (##core#primitive "vtk_wrap_vtkTexture_InterpolateOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_InterpolateOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-interpolate-off (##core#primitive "vtk_wrap_vtkTexture_InterpolateOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetQuality(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-quality (##core#primitive "vtk_wrap_vtkTexture_SetQuality"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetQuality(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-quality (##core#primitive "vtk_wrap_vtkTexture_GetQuality"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetQualityToDefault(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-quality-to-default (##core#primitive "vtk_wrap_vtkTexture_SetQualityToDefault"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetQualityTo16Bit(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-quality-to16bit (##core#primitive "vtk_wrap_vtkTexture_SetQualityTo16Bit"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetQualityTo32Bit(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-quality-to32bit (##core#primitive "vtk_wrap_vtkTexture_SetQualityTo32Bit"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetMapColorScalarsThroughLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-map-color-scalars-through-lookup-table (##core#primitive "vtk_wrap_vtkTexture_GetMapColorScalarsThroughLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetMapColorScalarsThroughLookupTable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-map-color-scalars-through-lookup-table (##core#primitive "vtk_wrap_vtkTexture_SetMapColorScalarsThroughLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_MapColorScalarsThroughLookupTableOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-map-color-scalars-through-lookup-table-on (##core#primitive "vtk_wrap_vtkTexture_MapColorScalarsThroughLookupTableOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_MapColorScalarsThroughLookupTableOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-map-color-scalars-through-lookup-table-off (##core#primitive "vtk_wrap_vtkTexture_MapColorScalarsThroughLookupTableOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetInput(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-input (##core#primitive "vtk_wrap_vtkTexture_SetInput"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetInput(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-input (##core#primitive "vtk_wrap_vtkTexture_GetInput"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_SetLookupTable(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-set-lookup-table (##core#primitive "vtk_wrap_vtkTexture_SetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetLookupTable(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-lookup-table (##core#primitive "vtk_wrap_vtkTexture_GetLookupTable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_GetMappedScalars(int,C_word,C_word,C_word);"))
(define vtk-vtk-texture-get-mapped-scalars (##core#primitive "vtk_wrap_vtkTexture_GetMappedScalars"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkTexture_MapScalarsToColors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-texture-map-scalars-to-colors (##core#primitive "vtk_wrap_vtkTexture_MapScalarsToColors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-class-name (##core#primitive "vtk_wrap_vtkActor_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-is-type-of (##core#primitive "vtk_wrap_vtkActor_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-is-a (##core#primitive "vtk_wrap_vtkActor_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-safe-down-cast (##core#primitive "vtk_wrap_vtkActor_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-print-self (##core#primitive "vtk_wrap_vtkActor_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_New(int,C_word,C_word);"))
(define vtk-vtk-actor-new (##core#primitive "vtk_wrap_vtkActor_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetActors(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-actors (##core#primitive "vtk_wrap_vtkActor_GetActors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_RenderOpaqueGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-render-opaque-geometry (##core#primitive "vtk_wrap_vtkActor_RenderOpaqueGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_RenderTranslucentGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-render-translucent-geometry (##core#primitive "vtk_wrap_vtkActor_RenderTranslucentGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_Render(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-render (##core#primitive "vtk_wrap_vtkActor_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-shallow-copy (##core#primitive "vtk_wrap_vtkActor_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-release-graphics-resources (##core#primitive "vtk_wrap_vtkActor_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_SetProperty(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-set-property (##core#primitive "vtk_wrap_vtkActor_SetProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetProperty(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-property (##core#primitive "vtk_wrap_vtkActor_GetProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_MakeProperty(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-make-property (##core#primitive "vtk_wrap_vtkActor_MakeProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_SetBackfaceProperty(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-set-backface-property (##core#primitive "vtk_wrap_vtkActor_SetBackfaceProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetBackfaceProperty(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-backface-property (##core#primitive "vtk_wrap_vtkActor_GetBackfaceProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_SetTexture(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-set-texture (##core#primitive "vtk_wrap_vtkActor_SetTexture"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetTexture(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-texture (##core#primitive "vtk_wrap_vtkActor_GetTexture"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_SetMapper(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-set-mapper (##core#primitive "vtk_wrap_vtkActor_SetMapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetMapper(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-mapper (##core#primitive "vtk_wrap_vtkActor_GetMapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_ApplyProperties(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-apply-properties (##core#primitive "vtk_wrap_vtkActor_ApplyProperties"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-m-time (##core#primitive "vtk_wrap_vtkActor_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_Get_Redraw_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-redraw-m-time (##core#primitive "vtk_wrap_vtkActor_Get_Redraw_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_InitPartTraversal(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-init-part-traversal (##core#primitive "vtk_wrap_vtkActor_InitPartTraversal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetNextPart(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-next-part (##core#primitive "vtk_wrap_vtkActor_GetNextPart"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor_GetNumberOfParts(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-get-number-of-parts (##core#primitive "vtk_wrap_vtkActor_GetNumberOfParts"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-class-name (##core#primitive "vtk_wrap_vtkWindow_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-is-type-of (##core#primitive "vtk_wrap_vtkWindow_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-is-a (##core#primitive "vtk_wrap_vtkWindow_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-safe-down-cast (##core#primitive "vtk_wrap_vtkWindow_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-print-self (##core#primitive "vtk_wrap_vtkWindow_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetDisplayId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-display-id (##core#primitive "vtk_wrap_vtkWindow_SetDisplayId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetWindowId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-window-id (##core#primitive "vtk_wrap_vtkWindow_SetWindowId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetParentId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-parent-id (##core#primitive "vtk_wrap_vtkWindow_SetParentId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetGenericDisplayId(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-generic-display-id (##core#primitive "vtk_wrap_vtkWindow_GetGenericDisplayId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetGenericWindowId(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-generic-window-id (##core#primitive "vtk_wrap_vtkWindow_GetGenericWindowId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetGenericParentId(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-generic-parent-id (##core#primitive "vtk_wrap_vtkWindow_GetGenericParentId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetGenericContext(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-generic-context (##core#primitive "vtk_wrap_vtkWindow_GetGenericContext"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetGenericDrawable(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-generic-drawable (##core#primitive "vtk_wrap_vtkWindow_GetGenericDrawable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetWindowInfo(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-window-info (##core#primitive "vtk_wrap_vtkWindow_SetWindowInfo"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetParentInfo(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-parent-info (##core#primitive "vtk_wrap_vtkWindow_SetParentInfo"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetPosition(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-position (##core#primitive "vtk_wrap_vtkWindow_GetPosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-size (##core#primitive "vtk_wrap_vtkWindow_GetSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetMapped(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-mapped (##core#primitive "vtk_wrap_vtkWindow_SetMapped"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetMapped(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-mapped (##core#primitive "vtk_wrap_vtkWindow_GetMapped"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_MappedOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-mapped-on (##core#primitive "vtk_wrap_vtkWindow_MappedOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_MappedOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-mapped-off (##core#primitive "vtk_wrap_vtkWindow_MappedOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetErase(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-erase (##core#primitive "vtk_wrap_vtkWindow_SetErase"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetErase(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-erase (##core#primitive "vtk_wrap_vtkWindow_GetErase"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_EraseOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-erase-on (##core#primitive "vtk_wrap_vtkWindow_EraseOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_EraseOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-erase-off (##core#primitive "vtk_wrap_vtkWindow_EraseOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetDoubleBuffer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-double-buffer (##core#primitive "vtk_wrap_vtkWindow_SetDoubleBuffer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetDoubleBuffer(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-double-buffer (##core#primitive "vtk_wrap_vtkWindow_GetDoubleBuffer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_DoubleBufferOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-double-buffer-on (##core#primitive "vtk_wrap_vtkWindow_DoubleBufferOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_DoubleBufferOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-double-buffer-off (##core#primitive "vtk_wrap_vtkWindow_DoubleBufferOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetWindowName(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-window-name (##core#primitive "vtk_wrap_vtkWindow_GetWindowName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetWindowName(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-window-name (##core#primitive "vtk_wrap_vtkWindow_SetWindowName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_Render(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-render (##core#primitive "vtk_wrap_vtkWindow_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetPixelData(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-pixel-data (##core#primitive "vtk_wrap_vtkWindow_GetPixelData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetDPI(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-dpi (##core#primitive "vtk_wrap_vtkWindow_GetDPI"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetDPI(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-dpi (##core#primitive "vtk_wrap_vtkWindow_SetDPI"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_Get_DPI_Min_Value(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-dpi-min-value (##core#primitive "vtk_wrap_vtkWindow_Get_DPI_Min_Value"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_Get_DPI_Max_Value(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-dpi-max-value (##core#primitive "vtk_wrap_vtkWindow_Get_DPI_Max_Value"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_SetOffScreenRendering(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-window-set-off-screen-rendering (##core#primitive "vtk_wrap_vtkWindow_SetOffScreenRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_GetOffScreenRendering(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-get-off-screen-rendering (##core#primitive "vtk_wrap_vtkWindow_GetOffScreenRendering"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_OffScreenRenderingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-off-screen-rendering-on (##core#primitive "vtk_wrap_vtkWindow_OffScreenRenderingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_OffScreenRenderingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-off-screen-rendering-off (##core#primitive "vtk_wrap_vtkWindow_OffScreenRenderingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkWindow_MakeCurrent(int,C_word,C_word,C_word);"))
(define vtk-vtk-window-make-current (##core#primitive "vtk_wrap_vtkWindow_MakeCurrent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_New(int,C_word,C_word);"))
(define vtk-vtk-renderer-collection-new (##core#primitive "vtk_wrap_vtkRendererCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-get-class-name (##core#primitive "vtk_wrap_vtkRendererCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-is-type-of (##core#primitive "vtk_wrap_vtkRendererCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-is-a (##core#primitive "vtk_wrap_vtkRendererCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkRendererCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-add-item (##core#primitive "vtk_wrap_vtkRendererCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-get-next-item (##core#primitive "vtk_wrap_vtkRendererCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_Render(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-render (##core#primitive "vtk_wrap_vtkRendererCollection_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRendererCollection_RenderOverlay(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-collection-render-overlay (##core#primitive "vtk_wrap_vtkRendererCollection_RenderOverlay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_New(int,C_word,C_word);"))
(define vtk-vtk-graphics-factory-new (##core#primitive "vtk_wrap_vtkGraphicsFactory_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-graphics-factory-get-class-name (##core#primitive "vtk_wrap_vtkGraphicsFactory_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-graphics-factory-is-type-of (##core#primitive "vtk_wrap_vtkGraphicsFactory_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-graphics-factory-is-a (##core#primitive "vtk_wrap_vtkGraphicsFactory_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-graphics-factory-safe-down-cast (##core#primitive "vtk_wrap_vtkGraphicsFactory_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_CreateInstance(int,C_word,C_word,C_word);"))
(define vtk-vtk-graphics-factory-create-instance (##core#primitive "vtk_wrap_vtkGraphicsFactory_CreateInstance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkGraphicsFactory_GetRenderLibrary(int,C_word,C_word);"))
(define vtk-vtk-graphics-factory-get-render-library (##core#primitive "vtk_wrap_vtkGraphicsFactory_GetRenderLibrary"))

(declare (foreign-declare "extern C_word vtk_wrap_delete_vtkGraphicsFactory(int,C_word,C_word,C_word);"))
(define vtk-delete-vtk-graphics-factory (##core#primitive "vtk_wrap_delete_vtkGraphicsFactory"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_CRYSTAL_EYES(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-crystal-eyes (##core#primitive "vtk_wrap_VTK_STEREO_CRYSTAL_EYES"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_RED_BLUE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-red-blue (##core#primitive "vtk_wrap_VTK_STEREO_RED_BLUE"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_INTERLACED(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-interlaced (##core#primitive "vtk_wrap_VTK_STEREO_INTERLACED"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_LEFT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-left (##core#primitive "vtk_wrap_VTK_STEREO_LEFT"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_RIGHT(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-right (##core#primitive "vtk_wrap_VTK_STEREO_RIGHT"))

(declare (foreign-declare "extern vtk_wrap_VTK_STEREO_DRESDEN(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtk-stereo-dresden (##core#primitive "vtk_wrap_VTK_STEREO_DRESDEN"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-class-name (##core#primitive "vtk_wrap_vtkRenderWindow_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-is-type-of (##core#primitive "vtk_wrap_vtkRenderWindow_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-is-a (##core#primitive "vtk_wrap_vtkRenderWindow_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-safe-down-cast (##core#primitive "vtk_wrap_vtkRenderWindow_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-print-self (##core#primitive "vtk_wrap_vtkRenderWindow_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_New(int,C_word,C_word);"))
(define vtk-vtk-render-window-new (##core#primitive "vtk_wrap_vtkRenderWindow_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_AddRenderer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-add-renderer (##core#primitive "vtk_wrap_vtkRenderWindow_AddRenderer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_RemoveRenderer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-remove-renderer (##core#primitive "vtk_wrap_vtkRenderWindow_RemoveRenderer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetRenderLibrary(int,C_word,C_word);"))
(define vtk-vtk-render-window-get-render-library (##core#primitive "vtk_wrap_vtkRenderWindow_GetRenderLibrary"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetRenderers(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-renderers (##core#primitive "vtk_wrap_vtkRenderWindow_GetRenderers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Render(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-render (##core#primitive "vtk_wrap_vtkRenderWindow_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Start(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-start (##core#primitive "vtk_wrap_vtkRenderWindow_Start"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Frame(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-frame (##core#primitive "vtk_wrap_vtkRenderWindow_Frame"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_CopyResultFrame(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-copy-result-frame (##core#primitive "vtk_wrap_vtkRenderWindow_CopyResultFrame"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_MakeRenderWindowInteractor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-make-render-window-interactor (##core#primitive "vtk_wrap_vtkRenderWindow_MakeRenderWindowInteractor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_HideCursor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-hide-cursor (##core#primitive "vtk_wrap_vtkRenderWindow_HideCursor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_ShowCursor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-show-cursor (##core#primitive "vtk_wrap_vtkRenderWindow_ShowCursor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetFullScreen(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-full-screen (##core#primitive "vtk_wrap_vtkRenderWindow_SetFullScreen"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetFullScreen(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-full-screen (##core#primitive "vtk_wrap_vtkRenderWindow_GetFullScreen"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_FullScreenOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-full-screen-on (##core#primitive "vtk_wrap_vtkRenderWindow_FullScreenOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_FullScreenOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-full-screen-off (##core#primitive "vtk_wrap_vtkRenderWindow_FullScreenOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetBorders(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-borders (##core#primitive "vtk_wrap_vtkRenderWindow_SetBorders"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetBorders(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-borders (##core#primitive "vtk_wrap_vtkRenderWindow_GetBorders"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_BordersOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-borders-on (##core#primitive "vtk_wrap_vtkRenderWindow_BordersOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_BordersOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-borders-off (##core#primitive "vtk_wrap_vtkRenderWindow_BordersOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetStereoCapableWindow(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-stereo-capable-window (##core#primitive "vtk_wrap_vtkRenderWindow_GetStereoCapableWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoCapableWindowOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-capable-window-on (##core#primitive "vtk_wrap_vtkRenderWindow_StereoCapableWindowOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoCapableWindowOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-capable-window-off (##core#primitive "vtk_wrap_vtkRenderWindow_StereoCapableWindowOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoCapableWindow(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-capable-window (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoCapableWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetStereoRender(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-stereo-render (##core#primitive "vtk_wrap_vtkRenderWindow_GetStereoRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoRender(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-render (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoRenderOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-render-on (##core#primitive "vtk_wrap_vtkRenderWindow_StereoRenderOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoRenderOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-render-off (##core#primitive "vtk_wrap_vtkRenderWindow_StereoRenderOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetPointSmoothing(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-point-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_SetPointSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetPointSmoothing(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-point-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_GetPointSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_PointSmoothingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-point-smoothing-on (##core#primitive "vtk_wrap_vtkRenderWindow_PointSmoothingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_PointSmoothingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-point-smoothing-off (##core#primitive "vtk_wrap_vtkRenderWindow_PointSmoothingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetLineSmoothing(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-line-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_SetLineSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetLineSmoothing(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-line-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_GetLineSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_LineSmoothingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-line-smoothing-on (##core#primitive "vtk_wrap_vtkRenderWindow_LineSmoothingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_LineSmoothingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-line-smoothing-off (##core#primitive "vtk_wrap_vtkRenderWindow_LineSmoothingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetPolygonSmoothing(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-polygon-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_SetPolygonSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetPolygonSmoothing(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-polygon-smoothing (##core#primitive "vtk_wrap_vtkRenderWindow_GetPolygonSmoothing"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_PolygonSmoothingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-polygon-smoothing-on (##core#primitive "vtk_wrap_vtkRenderWindow_PolygonSmoothingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_PolygonSmoothingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-polygon-smoothing-off (##core#primitive "vtk_wrap_vtkRenderWindow_PolygonSmoothingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetStereoType(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-stereo-type (##core#primitive "vtk_wrap_vtkRenderWindow_GetStereoType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoType(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoType"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToCrystalEyes(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-crystal-eyes (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToCrystalEyes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToRedBlue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-red-blue (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToRedBlue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToInterlaced(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-interlaced (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToInterlaced"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToLeft(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-left (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToLeft"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToRight(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-right (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToRight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetStereoTypeToDresden(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-stereo-type-to-dresden (##core#primitive "vtk_wrap_vtkRenderWindow_SetStereoTypeToDresden"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetStereoTypeAsString(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-stereo-type-as-string (##core#primitive "vtk_wrap_vtkRenderWindow_GetStereoTypeAsString"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoUpdate(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-update (##core#primitive "vtk_wrap_vtkRenderWindow_StereoUpdate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoMidpoint(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-midpoint (##core#primitive "vtk_wrap_vtkRenderWindow_StereoMidpoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_StereoRenderComplete(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-stereo-render-complete (##core#primitive "vtk_wrap_vtkRenderWindow_StereoRenderComplete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_WindowRemap(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-window-remap (##core#primitive "vtk_wrap_vtkRenderWindow_WindowRemap"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetSwapBuffers(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-swap-buffers (##core#primitive "vtk_wrap_vtkRenderWindow_SetSwapBuffers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetSwapBuffers(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-swap-buffers (##core#primitive "vtk_wrap_vtkRenderWindow_GetSwapBuffers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SwapBuffersOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-swap-buffers-on (##core#primitive "vtk_wrap_vtkRenderWindow_SwapBuffersOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SwapBuffersOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-swap-buffers-off (##core#primitive "vtk_wrap_vtkRenderWindow_SwapBuffersOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetPixelData(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-pixel-data (##core#primitive "vtk_wrap_vtkRenderWindow_SetPixelData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Get_RGBA_Pixel_Data(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-rgba-pixel-data (##core#primitive "vtk_wrap_vtkRenderWindow_Get_RGBA_Pixel_Data"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Set_RGBA_Pixel_Data(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-rgba-pixel-data (##core#primitive "vtk_wrap_vtkRenderWindow_Set_RGBA_Pixel_Data"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Get_RGBA_Char_Pixel_Data(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-rgba-char-pixel-data (##core#primitive "vtk_wrap_vtkRenderWindow_Get_RGBA_Char_Pixel_Data"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Set_RGBA_Char_Pixel_Data(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-rgba-char-pixel-data (##core#primitive "vtk_wrap_vtkRenderWindow_Set_RGBA_Char_Pixel_Data"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetZbufferData(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-zbuffer-data (##core#primitive "vtk_wrap_vtkRenderWindow_GetZbufferData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetZbufferData(int,C_word,C_word,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-zbuffer-data (##core#primitive "vtk_wrap_vtkRenderWindow_SetZbufferData"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Get_AA_Frames(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-aa-frames (##core#primitive "vtk_wrap_vtkRenderWindow_Get_AA_Frames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Set_AA_Frames(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-aa-frames (##core#primitive "vtk_wrap_vtkRenderWindow_Set_AA_Frames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Get_FD_Frames(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-fd-frames (##core#primitive "vtk_wrap_vtkRenderWindow_Get_FD_Frames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_Set_FD_Frames(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-fd-frames (##core#primitive "vtk_wrap_vtkRenderWindow_Set_FD_Frames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetSubFrames(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-sub-frames (##core#primitive "vtk_wrap_vtkRenderWindow_GetSubFrames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetSubFrames(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-sub-frames (##core#primitive "vtk_wrap_vtkRenderWindow_SetSubFrames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetNeverRendered(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-never-rendered (##core#primitive "vtk_wrap_vtkRenderWindow_GetNeverRendered"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetAbortRender(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-abort-render (##core#primitive "vtk_wrap_vtkRenderWindow_GetAbortRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetAbortRender(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-abort-render (##core#primitive "vtk_wrap_vtkRenderWindow_SetAbortRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetInAbortCheck(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-in-abort-check (##core#primitive "vtk_wrap_vtkRenderWindow_GetInAbortCheck"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetInAbortCheck(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-in-abort-check (##core#primitive "vtk_wrap_vtkRenderWindow_SetInAbortCheck"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_CheckAbortStatus(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-check-abort-status (##core#primitive "vtk_wrap_vtkRenderWindow_CheckAbortStatus"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetEventPending(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-event-pending (##core#primitive "vtk_wrap_vtkRenderWindow_GetEventPending"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetAbortCheckMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-abort-check-method (##core#primitive "vtk_wrap_vtkRenderWindow_SetAbortCheckMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetAbortCheckMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-abort-check-method-arg-delete (##core#primitive "vtk_wrap_vtkRenderWindow_SetAbortCheckMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetDesiredUpdateRate(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-desired-update-rate (##core#primitive "vtk_wrap_vtkRenderWindow_SetDesiredUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetDesiredUpdateRate(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-desired-update-rate (##core#primitive "vtk_wrap_vtkRenderWindow_GetDesiredUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetNumberOfLayers(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-number-of-layers (##core#primitive "vtk_wrap_vtkRenderWindow_GetNumberOfLayers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetNumberOfLayers(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-number-of-layers (##core#primitive "vtk_wrap_vtkRenderWindow_SetNumberOfLayers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetNumberOfLayersMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-number-of-layers-min-value (##core#primitive "vtk_wrap_vtkRenderWindow_GetNumberOfLayersMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetNumberOfLayersMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-number-of-layers-max-value (##core#primitive "vtk_wrap_vtkRenderWindow_GetNumberOfLayersMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetInteractor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-interactor (##core#primitive "vtk_wrap_vtkRenderWindow_GetInteractor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetInteractor(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-interactor (##core#primitive "vtk_wrap_vtkRenderWindow_SetInteractor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-un-register (##core#primitive "vtk_wrap_vtkRenderWindow_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetDisplayId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-display-id (##core#primitive "vtk_wrap_vtkRenderWindow_SetDisplayId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetWindowId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-window-id (##core#primitive "vtk_wrap_vtkRenderWindow_SetWindowId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetParentId(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-parent-id (##core#primitive "vtk_wrap_vtkRenderWindow_SetParentId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetGenericDisplayId(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-generic-display-id (##core#primitive "vtk_wrap_vtkRenderWindow_GetGenericDisplayId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetGenericWindowId(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-generic-window-id (##core#primitive "vtk_wrap_vtkRenderWindow_GetGenericWindowId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetGenericParentId(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-generic-parent-id (##core#primitive "vtk_wrap_vtkRenderWindow_GetGenericParentId"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetGenericContext(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-generic-context (##core#primitive "vtk_wrap_vtkRenderWindow_GetGenericContext"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetGenericDrawable(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-generic-drawable (##core#primitive "vtk_wrap_vtkRenderWindow_GetGenericDrawable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetWindowInfo(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-window-info (##core#primitive "vtk_wrap_vtkRenderWindow_SetWindowInfo"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_SetParentInfo(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-set-parent-info (##core#primitive "vtk_wrap_vtkRenderWindow_SetParentInfo"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_MakeCurrent(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-make-current (##core#primitive "vtk_wrap_vtkRenderWindow_MakeCurrent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindow_GetDepthBufferSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-get-depth-buffer-size (##core#primitive "vtk_wrap_vtkRenderWindow_GetDepthBufferSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_Element_set(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-element-set (##core#primitive "vtk_wrap_vtkMatrix4x4_Element_set"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_Element_get(int,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-element-get (##core#primitive "vtk_wrap_vtkMatrix4x4_Element_get"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_New(int,C_word,C_word);"))
(define vtk-vtk-matrix4x4-new (##core#primitive "vtk_wrap_vtkMatrix4x4_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-get-class-name (##core#primitive "vtk_wrap_vtkMatrix4x4_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-is-type-of (##core#primitive "vtk_wrap_vtkMatrix4x4_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-is-a (##core#primitive "vtk_wrap_vtkMatrix4x4_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-safe-down-cast (##core#primitive "vtk_wrap_vtkMatrix4x4_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-print-self (##core#primitive "vtk_wrap_vtkMatrix4x4_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_MultiplyFloatPoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-multiply-float-point (##core#primitive "vtk_wrap_vtkMatrix4x4_MultiplyFloatPoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_MultiplyDoublePoint(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-multiply-double-point (##core#primitive "vtk_wrap_vtkMatrix4x4_MultiplyDoublePoint"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_SetElement(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-set-element (##core#primitive "vtk_wrap_vtkMatrix4x4_SetElement"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkMatrix4x4_GetElement(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-matrix4x4-get-element (##core#primitive "vtk_wrap_vtkMatrix4x4_GetElement"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_New(int,C_word,C_word);"))
(define vtk-vtk-light-collection-new (##core#primitive "vtk_wrap_vtkLightCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-get-class-name (##core#primitive "vtk_wrap_vtkLightCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-is-type-of (##core#primitive "vtk_wrap_vtkLightCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-is-a (##core#primitive "vtk_wrap_vtkLightCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkLightCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-add-item (##core#primitive "vtk_wrap_vtkLightCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkLightCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-light-collection-get-next-item (##core#primitive "vtk_wrap_vtkLightCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_New(int,C_word,C_word);"))
(define vtk-vtk-prop-collection-new (##core#primitive "vtk_wrap_vtkPropCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-get-class-name (##core#primitive "vtk_wrap_vtkPropCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-is-type-of (##core#primitive "vtk_wrap_vtkPropCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-is-a (##core#primitive "vtk_wrap_vtkPropCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkPropCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-add-item (##core#primitive "vtk_wrap_vtkPropCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_GetNextProp(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-get-next-prop (##core#primitive "vtk_wrap_vtkPropCollection_GetNextProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_GetLastProp(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-get-last-prop (##core#primitive "vtk_wrap_vtkPropCollection_GetLastProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkPropCollection_GetNumberOfPaths(int,C_word,C_word,C_word);"))
(define vtk-vtk-prop-collection-get-number-of-paths (##core#primitive "vtk_wrap_vtkPropCollection_GetNumberOfPaths"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_New(int,C_word,C_word);"))
(define vtk-vtk-volume-collection-new (##core#primitive "vtk_wrap_vtkVolumeCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-get-class-name (##core#primitive "vtk_wrap_vtkVolumeCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-is-type-of (##core#primitive "vtk_wrap_vtkVolumeCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-is-a (##core#primitive "vtk_wrap_vtkVolumeCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkVolumeCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-add-item (##core#primitive "vtk_wrap_vtkVolumeCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_GetNextVolume(int,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-get-next-volume (##core#primitive "vtk_wrap_vtkVolumeCollection_GetNextVolume"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkVolumeCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-volume-collection-get-next-item (##core#primitive "vtk_wrap_vtkVolumeCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_New(int,C_word,C_word);"))
(define vtk-vtk-culler-collection-new (##core#primitive "vtk_wrap_vtkCullerCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-get-class-name (##core#primitive "vtk_wrap_vtkCullerCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-is-type-of (##core#primitive "vtk_wrap_vtkCullerCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-is-a (##core#primitive "vtk_wrap_vtkCullerCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkCullerCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-add-item (##core#primitive "vtk_wrap_vtkCullerCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-get-next-item (##core#primitive "vtk_wrap_vtkCullerCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCullerCollection_GetLastItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-culler-collection-get-last-item (##core#primitive "vtk_wrap_vtkCullerCollection_GetLastItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-print-self (##core#primitive "vtk_wrap_vtkCamera_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-class-name (##core#primitive "vtk_wrap_vtkCamera_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-is-type-of (##core#primitive "vtk_wrap_vtkCamera_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-is-a (##core#primitive "vtk_wrap_vtkCamera_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-safe-down-cast (##core#primitive "vtk_wrap_vtkCamera_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_New(int,C_word,C_word);"))
(define vtk-vtk-camera-new (##core#primitive "vtk_wrap_vtkCamera_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_OrthogonalizeViewUp(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-orthogonalize-view-up (##core#primitive "vtk_wrap_vtkCamera_OrthogonalizeViewUp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetDistance(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-distance (##core#primitive "vtk_wrap_vtkCamera_SetDistance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetDistance(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-distance (##core#primitive "vtk_wrap_vtkCamera_GetDistance"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Dolly(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-dolly (##core#primitive "vtk_wrap_vtkCamera_Dolly"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetRoll(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-roll (##core#primitive "vtk_wrap_vtkCamera_SetRoll"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetRoll(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-roll (##core#primitive "vtk_wrap_vtkCamera_GetRoll"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Roll(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-roll (##core#primitive "vtk_wrap_vtkCamera_Roll"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Azimuth(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-azimuth (##core#primitive "vtk_wrap_vtkCamera_Azimuth"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Yaw(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-yaw (##core#primitive "vtk_wrap_vtkCamera_Yaw"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Elevation(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-elevation (##core#primitive "vtk_wrap_vtkCamera_Elevation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Pitch(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-pitch (##core#primitive "vtk_wrap_vtkCamera_Pitch"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetParallelProjection(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-parallel-projection (##core#primitive "vtk_wrap_vtkCamera_SetParallelProjection"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetParallelProjection(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-parallel-projection (##core#primitive "vtk_wrap_vtkCamera_GetParallelProjection"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_ParallelProjectionOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-parallel-projection-on (##core#primitive "vtk_wrap_vtkCamera_ParallelProjectionOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_ParallelProjectionOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-parallel-projection-off (##core#primitive "vtk_wrap_vtkCamera_ParallelProjectionOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetViewAngle(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-view-angle (##core#primitive "vtk_wrap_vtkCamera_SetViewAngle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetViewAngle(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-view-angle (##core#primitive "vtk_wrap_vtkCamera_GetViewAngle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetParallelScale(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-parallel-scale (##core#primitive "vtk_wrap_vtkCamera_SetParallelScale"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetParallelScale(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-parallel-scale (##core#primitive "vtk_wrap_vtkCamera_GetParallelScale"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Zoom(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-zoom (##core#primitive "vtk_wrap_vtkCamera_Zoom"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetThickness(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-thickness (##core#primitive "vtk_wrap_vtkCamera_SetThickness"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetThickness(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-thickness (##core#primitive "vtk_wrap_vtkCamera_GetThickness"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetWindowCenter(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-window-center (##core#primitive "vtk_wrap_vtkCamera_SetWindowCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetObliqueAngles(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-oblique-angles (##core#primitive "vtk_wrap_vtkCamera_SetObliqueAngles"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetEyeAngle(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-eye-angle (##core#primitive "vtk_wrap_vtkCamera_SetEyeAngle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetEyeAngle(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-eye-angle (##core#primitive "vtk_wrap_vtkCamera_GetEyeAngle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_SetFocalDisk(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-set-focal-disk (##core#primitive "vtk_wrap_vtkCamera_SetFocalDisk"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetFocalDisk(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-focal-disk (##core#primitive "vtk_wrap_vtkCamera_GetFocalDisk"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetViewTransformMatrix(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-view-transform-matrix (##core#primitive "vtk_wrap_vtkCamera_GetViewTransformMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetPerspectiveTransformMatrix(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-perspective-transform-matrix (##core#primitive "vtk_wrap_vtkCamera_GetPerspectiveTransformMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetCompositePerspectiveTransformMatrix(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-composite-perspective-transform-matrix (##core#primitive "vtk_wrap_vtkCamera_GetCompositePerspectiveTransformMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_Render(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-render (##core#primitive "vtk_wrap_vtkCamera_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetViewingRaysMTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-viewing-rays-mt-ime (##core#primitive "vtk_wrap_vtkCamera_GetViewingRaysMTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_ViewingRaysModified(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-viewing-rays-modified (##core#primitive "vtk_wrap_vtkCamera_ViewingRaysModified"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetFrustumPlanes(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-frustum-planes (##core#primitive "vtk_wrap_vtkCamera_GetFrustumPlanes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetOrientation(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-orientation (##core#primitive "vtk_wrap_vtkCamera_GetOrientation"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetOrientationWXYZ(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-orientation-wxyz (##core#primitive "vtk_wrap_vtkCamera_GetOrientationWXYZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_ComputeViewPlaneNormal(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-compute-view-plane-normal (##core#primitive "vtk_wrap_vtkCamera_ComputeViewPlaneNormal"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetCameraLightTransformMatrix(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-camera-light-transform-matrix (##core#primitive "vtk_wrap_vtkCamera_GetCameraLightTransformMatrix"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_UpdateViewport(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-update-viewport (##core#primitive "vtk_wrap_vtkCamera_UpdateViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetViewTransform(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-view-transform (##core#primitive "vtk_wrap_vtkCamera_GetViewTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetPerspectiveTransform(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-perspective-transform (##core#primitive "vtk_wrap_vtkCamera_GetPerspectiveTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetCompositePerspectiveTransform(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-composite-perspective-transform (##core#primitive "vtk_wrap_vtkCamera_GetCompositePerspectiveTransform"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkCamera_GetViewTransformObject(int,C_word,C_word,C_word);"))
(define vtk-vtk-camera-get-view-transform-object (##core#primitive "vtk_wrap_vtkCamera_GetViewTransformObject"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-print-self (##core#primitive "vtk_wrap_vtkActor2D_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-class-name (##core#primitive "vtk_wrap_vtkActor2D_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-is-type-of (##core#primitive "vtk_wrap_vtkActor2D_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-is-a (##core#primitive "vtk_wrap_vtkActor2D_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-safe-down-cast (##core#primitive "vtk_wrap_vtkActor2D_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_New(int,C_word,C_word);"))
(define vtk-vtk-actor2d-new (##core#primitive "vtk_wrap_vtkActor2D_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_RenderOverlay(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-render-overlay (##core#primitive "vtk_wrap_vtkActor2D_RenderOverlay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_RenderOpaqueGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-render-opaque-geometry (##core#primitive "vtk_wrap_vtkActor2D_RenderOpaqueGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_RenderTranslucentGeometry(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-render-translucent-geometry (##core#primitive "vtk_wrap_vtkActor2D_RenderTranslucentGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetMapper(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-mapper (##core#primitive "vtk_wrap_vtkActor2D_SetMapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetMapper(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-mapper (##core#primitive "vtk_wrap_vtkActor2D_GetMapper"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetLayerNumber(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-layer-number (##core#primitive "vtk_wrap_vtkActor2D_SetLayerNumber"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetLayerNumber(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-layer-number (##core#primitive "vtk_wrap_vtkActor2D_GetLayerNumber"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetProperty(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-property (##core#primitive "vtk_wrap_vtkActor2D_GetProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetProperty(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-property (##core#primitive "vtk_wrap_vtkActor2D_SetProperty"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetPositionCoordinate(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-position-coordinate (##core#primitive "vtk_wrap_vtkActor2D_GetPositionCoordinate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetPosition(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-position (##core#primitive "vtk_wrap_vtkActor2D_GetPosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetDisplayPosition(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-display-position (##core#primitive "vtk_wrap_vtkActor2D_SetDisplayPosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetPosition2Coordinate(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-position2coordinate (##core#primitive "vtk_wrap_vtkActor2D_GetPosition2Coordinate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetPosition2(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-position2 (##core#primitive "vtk_wrap_vtkActor2D_GetPosition2"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetWidth(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-width (##core#primitive "vtk_wrap_vtkActor2D_SetWidth"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetWidth(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-width (##core#primitive "vtk_wrap_vtkActor2D_GetWidth"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_SetHeight(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-set-height (##core#primitive "vtk_wrap_vtkActor2D_SetHeight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetHeight(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-height (##core#primitive "vtk_wrap_vtkActor2D_GetHeight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-m-time (##core#primitive "vtk_wrap_vtkActor2D_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_GetActors2D(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-get-actors2d (##core#primitive "vtk_wrap_vtkActor2D_GetActors2D"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_ShallowCopy(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-shallow-copy (##core#primitive "vtk_wrap_vtkActor2D_ShallowCopy"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActor2D_ReleaseGraphicsResources(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor2d-release-graphics-resources (##core#primitive "vtk_wrap_vtkActor2D_ReleaseGraphicsResources"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-class-name (##core#primitive "vtk_wrap_vtkViewport_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-is-type-of (##core#primitive "vtk_wrap_vtkViewport_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-is-a (##core#primitive "vtk_wrap_vtkViewport_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-safe-down-cast (##core#primitive "vtk_wrap_vtkViewport_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-print-self (##core#primitive "vtk_wrap_vtkViewport_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_AddProp(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-add-prop (##core#primitive "vtk_wrap_vtkViewport_AddProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetProps(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-props (##core#primitive "vtk_wrap_vtkViewport_GetProps"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_RemoveProp(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-remove-prop (##core#primitive "vtk_wrap_vtkViewport_RemoveProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_AddActor2D(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-add-actor2d (##core#primitive "vtk_wrap_vtkViewport_AddActor2D"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_RemoveActor2D(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-remove-actor2d (##core#primitive "vtk_wrap_vtkViewport_RemoveActor2D"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetActors2D(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-actors2d (##core#primitive "vtk_wrap_vtkViewport_GetActors2D"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_ComputeAspect(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-compute-aspect (##core#primitive "vtk_wrap_vtkViewport_ComputeAspect"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetCenter(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-center (##core#primitive "vtk_wrap_vtkViewport_GetCenter"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_IsInViewport(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-is-in-viewport (##core#primitive "vtk_wrap_vtkViewport_IsInViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetVTKWindow(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-vtkw-indow (##core#primitive "vtk_wrap_vtkViewport_GetVTKWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_SetStartRenderMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-set-start-render-method (##core#primitive "vtk_wrap_vtkViewport_SetStartRenderMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_SetEndRenderMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-set-end-render-method (##core#primitive "vtk_wrap_vtkViewport_SetEndRenderMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_SetStartRenderMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-set-start-render-method-arg-delete (##core#primitive "vtk_wrap_vtkViewport_SetStartRenderMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_SetEndRenderMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-set-end-render-method-arg-delete (##core#primitive "vtk_wrap_vtkViewport_SetEndRenderMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_DisplayToView(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-display-to-view (##core#primitive "vtk_wrap_vtkViewport_DisplayToView"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_ViewToDisplay(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-view-to-display (##core#primitive "vtk_wrap_vtkViewport_ViewToDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_DisplayToWorld(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-display-to-world (##core#primitive "vtk_wrap_vtkViewport_DisplayToWorld"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_WorldToDisplay(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-world-to-display (##core#primitive "vtk_wrap_vtkViewport_WorldToDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_LocalDisplayToDisplay(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-local-display-to-display (##core#primitive "vtk_wrap_vtkViewport_LocalDisplayToDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_DisplayToNormalizedDisplay(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-display-to-normalized-display (##core#primitive "vtk_wrap_vtkViewport_DisplayToNormalizedDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_NormalizedDisplayToViewport(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-normalized-display-to-viewport (##core#primitive "vtk_wrap_vtkViewport_NormalizedDisplayToViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_ViewportToNormalizedViewport(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-viewport-to-normalized-viewport (##core#primitive "vtk_wrap_vtkViewport_ViewportToNormalizedViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_NormalizedViewportToView(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-normalized-viewport-to-view (##core#primitive "vtk_wrap_vtkViewport_NormalizedViewportToView"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_DisplayToLocalDisplay(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-display-to-local-display (##core#primitive "vtk_wrap_vtkViewport_DisplayToLocalDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_NormalizedDisplayToDisplay(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-normalized-display-to-display (##core#primitive "vtk_wrap_vtkViewport_NormalizedDisplayToDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_ViewportToNormalizedDisplay(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-viewport-to-normalized-display (##core#primitive "vtk_wrap_vtkViewport_ViewportToNormalizedDisplay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_NormalizedViewportToViewport(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-normalized-viewport-to-viewport (##core#primitive "vtk_wrap_vtkViewport_NormalizedViewportToViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_ViewToNormalizedViewport(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-view-to-normalized-viewport (##core#primitive "vtk_wrap_vtkViewport_ViewToNormalizedViewport"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetSize(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-size (##core#primitive "vtk_wrap_vtkViewport_GetSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetOrigin(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-origin (##core#primitive "vtk_wrap_vtkViewport_GetOrigin"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_PickProp(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-pick-prop (##core#primitive "vtk_wrap_vtkViewport_PickProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_PickPropFrom(int,C_word,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-pick-prop-from (##core#primitive "vtk_wrap_vtkViewport_PickPropFrom"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetPickX(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-pick-x (##core#primitive "vtk_wrap_vtkViewport_GetPickX"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetPickY(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-pick-y (##core#primitive "vtk_wrap_vtkViewport_GetPickY"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetIsPicking(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-is-picking (##core#primitive "vtk_wrap_vtkViewport_GetIsPicking"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkViewport_GetPickedZ(int,C_word,C_word,C_word);"))
(define vtk-vtk-viewport-get-picked-z (##core#primitive "vtk_wrap_vtkViewport_GetPickedZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_New(int,C_word,C_word);"))
(define vtk-vtk-actor-collection-new (##core#primitive "vtk_wrap_vtkActorCollection_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-get-class-name (##core#primitive "vtk_wrap_vtkActorCollection_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-is-type-of (##core#primitive "vtk_wrap_vtkActorCollection_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-is-a (##core#primitive "vtk_wrap_vtkActorCollection_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-safe-down-cast (##core#primitive "vtk_wrap_vtkActorCollection_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_AddItem(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-add-item (##core#primitive "vtk_wrap_vtkActorCollection_AddItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_GetNextActor(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-get-next-actor (##core#primitive "vtk_wrap_vtkActorCollection_GetNextActor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_GetLastActor(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-get-last-actor (##core#primitive "vtk_wrap_vtkActorCollection_GetLastActor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_GetNextItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-get-next-item (##core#primitive "vtk_wrap_vtkActorCollection_GetNextItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_GetLastItem(int,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-get-last-item (##core#primitive "vtk_wrap_vtkActorCollection_GetLastItem"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkActorCollection_ApplyProperties(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-actor-collection-apply-properties (##core#primitive "vtk_wrap_vtkActorCollection_ApplyProperties"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-class-name (##core#primitive "vtk_wrap_vtkRenderer_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-is-type-of (##core#primitive "vtk_wrap_vtkRenderer_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-is-a (##core#primitive "vtk_wrap_vtkRenderer_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-safe-down-cast (##core#primitive "vtk_wrap_vtkRenderer_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-print-self (##core#primitive "vtk_wrap_vtkRenderer_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_New(int,C_word,C_word);"))
(define vtk-vtk-renderer-new (##core#primitive "vtk_wrap_vtkRenderer_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_AddLight(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-add-light (##core#primitive "vtk_wrap_vtkRenderer_AddLight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_AddActor(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-add-actor (##core#primitive "vtk_wrap_vtkRenderer_AddActor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_AddVolume(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-add-volume (##core#primitive "vtk_wrap_vtkRenderer_AddVolume"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_RemoveActor(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-remove-actor (##core#primitive "vtk_wrap_vtkRenderer_RemoveActor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_RemoveVolume(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-remove-volume (##core#primitive "vtk_wrap_vtkRenderer_RemoveVolume"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_RemoveLight(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-remove-light (##core#primitive "vtk_wrap_vtkRenderer_RemoveLight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetLights(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-lights (##core#primitive "vtk_wrap_vtkRenderer_GetLights"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetVolumes(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-volumes (##core#primitive "vtk_wrap_vtkRenderer_GetVolumes"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetActors(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-actors (##core#primitive "vtk_wrap_vtkRenderer_GetActors"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetActiveCamera(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-active-camera (##core#primitive "vtk_wrap_vtkRenderer_SetActiveCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetActiveCamera(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-active-camera (##core#primitive "vtk_wrap_vtkRenderer_GetActiveCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_MakeCamera(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-make-camera (##core#primitive "vtk_wrap_vtkRenderer_MakeCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_AddCuller(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-add-culler (##core#primitive "vtk_wrap_vtkRenderer_AddCuller"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_RemoveCuller(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-remove-culler (##core#primitive "vtk_wrap_vtkRenderer_RemoveCuller"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetCullers(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-cullers (##core#primitive "vtk_wrap_vtkRenderer_GetCullers"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetAllocatedRenderTime(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-allocated-render-time (##core#primitive "vtk_wrap_vtkRenderer_SetAllocatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetAllocatedRenderTime(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-allocated-render-time (##core#primitive "vtk_wrap_vtkRenderer_GetAllocatedRenderTime"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetTimeFactor(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-time-factor (##core#primitive "vtk_wrap_vtkRenderer_GetTimeFactor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_Render(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-render (##core#primitive "vtk_wrap_vtkRenderer_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_DeviceRender(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-device-render (##core#primitive "vtk_wrap_vtkRenderer_DeviceRender"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_Clear(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-clear (##core#primitive "vtk_wrap_vtkRenderer_Clear"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_VisibleActorCount(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-visible-actor-count (##core#primitive "vtk_wrap_vtkRenderer_VisibleActorCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_VisibleVolumeCount(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-visible-volume-count (##core#primitive "vtk_wrap_vtkRenderer_VisibleVolumeCount"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_CreateLight(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-create-light (##core#primitive "vtk_wrap_vtkRenderer_CreateLight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_MakeLight(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-make-light (##core#primitive "vtk_wrap_vtkRenderer_MakeLight"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_ComputeVisiblePropBounds(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-compute-visible-prop-bounds (##core#primitive "vtk_wrap_vtkRenderer_ComputeVisiblePropBounds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetRenderWindow(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-render-window (##core#primitive "vtk_wrap_vtkRenderer_SetRenderWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetRenderWindow(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-render-window (##core#primitive "vtk_wrap_vtkRenderer_GetRenderWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetVTKWindow(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-vtkw-indow (##core#primitive "vtk_wrap_vtkRenderer_GetVTKWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetTwoSidedLighting(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-two-sided-lighting (##core#primitive "vtk_wrap_vtkRenderer_GetTwoSidedLighting"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetTwoSidedLighting(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-two-sided-lighting (##core#primitive "vtk_wrap_vtkRenderer_SetTwoSidedLighting"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_TwoSidedLightingOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-two-sided-lighting-on (##core#primitive "vtk_wrap_vtkRenderer_TwoSidedLightingOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_TwoSidedLightingOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-two-sided-lighting-off (##core#primitive "vtk_wrap_vtkRenderer_TwoSidedLightingOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetBackingStore(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-backing-store (##core#primitive "vtk_wrap_vtkRenderer_SetBackingStore"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetBackingStore(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-backing-store (##core#primitive "vtk_wrap_vtkRenderer_GetBackingStore"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_BackingStoreOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-backing-store-on (##core#primitive "vtk_wrap_vtkRenderer_BackingStoreOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_BackingStoreOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-backing-store-off (##core#primitive "vtk_wrap_vtkRenderer_BackingStoreOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetInteractive(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-interactive (##core#primitive "vtk_wrap_vtkRenderer_SetInteractive"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetInteractive(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-interactive (##core#primitive "vtk_wrap_vtkRenderer_GetInteractive"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_InteractiveOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-interactive-on (##core#primitive "vtk_wrap_vtkRenderer_InteractiveOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_InteractiveOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-interactive-off (##core#primitive "vtk_wrap_vtkRenderer_InteractiveOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetLayer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-layer (##core#primitive "vtk_wrap_vtkRenderer_SetLayer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetLayer(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-layer (##core#primitive "vtk_wrap_vtkRenderer_GetLayer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_Transparent(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-transparent (##core#primitive "vtk_wrap_vtkRenderer_Transparent"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetZ(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-z (##core#primitive "vtk_wrap_vtkRenderer_GetZ"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_RenderOverlay(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-render-overlay (##core#primitive "vtk_wrap_vtkRenderer_RenderOverlay"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_Get_M_Time(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-m-time (##core#primitive "vtk_wrap_vtkRenderer_Get_M_Time"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetLastRenderTimeInSeconds(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-last-render-time-in-seconds (##core#primitive "vtk_wrap_vtkRenderer_GetLastRenderTimeInSeconds"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetNumberOfPropsRenderedAsGeometry(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-number-of-props-rendered-as-geometry (##core#primitive "vtk_wrap_vtkRenderer_GetNumberOfPropsRenderedAsGeometry"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_PickProp(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-pick-prop (##core#primitive "vtk_wrap_vtkRenderer_PickProp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_SetLightFollowCamera(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-set-light-follow-camera (##core#primitive "vtk_wrap_vtkRenderer_SetLightFollowCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetLightFollowCamera(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-light-follow-camera (##core#primitive "vtk_wrap_vtkRenderer_GetLightFollowCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_LightFollowCameraOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-light-follow-camera-on (##core#primitive "vtk_wrap_vtkRenderer_LightFollowCameraOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_LightFollowCameraOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-light-follow-camera-off (##core#primitive "vtk_wrap_vtkRenderer_LightFollowCameraOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderer_GetRayCaster(int,C_word,C_word,C_word);"))
(define vtk-vtk-renderer-get-ray-caster (##core#primitive "vtk_wrap_vtkRenderer_GetRayCaster"))

(declare (foreign-declare "extern vtk_wrap_VTKI_TIMER_FIRST(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtki-timer-first (##core#primitive "vtk_wrap_VTKI_TIMER_FIRST"))

(declare (foreign-declare "extern vtk_wrap_VTKI_TIMER_UPDATE(int argc, C_word closure, C_word continuation, C_word value);"))
(define vtk-vtki-timer-update (##core#primitive "vtk_wrap_VTKI_TIMER_UPDATE"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_New(int,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-new (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_New"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetClassName(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-class-name (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetClassName"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_IsTypeOf(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-is-type-of (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_IsTypeOf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_IsA(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-is-a (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_IsA"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SafeDownCast(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-safe-down-cast (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SafeDownCast"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_PrintSelf(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-print-self (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_PrintSelf"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_Initialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-initialize (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_Initialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_ReInitialize(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-re-initialize (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_ReInitialize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_UnRegister(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-un-register (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_UnRegister"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_Start(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-start (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_Start"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_Enable(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-enable (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_Enable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_Disable(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-disable (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_Disable"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetEnabled(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-enabled (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetEnabled"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetRenderWindow(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-render-window (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetRenderWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetRenderWindow(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-render-window (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetRenderWindow"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_UpdateSize(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-update-size (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_UpdateSize"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_CreateTimer(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-create-timer (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_CreateTimer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_DestroyTimer(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-destroy-timer (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_DestroyTimer"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_TerminateApp(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-terminate-app (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_TerminateApp"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetInteractorStyle(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-interactor-style (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetInteractorStyle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetInteractorStyle(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-interactor-style (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetInteractorStyle"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetLightFollowCamera(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-light-follow-camera (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetLightFollowCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetLightFollowCamera(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-light-follow-camera (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetLightFollowCamera"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_LightFollowCameraOn(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-light-follow-camera-on (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_LightFollowCameraOn"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_LightFollowCameraOff(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-light-follow-camera-off (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_LightFollowCameraOff"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetDesiredUpdateRate(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-desired-update-rate (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetDesiredUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRateMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-desired-update-rate-min-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRateMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRateMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-desired-update-rate-max-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRateMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRate(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-desired-update-rate (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetDesiredUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetStillUpdateRate(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-still-update-rate (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetStillUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRateMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-still-update-rate-min-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRateMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRateMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-still-update-rate-max-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRateMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRate(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-still-update-rate (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetStillUpdateRate"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetInitialized(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-initialized (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetInitialized"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetPicker(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-picker (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetPicker"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetPicker(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-picker (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetPicker"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_CreateDefaultPicker(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-create-default-picker (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_CreateDefaultPicker"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetStartPickMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-start-pick-method (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetStartPickMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetStartPickMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-start-pick-method-arg-delete (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetStartPickMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetEndPickMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-end-pick-method (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetEndPickMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetEndPickMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-end-pick-method-arg-delete (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetEndPickMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetUserMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-user-method (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetUserMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetUserMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-user-method-arg-delete (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetUserMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetExitMethod(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-exit-method (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetExitMethod"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetExitMethodArgDelete(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-exit-method-arg-delete (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetExitMethodArgDelete"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_ExitCallback(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-exit-callback (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_ExitCallback"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_UserCallback(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-user-callback (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_UserCallback"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_StartPickCallback(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-start-pick-callback (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_StartPickCallback"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_EndPickCallback(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-end-pick-callback (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_EndPickCallback"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetMousePosition(int,C_word,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-mouse-position (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetMousePosition"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_HideCursor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-hide-cursor (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_HideCursor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_ShowCursor(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-show-cursor (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_ShowCursor"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_Render(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-render (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_Render"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetNumberOfFlyFrames(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-number-of-fly-frames (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetNumberOfFlyFrames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFramesMinValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-number-of-fly-frames-min-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFramesMinValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFramesMaxValue(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-number-of-fly-frames-max-value (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFramesMaxValue"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFrames(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-number-of-fly-frames (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetNumberOfFlyFrames"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_SetDolly(int,C_word,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-set-dolly (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_SetDolly"))

(declare (foreign-declare "extern C_word vtk_wrap_vtkRenderWindowInteractor_GetDolly(int,C_word,C_word,C_word);"))
(define vtk-vtk-render-window-interactor-get-dolly (##core#primitive "vtk_wrap_vtkRenderWindowInteractor_GetDolly"))


