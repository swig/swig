#include <string>
#include <list>
#include <iostream>
#include <cassert>
#include <exception>
#include "doh.h"

namespace doh {

  /* class DOH */
  DOH::DOH()
    : _line(0), _file(0), meta(0)
  {}

  DOH::DOH(const DOH &x)
    : _line(x._line), _file(x._file),
      meta(x.meta->clone())
  {}

  DOH::~DOH() {
    if (meta)
      delete meta;
  }

  void DOH::clear() {
    if (meta)
      delete meta;
    meta = 0;
    _line = 0;
    _file = 0;
    return;
  }

  void DOH::line(int l) {
    _line = l;
  }

  int DOH::line() {
    return _line;
  }

  void DOH::file(DOH *f) {
    _file = f;
  }

  DOH *DOH::file() {
    return _file;
  }

  void DOH::setmeta(DOH *name, DOH *value) {
    String &namestr = ref_cast<String>(name);
    if (0==meta)
      meta = new Hash;
    Hash &ho = *doh_cast<Hash*>(meta);
    ho[namestr] = value;
  }

  DOH *DOH::getmeta(DOH *name) {
    String &namestr = ref_cast<String>(name);
    if (0==meta)
      return 0;
    Hash &ho = ref_cast<Hash>(meta);
    if (ho.count(namestr) > 0)
      return ho[namestr];
    else
      return 0;
  }

  /* class Filelike */
  Filelike::Filelike()
  {}

  Filelike::Filelike(const Filelike& f)
    :DOH(f)
  {}


  /* class Container */
  Container::Container()
  {}
  Container::Container(const Container &x)
    :DOH(x)
  {}

  /* class _Iterator */
  _Iterator::~_Iterator() {
  }

  /* struct Iterator */
  Iterator::~Iterator() {
  }

  /* class DOHCaster */

  DOHCaster::DOHCaster(DOH *obj)
    :content(obj)
  {}

  DOHCaster::operator DOH* () {
    return to_ptr<DOH>();
  }

  DOHCaster::operator const char* () {
    return to_ptr<String>()->c_str();
  }

  DOHCaster::operator String* () {
    return to_ptr<String>();
  }

  DOHCaster::operator List* () {
    return to_ptr<List>();
  }

  template<class T>
  T* DOHCaster::to_ptr() const {
    return dynamic_cast<T*>(content);
  }


  /* class String_or_char_ptr */

  String_or_char_ptr::String_or_char_ptr(const String_or_char_ptr& str)
    :content_str(str.content_str),
    content_charptr(str.content_charptr),
    need_free(0) /* TODO: may potential memory leak/corrupt here */
  {}

  String_or_char_ptr::~String_or_char_ptr() {
    if (need_free) {
      delete content_str;
    }
  }

  // Casters
  // from const char*
  String_or_char_ptr::String_or_char_ptr(const char *s)
    :content_str(0), content_charptr(s),
    need_free(false)
  {}
  // from DOH*
  String_or_char_ptr::String_or_char_ptr(const DOH* str)
    :content_str(dynamic_cast<const String*>(str)),
    content_charptr(0),
    need_free(false)
  {}
  // to const char*
  String_or_char_ptr::operator const char* () const {
    return content_charptr ? content_charptr : content_str->c_str();
  }
  // to const String*
  String_or_char_ptr::operator const String* () const {
    if (!content_str) {
      content_str = new String(content_charptr);
      need_free = true;
    }
    return content_str;
  }

  /* wrapper of dynamic_cast with error detection */
  template<class T>
  T doh_cast(DOH *obj) {
    // TODO: raise exception
    T result = dynamic_cast<T>(obj);
    assert(result);
    return result;
  }

  template<class T>
  T doh_cast(const DOH *obj) {
    T result = dynamic_cast<T>(obj);
    assert(result);
    return result;
  }
 
  /* shortcut which cast DOH object pointer to reference */
  template<class T>
  T& ref_cast(DOH *obj) {
    return *doh_cast<T*>(obj);
  }


  /* Basic object methods */
  int DohCheck(const DOH *ptr) {
    if (ptr)
      return true;
    else
      return false;
  }

  int Len(const DOH* obj) {
    return obj->size();
  }

  DOHCaster Copy(const DOH* obj) {
    return obj->clone();
  }

  void Clear(DOH *obj) {
    obj->clear();
  }

  void Delete(DOH *obj) {
    delete obj;
    return;
  }

  /* Positional */

  int Getline(DOH *obj) {
    return obj->line();
  }
  void Setline(DOH *obj, int line) {
    obj->line(line);
  }

  DOH *Getfile(DOH *obj) {
    return obj->file();
  }

  void Setfile(DOH *obj, DOH *file) {
    return obj->file(file);
  }



  /* Common methods for List and String */
  int Dump(const DOH *obj, DOH *out) {
    // XXX only support string dump
    const String *so = doh_cast<const String*>(obj);
    Write(out, so->data(), so->size());
  }


  int Insertitem(DOH *obj, int index, DOH *value) {
    int len = obj->size();
    if (DOH_END == index) {
      index = len;
    }
    if (index < 0) {
      index = 0;
    }
    if (index > len) {
      index = len;
    }

    if (dynamic_cast<List*>(obj)) {
      /* is List */
      List *lo = doh_cast<List*>(obj);
      lo->insert(index, value);
    } else {
      /* is String */
      String *so = doh_cast<String*>(obj);
      String &str = ref_cast<String>(value);
      so->insert(index,str);
    }
    return 0;
  }

  int Append(DOH *x, DOH *item) {
    if (!item)
      return -1;
    if (dynamic_cast<List*>(x)) {
      /* the object is a list */
      List *lo = doh_cast<List*>(x);
      lo->push_back(item);
    } else {
      /* otherwise it is string */
      String *so = doh_cast<String*>(x);
      String &str = ref_cast<String>(item);
      so->append(str);
    }
    return 0;
  }

  int Delslice(DOH *obj, int sindex, int eindex) {
    int len = obj->size();
    if (eindex == DOH_END)
      eindex = len;
    if (sindex == DOH_BEGIN)
      sindex = 0;

    if (dynamic_cast<List*>(obj)) {
      /* is List */
      List *lo = doh_cast<List*>(obj);
      lo->erase(sindex, eindex - sindex);
    } else {
      /* is String */
      String *so = doh_cast<String*>(obj);
      so->erase(sindex, eindex - sindex);
    }
    return 0;
  }

  int Delitem(DOH *obj, int index) {
    int len = obj->size();
    if (index == DOH_END)
      index = len-1;
    if (index == DOH_BEGIN)
      index = 0;
    if (len == 0)
      return 0;
    return Delslice(obj, index, index+1);
  }

  /* Common methods for String and File */
  int Write(DOH * obj, const char *buffer, int length) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->write(buffer, length);
  }

  int Read(DOH * obj, char *buffer, int length) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->read(buffer, length);
  }

  int Seek(DOH * obj, long offset, int whence) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->seek(offset, whence);
  }

  long Tell(DOH * obj) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->tell();    
  }

  int Getc(DOH * obj) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->getc();  
  }

  int Putc(int ch, DOH * obj) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->putc(ch);
  }

  int Ungetc(int ch, DOH * obj) {
    Filelike *fo = doh_cast<Filelike*>(obj);
    return fo->ungetc(ch);
  }


  /* Iterator */
  Iterator First(DOH *obj) {
    Container *cont = dynamic_cast<Container*>(obj);
    assert(cont);
    return cont->first();
  }

  Iterator& Next(Iterator& x) {
    Container *cont = dynamic_cast<Container*>(x.object);
    assert(cont);
    return cont->next(x);
  }

  /* Miscellaneous */

  int DohIsMapping(const DOH *obj) {
    const Hash* o = dynamic_cast<const Hash*>(obj);
    return o ? true : false;
  }
  
  int DohIsSequence(const DOH *obj) {
    const List* o = dynamic_cast<const List*>(obj);
    return o ? true : false;
  }

  int DohIsString(const DOH *obj) {
    const String* o = dynamic_cast<const String*>(obj);
    return o ? true : false;
  }

  int DohIsFile(const DOH *obj) {
    const Filelike* o = dynamic_cast<const Filelike*>(obj);
    return o ? true : false;
  }
 
}


