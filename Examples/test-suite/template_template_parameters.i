%module template_template_parameters


%inline %{

/* part 1 */

  namespace pfc {
    template<typename t_item, template <typename> class t_alloc> class array_t {};
    template<typename t_item> class alloc_fast {
      public:
        typedef t_item alloc_type;
    };
  }

  template<typename t_item, typename t2> class list_impl_t {};

  template<typename t_item, template<typename> class t_alloc = pfc::alloc_fast >
    class list_tt : public list_impl_t<t_item,pfc::array_t<t_item,t_alloc> > {
  public:
    t_item item;
      typename t_alloc<t_item>::alloc_type allotype; // SWIG can handle this now
    void xx() {
      typename t_alloc<t_item>::alloc_type atype; // this type is the same as t_item type
      atype = true;
    }
  };

void TestInstantiations() {
  pfc::array_t<int, pfc::alloc_fast> myArrayInt;
  list_impl_t<int, pfc::array_t<int, pfc::alloc_fast> > myListImplInt;
  (void) myArrayInt;
  (void) myListImplInt;
}

/* part 2 */

template<class T>
struct Container1 { 
    T x;
};
template<class U>
struct Container2 { 
    U x;
};
template<class BaseT, template<class> class TemplateTemplateT>
struct TestStruct { 
    TemplateTemplateT<BaseT> x;
};

TestStruct<int, Container1> TestStructContainer1Method(TestStruct<int, Container1> ts1) {
  ts1.x.x += 10;
  return ts1;
}

%}

/* part 1 */
%template(ListImplFastBool) list_impl_t<bool, pfc::array_t<bool, pfc::alloc_fast> >;
%template(ListFastBool) list_tt<bool, pfc::alloc_fast>;

%template(ListImplFastDouble) list_impl_t<double, pfc::array_t<double, pfc::alloc_fast> >;
%template(ListDefaultDouble) list_tt<double>;

%template(BoolAllocFast) pfc::alloc_fast<bool>;
%template(DoubleAllocFast) pfc::alloc_fast<double>;

/* part 2 */
%template(IntContainer1) Container1<int>;
%template(FloatContainer2) Container2<float>;
%template(IntTestStruct) TestStruct<int, Container1>;
%template(FloatTestStruct) TestStruct<float, Container2>;

