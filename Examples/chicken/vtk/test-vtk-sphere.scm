;; run with './vtk test-vtk-sphere.scm'

;; All generic methods must be included first
(include "example_generic")

;; After generic are defined, can include TinyCLOS code
(include "example_clos")

;; -----------------
;; Creating a sphere
;; -----------------

;; create sphere geometry
(define sphere (+example-vtk-sphere-source-new+))
(-SetRadius- sphere 1.0)
(-SetThetaResolution- sphere 18)
(-SetPhiResolution- sphere 18)

;; map to graphics library
(define mymap (+example-vtk-poly-data-mapper-new+))
(-SetInput- mymap (-GetOutput- sphere))

;; actor coordinates geometry, properties, transformation
(define aSphere (+example-vtk-actor-new+))
(-SetMapper- aSphere mymap)
(-SetColor- (-GetProperty- aSphere) 0. 0. 1.) ;; sphere color blue

;; a renderer and render window
(define ren1 (+example-vtk-renderer-new+))
(define renWin (+example-vtk-render-window-new+))
(-AddRenderer- renWin ren1)

;; an interactor
(define iren (+example-vtk-render-window-interactor-new+))
(-SetRenderWindow- iren renWin)

;; add the actor to the scene
(-AddActor- ren1 aSphere)
(-SetBackground- ren1 1. 1. 1.) ;; Background color white

;; render an image (lights and cameras are created automatically)
(-Render- renWin)

;; begin mouse interaction
(display "Press 'q' to quit ...\n\n")
(-Start- iren)
