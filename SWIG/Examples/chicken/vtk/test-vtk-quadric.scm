;; run with './vtk test-vtk-quadric.scm'

;; All generic methods must be included first
(include "example_generic")

;; After generic are defined, can include TinyCLOS code
(include "example_clos")

;; ------------------------------
;; Visualizing a Quadric Function
;; ------------------------------

;; -- create the quadric function object --

;; create the quadric function definition
(define quadric (+example-vtk-quadric-new+))
(-SetCoefficients- quadric 0.5 1.0 0.2 0. 0.1 0. 0. 0.2 0. 0.)

;; sample the quadric function
(define sample (+example-vtk-sample-function-new+))
(-SetSampleDimensions- sample 50 50 50)
(-SetImplicitFunction- sample quadric)

;; Create five surfaces F(x,y,z) = constant between range specified
(define contours (+example-vtk-contour-filter-new+))
(-SetInput- contours (-GetOutput- sample));
(-GenerateValues- contours 5 0.0 1.2)

;; map the contours to graphical primitives
(define contMapper (+example-vtk-poly-data-mapper-new+))
(-SetInput- contMapper (-GetOutput- contours));
(-SetScalarRange- contMapper 0.0 1.2)

;; create an actor for the contours
(define contActor (+example-vtk-actor-new+))
(-SetMapper- contActor contMapper)

;; -- create a box around the function to indicate the sampling volume --

;; create outline
(define outline (+example-vtk-outline-filter-new+))
(-SetInput- outline (-GetOutput- sample));

;; map it to graphics primitives
(define outlineMapper (+example-vtk-poly-data-mapper-new+))
(-SetInput- outlineMapper (-GetOutput- outline));

;; create an actor for it
(define outlineActor (+example-vtk-actor-new+))
(-SetMapper- outlineActor outlineMapper)
(-SetColor- (-GetProperty- outlineActor) 0. 0. 0.)

;; -- render both of the objects --

;; a renderer and render window
(define ren1 (+example-vtk-renderer-new+))
(define renwin (+example-vtk-render-window-new+))
(-AddRenderer- renwin ren1)

;; an interactor
(define iren (+example-vtk-render-window-interactor-new+))
(-SetRenderWindow- iren renwin)

;; add the actors to the scene
(-AddActor- ren1 contActor)
(-AddActor- ren1 outlineActor)
(-SetBackground- ren1 1. 1. 1.) ;; Background color white

;; render an image (lights and cameras are created automatically)
(-Render- renwin)

;; begin mouse interaction
(display "Press 'q' to quit ...\n\n")
(-Start- iren)
