(* example_prog.ml *)

open Example ;;

let side_length (ax,ay) (bx,by) =
  sqrt (((bx -. ax) ** 2.0) +. ((by -. ay) ** 2.0)) ;;

let triangle_area a_pt b_pt c_pt =
  let a = (side_length a_pt b_pt) 
  and b = (side_length b_pt c_pt)
  and c = (side_length c_pt a_pt) in
  let s = (a +. b +. c) /. 2.0 in
    sqrt (s *. (s -. a) *. (s -. b) *. (s -. c)) ;;

let point_in_triangle (pta,ptb,ptc) x y =
  let delta = 0.0000001 in (* Error *)
  let ptx = (x,y) in
    begin
      let a_area = triangle_area pta ptb ptx
      and b_area = triangle_area ptb ptc ptx
      and c_area = triangle_area ptc pta ptx
      and x_area = triangle_area pta ptb ptc in
      let result = (abs_float (a_area +. b_area +. c_area -. x_area)) < delta
      in
	result
    end ;;

let triangle_class pts ob meth args =
  match meth with
      "cover" ->
	(match args with
	     C_list [ x_arg ; y_arg ] ->
	       C_bool (point_in_triangle 
			 pts (get_float x_arg) (get_float y_arg))
	   | _ -> raise (Failure "cover needs two double arguments."))
    | _ -> (invoke ob) meth args ;;
	       
let triangle =
  new_derived_object 
    new_shape
    (triangle_class ((0.0,0.0),(0.5,1.0),(1.0,0.0)))
    C_void ;;

let _ = _draw_shape_coverage (C_list [ triangle ; C_int 60 ; C_int 20 ]) ;;
