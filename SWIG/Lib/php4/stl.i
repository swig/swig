//
// SWIG typemaps for STL types
// Luigi Ballabio
// May 7, 2002
//
// PHP implementation


// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include exception.i

%{
#include <string>
%}

namespace std {

    class string;

    %typemap(in) string {
        convert_to_string_ex($input);
        $1 = std::string(Z_STRVAL_PP($input));
    }

    %typemap(in) const string & (std::string temp) {
        convert_to_string_ex($input);
        temp = std::string(Z_STRVAL_PP($input));
        $1 = &temp;
    }

    %typemap(out) string {
        RETURN_STRINGL(const_cast<char*>($1.c_str()),$1.length(),1);
    }

    %typemap(out) const string & {
        RETURN_STRINGL(const_cast<char*>($1->c_str()),$1->length(),1);
    }

}


// containers

// methods which can raise are caused to throw an IndexError
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


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// PHP as much as possible, namely, to allow the user to pass and 
// be returned PHP lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a PHP sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a PHP sequence of T:s 
//      is returned which is most easily used in other PHP functions
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
        // add generic typemaps here
      public:
        vector(unsigned int size = 0);
        // %rename(__len__) size;
        unsigned int size() const;
        // %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        // %rename(append) push_back;
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
        }
    };


    // specializations for built-ins

    template<> class vector<int> {
        // add specialized typemaps here
      public:
        vector(unsigned int size = 0);
        // %rename(__len__) size;
        unsigned int size() const;
        // %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        // %rename(append) push_back;
        void push_back(int x);
        %extend {
            int pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
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
        }
    };

    template<> class vector<double> {
        // add specialized typemaps here
      public:
        vector(unsigned int size = 0);
        // %rename(__len__) size;
        unsigned int size() const;
        // %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        // %rename(append) push_back;
        void push_back(double x);
        %extend {
            double pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
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
        }
    };

}

