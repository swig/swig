(declare (unit precsi))
(declare (uses example))

(if (not (member "-quiet" (cdr (argv))))
    (begin
      ;; display prelude to csi
      (display "vtk\n\n")

      (display "  A SWIG example for the CHICKEN compiler\n")
      (display "  Author: Jonah Beckford, January 2003\n\n")

      (display "C++ Classes:\n")
      (display "  See http://www.vtk.org/doc/nightly/html/\n")

      (display "\n")

      (display "Scheme Procedures:\n")
      (display "  There are way too many to document.\n")
      (display "  Examples: 
    vtkSphereSource::SetRadius (float radius) is
      (example-vtk-sphere-source-set-radius %sphere %radius)
")

      (display "\n")

      (display "TinyCLOS Classes:\n")
      (display "  There are way too many to document.\n")
      (display "  Examples:
    vtkSphereSource::SetRadius (float radius) is
      (-SetRadius- %sphereObject %radius)
")

      (display "\n")))
