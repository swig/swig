open Swig
open Li_cpointer_dynamic_cast

let _ =
  let null = 0 in (* repeasent C++ null pointer *)
  (* Get a Derived object using a Base pointer *)
  let base_point_derived = _Derived_NewDerived '() in
  let _ = assert '((base_point_derived -> val1 () as int) = 11) in
  let _ = assert '((base_point_derived -> val2 () as int) = 2) in
  (* Dynamic cast to original Derived class *)
  let derived_dyn = _dynDerivedCast '(base_point_derived) in
  let _ = assert '(derived_dyn as int != null) in
  let _ = assert '((derived_dyn -> val1 () as int) = 11) in
  let _ = assert '((derived_dyn -> val2 () as int) = 12) in
  (* Static cast work the same as dynamic cast, when used with the derived class! *)
  let derived_static = _staticDerivedCast '(base_point_derived) in
  let _ = assert '(derived_static as int != null) in
  let _ = assert '((derived_static -> val1 () as int) = 11) in
  let _ = assert '((derived_static -> val2 () as int) = 12) in

  (* Get an Other object using a Base pointer *)
  let base_point_other = _Other_NewOther '() in
  let _ = assert '((base_point_other -> val1 () as int) = 21) in
  let _ = assert '((base_point_other -> val2 () as int) = 2) in
  (* Dynamic cast to original Other class *)
  let other_dyn = _dynOtherCast '(base_point_other) in
  let _ = assert '(other_dyn as int != null) in
  let _ = assert '((other_dyn -> val1 () as int) = 21) in
  let _ = assert '((other_dyn -> val2 () as int) = 22) in
  (* Static cast work the same as dynamic cast, when used with the other class! *)
  let other_static = _staticOtherCast '(base_point_other) in
  let _ = assert '(other_static as int != null) in
  let _ = assert '((other_static -> val1 () as int) = 21) in
  let _ = assert '((other_static -> val2 () as int) = 22) in

  (* Get a Base object *)
  let base = _new_Base '() in
  let _ = assert '((base -> val1 () as int) = 1) in
  let _ = assert '((base -> val2 () as int) = 2) in

  (* Dynamic cast gives NULL as expected *)
  let _ = assert '((_dynOtherCast '(base_point_derived) as int) = null) in
  let _ = assert '((_dynDerivedCast(base_point_other) as int) = null) in
  let _ = assert '((_dynOtherCast(base) as int) = null) in
  let _ = assert '((_dynDerivedCast(base) as int) = null) in

  (* Static cast gives a hybrid result *)
  (* The virtual method point to original object class, as we expect! *)
  (* While the non-virtual method uses the new pointed class method! *)
  let non_cpp_other_derived = _staticOtherCast '(base_point_derived) in
  let _ = assert '(non_cpp_other_derived as int != null) in
  let _ = assert '((non_cpp_other_derived -> val1 () as int) = 11) in
  let _ = assert '((non_cpp_other_derived -> val2 () as int) = 22) in
  let non_cpp_derived_other = _staticDerivedCast '(base_point_other) in
  let _ = assert '(non_cpp_derived_other as int != null) in
  let _ = assert '((non_cpp_derived_other -> val1 () as int) = 21) in
  let _ = assert '((non_cpp_derived_other -> val2 () as int) = 12) in
  let non_cpp_base_derived = _staticDerivedCast '(base) in
  let _ = assert '(non_cpp_base_derived as int != null) in
  let _ = assert '((non_cpp_base_derived -> val1 () as int) = 1) in
  let _ = assert '((non_cpp_base_derived -> val2 () as int) = 12) in
  let non_cpp_base_other = _staticOtherCast '(base) in
  let _ = assert '(non_cpp_base_other as int != null) in
  let _ = assert '((non_cpp_base_other -> val1 () as int) = 1) in
  assert '((non_cpp_base_other -> val2 () as int) = 22)
