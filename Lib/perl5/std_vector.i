//
// SWIG typemaps for std::vector types
// Luigi Ballabio
// May 7, 2002
// Chris Seatory 
// August 5, 2002
//
// Perl implementation

%include exception.i

// containers

// methods which can raise are caused to throw an IndexError
%exception std::vector::get {
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

%exception std::vector::pop {
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
// Perl as much as possible, namely, to allow the user to pass and 
// be returned Perl lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a Perl sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a Perl sequence of T:s 
//      is returned which is most easily used in other Perl functions
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
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) != SVt_PVAV)
                    SWIG_croak("Type error in argument $argnum of $symname. "
                               "Expected an array of " #T);
                SV **tv;
                I32 len = av_len(av) + 1;
                T* obj;
                for (int i=0; i<len; i++) {
                    tv = av_fetch(av, i, 0);
                    if (SWIG_ConvertPtr(*tv, (void **)&obj, 
                                        $descriptor(T *),0) != -1) {
                        $1.push_back(*obj);
                    } else {
                        SWIG_croak("Type error in argument $argnum of "
                                   "$symname. "
                                   "Expected an array of " #T);
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,1) != -1){
                $1 = *v;
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) != SVt_PVAV)
                    SWIG_croak("Type error in argument $argnum of $symname. "
                               "Expected an array of " #T);
                SV **tv;
                I32 len = av_len(av) + 1;
                T* obj;
                for (int i=0; i<len; i++) {
                    tv = av_fetch(av, i, 0);
                    if (SWIG_ConvertPtr(*tv, (void **)&obj, 
                                        $descriptor(T *),0) != -1) {
                        temp.push_back(*obj);
                    } else {
                        SWIG_croak("Type error in argument $argnum of "
                                   "$symname. "
                                   "Expected an array of " #T);
                    }
                }
                $1 = &temp;
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,1) != -1){
                $1 = v;
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(out) vector<T> {
            int len = $1.size();
            SV **svs = new SV*[len];
            for (unsigned int i=0; i<len; i++) {
                svs[i] = sv_newmortal();
                SWIG_MakePtr(svs[i], (void*)&($1->at(i)), 
                             $descriptor(T *), 0);
            }
            AV *myav = av_make(len, svs);
            delete[] svs;
            $result = newRV_noinc((SV*) myav);
            sv_2mortal($result);
            argvi++;
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) == SVt_PVAV) {
                    SV **tv;
                    I32 len = av_len(av) + 1;
                    if (len == 0) {
                        /* an empty sequence can be of any type */
                        $1 = 1;
                    } else {
                        /* check the first element only */
                        T* obj;
                        tv = av_fetch(av, 0, 0);
                        if (SWIG_ConvertPtr(*tv, (void **)&obj, 
                                            $descriptor(T *),0) != -1)
                            $1 = 1;
                        else
                            $1 = 0;
                    }
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_&descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) == SVt_PVAV) {
                    SV **tv;
                    I32 len = av_len(av) + 1;
                    if (len == 0) {
                        /* an empty sequence can be of any type */
                        $1 = 1;
                    } else {
                        /* check the first element only */
                        T* obj;
                        tv = av_fetch(av, 0, 0);
                        if (SWIG_ConvertPtr(*tv, (void **)&obj, 
                                            $descriptor(T *),0) != -1)
                            $1 = 1;
                        else
                            $1 = 0;
                    }
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
        unsigned int size() const;
        bool empty() const;
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
            T& get(int i) {
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

    %define specialize_std_vector(T)
    template<> class vector<T> {
        // add specialized typemaps here
      public:
        vector();
        vector(unsigned int size, const T& value=T());
        vector(const vector<T> &);

        unsigned int size() const;
        bool empty() const;
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
            T get(int i) {
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

    specialize_std_vector(bool);
    specialize_std_vector(int);
    specialize_std_vector(short);
    specialize_std_vector(long);
    specialize_std_vector(unsigned int);
    specialize_std_vector(unsigned short);
    specialize_std_vector(unsigned long);
    specialize_std_vector(float);
    specialize_std_vector(double);

}

