;;; Draw some simple shapes

;; Use the wrapped GIFPlot library
(use-modules (simple))

(display "Drawing some basic shapes\n")

(define cmap (new-ColorMap))
(define f (new-FrameBuffer 400 400))

;; Clear the picture
(FrameBuffer-clear f (BLACK))

;; Make a red box
(FrameBuffer-box f 40 40 200 200 (RED))

;; Make a blue circle
(FrameBuffer-circle f 200 200 40 (BLUE))

;; Make green line
(FrameBuffer-line f 10 390 390 200 (GREEN))

;; Write an image out to disk

(FrameBuffer-writeGIF f cmap "image.gif")
(display "Wrote image.gif\n")

(delete-FrameBuffer f)
(delete-ColorMap cmap)

