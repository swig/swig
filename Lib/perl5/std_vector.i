//
// SWIG typemaps for std::vector types
// Luigi Ballabio
// May 7, 2002
// Chris Seatory 
// August 5, 2002
// Igor Bely
// May 16, 2003
//
// Perl implementation

%include <std_common.i>

// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// Perl as much as possible, namely, to allow the user to pass and 
// be returned Perl arrays.
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
            if (SWIG_ConvertPtr($input,(void **) &v, 
                                $&1_descriptor,1) != -1) {
                $1 = *v;
            } else if (SvROK($input)) {
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
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (SWIG_ConvertPtr($input,(void **) &v, 
                                $1_descriptor,1) != -1) {
                $1 = v;
            } else if (SvROK($input)) {
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
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(out) vector<T> {
            int len = $1.size();
            SV **svs = new SV*[len];
            for (unsigned int i=0; i<len; i++) {
                T* ptr = new T($1[i]);
                svs[i] = sv_newmortal();
                SWIG_MakePtr(svs[i], (void*) ptr, 
                             $descriptor(T *), $shadow|$owner);
            }
            AV *myav = av_make(len, svs);
            delete[] svs;
            $result = newRV_noinc((SV*) myav);
            sv_2mortal($result);
            argvi++;
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_&descriptor,0) != -1) {
                    $1 = 1;
                } else if (SvROK($input)) {
                    /* native sequence? */
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
                    $1 = 0;
                }
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1) {
                    $1 = 1;
                } else if (SvROK($input)) {
                    /* native sequence? */
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
                    $1 = 0;
                }
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);

        unsigned int size() const;
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
            T& get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const T& x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_vector(T,CHECK_T,TO_T,FROM_T)
    template<> class vector<T> {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (SWIG_ConvertPtr($input,(void **) &v, 
                                $&1_descriptor,1) != -1){
                $1 = *v;
            } else if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) != SVt_PVAV)
                    SWIG_croak("Type error in argument $argnum of $symname. "
                               "Expected an array of " #T);
                SV **tv;
                I32 len = av_len(av) + 1;
                for (int i=0; i<len; i++) {
                    tv = av_fetch(av, i, 0);
                    if (CHECK_T(*tv)) {
                        $1.push_back(TO_T(*tv));
                    } else {
                        SWIG_croak("Type error in argument $argnum of "
                                   "$symname. "
                                   "Expected an array of " #T);
                    }
                }
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (SWIG_ConvertPtr($input,(void **) &v, 
                                $1_descriptor,1) != -1) {
                $1 = v;
            } else if (SvROK($input)) {
                AV *av = (AV *)SvRV($input);
                if (SvTYPE(av) != SVt_PVAV)
                    SWIG_croak("Type error in argument $argnum of $symname. "
                               "Expected an array of " #T);
                SV **tv;
                I32 len = av_len(av) + 1;
                for (int i=0; i<len; i++) {
                    tv = av_fetch(av, i, 0);
                    if (CHECK_T(*tv)) {
                        temp.push_back(TO_T(*tv));
                    } else {
                        SWIG_croak("Type error in argument $argnum of "
                                   "$symname. "
                                   "Expected an array of " #T);
                    }
                }
                $1 = &temp;
            } else {
                SWIG_croak("Type error in argument $argnum of $symname. "
                           "Expected an array of " #T);
            }
        }
        %typemap(out) vector<T> {
            size_t len = $1.size();
            SV **svs = new SV*[len];
            for (size_t i=0; i<len; i++) {
                svs[i] = sv_newmortal();
                FROM_T(svs[i], $1[i]);
            }
            AV *myav = av_make(len, svs);
            delete[] svs;
            $result = newRV_noinc((SV*) myav);
            sv_2mortal($result);
            argvi++;
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_&descriptor,0) != -1) {
                    $1 = 1;
                } else if (SvROK($input)) {
                    /* native sequence? */
                    AV *av = (AV *)SvRV($input);
                    if (SvTYPE(av) == SVt_PVAV) {
                        SV **tv;
                        I32 len = av_len(av) + 1;
                        if (len == 0) {
                            /* an empty sequence can be of any type */
                            $1 = 1;
                        } else {
                            /* check the first element only */
                            tv = av_fetch(av, 0, 0);
                            if (CHECK_T(*tv))
                                $1 = 1;
                            else
                                $1 = 0;
                        }
                    }
                } else {
                    $1 = 0;
                }
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1) {
                    $1 = 1;
                } else if (SvROK($input)) {
                    /* native sequence? */
                    AV *av = (AV *)SvRV($input);
                    if (SvTYPE(av) == SVt_PVAV) {
                        SV **tv;
                        I32 len = av_len(av) + 1;
                        if (len == 0) {
                            /* an empty sequence can be of any type */
                            $1 = 1;
                        } else {
                            /* check the first element only */
                            tv = av_fetch(av, 0, 0);
                            if (CHECK_T(*tv))
                                $1 = 1;
                            else
                                $1 = 0;
                        }
                    }
                } else {
                    $1 = 0;
                }
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, T value);
        vector(const vector<T> &);

        unsigned int size() const;
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
            T get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, T x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
    %enddef

    specialize_std_vector(bool,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(char,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(int,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(short,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(long,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(unsigned char,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(unsigned int,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(unsigned short,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(unsigned long,SvIOK,SvIVX,sv_setiv);
    specialize_std_vector(float,SvNIOK,SwigSvToNumber,sv_setnv);
    specialize_std_vector(double,SvNIOK,SwigSvToNumber,sv_setnv);
    specialize_std_vector(std::string,SvPOK,SvPVX,SwigSvFromString);

}

