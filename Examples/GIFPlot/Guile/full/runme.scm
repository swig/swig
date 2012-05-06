;;; Plot a 3D function

;; Use the wrapped GIFPlot library
(use-modules (gifplot))

;; Here is the function to plot
(define (func x y)
  (* 5
     (cos (* 2 (sqrt (+ (* x x) (* y y)))))
     (exp (* -0.3 (sqrt (+ (* x x) (* y y)))))))

;; Here are some plotting parameters
(define xmin -5.0)
(define xmax  5.0)
(define ymin -5.0)
(define ymax  5.0)
(define zmin -5.0)
(define zmax  5.0)

;; Grid resolution
(define nxpoints  60)
(define nypoints  60)

(define cmap (new-ColorMap "cmap"))
(define frame (new-FrameBuffer 500 500))
(FrameBuffer-clear frame (BLACK))

(define p3 (new-Plot3D frame xmin ymin zmin xmax ymax zmax))
(Plot3D-lookat p3 (* 2 (- zmax zmin)))
(Plot3D-autoperspective p3 40)
(Plot3D-rotu p3 60)
(Plot3D-rotr p3 30)
(Plot3D-rotd p3 10)

(define (drawsolid)
  (Plot3D-clear p3 (BLACK))
  (Plot3D-start p3)
  (let ((dx (/ (- xmax xmin) nxpoints))
	(dy (/ (- ymax ymin) nypoints))
	(cscale (/ 240 (- zmax zmin))))
    (let x-loop ((x xmin) (i 0))
      (cond
       ((< i nxpoints)
	(let y-loop ((y ymin) (j 0))
	  (cond
	   ((< j nypoints)
	    (let* ((z1 (func x y))
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
				z3 x (+ y dy) z4 (+ c 16)))
	    (y-loop (+ y dy) (+ j 1)))))
	(x-loop (+ x dx) (+ i 1)))))))

(display "Making a nice 3D plot...\n")
(drawsolid)

(FrameBuffer-writeGIF frame cmap "image.gif")
(display "Wrote image.gif\n")
