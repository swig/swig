#ifndef __test_suite_refcount_h__
#define __test_suite_refcount_h__

struct RCObjBase  {
  /*!
    Return  the numbers of active references.

    \return The internal \c refCount value.
  */
  int ref_count() const
  {
    return refCount;
  }

  /*!
    Add one reference.

    \return The reference counter value.
  */
  int ref() const
  {
    return  add_ref();
  }
    
  /*!
    Delete one reference. If the refCount is zero, the
    object is deleted. 

    \return The reference counter value, which can be zero after
    deletion.
  */
  int unref() const
  {
    if (ref_count() == 0 || del_ref() == 0 )
      {
	delete this;
	return 0;
      } 
    return ref_count();
  }
    
protected:
  RCObjBase();
  RCObjBase(const RCObjBase& );
  virtual ~RCObjBase() = 0;

private:

  RCObjBase& operator=(const RCObjBase& );

  friend class RCObj;

  int add_ref() const
  {
    return ++refCount;
  }
    
  int del_ref() const
  {
    return --refCount;
  }
    
  mutable int refCount;
};

struct RCObj : virtual RCObjBase {
protected:
  RCObj()
  {
  }
};

/*! Reference an RCObj object
  \return The input pointer \a r
*/
template <class T>
inline
T* ref(T* r)
{ 
  return (r && r->ref() ) ? r : 0;
}
  
/*! Unreference an RCObj object.
  \return The input pointer \a r or nil if the object was deleted.
*/
template <class T>
inline
T* unref(T* r)
{ 
  return ( r && r->unref() ) ? r : 0;
}



RCObjBase::RCObjBase()
  : refCount(0)
{
}


RCObjBase::~RCObjBase()
{
}

RCObjBase::RCObjBase(const RCObjBase&)
  : refCount(0)
{
}


RCObjBase& RCObjBase::operator=(const RCObjBase&)
{
  return *this;
}


template <class T>                     
struct RCPtr  {
  typedef T* pointer_type;
  typedef T& refernce_type;
  typedef T  value_type;  
  
  RCPtr();
  RCPtr(T* realPtr);
  RCPtr(const RCPtr& rhs);

  ~RCPtr();

  RCPtr& operator=(const RCPtr& rhs);

  RCPtr& operator=(T* realPtr);
  
  T* operator->() { return pointee; }
  T& operator*() { return *pointee; }

  const T* operator->() const { return pointee; }
  const T& operator*() const { return *pointee; }

  operator T*() { return pointee; }
  operator T&() { return *pointee; }  

  operator const T*() const { return pointee; }
  operator const T&() const { return *pointee; }  

  T* get() { return pointee; }
  T* get() const { return pointee; }

    
private:
  T* pointee;
};


template <class T>
inline
RCPtr<T>::RCPtr()
  : pointee(0)
{
}

template <class T>
inline
RCPtr<T>::RCPtr(T* realPtr)
  : pointee(realPtr)
{
  ref(pointee);
}

template <class T>
inline
RCPtr<T>::RCPtr(const RCPtr& rhs)
  : pointee(rhs.pointee)
{
  ref(pointee);
}

template <class T>
inline
RCPtr<T>::~RCPtr()
{
  unref(pointee);
}

template <class T>
inline
RCPtr<T>& RCPtr<T>::operator=(const RCPtr& rhs)
{
  if (pointee != rhs.pointee) {
    unref(pointee);
    pointee = rhs.pointee;
    ref(pointee);
  }
  return *this;
}



#endif //__test_suite_refcount_h__
