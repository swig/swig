(* Draw some simple shapes *)

(* Use the wrapped GIFPlot library *)
open Simple
open Int32

let _ = print_endline "Drawing some basic shapes"

let cmap = new_colormap ("cmap")
let f = new_framebuffer (Int32.of_int 400,Int32.of_int 400)

(* Clear the picture *)
let _ = framebuffer_clear (f,black)

(* Make a red box *)
let _ = framebuffer_box (f,40,40,200,200,red)

(* Make a blue circle *)
let _ = framebuffer_circle (f,200,200,40,blue)

(* Make green line *)
let _ = framebuffer_line (f,10,390,390,200,green)

(* Write an image out to disk *)

let _ = framebuffer_writegif (f,cmap,"image.gif")
let _ = print_endline "Wrote image.gif"

let _ = delete_framebuffer f
let _ = delete_colormap cmap

