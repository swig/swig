//
// SWIG typemaps for STL types
// Luigi Ballabio
// Apr 8, 2002
//
// Ruby implementation


// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------
%{
#include <string>
%}

namespace std {

    // Ruby wants class names to start with a capital letter
    %rename(String) string;
    class string;

    %typemap(in) string {
        if (TYPE($input) == T_STRING) {
            $1 = std::string(STR2CSTR($input));
        } else {
            rb_raise(rb_eTypeError, "not a string");
        }
    }

    %typemap(in) const string & (std::string temp) {
        if (TYPE($input) == T_STRING) {
            temp = std::string(STR2CSTR($input));
            $1 = &temp;
        } else {
            rb_raise(rb_eTypeError, "not a string");
        }
    }

    %typemap(out) string {
        $result = rb_str_new2($1.c_str());
    }

    %typemap(out) const string & {
        $result = rb_str_new2($1->c_str());
    }

}



// containers

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
    
    template<class T> class vector {
        %typemap(in) vector<T> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<T>(size);
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x = (T*) SWIG_ConvertPtr(o, type);
                    (($1_type &)$1)[i] = *x;
                }
            } else {
                $1 = *(($&1_type) SWIG_ConvertPtr($input,$1_descriptor));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<T>(size);
                $1 = &temp;
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    T* x = (T*) SWIG_ConvertPtr(o, type);
                    temp[i] = *x;
                }
            } else {
                $1 = ($1_ltype) SWIG_ConvertPtr($input,$1_descriptor);
            }
        }
        %typemap(out) vector<T> {
            $result = rb_ary_new2($1.size());
            swig_type_info* type = SWIG_TypeQuery(#T " *");
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                rb_ary_store($result,i,
                             SWIG_NewPointerObj((void *) x, type, 1));
            }
        }
      public:
        vector(unsigned int size, const T& fill);
        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename(push) push_back;
        void push_back(const T& x);
        %addmethods {
            T pop() {
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

    template<> class vector<int> {
        %typemap(in) vector<int> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<int>(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (FIXNUM_P(o))
                        (($1_type &)$1)[i] = int(FIX2INT(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<int>)");
                }
            } else {
                $1 = *(($&1_type) SWIG_ConvertPtr($input,$1_descriptor));
            }
        }
        %typemap(in) const vector<int>& (std::vector<int> temp),
                     const vector<int>* (std::vector<int> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<int>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (FIXNUM_P(o))
                        temp[i] = int(FIX2INT(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<int>)");
                }
            } else {
                $1 = ($1_ltype) SWIG_ConvertPtr($input,$1_descriptor);
            }
        }
        %typemap(out) vector<int> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                rb_ary_store($result,i,INT2NUM((($1_type &)$1)[i]));
        }
      public:
        vector(unsigned int size, int fill);
        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename(push) push_back;
        void push_back(int x);
        %addmethods {
            int pop() {
                int x = self->back();
                self->pop_back();
                return x;
            }
            int __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, int x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                for (unsigned int i=0; i<self->size(); i++)
                    rb_yield(INT2NUM((*self)[i]));
            }
        }
    };

    template<> class vector<double> {
        %typemap(in) vector<double> {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                $1 = std::vector<double>(size);
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (TYPE(o) == T_FLOAT)
                        (($1_type &)$1)[i] = NUM2DBL(o);
                    else if (FIXNUM_P(o))
                        (($1_type &)$1)[i] = double(FIX2INT(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<double>)");
                }
            } else {
                $1 = *(($&1_type) SWIG_ConvertPtr($input,$1_descriptor));
            }
        }
        %typemap(in) const vector<double>& (std::vector<double> temp),
                     const vector<double>* (std::vector<double> temp) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                temp = std::vector<double>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    VALUE o = RARRAY($input)->ptr[i];
                    if (TYPE(o) == T_FLOAT)
                        temp[i] = NUM2DBL(o);
                    else if (FIXNUM_P(o))
                        temp[i] = int(FIX2INT(o));
                    else
                        rb_raise(rb_eTypeError,
                                 "wrong argument type"
                                 " (expected vector<double>)");
                }
            } else {
                $1 = ($1_ltype) SWIG_ConvertPtr($input,$1_descriptor);
            }
        }
        %typemap(out) vector<double> {
            $result = rb_ary_new2($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                rb_ary_store($result,i,rb_float_new((($1_type &)$1)[i]));
        }
      public:
        vector(unsigned int size, double fill);
        %rename(__len__) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename(push) push_back;
        void push_back(double x);
        %addmethods {
            double pop() {
                double x = self->back();
                self->pop_back();
                return x;
            }
            double __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setitem__(int i, double x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void each() {
                for (unsigned int i=0; i<self->size(); i++)
                    rb_yield(rb_float_new((*self)[i]));
            }
        }
    };

}

