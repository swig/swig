// Maps

%include <matlabcontainer.swg>

%fragment("StdMapCommonTraits","header",fragment="StdSequenceTraits")
{
  namespace swig {
    template <class ValueType>
    struct from_key_oper
    {
      typedef const ValueType& argument_type;
      typedef mxArray* result_type;
      result_type operator()(argument_type v) const
      {
	return swig::from(v.first);
      }
    };

    template <class ValueType>
    struct from_value_oper
    {
      typedef const ValueType& argument_type;
      typedef mxArray* result_type;
      result_type operator()(argument_type v) const
      {
	return swig::from(v.second);
      }
    };

    template<class OutIterator, class FromOper, class ValueType = typename OutIterator::value_type>
    struct MatlabMapIterator_T : MatlabSwigIteratorClosed_T<OutIterator, ValueType, FromOper>
    {
      MatlabMapIterator_T(OutIterator curr, OutIterator first, OutIterator last, mxArray* seq)
	: MatlabSwigIteratorClosed_T<OutIterator,ValueType,FromOper>(curr, first, last, seq)
      {
      }
    };


    template<class OutIterator,
	     class FromOper = from_key_oper<typename OutIterator::value_type> >
    struct MatlabMapKeyIterator_T : MatlabMapIterator_T<OutIterator, FromOper>
    {
      MatlabMapKeyIterator_T(OutIterator curr, OutIterator first, OutIterator last, mxArray* seq)
	: MatlabMapIterator_T<OutIterator, FromOper>(curr, first, last, seq)
      {
      }
    };

    template<typename OutIter>
    inline MatlabSwigIterator*
    make_output_key_iterator(const OutIter& current, const OutIter& begin, const OutIter& end, mxArray* seq = 0)
    {
      return new MatlabMapKeyIterator_T<OutIter>(current, begin, end, seq);
    }

    template<class OutIterator,
	     class FromOper = from_value_oper<typename OutIterator::value_type> >
    struct MatlabMapValueIterator_T : MatlabMapIterator_T<OutIterator, FromOper>
    {
      MatlabMapValueIterator_T(OutIterator curr, OutIterator first, OutIterator last, mxArray* seq)
	: MatlabMapIterator_T<OutIterator, FromOper>(curr, first, last, seq)
      {
      }
    };


    template<typename OutIter>
    inline MatlabSwigIterator*
    make_output_value_iterator(const OutIter& current, const OutIter& begin, const OutIter& end, mxArray* seq = 0)
    {
      return new MatlabMapValueIterator_T<OutIter>(current, begin, end, seq);
    }
  }
}

%fragment("StdMapTraits","header",fragment="StdMapCommonTraits")
{
  namespace swig {
    template <class MatlabSeq, class K, class T >
    inline void
    assign(const MatlabSeq& matlabseq, std::map<K,T > *map) {
      typedef typename std::map<K,T>::value_type value_type;
      typename MatlabSeq::const_iterator it = matlabseq.begin();
      for (;it != matlabseq.end(); ++it) {
	map->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::map<K,T> >  {
      typedef std::map<K,T> map_type;
      static int asptr(mxArray* obj, map_type **val) {
        map_type *pointer = 0;
        int result = SWIG_ConvertPtr(obj, (void **)&pointer, swig::type_info<map_type>(), 0);
        if (SWIG_IsOK(result) && val) *val = pointer;
        return result;
      }
    };

    template <class K, class T >
    struct traits_from<std::map<K,T> >  {
      typedef std::map<K,T> map_type;
      typedef typename map_type::const_iterator const_iterator;
      typedef typename map_type::size_type size_type;

      static mxArray* from(const map_type& map) {
        return SWIG_NewPointerObj(new map_type(map), swig::type_info<map_type>(), SWIG_POINTER_OWN);
      }
    };
  }
}

%define %swig_map_common(Map...)
  %swig_sequence_iterator(Map);
  %swig_container_methods(Map);
%enddef

%define %swig_map_methods(Map...)
     %swig_map_common(Map)
%enddef


%include <std/std_map.i>
