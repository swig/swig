%module cpp11_std_unordered_multimap

%include <std_pair.i>
%include <std_unordered_multimap.i>

%template(PairIntInt) std::pair<int,int>;
%template(UnorderedMultiMapIntInt) std::unordered_multimap<int, int>;
