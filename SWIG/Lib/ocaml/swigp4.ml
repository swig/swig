open Pcaml ;;

let lap x y = x :: y
let c_ify e loc = 	  
  match e with
      <:expr< $int:_$ >> -> <:expr< (C_int $e$) >>
    | <:expr< $str:_$ >> -> <:expr< (C_string $e$) >>
    | <:expr< $chr:_$ >> -> <:expr< (C_char $e$) >>
    | <:expr< $flo:_$ >> -> <:expr< (C_double $e$) >>
    | _ -> <:expr< $e$ >>
let rec mk_list args l f =
  match args with
      [] -> (let loc = l in <:expr< [] >>)
    | x :: xs ->
	(let loc = MLast.loc_of_expr x in
	   <:expr< [ ($f x loc$) ] @ ($mk_list xs loc f$) >>)

EXTEND
  expr:
  [ [ e1 = expr ; "'" ; "[" ; e2 = expr ; "]" ->
	<:expr< (invoke $e1$) "[]" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "->" ; l = LIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) $str:l$ (C_list $mk_list args loc c_ify$) >>
    | e1 = expr ; "->" ; u = UIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) $str:u$ (C_list $mk_list args loc c_ify$) >>
    | e1 = expr ; "'" ; "." ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) "()" (C_list $mk_list args loc c_ify$) >>
    | e1 = expr ; "'" ; "->" ->
	<:expr< (invoke ((invoke $e1$) "->" C_void)) >>
    | e1 = expr ; "'" ; "++" ->
	<:expr< (invoke $e1$) "++" C_void >>
    | e1 = expr ; "'" ; "--" ->
	<:expr< (invoke $e1$) "--" C_void >>
    | e1 = expr ; "'" ; "-" ; e2 = expr ->
	<:expr< (invoke $e1$) "-" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "+" ; e2 = expr -> <:expr< (invoke $e1$) "+" (C_list [ $c_ify e2 loc$ ])  >> 
    | e1 = expr ; "'" ; "*" ; e2 = expr -> <:expr< (invoke $e1$) "*" (C_list [ $c_ify e2 loc$ ])  >> 
    | "'" ; "&" ; e1 = expr -> 
	<:expr< (invoke $e1$) "&" C_void >> 
    | "'" ; "!" ; e1 = expr ->
	<:expr< (invoke $e1$) "!" C_void >>
    | "'" ; "~" ; e1 = expr ->
	<:expr< (invoke $e1$) "~" C_void >>
    | e1 = expr ; "'" ; "/" ; e2 = expr ->
	<:expr< (invoke $e1$) "/" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "%" ; e2 = expr ->
	<:expr< (invoke $e1$) "%" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "lsl" ; e2 = expr ->
	<:expr< (invoke $e1$) ("<" ^ "<") (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "lsr" ; e2 = expr ->
	<:expr< (invoke $e1$) (">" ^ ">") (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "<" ; e2 = expr ->
	<:expr< (invoke $e1$) "<" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "<=" ; e2 = expr ->
	<:expr< (invoke $e1$) "<=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; ">" ; e2 = expr ->
	<:expr< (invoke $e1$) ">" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; ">=" ; e2 = expr ->
	<:expr< (invoke $e1$) ">=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "==" ; e2 = expr ->
	<:expr< (invoke $e1$) "==" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "!=" ; e2 = expr ->
	<:expr< (invoke $e1$) "!=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "&" ; e2 = expr ->
	<:expr< (invoke $e1$) "&" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "^" ; e2 = expr ->
	<:expr< (invoke $e1$) "^" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "|" ; e2 = expr ->
	<:expr< (invoke $e1$) "|" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "&&" ; e2 = expr ->
	<:expr< (invoke $e1$) "&&" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "||" ; e2 = expr ->
	<:expr< (invoke $e1$) "||" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) "=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "+=" ; e2 = expr ->
	<:expr< (invoke $e1$) "+=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "-=" ; e2 = expr ->
	<:expr< (invoke $e1$) "-=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "*=" ; e2 = expr ->
	<:expr< (invoke $e1$) "*=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "/=" ; e2 = expr ->
	<:expr< (invoke $e1$) "/=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "%=" ; e2 = expr ->
	<:expr< (invoke $e1$) "%=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "lsl" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) ("<" ^ "<=") (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "lsr" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) (">" ^ ">=") (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "&=" ; e2 = expr ->
	<:expr< (invoke $e1$) "&=" (C_list [ $c_ify e2 loc$ ]) >>
    | e1 = expr ; "'" ; "^=" ; e2 = expr ->
	<:expr< (invoke $e1$) "^=" (C_list [ $c_ify e2 loc$ ]) >> 
    | e1 = expr ; "'" ; "|=" ; e2 = expr ->
	<:expr< (invoke $e1$) "|=" (C_list [ $c_ify e2 loc$ ]) >>
    | "'" ; e = expr -> c_ify e loc
    | c = expr ; "as" ; id = LIDENT -> <:expr< $lid:"get_" ^ id$ $c$ >>
    | c = expr ; "to" ; id = LIDENT -> <:expr< $uid:"C_" ^ id$ $c$ >>
    | f = expr ; "'" ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" -> 
	let l = mk_list args loc c_ify in
	  <:expr< $f$ (C_list $l$) >>
    ] ] ;
END ;;
      
