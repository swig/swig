;;; Plot a 3D function

;; Here is the function to plot
(defun func (x y)
  (* 5
     (cos (* 2 (sqrt (+ (* x x) (* y y)))))
     (exp (* -0.3 (sqrt (+ (* x x) (* y y)))))))

;; Here are some plotting parameters
(defvar xmin -5D0)
(defvar xmax  5D0)
(defvar ymin -5D0)
(defvar ymax  5D0)
(defvar zmin -5D0)
(defvar zmax  5D0)

;; Grid resolution
(defvar nxpoints  60)
(defvar nypoints  60)

(defun drawsolid (p3)
  (Plot3D-clear p3 0)
  (Plot3D-start p3)
  (let ((dx (/ (- xmax xmin) nxpoints))
	(dy (/ (- ymax ymin) nypoints))
	(cscale (/ 240 (- zmax zmin))))
    (loop for x from xmin by dx
	  repeat nxpoints
	  do (loop for y from ymin by dy
		   repeat nypoints
		   do (let* ((z1 (func x y))
			     (z2 (func (+ x dx) y))
			     (z3 (func (+ x dx) (+ y dy)))
			     (z4 (func x (+ y dy)))
			     (c1 (* cscale (- z1 zmin)))
			     (c2 (* cscale (- z2 zmin)))
			     (c3 (* cscale (- z3 zmin)))
			     (c4 (* cscale (- z4 zmin)))
			     (cc (/ (+ c1 c2 c3 c4) 4))
			     (c  (round (max (min cc 239) 0))))
			(Plot3D-solidquad p3 x y z1 (+ x dx) y z2 (+ x dx) (+ y dy)
					  z3 x (+ y dy) z4 (+ c 16)))))))

(defun action (cmap-filename)
  (let ((cmap (new-ColorMap cmap-filename))
	(frame (new-FrameBuffer 500 500)))
    (format t "Making a nice 3D plot...~%")
    (FrameBuffer-clear frame 0)
    (let ((p3 (new-Plot3D frame xmin ymin zmin xmax ymax zmax)))
      (Plot3D-lookat p3 (* 2 (- zmax zmin)))
      (Plot3D-autoperspective p3 40D0)
      (Plot3D-rotu p3 60D0)
      (Plot3D-rotr p3 30D0)
      (Plot3D-rotd p3 10D0)
      (drawsolid p3))
    (FrameBuffer-writeGIF frame cmap "/tmp/image.gif")
    (format t "Wrote image.gif~%")))


