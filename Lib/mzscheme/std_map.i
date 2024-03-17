/* -----------------------------------------------------------------------------
 * std_map.i
 *
 * SWIG typemaps for std::map
 * ----------------------------------------------------------------------------- */

%include <std_common.i>
%include <exception.i>

// ------------------------------------------------------------------------
// std::map
//
// The aim of all that follows would be to integrate std::map with
// MzScheme as much as possible, namely, to allow the user to pass and
// be returned Scheme association lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
//
//   -- f(std::map<T>), f(const std::map<T>&), f(const std::map<T>*):
//      the parameter being read-only, either a Scheme alist or a
//      previously wrapped std::map<T> can be passed.
//   -- f(std::map<T>&), f(std::map<T>*):
//      the parameter must be modified; therefore, only a wrapped std::map
//      can be passed.
//   -- std::map<T> f():
//      the map is returned by copy; therefore, a Scheme alist
//      is returned which is most easily used in other Scheme functions
//   -- std::map<T>& f(), std::map<T>* f(), const std::map<T>& f(),
//      const std::map<T>* f():
//      the map is returned by reference; therefore, a wrapped std::map
//      is returned
// ------------------------------------------------------------------------

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

    template<class K, class T, class C = std::less<K> > class map {
        %typemap(in) map< K, T, C > (std::map< K, T, C >* m) {
            if (SCHEME_NULLP($input)) {
                $1 = std::map< K, T, C >();
            } else if (SCHEME_PAIRP($input)) {
                $1 = std::map< K, T, C >();
                Scheme_Object* alist = $input;
                while (!SCHEME_NULLP(alist)) {
                    K* k;
                    T* x;
                    Scheme_Object *entry, *key, *val;
                    entry = scheme_car(alist);
                    if (!SCHEME_PAIRP(entry))
                        SWIG_exception(SWIG_TypeError,"alist expected");
                    key = scheme_car(entry);
                    val = scheme_cdr(entry);
                    k = (K*) SWIG_MustGetPtr(key,$descriptor(K *),$argnum, 0);
                    if (SWIG_ConvertPtr(val,(void**) &x,
                                    $descriptor(T *), 0) == -1) {
                        if (!SCHEME_PAIRP(val))
                            SWIG_exception(SWIG_TypeError,"alist expected");
                        val = scheme_car(val);
                        x = (T*) SWIG_MustGetPtr(val,$descriptor(T *),$argnum, 0);
                    }
%#ifdef __cpp_lib_map_try_emplace
                    (($1_type &)$1).insert_or_assign(*k, *x);
%#else
                    (($1_type &)$1)[*k] = *x;
%#endif
                    alist = scheme_cdr(alist);
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum, 0));
            }
        }
        %typemap(in) const map< K, T, C >& (std::map< K, T, C > temp,
                                      std::map< K, T, C >* m),
                     const map< K, T, C >* (std::map< K, T, C > temp,
                                      std::map< K, T, C >* m) {
            if (SCHEME_NULLP($input)) {
                temp = std::map< K, T, C >();
                $1 = &temp;
            } else if (SCHEME_PAIRP($input)) {
                temp = std::map< K, T, C >();
                $1 = &temp;
                Scheme_Object* alist = $input;
                while (!SCHEME_NULLP(alist)) {
                    K* k;
                    T* x;
                    Scheme_Object *entry, *key, *val;
                    entry = scheme_car(alist);
                    if (!SCHEME_PAIRP(entry))
                        SWIG_exception(SWIG_TypeError,"alist expected");
                    key = scheme_car(entry);
                    val = scheme_cdr(entry);
                    k = (K*) SWIG_MustGetPtr(key,$descriptor(K *),$argnum, 0);
                    if (SWIG_ConvertPtr(val,(void**) &x,
                                    $descriptor(T *), 0) == -1) {
                        if (!SCHEME_PAIRP(val))
                            SWIG_exception(SWIG_TypeError,"alist expected");
                        val = scheme_car(val);
                        x = (T*) SWIG_MustGetPtr(val,$descriptor(T *),$argnum, 0);
                    }
%#ifdef __cpp_lib_map_try_emplace
                    temp.insert_or_assign(*k, *x);
%#else
                    temp[*k] = *x;
%#endif
                    alist = scheme_cdr(alist);
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum, 0);
            }
        }
        %typemap(out) map< K, T, C > {
            Scheme_Object* alist = scheme_null;
            for (std::map< K, T, C >::reverse_iterator i=$1.rbegin(); 
                                                  i!=$1.rend(); ++i) {
                K* key = new K(i->first);
                T* val = new T(i->second);
                Scheme_Object* k = SWIG_NewPointerObj(key,$descriptor(K *), 1);
                Scheme_Object* x = SWIG_NewPointerObj(val,$descriptor(T *), 1);
                Scheme_Object* entry = scheme_make_pair(k,x);
                alist = scheme_make_pair(entry,alist);
            }
            $result = alist;
        }
        %typecheck(SWIG_TYPECHECK_MAP) map< K, T, C > {
            /* native sequence? */
            if (SCHEME_NULLP($input)) {
                /* an empty sequence can be of any type */
                $1 = 1;
            } else if (SCHEME_PAIRP($input)) {
                /* check the first element only */
                K* k;
                T* x;
                Scheme_Object* head = scheme_car($input);
                if (SCHEME_PAIRP(head)) {
                    Scheme_Object* key = scheme_car(head);
                    Scheme_Object* val = scheme_cdr(head);
                    if (SWIG_ConvertPtr(key,(void**) &k,
                                    $descriptor(K *), 0) == -1) {
                        $1 = 0;
                    } else {
                        if (SWIG_ConvertPtr(val,(void**) &x,
                                        $descriptor(T *), 0) != -1) {
                            $1 = 1;
                        } else if (SCHEME_PAIRP(val)) {
                            val = scheme_car(val);
                            if (SWIG_ConvertPtr(val,(void**) &x,
                                            $descriptor(T *), 0) != -1)
                                $1 = 1;
                            else
                                $1 = 0;
                        } else {
                            $1 = 0;
                        }
                    }
                } else {
                    $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::map< K, T, C >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                $&1_descriptor, 0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map< K, T, C >&,
                                       const map< K, T, C >* {
            /* native sequence? */
            if (SCHEME_NULLP($input)) {
                /* an empty sequence can be of any type */
                $1 = 1;
            } else if (SCHEME_PAIRP($input)) {
                /* check the first element only */
                K* k;
                T* x;
                Scheme_Object* head = scheme_car($input);
                if (SCHEME_PAIRP(head)) {
                    Scheme_Object* key = scheme_car(head);
                    Scheme_Object* val = scheme_cdr(head);
                    if (SWIG_ConvertPtr(key,(void**) &k,
                                    $descriptor(K *), 0) == -1) {
                        $1 = 0;
                    } else {
                        if (SWIG_ConvertPtr(val,(void**) &x,
                                        $descriptor(T *), 0) != -1) {
                            $1 = 1;
                        } else if (SCHEME_PAIRP(val)) {
                            val = scheme_car(val);
                            if (SWIG_ConvertPtr(val,(void**) &x,
                                            $descriptor(T *), 0) != -1)
                                $1 = 1;
                            else
                                $1 = 0;
                        } else {
                            $1 = 0;
                        }
                    }
                } else {
                    $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::map< K, T, C >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                $1_descriptor, 0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %rename("length") size;
        %rename("null?") empty;
        %rename("clear!") clear;
        %rename("ref") __getitem__;
        %rename("set!") __setitem__;
        %rename("delete!") __delitem__;
        %rename("has-key?") has_key;
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef K key_type;
        typedef T mapped_type;
        typedef std::pair< const K, T > value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        map();
        map(const map& other);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            T& __getitem__(const K& key) throw (std::out_of_range) {
                std::map< K, T, C >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(const K& key, const T& x) {
%#ifdef __cpp_lib_map_try_emplace
                (*self).insert_or_assign(key, x);
%#else
                (*self)[key] = x;
%#endif
            }
            void __delitem__(const K& key) throw (std::out_of_range) {
                std::map< K, T, C >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map< K, T, C >::iterator i = self->find(key);
                return i != self->end();
            }
            Scheme_Object* keys() {
                Scheme_Object* result = scheme_null;
                for (std::map< K, T, C >::reverse_iterator i=self->rbegin(); 
                                                      i!=self->rend(); ++i) {
                    K* key = new K(i->first);
                    Scheme_Object* k = SWIG_NewPointerObj(key,$descriptor(K *), 1);
                    result = scheme_make_pair(k,result);
                }
                return result;
            }
        }
    };

}
