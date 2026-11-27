open Swig
open Director_member_pointer

let member_ptr_director ob meth args =
  match meth with
    | "useMemberPtr" ->
      (match args with
         | C_list [ m; x ] -> _MemberPtrDirector_callMemberPtr (C_list [ m; C_int ((get_int x) + 10) ])
         | _ -> raise (Failure meth))
    | "useMemberPtrCref" ->
      (match args with
         | C_list [ m; x ] -> _MemberPtrDirector_callMemberPtr (C_list [ m; C_int ((get_int x) + 20) ])
         | _ -> raise (Failure meth))
    | "getMemberPtr" -> _MemberPtrDirector_addPtr '()
    | "getMemberPtrCref" -> _MemberPtrDirector_addPtr '()
    | _ -> (invoke ob) meth args

let _ =
  let d = new_MemberPtrDirector '() in
  assert (d -> callUseMemberPtr ((C_int 5)) as int = 7);
  assert (d -> callUseMemberPtrCref ((C_int 5)) as int = 7);
  assert (d -> callGetMemberPtr ((C_int 5)) as int = 6);
  assert (d -> callGetMemberPtrCref ((C_int 5)) as int = 6);
  let d = new_derived_object new_MemberPtrDirector (member_ptr_director) '() in
  assert (d -> callUseMemberPtr ((C_int 5)) as int = 17);
  assert (d -> callUseMemberPtrCref ((C_int 5)) as int = 27);
  assert (d -> callGetMemberPtr ((C_int 5)) as int = 7);
  assert (d -> callGetMemberPtrCref ((C_int 5)) as int = 7)
