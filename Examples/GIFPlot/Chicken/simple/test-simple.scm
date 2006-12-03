;;; Draw some simple shapes

(declare (uses simple))

(display "Drawing some basic shapes\n")

(define cmap (simple:new-ColorMap #f))
(define f (simple:new-FrameBuffer 400 400))

;; Clear the picture
(simple:FrameBuffer-clear f (simple:BLACK))

;; Make a red box
(simple:FrameBuffer-box f 40 40 200 200 (simple:RED))

;; Make a blue circle
(simple:FrameBuffer-circle f 200 200 40 (simple:BLUE))

;; Make green line
(simple:FrameBuffer-line f 10 390 390 200 (simple:GREEN))

;; Write an image out to disk

(simple:FrameBuffer-writeGIF f cmap "image.gif")
(display "Wrote image.gif\n")

(simple:delete-FrameBuffer f)
(simple:delete-ColorMap cmap)

