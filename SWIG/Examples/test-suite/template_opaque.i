%module template_opaque
%include std_vector.i

%{
  namespace A 
  {
    struct OpaqueStruct 
    {
    };
  }
%}

  
%inline {
namespace A {
  struct OpaqueStruct;
  typedef OpaqueStruct OpaqueType;
  typedef std::vector<OpaqueType> OpaqueVectorType;
  
  void FillVector(OpaqueVectorType& v) 
  {
    for (size_t i = 0; i < v.size(); ++i) {
      v[i] = OpaqueStruct();
    }
  }
}
}

%template(OpaqueVectorType) std::vector<A::OpaqueType>; 
