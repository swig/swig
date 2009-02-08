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
#include <cstdlib>
namespace doh {
  /* class Hash */
  /* Constructors */
  Hash::Hash() {       
  }

  Hash::Hash(const Hash &x)
    : Container(x), map_doh(x)
  {}

  /* inherit from DOH */    
  DOH *Hash::clone() const {
    return new Hash(*this);
  }

  void Hash::clear() {
    map_doh::clear();
    DOH::clear();
  }

  int Hash::size() const {
    return map_doh::size();
  }

   /* internal iterator for Hash */
  class Hash::_iterator
    : public _Iterator, public map_doh::iterator {
  public:
    _iterator(const map_doh::iterator& i)
      :map_doh::iterator(i)
    {}
    virtual ~_iterator() {
    }
  };


  /* inherit from Container */
  Iterator Hash::first() {
    Iterator i;
    /* XXX potential memory leak since we only
     * delete i._iter when the iterator reached
     * its end. */ 
    i._iter = new _iterator(begin());
    i.object = this;
    check_iter(i);
    return i; 
  }
  Iterator& Hash::next(Iterator& i) {
    _iterator* _i = dynamic_cast<_iterator*>(i._iter);
    ++(*_i);
    check_iter(i);
  }
  
   // Check and set state of iterator
  void Hash::check_iter(Iterator &i) {
    _iterator* _i = dynamic_cast<_iterator*>(i._iter);
    if (0==_i)
      return;
    if (end() != *_i) {
      i.key = (**_i).first.c_str();
      i.item = (**_i).second;
    } else {
      i.key = 0;
      i.item = 0;
      delete i._iter;
      i._iter = 0;
    } 
  }

  Hash *NewHash(void) {
    return new Hash();
  }

  DOHCaster Getattr(DOH *obj, const String_or_char_ptr name) {
    Hash &ho = ref_cast<Hash>(obj); 
    std::string key(name);
    if (ho.count(key) > 0)
      return ho[key];
    else
      return 0;
  }

  int Setattr(DOH *obj, const String_or_char_ptr name, const char *value) {
    Hash &ho = ref_cast<Hash>(obj); 
    std::string key(name);
    DOH *so = new String(value);
    int r = ho.count(key);
    ho[key] = so;
    return r;
  }

  int Setattr(DOH *obj, const String_or_char_ptr name, DOH *value) {
    Hash &ho = ref_cast<Hash>(obj); 
    std::string key(name);
    int r = ho.count(key);
    ho[key] = value;
    return r;
  }

  int Checkattr(DOH *obj, const String_or_char_ptr name, const String_or_char_ptr value) {
    DOH *attr = Getattr(obj, name);
    if (!attr) return 0;
    return Equal(doh_cast<String*>(attr), value);
  }

  DOHCaster Keys(DOH *obj) {
    Hash &ho = ref_cast<Hash>(obj); 
    List *keys = new List();
    map_doh::iterator iter = ho.begin();
    for(;iter!=ho.end(); iter++) {
      keys->push_back(new String(iter->first));
    }
    return keys;
  }

  int GetInt(DOH *obj, const String_or_char_ptr name) {
    Hash &ho = ref_cast<Hash>(obj); 
    std::string key(name);
    if (ho.count(key)>0) {
      String *val = doh_cast<String*>(ho[key]);
      return atoi(val->c_str()); 
    } else
      return 0;    
  }

  void SetInt(DOH *obj, const String_or_char_ptr name, int value) {
    String *val = NewStringEmpty();
    Printf(val, "%d", value);
    Setattr(obj, name, val);
  }

  DOHCaster GetFlagAttr(DOH *obj, const String_or_char_ptr name) {
    DOH *val = Getattr(obj, name);
    if (!val) {
      return 0;
    } else {
      String &sval = ref_cast<String>(val);
      return (sval != "0") ? val : NULL; 
    }
  }

  int GetFlag(DOH *obj, const String_or_char_ptr name) {
    return (DOH*) GetFlagAttr(obj, name) ? 1 : 0;
  }
  
  void SetFlagAttr(DOH *obj, const String_or_char_ptr name, DOH *attr) {
    Setattr(obj, name, attr ? attr : NewString("0"));
  }

  void SetFlag(DOH *obj, const String_or_char_ptr name) {
    Setattr(obj, name, NewString("1"));
  }

}
