open Swig
open Li_std_except

let _ =
  let t = new_Test '() in
  try let _ = t -> throw_bad_cast () in assert false with Failure s -> ();
  try let _ = t -> throw_bad_exception () in assert false with Failure s -> ();
  try let _ = t -> throw_domain_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_exception () in assert false with Failure s -> ();
  try let _ = t -> throw_invalid_argument () in assert false with Invalid_argument s -> assert (s = "oops");
  try let _ = t -> throw_length_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_logic_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_out_of_range () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_overflow_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_range_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_runtime_error () in assert false with Failure s -> assert (s = "oops");
  try let _ = t -> throw_underflow_error () in assert false with Failure s -> assert (s = "oops");
;;
