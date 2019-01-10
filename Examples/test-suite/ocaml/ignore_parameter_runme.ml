open Swig
open Ignore_parameter

let _ =
  assert (get_string (_jaguar (C_list [ C_int 200 ; C_float 0. ])) = "hello");
  assert (get_int (_lotus (C_list [ C_string "fast" ; C_float 0. ])) = 101);
  assert (get_float (_tvr (C_list [ C_string "fast" ; C_int 200 ])) = 8.8);
  assert (get_int (_ferrari (C_void)) = 101);
;;
let sc = new_SportsCars (C_void)
let _ =
  assert (get_string ((invoke sc) "daimler" (C_list [ C_int 200 ; C_float 0. ])) = "hello");
  assert (get_int ((invoke sc) "astonmartin" (C_list [ C_string "fast" ; C_float 0. ])) = 101);
  assert (get_float ((invoke sc) "bugatti" (C_list [ C_string "fast" ; C_int 200 ])) = 8.8);
  assert (get_int ((invoke sc) "lamborghini" (C_void)) = 101);
;;
let mc = new_MiniCooper (C_list [ C_int 200 ; C_float 0. ])
let mm = new_MorrisMinor (C_list [ C_string "slow" ; C_float 0. ])
let fa = new_FordAnglia (C_list [ C_string "slow" ; C_int 200 ])
let aa = new_AustinAllegro (C_void)
