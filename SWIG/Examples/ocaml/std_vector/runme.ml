(* This example was mostly lifted from the guile example directory *)

open Example

(* repeatedly invoke a procedure with v and an index as arguments *)
let with_vector v proc size =
  let rec with_vector_item =
    (fun v i -> if (i < size) then
       begin
	 proc v i ;
	 with_vector_item v (succ i)
       end) in
    with_vector_item v 0

let with_vector v proc = 
  with_vector v proc (get_int ((invoke v) "size" (C_void)))



let dbl_vector_ref v i = 
  match ((invoke v) "[]" (C_int i)) with
      C_float f | C_double f -> f | _ -> 0.0

let print_DoubleVector v =
  begin
    with_vector v 
      (fun v i -> 
	 (print_float (dbl_vector_ref v i)) ;
	 (print_string " ")) ;
    print_endline 
  end

let fill_int_vector_from_array a v i = 
  (invoke v) "set" (C_list [ C_int i ; C_int a.(i) ]) 

(* Call average with a Ocaml array... *)

let y = new_IntVector (C_uint (Int32.of_int 4)) 
let _ = with_vector y (fill_int_vector_from_array [| 1;2;3;4 |]) 
let _ = (print_float (get_float (_average y)) ; print_newline ())
