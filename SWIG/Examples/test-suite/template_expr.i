%module template_expr

// bug #925555
%inline %{

  template<int __stride, class __elementTypeSequence,
    class __dataPtrType, class __elementType>
    inline const ThisType & 
    ConcatenationOf(const vctFixedLengthConstSequenceBase<_size - 1,
		    __stride, __elementTypeSequence, __dataPtrType> & other,
		    __elementType last);
%}

// bug #956282
%inline %{

  
template<int q>
class X {};


%}

%template(X_1) X<1>;
%template(X_m1) X<-1>;
%template(X_1plus2) X<1+2>;
%template(X_1024div8) X<1024/8>;


// bug 1338527


%inline %{

  template<typename, typename> class PatchList;

%}
