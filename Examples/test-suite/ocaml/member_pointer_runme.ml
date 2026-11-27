open Swig
open Member_pointer

let _ =
  let area_pt = _areapt '() in
  let perim_pt = _perimeterpt '() in
  let s = new_Square '(10.) in
  assert (_do_op '(s, area_pt) as float = 100.);
  assert (_do_op '(s, perim_pt) as float = 40.);
  let area_var = _areavar '() in
  let perim_var = _perimetervar '() in
  assert (_do_op '(s, area_var) as float = 100.);
  assert (_do_op '(s, perim_var) as float = 40.);
  ignore (_areavar perim_pt);
  let area_var = _areavar '() in
  assert (_do_op '(s, area_var) as float = 40.);
  let area_const = _AREAPT '() in
  let perim_const = _PERIMPT '() in
  assert (_do_op '(s, area_const) as float = 100.);
  assert (_do_op '(s, perim_const) as float = 40.);
  assert (_do_op_td '(s, perim_pt) as float = 40.);
  let perim_td = _perimeterpt_td '() in
  assert (_do_op_td '(s, perim_td) as float = 40.);
  assert (_do_op_cref '(s, area_pt) as float = 100.);
  let perim_cref = _perimetervar_td_cref '() in
  assert (_do_op_cref '(s, perim_cref) as float = 40.);
  assert (_do_op '(s, perim_cref) as float = 40.);
  let add_by_value = _ADD_BY_VALUE '() in
  let add_by_pointer = _ADD_BY_POINTER '() in
  let add_by_reference = _ADD_BY_REFERENCE '() in
  assert (_call1 '(add_by_value, 1, 2) as int = 3);
  assert (_call2 '(add_by_pointer, 3, 4) as int = 7);
  assert (_call3 '(add_by_reference, 5, 6) as int = 11);
  assert (_call_overloaded '(add_by_value, 1, 2) as int = 3);
  assert (_call_overloaded '(add_by_pointer, 3, 4) as int = -7);
  assert (_call_overloaded '(10, 5, 6) as int = 110);
  (try
    ignore (_do_op '(s, add_by_value)); assert false
  with Failure _ -> ());
  (* A member pointer value is not a pointer to an object *)
  (try
    ignore (_do_op '(area_pt, area_pt)); assert false
  with Failure _ -> ());
  try
    ignore (_do_op_cref '(s, add_by_value)); assert false
  with Failure _ -> ()
;;
