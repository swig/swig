(* Draw some simple shapes *)

(* Use the wrapped GIFPlot library *)
open Swig
open Simple
open Int32

let _ = print_endline "Drawing some basic shapes"

let cmap = _new_ColorMap (C_string "cmap")
let f = _new_FrameBuffer (C_list [ C_int 400 ; C_int 400 ])

(* Clear the picture *)
let _ = _FrameBuffer_clear (C_list [ f ; _BLACK C_void ])

(* Make a red box *)
let _ = _FrameBuffer_box 
	  (C_list [ f ; C_int 40 ; C_int 40 ; C_int 200 ; C_int 200 ; _RED C_void ])

(* Make a blue circle *)
let _ = _FrameBuffer_circle 
	  (C_list [ f ; C_int 200 ; C_int 200 ; C_int 40 ; _BLUE C_void ])

(* Make green line *)
let _ = _FrameBuffer_line 
	  (C_list [ f ; C_int 10 ; C_int 390 ; C_int 390 ; C_int 200 ; _GREEN C_void ])

(* Write an image out to disk *)

let _ = _FrameBuffer_writeGIF (C_list [ f ; cmap ; C_string "image.gif" ])
let _ = print_endline "Wrote image.gif"

let _ = _delete_FrameBuffer f
let _ = _delete_ColorMap cmap

