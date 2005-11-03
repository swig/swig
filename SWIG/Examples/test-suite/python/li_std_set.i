%module li_std_set

%include <std_string.i>
%include <std_set.i>
%include <std_multiset.i>
%include <std_vector.i>

%template(set_string) std::set<std::string>;
%template(set_int) std::multiset<int>;


%template(v_int) std::vector<int>;




%template(pyset) std::set<swig::PyItem>; 
