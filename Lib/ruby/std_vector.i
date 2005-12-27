//
// SWIG typemaps for std::vector
// Luigi Ballabio
// Apr 8, 2002
//
// Ruby implementation

%include <std_common.i>

// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// Ruby as much as possible, namely, to allow the user to pass and 
// be returned Ruby arrays
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a Ruby array or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a Ruby array of T:s 
//      is returned which is most easily used in other Ruby functions
//   -- std::vector<T>& f(), std::vector<T>* f(), const std::vector<T>& f(),
//      const std::vector<T>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
// ------------------------------------------------------------------------

%{
#include <vector>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

    %mixin vector "Enumerable";

    template<class T> class vector {
        %typemap(in) vector<T> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x;
		    SWIG_ConvertPtr(o, (void **) &x, $descriptor(T *), 1);
                    (($1_type &)$1)[i] = *x;
                }
            } else {
	        void *ptr;
                SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 1);
                $1 = *(($&1_type) ptr);
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x;
                    SWIG_ConvertPtr(o, (void **) &x, $descriptor(T *), 1);
                    temp[i] = *x;
                }
            } else {
                SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);
            }
        }
        %typemap(out) vector<T> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                rb_ary_store($result,i,
                             SWIG_NewPointerObj((void *) x, 
                                                $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    VALUE o = RARRAY($input)->ptr[0];
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    VALUE o = RARRAY($input)->ptr[0];
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);

        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        void clear();
        %rename(push) push_back;
        void push_back(const T& x);
        %extend {
            T pop() throw (std::out_of_range) {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T& __getitem__(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, const T& x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                for (unsigned int i=0; i<self->size(); i++) {
                    T* x = &((*self)[i]);
                    rb_yield(SWIG_NewPointerObj((void *) x, 
                                                $descriptor(T *), 0));
                }
            }
        }
    };

    // Partial specialization for vectors of pointers.  [ beazley ]

    %mixin vector<T*> "Enumerable";
    template<class T> class vector<T*> {
        %typemap(in) vector<T*> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T* >(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x;
                    SWIG_ConvertPtr(o, (void **) &x, $descriptor(T *), 1);
                    (($1_type &)$1)[i] = x;
                }
            } else {
                void *ptr;
                SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 1);
                $1 = *(($&1_type) ptr);
            }
        }
        %typemap(in) const vector<T*>& (std::vector<T*> temp),
                     const vector<T*>* (std::vector<T*> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T* >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x;
                    SWIG_ConvertPtr(o, (void **) &x, $descriptor(T *), 1);
                    temp[i] = x;
                }
            } else {
                SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);
            }
        }
        %typemap(out) vector<T*> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = (($1_type &)$1)[i];
                rb_ary_store($result,i,
                             SWIG_NewPointerObj((void *) x, 
                                                $descriptor(T *), 0));
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T*> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    VALUE o = RARRAY($input)->ptr[0];
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T* >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T*>&,
                                          const vector<T*>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    VALUE o = RARRAY($input)->ptr[0];
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T* >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, T * &value);
        vector(const vector<T*> &);

        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        void clear();
        %rename(push) push_back;
        void push_back(T* x);
        %extend {
            T* pop() throw (std::out_of_range) {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T* x = self->back();
                self->pop_back();
                return x;
            }
            T* __getitem__(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, T* x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                for (unsigned int i=0; i<self->size(); i++) {
                    T* x = (*self)[i];
                    rb_yield(SWIG_NewPointerObj((void *) x, 
                                                $descriptor(T *), 0));
                }
            }
        }
    };
        

    // specializations for built-ins

    %define specialize_std_vector(T,CHECK,CONVERT_FROM,CONVERT_TO)
    %mixin vector<T> "Enumerable";
    template<> class vector<T> {
        %typemap(in) vector<T> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (CHECK(o))
                        (($1_type &)$1)[i] = (T)(CONVERT_FROM(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<" #T ">)");
                }
            } else {
	        void *ptr;
                SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 1);
                $1 = *(($&1_type) ptr);
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (CHECK(o))
                        temp[i] = (T)(CONVERT_FROM(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<" #T ">)");
                }
            } else {
                SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);
            }
        }
        %typemap(out) vector<T> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                rb_ary_store($result,i,CONVERT_TO((($1_type &)$1)[i]));
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    VALUE o = RARRAY($input)->ptr[0];
                    if (CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    VALUE o = RARRAY($input)->ptr[0];
                    if (CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);

        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        void clear();
        %rename(push) push_back;
        void push_back(T x);
        %extend {
            T pop() throw (std::out_of_range) {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T __getitem__(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, T x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                for (unsigned int i=0; i<self->size(); i++)
                    rb_yield(CONVERT_TO((*self)[i]));
            }
        }
    };
    %enddef

    specialize_std_vector(bool,SWIG_BOOL_P,SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_vector(char,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(int,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(short,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(long,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned char,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned int,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned short,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned long,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(double,SWIG_FLOAT_P,SWIG_NUM2DBL,rb_float_new);
    specialize_std_vector(float,SWIG_FLOAT_P,SWIG_NUM2DBL,rb_float_new);
    specialize_std_vector(std::string,SWIG_STRING_P,SWIG_RB2STR,SWIG_STR2RB);

}

