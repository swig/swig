//
// SWIG typemaps for STL types
// Luigi Ballabio
// Apr 8, 2002
//
// Guile implementation

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

    %typemap(in) string (char* tempptr) {
        if (gh_string_p($input)) {
            tempptr = gh_scm2newstr($input, NULL);
            $1 = std::string(tempptr);
            if (tempptr) scm_must_free(tempptr);
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(in) const string & (std::string temp,
                                 char* tempptr) {
        if (gh_string_p($input)) {
            tempptr = gh_scm2newstr($input, NULL);
            temp = std::string(tempptr);
            if (tempptr) scm_must_free(tempptr);
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = gh_str02scm($1.c_str());
    }

    %typemap(out) const string & {
        $result = gh_str02scm($1->c_str());
    }

}



// containers


%exception ref {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception set {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception pop  {
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
        /*
        %typemap(in) vector<T> {
            if (gh_vector_p($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                unsigned long size = gh_vector_length($input);
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    SCM o = gh_vector_ref($input,gh_long2scm(i));
                    (($1_type &)$1)[i] =
                        *((T*) SWIG_MustGetPtr(o,type,$argnum));
                }
            } else if (gh_null_p($input)) {
                $1 = std::vector<T>();
            } else if (gh_pair_p($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                SCM head, tail;
                $1 = std::vector<T>();
                tail = $input;
                while (!gh_null_p(tail)) {
                    head = gh_car(tail);
                    tail = gh_cdr(tail);
                    $1.push_back(*((T*)SWIG_MustGetPtr(head,type,$argnum)));
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (gh_vector_p($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                unsigned int size = SCHEME_VEC_SIZE($input);
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    SCM o = gh_vector_ref($input,gh_long2scm(i));
                    temp[i] = *((T*) SWIG_MustGetPtr(o,type,$argnum));
                }
            } else if (gh_null_p($input)) {
                temp = std::vector<T>();
                $1 = &temp;
            } else if (gh_pair_p($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                temp = std::vector<T>();
                $1 = &temp;
                SCM head, tail;
                tail = $input;
                while (!gh_null_p(tail)) {
                    head = gh_car(tail);
                    tail = gh_cdr(tail);
                    temp.push_back(*((T*) SWIG_MustGetPtr(head,type,$argnum)));
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<T> {
        swig_type_info* type = SWIG_TypeQuery(#T " *");
            $result = gh_make_vector(gh_long2scm($1.size()),SCM_UNSPECIFIED);
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                gh_vector_set($result,gh_long2scm(i),SWIG_MakePtr(x,type));
            }
        }
        */
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

    template<> class vector<int> {
        %typemap(in) vector<int> {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                $1 = std::vector<int>(size);
                long* data = gh_scm2longs($input,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else if (gh_null_p($input)) {
                $1 = std::vector<int>();
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                $1 = std::vector<int>(size);
                long* data = gh_scm2longs(v,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<int>& (std::vector<int> temp),
                     const vector<int>* (std::vector<int> temp) {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                temp = std::vector<int>(size);
                $1 = &temp;
                long* data = gh_scm2longs($input,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else if (gh_null_p($input)) {
                temp = std::vector<int>();
                $1 = &temp;
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                temp = std::vector<int>(size);
                $1 = &temp;
                long* data = gh_scm2longs(v,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<int> {
            int* data = new int[$1.size()];
            std::copy($1.begin(),$1.end(),data);
            $result = gh_ints2scm(data,$1.size());
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
        void push_back(int x);
        %extend {
            int pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                int x = self->back();
                self->pop_back();
                return x;
            }
            int ref(int i) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, int x) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };


    template<> class vector<double> {
        %typemap(in) vector<double> {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                $1 = std::vector<double>(size);
                double* data = gh_scm2doubles($input,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else if (gh_null_p($input)) {
                $1 = std::vector<double>();
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                $1 = std::vector<double>(size);
                double* data = gh_scm2doubles(v,NULL);
                std::copy(data,data+size,$1.begin());
                free(data);
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<double>& (std::vector<double> temp),
                     const vector<double>* (std::vector<double> temp) {
            if (gh_vector_p($input)) {
                unsigned long size = gh_vector_length($input);
                temp = std::vector<double>(size);
                $1 = &temp;
                double* data = gh_scm2doubles($input,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else if (gh_null_p($input)) {
                temp = std::vector<double>();
                $1 = &temp;
            } else if (gh_pair_p($input)) {
                SCM v = gh_list_to_vector($input);
                unsigned long size = gh_vector_length(v);
                temp = std::vector<double>(size);
                $1 = &temp;
                double* data = gh_scm2doubles(v,NULL);
                std::copy(data,data+size,temp.begin());
                free(data);
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<double> {
            double* data = new double[$1.size()];
            std::copy($1.begin(),$1.end(),data);
            $result = gh_doubles2scm(data,$1.size());
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
        void push_back(double x);
        %extend {
            double pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                double x = self->back();
                self->pop_back();
                return x;
            }
            double ref(int i) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, double x) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };

}

