//
// SWIG typemaps for std::vector
// Luigi Ballabio
// Apr 8, 2002
//
// Guile implementation

%include exception.i

// containers


%exception std::vector::ref {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::set {
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
// Guile as much as possible, namely, to allow the user to pass and 
// be returned Guile vectors or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a Guile sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a Guile vector of T:s 
//      is returned which is most easily used in other Guile functions
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
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    SCM o = gh_vector_ref($input,gh_long2scm(i));
                    (($1_type &)$1)[i] =
                        *((T*) SWIG_MustGetPtr(o,$descriptor(T *),$argnum));
                }
            } else if (gh_null_p($input)) {
                $1 = std::vector<T>();
            } else if (gh_pair_p($input)) {
                SCM head, tail;
                $1 = std::vector<T>();
                tail = $input;
                while (!gh_null_p(tail)) {
                    head = gh_car(tail);
                    tail = gh_cdr(tail);
                    $1.push_back(*((T*)SWIG_MustGetPtr(head,
                                                       $descriptor(T *),
                                                       $argnum)));
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (gh_vector_p($input)) {
                unsigned int size = gh_vector_length($input);
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    SCM o = gh_vector_ref($input,gh_long2scm(i));
                    temp[i] = *((T*) SWIG_MustGetPtr(o,
                                                     $descriptor(T *),
                                                     $argnum));
                }
            } else if (gh_null_p($input)) {
                temp = std::vector<T>();
                $1 = &temp;
            } else if (gh_pair_p($input)) {
                temp = std::vector<T>();
                $1 = &temp;
                SCM head, tail;
                tail = $input;
                while (!gh_null_p(tail)) {
                    head = gh_car(tail);
                    tail = gh_cdr(tail);
                    temp.push_back(*((T*) SWIG_MustGetPtr(head,
                                                          $descriptor(T *),
                                                          $argnum)));
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<T> {
            $result = gh_make_vector(gh_long2scm($1.size()),SCM_UNSPECIFIED);
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                gh_vector_set($result,gh_long2scm(i),
                              SWIG_MakePtr(x,$descriptor(T *)));
            }
        }
      public:
        vector(unsigned int size = 0);
        %rename(length) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename("set!") set;
        %rename("pop!") pop;
        %rename("push!") push_back;
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
    %define specialize_stl_vector(T,HOST,CONVERT_FROM,CONVERT_TO)
    template<> class vector<T> {
        %typemap(in) vector<T> {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                $1 = std::vector<T>(size);
                HOST* data = CONVERT_FROM($input,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else if (gh_null_p($input)) {
                $1 = std::vector<T>();
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                $1 = std::vector<T>(size);
                HOST* data = CONVERT_FROM(v,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                temp = std::vector<T>(size);
                $1 = &temp;
                HOST* data = CONVERT_FROM($input,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else if (gh_null_p($input)) {
                temp = std::vector<T>();
                $1 = &temp;
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                temp = std::vector<T>(size);
                $1 = &temp;
                HOST* data = CONVERT_FROM(v,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<T> {
            HOST* data = new HOST[$1.size()];
            std::copy($1.begin(),$1.end(),data);
            $result = CONVERT_TO(data,$1.size());
            delete [] data;
        }
      public:
        vector(unsigned int size = 0);
        %rename(length) size;
        unsigned int size() const;
        %rename("empty?") empty;
        bool empty() const;
        %rename("clear!") clear;
        void clear();
        %rename("set!") set;
        %rename("pop!") pop;
        %rename("push!") push_back;
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

    specialize_stl_vector(int,long,gh_scm2longs,gh_longs2ivect);
    specialize_stl_vector(long,long,gh_scm2longs,gh_longs2ivect);
    specialize_stl_vector(short,short,gh_scm2shorts,gh_shorts2svect);
    specialize_stl_vector(unsigned int,long,gh_scm2longs,gh_longs2ivect);
    specialize_stl_vector(unsigned long,long,gh_scm2longs,gh_longs2ivect);
    specialize_stl_vector(unsigned short,short,gh_scm2shorts,gh_shorts2svect);
    specialize_stl_vector(float,float,gh_scm2floats,gh_floats2fvect);
    specialize_stl_vector(double,double,gh_scm2doubles,gh_doubles2scm);

}

