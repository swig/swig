/* File : example.i */
%module example

/* STANDARD VTK CLASSES */

%{
/* Put headers and other declarations here.  SWIG does not parse this
   section. */
#include "vtkConfigure.h"
#include "vtkSystemIncludes.h"
#ifdef VTK_MAJOR_VERSION
  /* only defined since Nov 19 2002, just after 4.0 release */
#include "vtkObjectBase.h"
#endif
#include "vtkIndent.h"
#include "vtkTimeStamp.h"
#include "vtkSetGet.h"
#include "vtkObject.h"
#include "vtkCommand.h"
#include "vtkDataArray.h"
#include "vtkIdList.h"
#include "vtkFieldData.h"
#include "vtkDataObject.h"
#include "vtkDataSetAttributes.h"
#include "vtkCellData.h"
#include "vtkPointData.h"
#include "vtkCell.h"
#include "vtkGenericCell.h"
#include "vtkCellTypes.h"
#include "vtkDataSet.h"
#include "vtkLocator.h"
#include "vtkPoints.h"
#include "vtkPointLocator.h"
#include "vtkPointSet.h"
#include "vtkCellArray.h"
#include "vtkCellLinks.h"
#include "vtkProcessObject.h"
#include "vtkSource.h"
#include "vtkPolyData.h"
#include "vtkPolyDataSource.h"
#include "vtkSphereSource.h"
#include "vtkCollection.h"
#include "vtkImplicitFunction.h"
#include "vtkPlane.h"
#include "vtkPlaneCollection.h"
#include "vtkPlanes.h"
#include "vtkTimerLog.h"
#include "vtkAbstractMapper.h"
#include "vtkAbstractMapper3D.h"
#include "vtkScalarsToColors.h"
#include "vtkMapper.h"
#include "vtkQuadric.h"
#include "vtkImageSource.h"
#include "vtkImageData.h"
#include "vtkStructuredPoints.h"
#include "vtkStructuredPointsSource.h"
#include "vtkSampleFunction.h"
#include "vtkDataSetToPolyDataFilter.h"
#include "vtkContourValues.h"
#include "vtkContourFilter.h"
#include "vtkOutlineFilter.h"
#include "vtkPolyDataMapper.h"
#include "vtkProp.h"
#include "vtkProp3D.h"
#include "vtkProperty.h"
#include "vtkTexture.h"
#include "vtkActor.h"
#include "vtkWindow.h"
#include "vtkRendererCollection.h"
#include "vtkGraphicsFactory.h"
#include "vtkRenderWindow.h"
#include "vtkMatrix4x4.h"
#include "vtkLightCollection.h"
#include "vtkPropCollection.h"
#include "vtkVolumeCollection.h"
#include "vtkCullerCollection.h"
#include "vtkCamera.h"
#include "vtkActor2D.h"
#include "vtkViewport.h"
#include "vtkActorCollection.h"
#include "vtkRenderer.h"
#include "vtkRenderWindowInteractor.h"
%}

%include typemaps.i

#define VTK_COMMON_EXPORT
#define VTK_FILTERING_EXPORT
#define VTK_GRAPHICS_EXPORT
#define VTK_IMAGING_EXPORT
#define VTK_RENDERING_EXPORT


/* We need a way to convert the input and output arguments that are
   VTK objects into TinyCLOS objects, and vice versa.  We can use the
   clos_in and clos_out typemaps for this.  Just specify the typemaps
   for classes that are at the top of the inheritance tree.

   We have things quite easy because VTK handles object deletion with
   reference counting (so we don't have to make a finalizer procedure
   for the garbage collector), and because most of the classes derive
   from vtkObjectBase or vtkObject.

   In post VTK 4.0 releases, most things derive from vtkObjectBase.
   In other releases, things come from vtkObject. */
#ifdef VTK_MAJOR_VERSION
  /* only defined since Nov 19 2002, just after 4.0 release */
%typemap("clos_in") vtkObjectBase * = SIMPLE_CLOS_OBJECT *;
%typemap("clos_out") vtkObjectBase * = SIMPLE_CLOS_OBJECT *;
#else
%typemap("clos_in") vtkObject * = SIMPLE_CLOS_OBJECT *;
%typemap("clos_out") vtkObject * = SIMPLE_CLOS_OBJECT *;
#endif
%apply SIMPLE_CLOS_OBJECT * { 
  vtkIndent*, vtkTimeStamp*, vtkCollectionElement*, vtkTimerLogEntry*, 
    vtkCommand*, _vtkLink_s*
}; 

/* We have one problem with the above typemaps ... they assume that
   SWIG can know that a given class is derived from one of the above
   superclasses (like derived from vtkObjectBase).  However, sometimes
   SWIG will get to a function or member declaration that relies some
   object that was forward declared.  For example,

   class vtkRenderer;
   class vtkRenderWindow {
      // ...
      virtual void AddRenderer (vtkRenderer *rendererArg);
      // ...
   };

   In this case, SWIG cannot know that vtkRenderer is derived from
   vtkObject, and hence will not put a TinyCLOS clos_in/clos_out
   converter around "rendererArg" (instead, you will have to pass in a
   low-level SWIG CHICKEN object pointer).

   To help SWIG out, we explicitly define clos_in/clos_out typemaps
   for some of the classes that are forward declared.
 */
%apply SIMPLE_CLOS_OBJECT * {
  vtkRenderer*
};

/* The -mixed command line argument for SWIG will screw up on esoteric
   names (with two upcase characters in a row) like below.  Example:
   GetMTime becomes get-mt-ime, but if we rename it to Get_M_Time, it
   becomes get-m-time.  So we help it along by putting in
   underscores. */
%rename GetMTime           Get_M_Time;
%rename SetMTime           Set_M_Time;
%rename ShouldIReleaseData Should_I_Release_Data;
%rename SetPipelineMTime   Set_Pipeline_M_Time;
%rename GetPipelineMTime   Get_Pipeline_M_Time;
%rename SetActiveTCoords   Set_Active_T_Coords;
%rename GetActiveTCoords   Get_Active_T_Coords;
%rename SetTCoords         Set_T_Coords;
%rename GetTCoords         Get_T_Coords;
%rename SetCopyTCoords     Set_Copy_T_Coords;
%rename GetCopyTCoords     Get_Copy_T_Coords;
%rename HitBBox            Hit_B_Box;
%rename IsARenderIntoImageMapper Is_A_Render_Into_Image_Mapper;
%rename IsARayCastMapper         Is_A_Ray_Cast_Mapper;
%rename GetRedrawMTime     Get_Redraw_M_Time;
%rename SetRedrawMTime     Set_Redraw_M_Time;
%rename GetXRange          Get_X_Range;
%rename SetXRange          Set_X_Range;
%rename GetYRange          Get_Y_Range;
%rename SetYRange          Set_Y_Range;
%rename GetZRange          Get_Z_Range;
%rename SetZRange          Set_Z_Range;
%rename GetDPIMinValue     Get_DPI_Min_Value;
%rename SetDPIMinValue     Set_DPI_Min_Value;
%rename GetDPIMaxValue     Get_DPI_Max_Value;
%rename SetDPIMaxValue     Set_DPI_Max_Value;
%rename GetRGBAPixelData   Get_RGBA_Pixel_Data;
%rename SetRGBAPixelData   Set_RGBA_Pixel_Data;
%rename GetRGBACharPixelData     Get_RGBA_Char_Pixel_Data;
%rename SetRGBACharPixelData     Set_RGBA_Char_Pixel_Data;
%rename GetAAFrames        Get_AA_Frames;
%rename SetAAFrames        Set_AA_Frames;
%rename GetFDFrames        Get_FD_Frames;
%rename SetFDFrames        Set_FD_Frames;

/* Things that are too difficult to wrap: We have 2 general mechanisms
   to exclude the difficult classes and/or methods from SWIG.

   1.  Write an SWIG interface file (we use a .i suffix) that is a
   copy of the header file with the difficult parts removed.

   2.  Use "%ignore" directives, before SWIG parses the relevant
   class/method/function/variable declaration.  Example: 

       %ignore vtkDataSet::POINT_DATA_FIELD;
       %ignore someVariable;
       %ignore someFunction;
       %ignore someMethod;
       %ignore someClass;
       %ignore someClass::someMethod;

   Now it so happens that VTK already comes with its own
   Python/TCL/Java wrapper modules, and the difficult sections have
   already been marked in the header files.  VTK uses //BTX to mark
   the beginning of a difficult section, and //ETX to mark the end.
   So we use a simple 'sed' script to change //BTX to "#if 0" and
   //ETX to "#endif", and place the result in a .i file.  This is done
   by the "btx-etx" Makefile target.

*/

%include "vtkConfigure.h"
%include "vtkSystemIncludes.h"
#ifdef VTK_MAJOR_VERSION
  /* only defined since Nov 19 2002, just after 4.0 release */
%include "vtkObjectBase.h"
#endif
%include "vtkIndent.h"
%include "vtkTimeStamp.h"
%include "vtkSetGet.h"
%include "vtkCommand.h"
%include "vtkObject.h"
%include "vtkDataArray.h"
%include "vtkIdList.h"
%include "vtkFieldData.i"
%include "vtkDataObject.h"
%include "vtkDataSetAttributes.i"
%include "vtkCellData.h"
%include "vtkPointData.h"
%include "vtkCell.h"
%include "vtkGenericCell.h"
%include "vtkCellTypes.h"
%include "vtkDataSet.h"
%include "vtkLocator.h"
%include "vtkPoints.h"
%include "vtkPointLocator.h"
%include "vtkPointSet.h"
%include "vtkCellArray.h"
%include "vtkCellLinks.h"
%include "vtkProcessObject.h"
%include "vtkSource.h"
%include "vtkPolyData.h"
%include "vtkPolyDataSource.h"
%include "vtkSphereSource.h"
%include "vtkCollection.h"
%include "vtkImplicitFunction.h"
%include "vtkPlane.h"
%include "vtkPlaneCollection.h"
%include "vtkPlanes.h"
%include "vtkTimerLog.h"
%include "vtkAbstractMapper.h"
%include "vtkAbstractMapper3D.h"
%include "vtkScalarsToColors.h"
%include "vtkMapper.h"
%include "vtkQuadric.h"
%include "vtkImageSource.h"
%include "vtkImageData.h"
%include "vtkStructuredPoints.h"
%include "vtkStructuredPointsSource.h"
%include "vtkSampleFunction.h"
%include "vtkDataSetToPolyDataFilter.h"
%include "vtkContourValues.h"
%include "vtkContourFilter.h"
%include "vtkOutlineFilter.h"
%include "vtkPolyDataMapper.h"
%include "vtkProp.h"
%include "vtkProp3D.h"
%include "vtkProperty.h"
%include "vtkTexture.h"
%include "vtkActor.h"
%include "vtkWindow.h"
%include "vtkRendererCollection.h"
%include "vtkGraphicsFactory.h"
%include "vtkRenderWindow.h"
%include "vtkMatrix4x4.h"
%include "vtkLightCollection.h"
%include "vtkPropCollection.h"
%include "vtkVolumeCollection.h"
%include "vtkCullerCollection.h"
%include "vtkCamera.h"
%include "vtkActor2D.h"
%include "vtkViewport.h"
%include "vtkActorCollection.h"
%include "vtkRenderer.h"
%include "vtkRenderWindowInteractor.h"

/* VTK CALLBACKS */

/* We want lambda procedures to be used as callbacks in VTK.  To do
   this, we must create a subclass of vtkCommand and let it's Execute
   method call our Scheme lambda procedures. */

%{
#include "vtkChickenCommand.h"
vtkObject * pointerToVtkObject (C_word obj) { 
  if (!C_swig_is_ptr(obj)) return 0;
  return (vtkObject*)C_pointer_address(obj); 
}
vtkCommand* pointerToVtkCommand (C_word obj) { 
  if (!C_swig_is_ptr(obj)) return 0;
  return (vtkCommand*)C_pointer_address(obj); 
}
%}

%include "vtkChickenCommand.h"
extern vtkObject * pointerToVtkObject (C_word obj);
extern vtkCommand* pointerToVtkCommand (C_word obj);

%insert(chicken) {
(define-external 
  (execute_vtk_chicken_command
   (c-pointer thisCommand) ;; vtkCommand *
   (scheme-object continuation) 
   (c-pointer caller) ;; vtkObject *
   (unsigned-long eventId)
   (c-pointer callData) ;; void *
   )
 void
 (continuation (+example-pointer-to-vtk-command+ thisCommand)
  (+example-pointer-to-vtk-object+ caller) eventId callData)
 )
}

/* DEBUGGING CLASSES */

%{
#include <iostream>

istream *std_cin  = &cin;
ostream *std_cout = &cout;
ostream *std_cerr = &cerr;

%}

extern istream *std_cin;
extern ostream *std_cout;
extern ostream *std_cerr;
