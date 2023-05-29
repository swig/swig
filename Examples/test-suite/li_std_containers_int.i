%module li_std_containers_int

//
// Test containers of type int
//

%include std_vector.i

#ifndef SWIGJAVASCRIPT
%include std_list.i
#endif


%template(vector_int) std::vector<int>;

#ifndef SWIGJAVASCRIPT
%template(list_int) std::list<int>;
#endif
