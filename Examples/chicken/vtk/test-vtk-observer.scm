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

;; create an observer
(define printStatus 
  (lambda (thisCommand caller eventId data)
    (display "Received an event!\n")
    (display "event: ")
    (display (example-vtk-command-get-string-from-event-id 
              (exact->inexact eventId)))
    (display "\n")
    (display "caller: class ")
    (display (-GetClassName- caller))
    (display "\n")
    (-PrintSelf- caller (example-std-cout) (make <example-vtk-indent> 4))
    (display "data: ")
    (display data)
    (display "\n\n")))
(define printStatusObserver (example-vtk-chicken-command-new printStatus))

;; attach observer to sphere's Start event
(-AddObserver- sphere (exact->inexact (example-vtk-command-start-event))
               printStatusObserver)

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

;; attach observer to interactor's User event
(-AddObserver- iren (exact->inexact (example-vtk-command-user-event))
               printStatusObserver)

;; add the actor to the scene
(-AddActor- ren1 aSphere)
(-SetBackground- ren1 1. 1. 1.) ;; Background color white

;; render an image (lights and cameras are created automatically)
(-Render- renWin)

;; begin mouse interaction
(display "Press 'u' for user event, and 'q' to quit ...\n\n")
(-Start- iren)
