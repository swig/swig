open Swig
open Aggregate

let _ =
  assert((_move (_UP '()) as int) = (_UP '() as int));
  assert((_move (_DOWN '()) as int) = (_DOWN '() as int));
  assert((_move (_LEFT '()) as int) = (_LEFT '() as int));
  assert((_move (_RIGHT '()) as int) = (_RIGHT '() as int));
;;

let _ =
  try
    _move(0 to int)
  with Failure _ -> exit 0
let _ = raise (Failure "0 test failed")
