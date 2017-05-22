/* -----------------------------------------------------------------------------
 * std_list.i
 *
 * SWIG typemaps for std::list<T>
 * C# implementation
 * The C# wrapper is made to look and feel like a C# System.Collections.Generic.LinkedList<> collection.
 *
 * ----------------------------------------------------------------------------- */
 
%include <std_common.i>
%define SWIG_STD_LIST_MINIMUM_INTERNAL(CONST_REFERENCE, CTYPE...)
%typemap(csinterfaces) std::list< CTYPE > "global::System.Collections.Generic.ICollection<$typemap(cstype, CTYPE)>, global::System.Collections.Generic.IEnumerable<$typemap(cstype, CTYPE)>, global::System.Collections.IEnumerable, global::System.IDisposable"
%proxycode %{
  public $csclassname(global::System.Collections.IEnumerable c) : this() {
    if (c == null)
      throw new global::System.ArgumentNullException("c");
    foreach ($typemap(cstype, CTYPE) element in c) {
      this.AddLast(element);
    }
  }

  public bool IsReadOnly {
    get {
      return false;
    }
  }
  
  public int Count {
    get {
      return (int)size();
    }
  }
  
  public $csclassnameNode First {
    get { 
	  if (Count == 0)
	    return null;
	  return new $csclassnameNode(getFirstIter(), this);
    }
  }

  public $csclassnameNode Last {
    get {
	  if (Count == 0)
	    return null;
      return new $csclassnameNode(getLastIter(), this);
    }
  }
  
  public  $csclassnameNode AddFirst($typemap(cstype, CTYPE) value) {
	push_front(value);
	return new $csclassnameNode(getFirstIter(), this);
  }

  public void AddFirst($csclassnameNode newNode) {
    ValidateNewNode(newNode);
	if (!newNode.inlist) {
	  push_front(newNode.csharpvalue);
	  newNode.iter = getFirstIter();
	  newNode.inlist = true;
	} else {
	  throw new global::System.InvalidOperationException("The " + newNode.GetType().Name + " node already belongs to a " + this.GetType().Name);
	}
  }

  public $csclassnameNode AddLast($typemap(cstype, CTYPE) value) {
    push_back(value);
	return new $csclassnameNode(getLastIter(), this);
  }

  public void AddLast($csclassnameNode newNode) {
    ValidateNewNode(newNode);
	if (!newNode.inlist) {
	  push_back(newNode.csharpvalue);
	  newNode.iter = getLastIter();
	  newNode.inlist = true;
	} else {
	  throw new global::System.InvalidOperationException("The " + newNode.GetType().Name + " node already belongs to a " + this.GetType().Name);
	}
  }
  
  public $csclassnameNode AddBefore($csclassnameNode node, $typemap(cstype, CTYPE) value) {
	return new $csclassnameNode(insertNode(node.iter, value), this);
  }

  public void AddBefore($csclassnameNode node, $csclassnameNode newNode) {
    ValidateNode(node);
	ValidateNewNode(newNode);
	if (!newNode.inlist) {
	  newNode.iter = insertNode(node.iter, newNode.csharpvalue);
	  newNode.inlist = true;
	} else {
	  throw new global::System.InvalidOperationException("The " + newNode.GetType().Name + " node already belongs to a " + this.GetType().Name);
	}
  }

  public $csclassnameNode AddAfter($csclassnameNode node, $typemap(cstype, CTYPE) value) {
	node = node.Next;
	return new $csclassnameNode(insertNode(node.iter, value), this);
  }

  public void AddAfter($csclassnameNode node, $csclassnameNode newNode) {
    ValidateNode(node);
	ValidateNewNode(newNode);
	if (!newNode.inlist) {
	  if (node == this.Last)
	    AddLast(newNode);
	  else
	  {
	    node = node.Next;
	    newNode.iter = insertNode(node.iter, newNode.csharpvalue);
	    newNode.inlist = true;
	  }
	} else {
	  throw new global::System.InvalidOperationException("The " + newNode.GetType().Name + " node already belongs to a " + this.GetType().Name);
	}
  }

  public void Add($typemap(cstype, CTYPE) value) {
    AddLast(value);
  }

  public bool Remove($typemap(cstype, CTYPE) value) {
    var node = Find(value);
    if (node == null)
	  return false;
	Remove(node);
	return true;
  }

  public void Remove($csclassnameNode node) {
    ValidateNode(node);
    eraseIter(node.iter);  
  }

  public $csclassnameNode Find($typemap(cstype, CTYPE) value) {
    System.IntPtr tmp = find(value);
    if (tmp != System.IntPtr.Zero) {
	  return new $csclassnameNode(tmp, this);
	}
	return null;
  }
  
  public void CopyTo($typemap(cstype, CTYPE)[] array, int index) {
    if (array == null)
      throw new global::System.ArgumentNullException("array");
    if (index < 0 || index > array.Length)
      throw new global::System.ArgumentOutOfRangeException("index", "Value is less than zero");
    if (array.Rank > 1)
      throw new global::System.ArgumentException("Multi dimensional array.", "array");
    $csclassnameNode node = this.First;
    if (node != null) {
      do {
        array[index++] = node.Value;
        node = node.Next;
      } while (node != null);
    }
  }

  internal void ValidateNode($csclassnameNode node) {
    if (node == null) {
      throw new System.ArgumentNullException("node"); 
    } 
    if (!node.inlist || node.list != this) { 
      throw new System.InvalidOperationException("node");
    }
  }

  internal void ValidateNewNode($csclassnameNode node) {
    if (node == null) {
      throw new System.ArgumentNullException("node"); 
    } 
  }

  global::System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)> global::System.Collections.Generic.IEnumerable<$typemap(cstype, CTYPE)>.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  global::System.Collections.IEnumerator global::System.Collections.IEnumerable.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  public $csclassnameEnumerator GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }
  
  public sealed class $csclassnameEnumerator : global::System.Collections.IEnumerator,
    global::System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)>
  {
    private $csclassname collectionRef;
    private $csclassnameNode currentNode;
    private int currentIndex;
    private object currentObject;
    private int currentSize;
      
    public $csclassnameEnumerator($csclassname collection) {
      collectionRef = collection;
      currentNode = collection.First;
      currentIndex = 0;
      currentObject = null;
      currentSize = collectionRef.Count;
    }
    
    // Type-safe iterator Current
    public $typemap(cstype, CTYPE) Current {
      get {
        if (currentIndex == -1)
          throw new global::System.InvalidOperationException("Enumeration not started.");
        if (currentIndex > currentSize)
          throw new global::System.InvalidOperationException("Enumeration finished.");
        if (currentObject == null)
          throw new global::System.InvalidOperationException("Collection modified.");
        return ($typemap(cstype, CTYPE))currentObject;
      }
    }
  
    // Type-unsafe IEnumerator.Current
    object global::System.Collections.IEnumerator.Current {
      get {
        return Current;
      }
    }
    
    public bool MoveNext() {
      if (currentNode == null) {
        currentIndex = collectionRef.Count + 1;
        return false;
      }
      ++currentIndex;
      currentObject = currentNode.Value;
      currentNode = currentNode.Next;
      return true;
    }
    
    public void Reset() {
      currentIndex = -1;
      currentObject = null;
      if (collectionRef.Count != currentSize) {
        throw new global::System.InvalidOperationException("Collection modified.");
      }
    }
    
    public void Dispose() {
      currentIndex = -1;
      currentObject = null;
    }
  }
  
  public sealed class $csclassnameNode {
    internal $csclassname list;
    internal System.IntPtr iter;
	internal $typemap(cstype, CTYPE) csharpvalue;
	internal bool inlist;
    
    public $csclassnameNode($typemap(cstype, CTYPE) value) {
	  csharpvalue = value;
	  inlist = false;
    }

    internal $csclassnameNode(System.IntPtr _iter, $csclassname _list) {
      list = _list;
      iter = _iter;
	  inlist = true;
    }
    
    public $csclassname List {
      get { 
        return this.list; 
      }
    }

    public $csclassnameNode Next {
      get { 
	    if (list.getNextIter(iter) == System.IntPtr.Zero)
		  return null;
        return new $csclassnameNode(list.getNextIter(iter), list);
      }
    }
  
    public $csclassnameNode Previous {
      get {
	    if (list.getPrevIter(iter) == System.IntPtr.Zero)
		  return null;
        return new $csclassnameNode(list.getPrevIter(iter), list);
      }
    }
    
	public $typemap(cstype, CTYPE) Value {
      get { 
        return list.getItem(this.iter); 
      }
      set { 
        list.setItem(this.iter, value); 
      }
    }

	public static bool operator== ($csclassnameNode node1, $csclassnameNode node2) {
	  if (object.ReferenceEquals(node1, null) && object.ReferenceEquals(node2, null))
	    return true;
	  if (object.ReferenceEquals(node1, null) || object.ReferenceEquals(node2, null))
	    return false;
	  return node1.Equals(node2);
	}

    public static bool operator!= ($csclassnameNode node1, $csclassnameNode node2) {
	  if (node1 == null && node2 == null)
	    return false;
	  if (node1 == null || node2 == null)
	    return true;
	  return !node1.Equals(node2);
	}

	public bool Equals($csclassnameNode node) {
	  if (node == null)
	    return false;
	  if (!node.inlist || !this.inlist)
	    return object.ReferenceEquals(this, node);
	  return list.equals(this.iter, node.iter);
	}

	public override bool Equals(object node) {
	  return Equals(($csclassnameNode)node);
	}

	public override int GetHashCode() {
	  int hash = 13;
	  if (inlist) {
	    hash = (hash * 7) + this.list.GetHashCode();
	    hash = (hash * 7) + this.Value.GetHashCode();
	    hash = (hash * 7) + this.list.getNextIter(this.iter).GetHashCode();
	    hash = (hash * 7) + this.list.getPrevIter(this.iter).GetHashCode();
	  } else {
	    hash = (hash * 7) + this.csharpvalue.GetHashCode();	  
	  }
	  return hash;
	}

	public void Dispose() {
	  list.deleteIter(this.iter);
	}
  }
%}

public:
  typedef size_t size_type;
  typedef CTYPE value_type;
  typedef CONST_REFERENCE const_reference;
  void push_front(CTYPE const& x);
  void push_back(CTYPE const& x);
  %rename(RemoveFirst) pop_front;
  void pop_front();
  %rename(RemoveLast) pop_back;
  void pop_back();
  size_type size() const;
  %rename(Clear) clear;
  void clear();
  %extend {
	CONST_REFERENCE getItem(void *iter) {
      std::list< CTYPE >::iterator it = *reinterpret_cast<std::list< CTYPE >::iterator*>(iter);
	  return *it;
    }

	void setItem(void *iter, CTYPE const& val) {
	  std::list< CTYPE >::iterator* it = reinterpret_cast<std::list< CTYPE >::iterator*>(iter);
	  *(*it) = val;
	}
    
	void *getFirstIter() {
	  if ($self->size() == 0)
	    return NULL;
	  auto iterator = new std::list< CTYPE >::iterator($self->begin());
	  return reinterpret_cast<void *>(iterator);
	}

	void *getLastIter() {
	  if ($self->size() == 0)
	    return NULL;
	  auto iterator = new std::list< CTYPE >::iterator(--$self->end());
	  return reinterpret_cast<void *>(iterator);
	}

	void *getNextIter(void *iter) {
	  auto it = *(reinterpret_cast<std::list< CTYPE >::iterator *>(iter));
	  if (std::distance(it, --$self->end()) != 0) {
		auto itnext =  new std::list< CTYPE >::iterator(++it);
		return itnext;
	  }
	  return NULL;
	}

	void *getPrevIter(void *iter) {
      auto it = *(reinterpret_cast<std::list< CTYPE >::iterator *>(iter));
	  if (std::distance($self->begin(), it) != 0) {
		auto itprev =  new std::list< CTYPE >::iterator(--it);
		return itprev;
	  }
	  return NULL;
	}

	void *insertNode(void *iter, CTYPE const& value) {
	  auto it = $self->insert(*(reinterpret_cast<std::list< CTYPE >::iterator *>(iter)), value);
	  auto newit = reinterpret_cast<void *>(new std::list< CTYPE >::iterator(it));
	  return newit;
	}

	void *find(CTYPE const& value) {
	  if (std::find($self->begin(), $self->end(), value) != $self->end()) {
	    auto it = reinterpret_cast<void *>(new std::list< CTYPE >::iterator(std::find($self->begin(), $self->end(), value)));
	    return it;
	  }
	  return NULL;
	}

	void eraseIter(void *iter) {
	  auto it = *reinterpret_cast<std::list< CTYPE >::iterator*>(iter);
	  $self->erase(it);
	}

	void deleteIter(void *iter) {
	  std::list< CTYPE >::iterator* it = reinterpret_cast<std::list< CTYPE >::iterator*>(iter);
	  delete it;
	}
	
	bool equals(void *iter1, void *iter2) {
	  if (iter1 == NULL && iter2 == NULL)
	    return true;
	  std::list< CTYPE >::iterator it1 = *reinterpret_cast<std::list< CTYPE >::iterator*>(iter1);
	  std::list< CTYPE >::iterator it2 = *reinterpret_cast<std::list< CTYPE >::iterator*>(iter2);
	  return it1 == it2;
	}
   
    bool Contains(CTYPE const& value) {
      return std::find($self->begin(), $self->end(), value) != $self->end();
    }
  }
%enddef
 
%apply void *VOID_INT_PTR { void *iter1, void *iter2, void *iter, void *find, void *insertNode, void *getPrevIter, void *getNextIter, void *getFirstIter, void *getLastIter }

%define SWIG_STD_LIST_ENHANCED(CTYPE...)
namespace std {
  template<> class list< CTYPE > {
    SWIG_STD_LIST_MINIMUM_INTERNAL(%arg(CTYPE const&), %arg(CTYPE));
  };
}
%enddef



%{
#include <iostream>
#include <list>
#include <algorithm>
#include <stdexcept>
%}

%csmethodmodifiers std::list::size "private"
%csmethodmodifiers std::list::getItem "private"
%csmethodmodifiers std::list::setItem "private"
%csmethodmodifiers std::list::push_front "private"
%csmethodmodifiers std::list::push_back "private"
%csmethodmodifiers std::list::getFirstIter "private"
%csmethodmodifiers std::list::getNextIter "private"
%csmethodmodifiers std::list::getPrevIter "private"
%csmethodmodifiers std::list::getLastIter "private"
%csmethodmodifiers std::list::find "private"
%csmethodmodifiers std::list::deleteIter "private"

namespace std {
  template<class T> 
  class list {
    SWIG_STD_LIST_MINIMUM_INTERNAL(T const&, T)
  };
  template<class T> 
  class list<T *> 
  {
    SWIG_STD_LIST_MINIMUM_INTERNAL(T *const&, T *)
  };
  template<> 
  class list<bool> {
    SWIG_STD_LIST_MINIMUM_INTERNAL(bool, bool)
  };
}
