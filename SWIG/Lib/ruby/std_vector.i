//
// SWIG typemaps for std::vector
// Luigi Ballabio
// Apr 8, 2002
//
// Ruby implementation


%include exception.i

// containers

%exception std::vector::__getitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::__setitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::pop  {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}


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

#define SWIG_FLOAT_P(x) ((TYPE(x) == T_FLOAT) || FIXNUM_P(x))

double SWIG_NUM2DBL(VALUE x) {
    return (FIXNUM_P(x) ? FIX2INT(x) : NUM2DBL(x));
}
%}

// exported class

namespace std {
    
    template<class T> class vector {
        %typemap(in) vector<T> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x = (T*) SWIG_ConvertPtr(o, $descriptor(T *));
                    (($1_type &)$1)[i] = *x;
                }
            } else {
                $1 = *(($&1_type) SWIG_ConvertPtr($input,$&1_descriptor));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x = (T*) SWIG_ConvertPtr(o, $descriptor(T *));
                    temp[i] = *x;
                }
            } else {
                $1 = ($1_ltype) SWIG_ConvertPtr($input,$1_descriptor);
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
      public:
        vector(unsigned int size = 0);
        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename(push) push_back;
        void push_back(const T& x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T& __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, const T& x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                for (unsigned int i=0; i<self->size(); i++) {
                    T* x = new T((*self)[i]);
                    rb_yield(SWIG_NewPointerObj((void *) x, type, 1));
                }
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_vector(T,CHECK,CONVERT_FROM,CONVERT_TO)
    template<> class vector<T> {
        %typemap(in) vector<T> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (CHECK(o))
                        (($1_type &)$1)[i] = T(CONVERT_FROM(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<" #T ">)");
                }
            } else {
                $1 = *(($&1_type) SWIG_ConvertPtr($input,$&1_descriptor));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (CHECK(o))
                        temp[i] = T(CONVERT_FROM(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<" #T ">)");
                }
            } else {
                $1 = ($1_ltype) SWIG_ConvertPtr($input,$1_descriptor);
            }
        }
        %typemap(out) vector<T> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                rb_ary_store($result,i,CONVERT_TO((($1_type &)$1)[i]));
        }
      public:
        vector(unsigned int size = 0);
        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename(push) push_back;
        void push_back(T x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, T x) {
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

    specialize_std_vector(int,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(short,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(long,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned int,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned short,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(unsigned long,FIXNUM_P,FIX2INT,INT2NUM);
    specialize_std_vector(double,SWIG_FLOAT_P,SWIG_NUM2DBL,rb_float_new);
    specialize_std_vector(float,SWIG_FLOAT_P,SWIG_NUM2DBL,rb_float_new);

}

