%module li_std_combinations

%include <std_vector.i>
%include <std_string.i>
%include <std_pair.i>

%template(VectorInt) std::vector<int>;
%template(VectorString) std::vector<std::string>;
%template(PairIntString) std::pair<int, std::string>;

%template(VectorPairIntString) std::vector< std::pair<int, std::string> >;
%template(PairIntVectorString) std::pair< int, std::vector<std::string> >;

%template(VectorVectorString) std::vector< std::vector<std::string> >;
%template(PairIntPairIntString) std::pair< int, std::pair<int, std::string> >;
