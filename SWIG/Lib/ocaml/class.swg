(*Stream:class_ctors*)
let create_$classname_from_ptr raw_ptr =
  C_obj 
    (let rec method_table = [
       "nop", (fun args -> C_void) ;
       $classbody
	 "&", (fun args -> raw_ptr) ;
       ":parents",
       (fun args ->
          C_list
          (List.map
	     (fun (x,y) ->
		C_string (String.sub x 2 ((String.length x) - 2)))
	     (List.filter
		(fun (x,y) ->
		   ((String.length x) > 2)
		   && x.[0] == ':' && x.[1] == ':') method_table))) ;
       ":classof", (fun args -> C_string "$realname") ;
       ":methods", (fun args -> C_list (List.map (fun (x,y) -> C_string x)
					  method_table)) ] in
       (fun mth arg ->
	  try
	    let method_name,application = 
	      List.hd 
		(List.filter (fun (x,y) -> x = mth) method_table) in
	      application
		(match arg with 
		     C_list l -> (C_list (raw_ptr :: l)) 
		   | C_void -> (C_list [ raw_ptr ])
		   | v -> (C_list [ raw_ptr ; v ]))
	  with 
	      (Failure "hd") -> 
		(* Try parent classes *)
		begin
		  let parent_classes = [
		    $baselist
		  ] in
		  let rec try_parent plist raw_ptr =
		    match plist with
			p :: tl -> 
			  begin
			    try
			      (invoke (p raw_ptr)) mth arg
			    with (BadMethodName (p,m,s)) -> 
			      try_parent tl raw_ptr
			  end
		      | [] ->
			  raise (BadMethodName (raw_ptr,mth,"$realname"))
		  in try_parent parent_classes raw_ptr
		end))

let _ = Callback.register 
          "create_$normalized_from_ptr"
          create_$classname_from_ptr

(*Stream:mli*)
val create_$classname_from_ptr : c_obj -> c_obj

