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
// Guile as much as possible, namely, to allow the user to pass and
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
        %typemap(in) map< K, T, C > {
            if (scm_is_null($input)) {
                $1 = std::map< K, T, C >();
            } else if (scm_is_pair($input)) {
                $1 = std::map< K, T, C >();
                SCM alist = $input;
                while (!scm_is_null(alist)) {
                    K* k;
                    T* x;
                    SCM entry, key, val;
                    entry = SCM_CAR(alist);
                    if (!scm_is_pair(entry))
                        SWIG_exception(SWIG_TypeError,"alist expected");
                    key = SCM_CAR(entry);
                    val = SCM_CDR(entry);
                    k = (K*) SWIG_MustGetPtr(key,$descriptor(K *),$argnum, 0);
                    if (SWIG_ConvertPtr(val,(void**) &x,
                                    $descriptor(T *), 0) != 0) {
                        if (!scm_is_pair(val))
                            SWIG_exception(SWIG_TypeError,"alist expected");
                        val = SCM_CAR(val);
                        x = (T*) SWIG_MustGetPtr(val,$descriptor(T *),$argnum, 0);
                    }
%#ifdef __cpp_lib_map_try_emplace
                    (($1_type &)$1).insert_or_assign(*k, *x);
%#else
                    (($1_type &)$1)[*k] = *x;
%#endif
                    alist = SCM_CDR(alist);
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum, 0));
            }
        }
        %typemap(in) const map< K, T, C >& (std::map< K, T, C > temp),
                     const map< K, T, C >* (std::map< K, T, C > temp) {
            if (scm_is_null($input)) {
                temp = std::map< K, T, C >();
                $1 = &temp;
            } else if (scm_is_pair($input)) {
                temp = std::map< K, T, C >();
                $1 = &temp;
                SCM alist = $input;
                while (!scm_is_null(alist)) {
                    K* k;
                    T* x;
                    SCM entry, key, val;
                    entry = SCM_CAR(alist);
                    if (!scm_is_pair(entry))
                        SWIG_exception(SWIG_TypeError,"alist expected");
                    key = SCM_CAR(entry);
                    val = SCM_CDR(entry);
                    k = (K*) SWIG_MustGetPtr(key,$descriptor(K *),$argnum, 0);
                    if (SWIG_ConvertPtr(val,(void**) &x,
                                    $descriptor(T *), 0) != 0) {
                        if (!scm_is_pair(val))
                            SWIG_exception(SWIG_TypeError,"alist expected");
                        val = SCM_CAR(val);
                        x = (T*) SWIG_MustGetPtr(val,$descriptor(T *),$argnum, 0);
                    }
%#ifdef __cpp_lib_map_try_emplace
                    temp.insert_or_assign(*k, *x);
%#else
                    temp[*k] = *x;
%#endif
                    alist = SCM_CDR(alist);
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum, 0);
            }
        }
        %typemap(out) map< K, T, C > {
            SCM alist = SCM_EOL;
            for (std::map< K, T, C >::reverse_iterator i=$1.rbegin(); i!=$1.rend(); ++i) {
                K* key = new K(i->first);
                T* val = new T(i->second);
                SCM k = SWIG_NewPointerObj(key,$descriptor(K *), 1);
                SCM x = SWIG_NewPointerObj(val,$descriptor(T *), 1);
                SCM entry = scm_cons(k,x);
                alist = scm_cons(entry,alist);
            }
            $result = alist;
        }
        %typecheck(SWIG_TYPECHECK_MAP) map< K, T, C > {
            /* native sequence? */
            if (scm_is_null($input)) {
                /* an empty sequence can be of any type */
                $1 = 1;
            } else if (scm_is_pair($input)) {
                /* check the first element only */
                K* k;
                T* x;
                SCM head = SCM_CAR($input);
                if (scm_is_pair(head)) {
                    SCM key = SCM_CAR(head);
                    SCM val = SCM_CDR(head);
                    if (SWIG_ConvertPtr(key,(void**) &k,
                                    $descriptor(K *), 0) != 0) {
                        $1 = 0;
                    } else {
                        if (SWIG_ConvertPtr(val,(void**) &x,
                                        $descriptor(T *), 0) == 0) {
                            $1 = 1;
                        } else if (scm_is_pair(val)) {
                            val = SCM_CAR(val);
                            if (SWIG_ConvertPtr(val,(void**) &x,
                                            $descriptor(T *), 0) == 0)
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
                                $&1_descriptor, 0) == 0)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map< K, T, C >&,
                                       const map< K, T, C >* {
            /* native sequence? */
            if (scm_is_null($input)) {
                /* an empty sequence can be of any type */
                $1 = 1;
            } else if (scm_is_pair($input)) {
                /* check the first element only */
                K* k;
                T* x;
                SCM head = SCM_CAR($input);
                if (scm_is_pair(head)) {
                    SCM key = SCM_CAR(head);
                    SCM val = SCM_CDR(head);
                    if (SWIG_ConvertPtr(key,(void**) &k,
                                    $descriptor(K *), 0) != 0) {
                        $1 = 0;
                    } else {
                        if (SWIG_ConvertPtr(val,(void**) &x,
                                        $descriptor(T *), 0) == 0) {
                            $1 = 1;
                        } else if (scm_is_pair(val)) {
                            val = SCM_CAR(val);
                            if (SWIG_ConvertPtr(val,(void**) &x,
                                            $descriptor(T *), 0) == 0)
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
                                $1_descriptor, 0) == 0)
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
            const T& __getitem__(const K& key) throw (std::out_of_range) {
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
            SCM keys() {
                SCM result = SCM_EOL;
                for (std::map< K, T, C >::reverse_iterator i=self->rbegin(); i!=self->rend(); ++i) {
                    K* key = new K(i->first);
                    SCM k = SWIG_NewPointerObj(key,$descriptor(K *), 1);
                    result = scm_cons(k,result);
                }
                return result;
            }
        }
    };

}
