(* Draw some simple shapes *)

(* Use the wrapped GIFPlot library *)
open Simple
open Int32

let _ = print_endline "Drawing some basic shapes"

let cmap = new_ColorMap ("cmap")
let f = new_FrameBuffer (Int32.of_int 400,Int32.of_int 400)

(* Clear the picture *)
let _ = _FrameBuffer_clear (f,_BLACK)

(* Make a red box *)
let _ = _FrameBuffer_box (f,40,40,200,200,_RED)

(* Make a blue circle *)
let _ = _FrameBuffer_circle (f,200,200,40,_BLUE)

(* Make green line *)
let _ = _FrameBuffer_line (f,10,390,390,200,_GREEN)

(* Write an image out to disk *)

let _ = _FrameBuffer_writeGIF (f,cmap,"image.gif")
let _ = print_endline "Wrote image.gif"

let _ = delete_FrameBuffer f
let _ = delete_ColorMap cmap

