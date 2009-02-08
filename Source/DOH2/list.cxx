/*
 *  This file is part of SWIG.
 *
 *  SWIG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SWIG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SWIG.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "doh.h"
#include <cassert>
namespace doh {
 
  /* class List */
  
  /* Constructors */

  List::List() {
  }

  List::List(const List &x)
    :list_doh(x), Container(x)
  {}
  
  /* inherit from DOH */

  DOH* List::clone() const {
    return new List(*this);
  }

  void List::clear() {
    list_doh::clear();
    DOH::clear();
    return;
  }

  int List::size() const {
    return list_doh::size();
  }

  /* internal iterator for List */
  class List::_iterator
    : public _Iterator, public list_doh::iterator {
  public:
    _iterator(const list_doh::iterator& i)
      :list_doh::iterator(i)
    {}
    virtual ~_iterator() {
    }
  };

  /* inherit from Container */

  Iterator List::first() {
    Iterator i;
    /* XXX potential memory leak since we only
     * delete i._iter when the iterator reached
     * its end. */ 
    i._iter = new _iterator(begin());
    i.object = this;
    i.key = 0;
    check_iter(i);
    return i;
  }

  Iterator& List::next(Iterator& i) {
    _iterator* _i = dynamic_cast<_iterator*>(i._iter);
    ++(*_i);
    check_iter(i);
    return i;
  }

  void List::check_iter(Iterator& i) {
    _iterator* _i = dynamic_cast<_iterator*>(i._iter);
    if (0==_i)
      return;
    if (end() != *_i) {
      i.item = (**_i);
    } else {
      i.item = 0;
      delete i._iter;
      i._iter = 0;
    }
  }
  
  /* Overloaded for convenience */
  void List::insert(size_t pos, DOH *x) {
    iterator iter = begin();
    while (pos--)
      iter++;
    list_doh::insert(iter, x);
    return;
  }
  
  void List::erase(size_t pos, size_t n) {
    iterator iter = begin();
    while (pos--)
      iter++;
    while (n--)
      iter = list_doh::erase(iter);
    return;
  }

  /* DOH List methods */

  List *NewList() {
    return new List();
  }

  void SortList(DOH *lo, int (*cmp) (const String_or_char_ptr, const String_or_char_ptr)) {
    List *l = doh_cast<List*>(lo);
    if (!cmp) {
      cmp = Cmp;
    }
    l->sort(cmp);
  }
}
