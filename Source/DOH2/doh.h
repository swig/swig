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

#ifndef _DOH_H
#define _DOH_H

#include <string>
#include <list>
#include <map>
#include <fstream>

/* Problems need to be solved:
 *
 * 1. String_or_char *: find a replacement so foo(String_or_char * c) works.
 *
 * 2. List and Hash require the ability to contain any DOH objects
 *      (No longer require things like boost::any!)
 *      All DOH types inherit from DOH
 *
 * 3. Auto cast return value to String* or List* etc. (for Getattr())
 *      Casters.
 *      All casters storage content as DOH*
 *      StringCaster : cast from const char*, std::string, String*
 *                            to const char*, std::string&, String*
 *      DohCaster : StringCaster adds caster for List* and Hash*
 *
 * 4. Extra data attached to each object (file, line, meta)
 *      In DOH
 *
 * 5. Keep the DOH iterator interface
 *
 * 6. Co-operating with STL
 *
 * 7. DOH String is file-like
 *
 * 8. varargs
 *
 *
 * Core types:
 *      String, List, Mapping, File, Iterator
 */

namespace doh {
  /* Base class for DOH types */
  class DOH {
  public:
    DOH();
    DOH(const DOH &x);
    virtual ~DOH();
    
    virtual DOH *clone() const = 0;
    virtual void clear();
    virtual int size() const = 0;

    void line(int l);
    int line();
    void file(DOH *f);
    DOH *file();
    void setmeta(DOH *name, DOH *value);
    DOH *getmeta(DOH *name);

  protected:
    DOH *meta;
    int _line;
    DOH *_file;
  };
  
  /* Interface for file-like objects (String and File) */
  class Filelike : public DOH {
  public:
    Filelike();
    Filelike(const Filelike& f);

    virtual int write(const char *buffer, size_t length) = 0;
    virtual int read(char *buffer, size_t length) = 0;
    virtual int seek(off_t offset, int whence) = 0;
    virtual off_t tell() = 0;
    virtual char getc() = 0;
    virtual char putc(char c) = 0;
    virtual char ungetc(char ch) = 0;
  };

  class String : public Filelike, public std::string {
  public:
    /* Constructors */
    String();
    String(const String& str);
    String(const std::string& str);
    String(const char *s);
    String(const char *s, size_t n);

    virtual DOH *clone() const;
    virtual void clear();
    virtual int size() const;

    virtual int write(const char *buffer, size_t length);
    virtual int read(char *buffer, size_t length);
    virtual int seek(off_t offset, int whence);
    virtual off_t tell();
    virtual char getc();
    virtual char putc(char c);
    virtual char ungetc(char ch);

    int doh_replace(const char *token, const char *rep, int flags);
    
    /*TODO: override all modifiers of std::string
     * to keep sp always at correct position
     */
    String& insert(size_t pos, const std::string &str);
    String& erase(size_t pos, size_t n);

  private:
    off_t sp;
  };

  /* XXX Now we uses cstdio for file I/O, may switch to fstream */
  //class File : public Filelike, public std::fstream {
  class File : public Filelike {
  public:
    /* Constructors */
    File();
    File(const File &f);
    File(const char *filename, const char *mode); 

    virtual DOH *clone() const;
    virtual void clear();
    virtual int size() const;

    virtual int write(const char *buffer, size_t length);
    virtual int read(char *buffer, size_t length);
    virtual int seek(off_t offset, int whence);
    virtual off_t tell();
    virtual char getc();
    virtual char putc(char c);
    virtual char ungetc(char ch);
  private:
    FILE *fp;
  };

  /* Iterator */

  /* class _Iterator, internal use for containers */
  class _Iterator {
  public:
    virtual ~_Iterator();
  };

  /* Public iterator */
  struct Iterator {
    /* XXX key should be DOH*, but have to be 
     * const char * to prevent memory leak */
    const char * key;
    DOH* item;
    DOH* object;
    _Iterator *_iter;
    ~Iterator();
  };

  class Container : public DOH {
  public:
    Container();
    Container(const Container &x);
    virtual Iterator first() = 0;
    virtual Iterator& next(Iterator& i) = 0;
  };

  /* TODO containers must have own copy of contained objects */

  typedef std::list<DOH*> list_doh;
  class List : public Container, public list_doh {
  public:
    /* Constructors */
    List();
    List(const List &x);

    virtual DOH *clone() const;
    virtual void clear();
    virtual int size() const;

    virtual Iterator first();
    virtual Iterator& next(Iterator& i);

    void insert(size_t pos, DOH *x);
    void erase(size_t pos, size_t n);
  private:
    //Internal iterator for List
    class _iterator;
    //Check and set state of iterator
    void check_iter(Iterator &i);
  };

  typedef std::map<std::string, DOH*> map_doh;
  class Hash : public Container, public map_doh {
  public:
    /* Constructors */
    Hash();
    /* Copy constructor */
    Hash(const Hash &x);
    virtual DOH *clone() const;
    virtual void clear();
    virtual int size() const;

    virtual Iterator first();
    virtual Iterator& next(Iterator& i);
  private:
    //Internal iterator for Hash
    class _iterator;
    //Check and set state of iterator
    void check_iter(Iterator &i);
  };

  
  /* Caster */
  class DOHCaster {
  public:
    // from DOH*
    DOHCaster(DOH *obj);
    // to DOH*
    operator DOH* ();
    // to const char*
    operator const char* ();
    // to String*
    operator String* ();
    // to List*
    operator List* ();
    // to Hash*
    operator Hash* ();

  private:
    template<class T>
      T* to_ptr() const;

    DOH * const content;
  };

  /* wrapper of dynamic_cast with error detection */
  template<class T>
  T doh_cast(DOH *obj);

  template<class T>
  const T constdoh_cast(const DOH *obj);
   
  /* shortcut which cast DOH object pointer to reference */
  template<class T>
  T& ref_cast(DOH *obj);

  /* This class should only be used as
   * function input argument type.
   * It is the equivalence of
   *    const String_or_char *
   */
  class const_String_or_char_ptr {
  public:
    // Copy constructor
    const_String_or_char_ptr(const const_String_or_char_ptr& str);
    // Destructor
    ~const_String_or_char_ptr();

    /* Casters */
    // from const char*
    const_String_or_char_ptr(const char *s);
    // from DOH*
    const_String_or_char_ptr(const DOH* str);
    // to const char*
    operator const char* () const;
    // to const String*
    operator const String* () const;

  private:
    mutable bool need_free;
    mutable const String *content_str;
    const char *content_charptr;
  };

  /* ----------------------------------------------------------------------------- 
  * Our own varargs mechanism, so Printf and Stringf works.
  * This varargs implementation convert any DOH object to POD,
  * and then store it in a union.
  * -----------------------------------------------------------------------------*/  
  union vararg_item {
    int _int;
    double _double;
    const char *_str;
    void *_pointer;

    inline vararg_item(doh::DOH *obj)
      : _str(doh::doh_cast<String*>(obj)->c_str())
    {}
    inline vararg_item(const char *c)
      : _str(c)
    {}
    inline vararg_item(int i)
      : _int(i)
    {}

    inline vararg_item(double d)
      : _double(d)
    {}

    inline vararg_item(void *p)
      : _pointer(p)
    {}
  };

#define VA_DECL  vararg_item varg_0 = 0, \
                    vararg_item varg_1 = 0, \
                    vararg_item varg_2 = 0, \
                    vararg_item varg_3 = 0, \
                    vararg_item varg_4 = 0

#define VA_DEF  vararg_item varg_0, \
                    vararg_item varg_1, \
                    vararg_item varg_2, \
                    vararg_item varg_3, \
                    vararg_item varg_4
#define VA_CALL varg_0, varg_1, varg_2, varg_3, varg_4
#define VA_INIT int _varg_index = 0; \
                    vararg_item _varg_items[] = {VA_CALL};
#define VA_GET  (_varg_items[_varg_index++])



  /* Basic object methods. Common to most objects */
  int DohCheck(const DOH *ptr);	/* Check if a DOH object */
  void Delete(DOH *obj);
  DOHCaster Copy(const DOH* obj); /* Shallow copy. Copy meta, file, line */
  void Clear(DOH *obj);
  String *Str(const DOH *obj); // Rare
  void *Data(const DOH *obj); // Rare: only swig/typesys.c:1867
  int Dump(const DOH *obj, DOH *out);
  int Len(const DOH* obj);
  /* Cmp removed to string method section */
  int Hashval(const DOH *obj); // Never
  void DohIncref(DOH *obj); //Rare. Is it really useful?

  /* Mapping methods */
  //XXX Removed all the const qulifier of 'DOH *value' argument
  DOHCaster Getattr(DOH *obj, const_String_or_char_ptr name);
  int Setattr(DOH *obj, const_String_or_char_ptr name, const char *value); // Overloaded
  int Setattr(DOH *obj, const_String_or_char_ptr name, DOH *value);
  int Checkattr(DOH *obj, const_String_or_char_ptr name, const_String_or_char_ptr value);
  DOHCaster Keys(DOH *obj);
  int GetInt(DOH *obj, const_String_or_char_ptr name);
  void SetInt(DOH *obj, const_String_or_char_ptr name, int value);
  #define DohSetInt SetInt
  double GetDouble(DOH *obj, const_String_or_char_ptr name); // Never
  double SetDouble(DOH *obj, const_String_or_char_ptr name, double); // Never
  char *GetChar(DOH *obj, const_String_or_char_ptr name); // These are redundant 
  void SetChar(DOH *obj, const DOH *name, char *value);
  DOHCaster GetFlagAttr(DOH *obj, const_String_or_char_ptr name);
  int GetFlag(DOH *obj, const_String_or_char_ptr name);
  void SetFlagAttr(DOH *obj, const_String_or_char_ptr name, DOH *attr); // Rare
  void SetFlag(DOH *obj, const_String_or_char_ptr name);
  void GetVoid(DOH *obj, const_String_or_char_ptr name); // Rare, unable to support.  Modules/allegrocl.cxx
  void *SetVoid(DOH *obj, const_String_or_char_ptr name, void *value);
  #define UnsetFlag(o,n)     SetFlagAttr(o,n,NULL)

  /* Sequence methods */
  DOHCaster Getitem(DOH *obj, int index);
  int Setitem(DOH *obj, int index, DOH *value); // overloaded
  int Setitem(DOH *obj, int index, const char *value);
  int Delitem(DOH *obj, int index);
  int Insertitem(DOH *obj, int index, DOH *value); // overloaded
  int Insertitem(DOH *obj, int index, const char *value);
  int Delslice(DOH *obj, int sindex, int eindex);
  int Append(DOH *x, DOH *item); // was a macro
  #define Insert             DohInsertitem
//  #define Append(s,x)        DohInsertitem(s,DOH_END,x)
  #define Push(s,x)          DohInsertitem(s,DOH_BEGIN,x)

  /* Sequence position flags */
  #define DOH_BEGIN          -1
  #define DOH_END            -2
  #define DOH_CUR            -3
  #define DOH_CURRENT        -3

  /* File methods */

  int Write(DOH * obj, const char *buffer, int length);
  int Read(DOH * obj, char *buffer, int length);
  int Seek(DOH * obj, long offset, int whence);
  long Tell(DOH * obj);
  int Getc(DOH * obj);
  int Putc(int ch, DOH * obj);
  int Ungetc(int ch, DOH * obj);

  /* Iterator */
  Iterator First(DOH *obj);
  Iterator& Next(Iterator& x);

  /* Positional */

  int Getline(DOH *obj);
  void Setline(DOH *obj, int line);
  DOH *Getfile(DOH *obj);
  void Setfile(DOH *obj, DOH *file);

  /* String Methods */
  int Cmp(const_String_or_char_ptr obj1, const_String_or_char_ptr obj2);
  int Equal(const_String_or_char_ptr obj1, const_String_or_char_ptr obj2);
  int Replace(DOH * src, const_String_or_char_ptr token, const_String_or_char_ptr rep, int flags);
  void Chop(DOH * src);

  /* Meta-variables */
  DOH *Getmeta(DOH *obj, const DOH *name);
  int Setmeta(DOH *obj, const DOH *name, const DOH *value);
  int Delmeta(DOH *obj, const DOH *name);

  /* Utility functions */

  void DohEncoding(char *name, DOH *(*fn) (DOH *s));
  int Printf(DOH * obj, const char *format, VA_DECL);
  int Printf(FILE *obj, const char *format, VA_DECL);
  int vPrintf(DOH * obj, const char *format, VA_DECL);
  int Printv(DOH * obj, VA_DECL);
  int Printv(FILE * obj, VA_DECL);
  DOH *Readline(DOH * in); // Never

  /* Miscellaneous */

  int DohIsMapping(const DOH *obj);
  int DohIsSequence(const DOH *obj);
  int DohIsString(const DOH *obj);
  int DohIsFile(const DOH *obj);

  void DohSetmark(DOH *obj, int x);
  int DohGetmark(DOH *obj);

  /* -----------------------------------------------------------------------------
   * Strings.
   * ----------------------------------------------------------------------------- */

  String *NewStringEmpty(void);
  String *NewString(const_String_or_char_ptr c);
  String *NewStringWithSize(const_String_or_char_ptr c, int len);
  String *NewStringf(const_String_or_char_ptr fmt, VA_DECL);

  const char *Char(const_String_or_char_ptr s);

  int Strcmp(const_String_or_char_ptr s1, const_String_or_char_ptr s2);
  int Strncmp(const_String_or_char_ptr s1, const_String_or_char_ptr s2, int n);
  const char *Strstr(const_String_or_char_ptr s1, const_String_or_char_ptr s2);
  const char *Strchr(const_String_or_char_ptr s1, int ch);

  /* String replacement flags */

  #define   DOH_REPLACE_ANY         0x01
  #define   DOH_REPLACE_NOQUOTE     0x02
  #define   DOH_REPLACE_ID          0x04
  #define   DOH_REPLACE_FIRST       0x08
  #define   DOH_REPLACE_ID_BEGIN    0x10
  #define   DOH_REPLACE_ID_END      0x20

  #define Replaceall(s,t,r)  Replace(s,t,r,DOH_REPLACE_ANY)
  #define Replaceid(s,t,r)   Replace(s,t,r,DOH_REPLACE_ID)


  /* -----------------------------------------------------------------------------
   * Files
   * ----------------------------------------------------------------------------- */

  DOH *NewFile(DOH *filename, const char *mode, DOH *outfiles);
  DOH *NewFileFromFile(FILE *f); // Never
  DOH *NewFileFromFd(int fd); // Never
  void FileErrorDisplay(DOH *filename);
  int Close(DOH *file);
  int Copyto(DOH *input, DOH *output); // Never

  /* -----------------------------------------------------------------------------
   * List
   * ----------------------------------------------------------------------------- */

  List *NewList();
  //void SortList(DOH *lo, int (*cmp) (const DOH *, const DOH *));
  void SortList(DOH *lo, int (*cmp) 
          (const_String_or_char_ptr, const_String_or_char_ptr));

  /* -----------------------------------------------------------------------------
   * Hash
   * ----------------------------------------------------------------------------- */

  Hash *NewHash(void);

  /* -----------------------------------------------------------------------------
   * Void
   * ----------------------------------------------------------------------------- */

  DOH *DohNewVoid(void *ptr, void (*del) (void *)); // Never
  List *Split(DOH *input, char ch, int nsplits);
  List *SplitLines(DOH *input);
  #define DohSplitLines(x) SplitLines(x)
  #define DohNone 0

  extern void DohMemoryDebug(void);


}

#endif				/* DOH_H */
