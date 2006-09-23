/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_map.i
 *
 * SWIG typemaps for std::map
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::map
//
// The aim of all that follows would be to integrate std::map with
// Ruby as much as possible, namely, to allow the user to pass and
// be returned Ruby hash maps.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
//
//   -- f(std::map<T>), f(const std::map<T>&), f(const std::map<T>*):
//      the parameter being read-only, either a Ruby hash or a
//      previously wrapped std::map<T> can be passed.
//   -- f(std::map<T>&), f(std::map<T>*):
//      the parameter must be modified; therefore, only a wrapped std::map
//      can be passed.
//   -- std::map<T> f():
//      the map is returned by copy; therefore, a Ruby hash
//      is returned which is most easily used in other Ruby functions
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

    %mixin map "Enumerable";

    template<class K, class T> class map {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                $1 = std::map<K,T >();
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    SWIG_ConvertPtr(key, (void **) &k, $descriptor(K *), 1);
                    SWIG_ConvertPtr(val, (void **) &x, $descriptor(T *), 1);
                    (($1_type &)$1)[*k] = *x;
                }
            } else {
                SWIG_ConvertPtr($input, (void **) &m, $&1_descriptor, 1);
                $1 = *m;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                temp = std::map<K,T >();
                $1 = &temp;
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    SWIG_ConvertPtr(key, (void **) &k, $descriptor(K *), 1);
                    SWIG_ConvertPtr(val, (void **) &x, $descriptor(T *), 1);
                    temp[*k] = *x;
                }
            } else {
                SWIG_ConvertPtr($input, (void **) &m, $1_descriptor, 1);
                $1 = m;
            }
        }
        %typemap(out) map<K,T> {
            $result = rb_hash_new();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                K* key = new K(i->first);
                T* val = new T(i->second);
                rb_hash_aset($result,
                             SWIG_NewPointerObj((void *) key, 
                                                $descriptor(K *), 1),
                             SWIG_NewPointerObj((void *) val, 
                                                $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(val,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(val,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %rename(__len__) size;
        %rename("empty?") empty;
        %rename("delete") __delitem__;
        %rename("has_key?") has_key;
      public:
        map();
        map(const map<K,T> &);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            T& __getitem__(const K& key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(const K& key, const T& x) {
                (*self)[key] = x;
            }
            T __delitem__(const K& key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end()) {
                    T x = i->second;
                    self->erase(i);
                    return x;
                } else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            VALUE keys() {
                VALUE keyList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    rb_ary_store(keyList,j,
                                 SWIG_NewPointerObj((void *) ptr,
                                                    $descriptor(K *),1));
                }
                return keyList;
            }
            VALUE values() {
                VALUE valueList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    T* ptr = new T(i->second);
                    rb_ary_store(valueList,j,
                                 SWIG_NewPointerObj((void *) ptr,
                                                    $descriptor(T *),1));
                }
                return valueList;
            }
            void each() {
                std::map<K,T >::iterator i;
                for (i=self->begin(); i!=self->end(); ++i) {
                    K* key = new K(i->first);
                    T* val = &(i->second);
                    VALUE entry = rb_ary_new2(2);
                    VALUE k = SWIG_NewPointerObj((void *) key,
                                                 $descriptor(K *),1);
                    VALUE x = SWIG_NewPointerObj((void *) val,
                                                 $descriptor(T *),0);
                    rb_ary_store(entry,0,k);
                    rb_ary_store(entry,1,x);
                    rb_yield(entry);
                }
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_map_on_key(K,CHECK,CONVERT_FROM,CONVERT_TO)

    %mixin map<K,T> "Enumerable";

    template<class T> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                $1 = std::map<K,T >();
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!CHECK(key))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    SWIG_ConvertPtr(val,(void **) &x,
                                    $descriptor(T *),1);
                    (($1_type &)$1)[CONVERT_FROM(key)] = *x;
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m, $&1_descriptor,1);
                $1 = *m;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                temp = std::map<K,T >();
                $1 = &temp;
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!CHECK(key))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    SWIG_ConvertPtr(val,(void **) &x,
                                    $descriptor(T *),1);
                    temp[CONVERT_FROM(key)] = *x;
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m,$1_descriptor,1);
                $1 = m;
            }
        }
        %typemap(out) map<K,T> {
            $result = rb_hash_new();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                T* obj = new T(i->second);
                rb_hash_aset($result,
                             CONVERT_TO(i->first),
                             SWIG_NewPointerObj((void *) obj,
                                                $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(val,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    T* x;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(val,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %rename(__len__) size;
        %rename("empty?") empty;
        %rename("delete") __delitem__;
        %rename("has_key?") has_key;
      public:
        map();
        map(const map<K,T> &);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            T& __getitem__(K key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(K key, const T& x) {
                (*self)[key] = x;
            }
            T __delitem__(K key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end()) {
                    T x = i->second;
                    self->erase(i);
                    return x;
                } else
                    throw std::out_of_range("key not found");
            }
            bool has_key(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            VALUE keys() {
                VALUE keyList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    rb_ary_store(keyList,j,
                                 CONVERT_TO(i->first));
                }
                return keyList;
            }
            VALUE values() {
                VALUE valueList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    T* ptr = new T(i->second);
                    rb_ary_store(valueList,j,
                                 SWIG_NewPointerObj((void *) ptr,
                                                    $descriptor(T *),1));
                }
                return valueList;
            }
            void each() {
                std::map<K,T >::iterator i;
                for (i=self->begin(); i!=self->end(); ++i) {
                    T* val = &(i->second);
                    VALUE entry = rb_ary_new2(2);
                    VALUE k = CONVERT_TO(i->first);
                    VALUE x = SWIG_NewPointerObj((void *) val,
                                                 $descriptor(T *),0);
                    rb_ary_store(entry,0,k);
                    rb_ary_store(entry,1,x);
                    rb_yield(entry);
                }
            }
        }
    };
    %enddef

    %define specialize_std_map_on_value(T,CHECK,CONVERT_FROM,CONVERT_TO)

    %mixin map<K,T> "Enumerable";

    template<class K> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                $1 = std::map<K,T >();
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!CHECK(val))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    SWIG_ConvertPtr(key,(void **) &k,
                                    $descriptor(K *),1);
                    (($1_type &)$1)[*k] = CONVERT_FROM(val);
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m, $&1_descriptor,1);
                $1 = *m;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                temp = std::map<K,T >();
                $1 = &temp;
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!CHECK(val))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    SWIG_ConvertPtr(key,(void **) &k,
                                    $descriptor(K *),1);
                    temp[*k] = CONVERT_FROM(val);
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m, $1_descriptor,1);
                $1 = m;
            }
        }
        %typemap(out) map<K,T> {
            $result = rb_hash_new();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                K* key = new K(i->first);
                rb_hash_aset($result,
                             SWIG_NewPointerObj((void *) key,
                                                $descriptor(K *), 1),
                             CONVERT_TO(i->second));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    K* k;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (SWIG_ConvertPtr(val,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(val))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    K* k;
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (SWIG_ConvertPtr(val,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(val))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %rename(__len__) size;
        %rename("empty?") empty;
        %rename("delete") __delitem__;
        %rename("has_key?") has_key;
      public:
        map();
        map(const map<K,T> &);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            T __getitem__(const K& key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(const K& key, T x) {
                (*self)[key] = x;
            }
            T __delitem__(const K& key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end()) {
                    T x = i->second;
                    self->erase(i);
                    return x;
                } else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            VALUE keys() {
                VALUE keyList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    rb_ary_store(keyList,j,
                                 SWIG_NewPointerObj((void *) ptr,
                                                    $descriptor(K *),1));
                }
                return keyList;
            }
            VALUE values() {
                VALUE valueList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    rb_ary_store(valueList,j,
                                 CONVERT_TO(i->second));
                }
                return valueList;
            }
            void each() {
                std::map<K,T >::iterator i;
                for (i=self->begin(); i!=self->end(); ++i) {
                    K* key = new K(i->first);
                    VALUE entry = rb_ary_new2(2);
                    VALUE k = SWIG_NewPointerObj((void *) key,
                                                 $descriptor(K *),1);
                    VALUE x = CONVERT_TO(i->second);
                    rb_ary_store(entry,0,k);
                    rb_ary_store(entry,1,x);
                    rb_yield(entry);
                }
            }
        }
    };
    %enddef

    %define specialize_std_map_on_both(K,CHECK_K,CONVERT_K_FROM,CONVERT_K_TO,
                                       T,CHECK_T,CONVERT_T_FROM,CONVERT_T_TO)
    %mixin map<K,T> "Enumerable";

    template<> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                $1 = std::map<K,T >();
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!(CHECK_K(key) && CHECK_T(val)))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    (($1_type &)$1)[CONVERT_K_FROM(key)] = 
                                               CONVERT_T_FROM(val);
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m, $&1_descriptor,1);
                $1 = *m;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                temp = std::map<K,T >();
                $1 = &temp;
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                for (unsigned int i=0; i<size; i++) {
                    VALUE key = RARRAY_PTR(keys)[i];
                    VALUE val = rb_hash_aref($input,key);
                    if (!(CHECK_K(key) && CHECK_T(val)))
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected map<" #K "," #T ">)");
                    temp[CONVERT_K_FROM(key)] = CONVERT_T_FROM(val);
                }
            } else {
                SWIG_ConvertPtr($input,(void **) &m, $1_descriptor,1);
                $1 = m;
            }
        }
        %typemap(out) map<K,T> {
            $result = rb_hash_new();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                rb_hash_aset($result,
                             CONVERT_K_TO(i->first),
                             CONVERT_T_TO(i->second));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (CHECK_K(key) && CHECK_T(val))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            // native sequence?
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                VALUE keys = rb_funcall($input,rb_intern("keys"),0);
                unsigned int size = RARRAY_LEN(keys);
                if (size == 0) {
                    // an empty dictionary can be of any type
                    $1 = 1;
                } else {
                    // check the first element only
                    VALUE key = RARRAY_PTR(keys)[0];
                    VALUE val = rb_hash_aref($input,key);
                    if (CHECK_K(key) && CHECK_T(val))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                // wrapped map?
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %rename(__len__) size;
        %rename("empty?") empty;
        %rename("delete") __delitem__;
        %rename("has_key?") has_key;
      public:
        map();
        map(const map<K,T> &);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            T __getitem__(K key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(K key, T x) {
                (*self)[key] = x;
            }
            T __delitem__(K key) throw (std::out_of_range) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end()) {
                    T x = i->second;
                    self->erase(i);
                    return x;
                } else
                    throw std::out_of_range("key not found");
            }
            bool has_key(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            VALUE keys() {
                VALUE keyList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    rb_ary_store(keyList,j,
                                 CONVERT_K_TO(i->first));
                }
                return keyList;
            }
            VALUE values() {
                VALUE valueList = rb_ary_new2(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    rb_ary_store(valueList,j,
                                 CONVERT_T_TO(i->second));
                }
                return valueList;
            }
            void each() {
                std::map<K,T >::iterator i;
                for (i=self->begin(); i!=self->end(); ++i) {
                    VALUE entry = rb_ary_new2(2);
                    rb_ary_store(entry,0,CONVERT_K_TO(i->first));
                    rb_ary_store(entry,1,CONVERT_T_TO(i->second));
                    rb_yield(entry);
                }
            }
        }
    };
    %enddef


    specialize_std_map_on_key(bool,SWIG_BOOL_P,
                              SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_key(int,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(short,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(long,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(unsigned int,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(unsigned short,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(unsigned long,FIXNUM_P,
                              FIX2INT,INT2NUM);
    specialize_std_map_on_key(double,SWIG_FLOAT_P,
                              SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_key(float,SWIG_FLOAT_P,
                              SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_key(std::string,SWIG_STRING_P,
                              SWIG_RB2STR,SWIG_STR2RB);

    specialize_std_map_on_value(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_value(int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_map_on_value(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_value(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_value(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);

    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               bool,SWIG_BOOL_P,
                               SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               unsigned int,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               unsigned short,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               unsigned long,FIXNUM_P,
                               FIX2INT,INT2NUM);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               double,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               float,SWIG_FLOAT_P,
                               SWIG_NUM2DBL,rb_float_new);
    specialize_std_map_on_both(std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB,
                               std::string,SWIG_STRING_P,
                               SWIG_RB2STR,SWIG_STR2RB);
}
