//
// SWIG typemaps for std::vector
// Luigi Ballabio
// Apr 8, 2002
//
// MzScheme implementation

%include exception.i

// containers


%exception std::vector::ref {
    try {
        $action
    } catch (std::out_of_range& e) {
	failwith("out_of_range");
    }
}

%exception std::vector::set {
    try {
        $action
    } catch (std::out_of_range& e) {
        failwith("out_of_range");
    }
}

%exception std::vector::pop  {
    try {
        $action
    } catch (std::out_of_range& e) {
        failwith("out_of_range");
    }
}


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// MzScheme as much as possible, namely, to allow the user to pass and 
// be returned MzScheme vectors or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a MzScheme sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a MzScheme vector of T:s 
//      is returned which is most easily used in other MzScheme functions
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
                unsigned int size = Wosize_val($input);
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    (($1_type &)$1)[i] =
                        *((T*) SWIG_MustGetPtr(Field($input,i),
                                               $descriptor(T *),
                                               $argnum));
                }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
                unsigned int size = Wosize_val($input);
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    temp[i] = *((T*) SWIG_MustGetPtr(Field($input,i),
                                                     $descriptor(T *),
                                                     $argnum));
                }
        }
        %typemap(out) vector<T> {
            $result = alloc_tuple($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                Store_field($result,i,SWIG_MakePtr(x,$descriptor(T *)));
            }
        }
      public:
        vector(unsigned int size = 0);
        %rename(length) size;
        unsigned int size() const;
        bool empty() const;
        void clear();
        void push_back(const T& x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T& ref(int i) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const T& x) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_vector(T,CONVERT_FROM,CONVERT_TO)
    template<> class vector<T> {
        %typemap(in) vector<T> {
                unsigned int size = Wosize_val($input);
                $1 = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    (($1_type &)$1)[i] = CONVERT_FROM(Field($input,i));
                }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
                unsigned int size = Wosize_val($input);
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    temp[i] = CONVERT_FROM(Field($input,i));
                }
        }
        %typemap(out) vector<T> {
            $result = alloc_tuple($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
               	Store_field($result,i,CONVERT_TO((($1_type &)$1)[i]));
        }
      public:
        vector(unsigned int size = 0);
        %rename(length) size;
        unsigned int size() const;
        bool empty() const;
        void clear();
        void push_back(T x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T ref(int i) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, T x) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
    %enddef

    specialize_std_vector(int,Int_val,Val_int);
    specialize_std_vector(short,Int_val,Val_int);
    specialize_std_vector(long,Int64_val,copy_int64);
    specialize_std_vector(unsigned int,Int32_val,copy_int32);
    specialize_std_vector(unsigned short,Int_val,Val_int);
    specialize_std_vector(unsigned long,Int64_val,copy_int64);
    specialize_std_vector(float,Double_val,copy_double);
    specialize_std_vector(double,Double_val,copy_double);
}

