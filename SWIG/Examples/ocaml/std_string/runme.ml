(* This example was mostly lifted from the guile example directory *)

open Example

let y = "\205\177"
let z = _to_wstring_with_locale (C_list [ C_string y ; C_string Sys.argv.(1) ])

let _ = 
  begin
    print_string "the original string contains " ;
    print_int (String.length y) ;
    print_newline () ;
    
    print_string "the new string contains " ;
    print_int (get_int ((invoke z) "size" C_void)) ;
    print_string " : [ " ;
    for i = 0 to pred (get_int ((invoke z) "size" C_void)) do
      print_int (get_int ((invoke z) "[]" (C_int i))) ;
      print_string "; " ;
    done ;
    print_string "]" ;
    print_newline () ;
  end    
