#include "vtkQuadric.h"
#include "vtkSampleFunction.h"
#include "vtkContourFilter.h"
#include "vtkOutlineFilter.h"
#include "vtkPolyDataMapper.h"
#include "vtkActor.h"
#include "vtkRenderWindow.h"
#include "vtkRenderer.h"
#include "vtkRenderWindowInteractor.h"

void main ()
{
  // -- create the quadric function object --

  // create the quadric function definition
  vtkQuadric *quadric = vtkQuadric::New();
  quadric->SetCoefficients(.5,1,.2,0,.1,0,0,.2,0,0);

  // sample the quadric function
  vtkSampleFunction *sample = vtkSampleFunction::New();
  sample->SetSampleDimensions(50,50,50);
  sample->SetImplicitFunction(quadric);

  // Create five surfaces F(x,y,z) = constant between range specified
  vtkContourFilter *contours = vtkContourFilter::New();
  contours->SetInput(sample->GetOutput());
  contours->GenerateValues(5, 0.0, 1.2);

  // map the contours to graphical primitives
  vtkPolyDataMapper *contMapper = vtkPolyDataMapper::New();
  contMapper->SetInput(contours->GetOutput());
  contMapper->SetScalarRange(0.0, 1.2);

  // create an actor for the contours
  vtkActor *contActor = vtkActor::New();
  contActor->SetMapper(contMapper);

  // -- create a box around the function to indicate the sampling volume --

  // create outline
  vtkOutlineFilter *outline = vtkOutlineFilter::New();
  outline->SetInput(sample->GetOutput());

  // map it to graphics primitives
  vtkPolyDataMapper *outlineMapper = vtkPolyDataMapper::New();
  outlineMapper->SetInput(outline->GetOutput());

  // create an actor for it
  vtkActor *outlineActor = vtkActor::New();
  outlineActor->SetMapper(outlineMapper);
  outlineActor->GetProperty()->SetColor(0,0,0);

  // -- render both of the objects --

  // a renderer and render window
  vtkRenderer *ren1 = vtkRenderer::New();
  vtkRenderWindow *renWin = vtkRenderWindow::New();
  renWin->AddRenderer(ren1);

  // an interactor
  vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();
  iren->SetRenderWindow(renWin);

  // add the actors to the scene
  ren1->AddActor(contActor);
  ren1->AddActor(outlineActor);
  ren1->SetBackground(1,1,1); // Background color white

  // render an image (lights and cameras are created automatically)
  renWin->Render();

  // begin mouse interaction
  iren->Start();
}
