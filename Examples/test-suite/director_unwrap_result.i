%module(directors="1") director_unwrap_result

%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) Storage;
%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) StorageTmpl;

%feature("director") Element;
%feature("director") Storage;
%feature("director") StorageTmpl;

%inline %{

class Element {
  Element* self;
  Element** selfptr;
  public:
    Element() {
      self = this;
      selfptr = &self;
    }
    virtual ~Element() {}
    Element **getPtrPtr() {
      return &self;
    }
    Element ***getPtrPtrPtr() {
      return &selfptr;
    }
};
typedef Element * element_ptr_t;
typedef Element & element_ref_t;

class Storage {
  public:
    virtual ~Storage() {}
    virtual Element **getIt() = 0;
    Element getElement() {
      return **getIt();
    }
    Element* const getElementPtr() {
      return *getIt();
    }
    Element& getElementRef() {
      return **getIt();
    }
    Element* const *getElementPtrPtr() {
      return getIt();
    }
    Element *&getElementPtrRef() {
      return *getIt();
    }
    element_ref_t getElementRefTypedef() {
      return **getIt();
    }
    element_ptr_t getElementPtrTypedef() {
      return *getIt();
    }
    element_ptr_t &getElementPtrRefTypedef() {
      return *getIt();
    }
};

template<class T> class StorageTmpl {
  public:
    virtual ~StorageTmpl() {}
    virtual T &getIt() = 0;
    T getVal() {
      return getIt();
    }
    T *getPtr() {
      return &getIt();
    }
    T &getRef() {
      return getIt();
    }
};

%}

%template(ElementStorage) StorageTmpl<Element>;
%template(ElementPtrStorage) StorageTmpl<Element *>;
%template(ElementPtrPtrStorage) StorageTmpl<Element *const *>;

%inline %{

template<class T> T getParam(T t) {
  return t;
}

%}

%template(getIntParam) getParam<int>;
%template(getIntPtrParam) getParam<int*>;
%template(getElementPtrParam) getParam<Element *>;

