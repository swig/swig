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
	public $csclassname(global::System.Collections.IEnumerable c) : this() 
	{
		if (c == null)
			throw new global::System.ArgumentNullException("c");
		foreach ($typemap(cstype, CTYPE) element in c) 
		{
			this.AddLast(element);
		}
	}

	public bool IsReadOnly 
	{
		get {
			return false;
		}
	}
	
	public int Count 
	{
		get {
			return (int)size();
		}
	}
	
	private	$csclassnameNode _head;
	internal $csclassnameNode head
	{
		get {
			if (this._head == null && (int)size() > 0)
			{
				this._head = new $csclassnameNode(($typemap(cstype, CTYPE))getItem(0), 0, this);
			}
			return this._head;
		}
		set { this._head = value; }
	}
	public $csclassnameNode First
	{
		get { return this.head;	}
	}
	
	private	$csclassnameNode _tail;
	internal $csclassnameNode tail
	{
		get {
			if (this._tail == null && (int)size() > 0) {
				this._tail = new $csclassnameNode(($typemap(cstype, CTYPE))getItem((int)size() - 1), (int)size() - 1, this);
			}
			return this._tail;
		}
		set { this._tail = value; }
	}
	
	public $csclassnameNode Last
	{
		get { return this.tail;	}
	}
	
	public $csclassnameNode AddFirst($typemap(cstype, CTYPE) value)
	{
		$csclassnameNode	newNode = new $csclassnameNode(value, 0, this);
		AddFirst(newNode);
		return newNode;
	}
	
	public void AddFirst($csclassnameNode newNode)
	{
		if (this.Count == 0)
		{
			newNode.next = null;
			newNode.prev = null;
			this.head = newNode;
			this.tail = newNode;
		}
		else
		{
			$csclassnameNode	tmp = this.First;
			
			while (tmp != null)	{
				tmp.index++;
				tmp = tmp.Next;
			}
			newNode.next = this.head;
			this.head.prev = newNode;
			this.head = newNode;
		}
		push_front(newNode.Value);
		if (newNode.index == -1)
			newNode.index = 0;
		if (newNode.list == null)
			newNode.list = this;
	}

	public $csclassnameNode AddLast($typemap(cstype, CTYPE) value)
	{
		$csclassnameNode	newNode = new $csclassnameNode(value, (int)size(), this);
		AddLast(newNode);
		return newNode;
	}

	public void AddLast($csclassnameNode newNode)
	{
		if (this.Count == 0)
		{
			newNode.next = null;
			newNode.prev = null;
			this.head = newNode;
			this.tail = newNode;
		}
		else
		{
			newNode.prev = this.Last;
			this.Last.next = newNode;
			this.tail = newNode;
		}
		push_back(newNode.Value);
		if (newNode.index == -1)
			newNode.index = (int)size() - 1;
		if (newNode.list == null)
			newNode.list = this;
	}
	
	public $csclassnameNode AddBefore($csclassnameNode node, $typemap(cstype, CTYPE) value)
	{
		$csclassnameNode newNode = new $csclassnameNode(value, node.index, this);
		AddBefore(node, newNode);
		return newNode;
	}

	public void AddBefore($csclassnameNode node, $csclassnameNode newNode)
	{
		ValidateNode(node);
		ValidateNode(newNode);
		newNode.next = node;
		newNode.prev = node.Previous;
		node.Previous.next = newNode;
		node.prev = newNode;
		insertIndex(node.index, newNode.Value);

		if (newNode.index == -1)
			newNode.index = node.index;
		if (newNode.list == null)
			newNode.list = this;

		$csclassnameNode tmp = node;
		while (tmp != null)
		{
			tmp.index++;
			tmp = tmp.Next;
		}
	}

	public $csclassnameNode AddAfter($csclassnameNode node, $typemap(cstype, CTYPE) value)
	{
		$csclassnameNode newNode = new $csclassnameNode(value, node.index + 1, this);
		AddBefore(node.Next, newNode);
		return newNode;
	}

	public void AddAfter($csclassnameNode node, $csclassnameNode newNode)
	{
		AddBefore(node.Next, newNode);
	}

	public void Add($typemap(cstype, CTYPE) value)
	{
		this.AddLast(value);
	}
	
	public void RemoveFirst()
	{
		pop_front();
		this.First.Next.prev = null;
		this.head = this.First.Next;
		$csclassnameNode node = this.First;
		while (node != null) {
			node.index--;
			node = node.Next;
		}
	}

	public void RemoveLast()
	{
		pop_back();
		this.Last.Previous.next = null;
		this.tail = this.Last.Previous;
	}

	public bool Remove($typemap(cstype, CTYPE) value)
	{
		$csclassnameNode node = Find(value);
		return Remove(node);
	}

	public bool Remove($csclassnameNode node)
	{
		ValidateNode(node);
		if (node != null)
		{
			if (node.index == 0)
				RemoveFirst();
			else if (node.index == (int)size() - 1)
				RemoveLast();
			else
			{
				rmvIndex(node.index);
				$csclassnameNode tmp = node;
				while (tmp != null) {
					tmp.index--;
					tmp = tmp.Next;
				}
				node.Next.prev = node.Previous; 
				node.Previous.next = node.Next;
				if (this.head == node) {
					this.head = node.Next;
				} 
				else if (this.tail == node) {
					this.tail = node.Previous;
				}
			}
			return true;
		}
		return false;
	}

	public $csclassnameNode Find($typemap(cstype, CTYPE) value)
	{
		int tmpPos = find_item(value);
		$csclassnameNode tmp = this.First;
		int i = 0;

		if (tmpPos != -1) {
			while (i != tmpPos) {
				tmp = tmp.Next;
				++i;
			}
			return tmp;
		}
		return null;
	}
	
	public void CopyTo($typemap(cstype, CTYPE)[] array, int index)
	{
		if (array == null)
			throw new global::System.ArgumentNullException("array");
		if (index < 0)
			throw new global::System.ArgumentOutOfRangeException("index", "Value is less than zero");
		if (array.Rank > 1)
			throw new global::System.ArgumentException("Multi dimensional array.", "array");
		$csclassnameNode current = this.First;
		if (current != null)
		{
			do
			{
				array[index++] = current.Value;
				current = current.Next;
			} while (current != null);
		}
	}

	public void Clear()
	{
		$csclassnameNode current = this.First;
		
		while (current != null)
		{
			$csclassnameNode tmp = current;
			current = current.Next;
			tmp.list = null;
			tmp.next = null;
			tmp.prev = null;
		}
		
		this.head = null;
		clear();
	}

	internal void ValidateNode($csclassnameNode node)
	{
		if (node == null) {
			throw new System.ArgumentNullException("node"); 
		} 
		
		if ( node.list != this) { 
			throw new System.InvalidOperationException("node");
		}
	}

	global::System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)> global::System.Collections.Generic.IEnumerable<$typemap(cstype, CTYPE)>.GetEnumerator() 
	{
		return new $csclassnameEnumerator(this);
	}

	global::System.Collections.IEnumerator global::System.Collections.IEnumerable.GetEnumerator() 
	{
		return new $csclassnameEnumerator(this);
	}

	public $csclassnameEnumerator GetEnumerator() 
	{
		return new $csclassnameEnumerator(this);
	}
	
	public sealed class $csclassnameEnumerator : global::System.Collections.IEnumerator,
		global::System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)>
	{
		private $csclassname collectionRef;
		private $csclassnameNode currentNode;
		private int	currentIndex;
		private object currentObject;
		private int	currentSize;
		
		public $csclassnameEnumerator($csclassname collection)
		{
			collectionRef = collection;
			currentNode = collection.First;
			currentIndex = 0;
			currentObject = null;
			currentSize = collectionRef.Count;
		}
		
		// Type-safe iterator Current
		public $typemap(cstype, CTYPE) Current 
		{
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
		object global::System.Collections.IEnumerator.Current 
		{
			get {
				return Current;
			}
		}
		
		public bool MoveNext()
		{
			if (currentNode == null) {
				currentIndex = collectionRef.Count + 1;
				return false;
			}
			++currentIndex;
			currentObject = currentNode.Value;
			currentNode = currentNode.Next;
			return true;
		}
		
		public void Reset()
		{
			currentIndex = -1;
			currentObject = null;
			if (collectionRef.Count != currentSize) {
				throw new global::System.InvalidOperationException("Collection modified.");
			}
		}
		
		public void Dispose()
		{
			currentIndex = -1;
			currentObject = null;
		}
	}
	
	public sealed class $csclassnameNode
	{
		internal $csclassname list;
		internal $typemap(cstype, CTYPE) item;
		internal int index;
		
		public $csclassnameNode($typemap(cstype, CTYPE) value)
		{
			this.item = value;
		}

		internal $csclassnameNode($typemap(cstype, CTYPE) value, int _index, $csclassname _list)
		{
			this.list = _list;
			this.item = value;
			this.index = _index;
		}
		
		public $csclassname List
		{
			get { return this.list; }
		}

		private $csclassnameNode _next;
		internal $csclassnameNode next
		{
			get {
				if (this._next == null && index + 1 < (int)this.list.size()) {
					this._next = new $csclassnameNode(this.list.getItem(index + 1), index + 1, this.list);
					this._next.prev = this;
				}
				if (index + 1 == (int)this.list.size() - 1)
					this.list.tail = this._next;
				return this._next; 
			}
			set { this._next = value; }
		}

		public $csclassnameNode Next
		{
			get { return this.next; }
		}
	
		private $csclassnameNode _prev;
		internal $csclassnameNode	prev
		{
			get { 
				if (this._prev == null && index - 1 >= 0) {
					this._prev = new $csclassnameNode(this.list.getItem(index - 1), index - 1, this.list);
					this._prev.next = this;
				}
				if (index - 1 == 0)
					this.list.head = this._prev;
				return this._prev;
			}
			set { this._prev = value; }
		}

		public $csclassnameNode Previous
		{
			get { return this.prev; }
		}
		
		public $typemap(cstype, CTYPE) Value
		{
			get { return this.item; }
			set { this.item = value; }
		}
	}
%}

public:
	typedef size_t size_type;
	typedef CTYPE value_type;
	typedef CONST_REFERENCE const_reference;
	void clear();
	void push_front(CTYPE const& x);
	void push_back(CTYPE const& x);
	void pop_front();
	void pop_back();
	size_type size() const;
	%extend {
		const CTYPE& getItem(int index) {
			std::list< CTYPE >::iterator it = $self->begin();
			
			if (index >= 0 && index < (int)($self->size())) {
				for (int i = 0; i != index; i++)
					it++;
				return *it;
			} else {
				throw std::out_of_range("index");
			}
		}
		
		int find_item(CTYPE const& x) {
			std::list< CTYPE >::iterator it = $self->begin();
			int i = 0;
		
			while (it != $self->end() && (CTYPE const&)*it != x) {
				++it;
				++i;
			}
			if (it != $self->end())
				return i;
			return -1;
		}

		void insertIndex(int index, CTYPE const& value) {
			std::list< CTYPE >::iterator it = $self->begin();
			int i = 0;

			while (it != $self->end() && i != index) {
				++it;
				++i;
			}
			$self->insert(it, value);
		}

		bool rmv(const CTYPE& value) {
			std::list< CTYPE >::iterator it = std::find($self->begin(), $self->end(), value);
			
			if ($self->erase(it) != $self->end())
				return true;
			return false;
		}

		bool rmvIndex(int index) {
			std::list< CTYPE >::iterator it = $self->begin();

			for (int i = 0; i != index; i++)
				++it;
			if (it != $self->end()) {
				$self->erase(it);
				return true;
			}
			return false;
		}
		
		bool Contains(CTYPE const& value) {
			return std::find($self->begin(), $self->end(), value) != $self->end();
		}
	}
%enddef
 
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
%csmethodmodifiers std::list::find_item "private"
%csmethodmodifiers std::list::push_front "private"
%csmethodmodifiers std::list::push_back "private"
%csmethodmodifiers std::list::rmv "private"
%csmethodmodifiers std::list::rmvIndex "private"
%csmethodmodifiers std::list::insertIndex "private"

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
