(* Plot a 3D Function *)

(* Use the wrapped GIFPlot library *)
open Gifplot
open Int32

(* Here is the function to plot *)
let func x y = 
  5.0 *. 
    (cos (2.0 *. (sqrt (x *. x) +. (y *. y)))) *.
    (exp (-0.3 *. (sqrt (x *. x) +. (y *. y)))) 

(* Here are some plotting parameters *)

let xmin = -5.0
let xmax =  5.0
let ymin = -5.0
let ymax =  5.0
let zmin = -5.0
let zmax =  5.0

(* Grid resolution *)
let nxpoints = 60
let nypoints = 60

let cmap = new_colormap "cmap"
let frame = new_framebuffer (Int32.of_int 500,Int32.of_int 500)
let _ = framebuffer_clear (frame,black)

let p2 = new_plot3d (frame,xmin,ymin,zmin,xmax,ymax,zmax)
let _ = plot3d_lookat (p2,2.0 *. (zmax -. zmin))
let _ = plot3d_autoperspective (p2,40.0)
let _ = plot3d_rotu (p2,60.0)
let _ = plot3d_rotr (p2,30.0)
let _ = plot3d_rotd (p2,10.0)

let drawsolid () =
  begin
    plot3d_clear (p2,black) ;
    plot3d_start (p2) ;
    let dx = ((xmax -. xmin) /. (float_of_int nxpoints))
    and dy = ((ymax -. ymin) /. (float_of_int nypoints)) 
    and cscale = (240.0 /. (zmax -. zmin)) in
    let rec x_loop x i =
      if i < nxpoints then
	begin
	  let rec y_loop y j =
	    begin
	      if j < nypoints then
		let z1 = func x y
		and z2 = func (x +. dx) y
		and z3 = func (x +. dx) (y +. dy)
		and z4 = func x (y +. dy) in
		let c1 = cscale *. (z1 -. zmin)
		and c2 = cscale *. (z2 -. zmin)
		and c3 = cscale *. (z3 -. zmin)
		and c4 = cscale *. (z4 -. zmin) in
		let cc = (c1 +. c2 +. c3 +. c4) /. 4.0 in
		let c =  (max (min (int_of_float cc) 239) 0) in
		plot3d_solidquad (p2,x,y,z1,x +. dx,y,z2,x +. dx,y +. dy,
				  z3,x,y +. dx,z4,c + 16) ;
		y_loop (y +. dy) (j + 1) 
	    end in
	  begin
	    y_loop ymin 0 ;
	    x_loop (x +. dx) (i + 1)
	  end 
	end in
    x_loop xmin 0
  end

let _ = print_endline "Making a nice 3D plot..."
let _ = drawsolid ()

let _ = framebuffer_writegif (frame,cmap,"image.gif")
let _ = print_endline "Write image.gif"
