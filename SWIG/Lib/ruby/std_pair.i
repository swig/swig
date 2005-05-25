//
// SWIG typemaps for std::pair
// Luigi Ballabio
// July 2003
//
// Ruby implementation

%include std_common.i
%include exception.i

// ------------------------------------------------------------------------
// std::pair
//
// See std_vector.i for the rationale of typemap application
// ------------------------------------------------------------------------

%{
#include <utility>
%}

// exported class

namespace std {

    template<class T, class U> struct pair {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2)
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                T* x;
                U* y;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                SWIG_ConvertPtr(first, (void **) &x, $descriptor(T *), 1);
                SWIG_ConvertPtr(second, (void **) &y, $descriptor(U *), 1);
                $1 = std::make_pair(x,y);
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $&1_descriptor, 1);
                $1 = *p;
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2)
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                T* x;
                U* y;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                SWIG_ConvertPtr(first, (void **) &x, $descriptor(T *), 1);
                SWIG_ConvertPtr(second, (void **) &y, $descriptor(U *), 1);
                temp = std::make_pair(x,y);
                $1 = &temp;
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $1_descriptor, 1);
                $1 = p;
            }
        }
        %typemap(out) pair<T,U> {
            $result = rb_ary_new2(2);
            T* x = new T($1.first);
            U* y = new U($1.second);
            rb_ary_store($result,0,
                         SWIG_NewPointerObj((void *) x, 
                                            $descriptor(T *), 1));
            rb_ary_store($result,1,
                         SWIG_NewPointerObj((void *) y, 
                                            $descriptor(U *), 1));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    T* x;
                    U* y;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    T* x;
                    U* y;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        pair();
        pair(T first, U second);
        pair(const pair& p);

        template <class U1, class U2> pair(const pair<U1, U2> &p);

        T first;
        U second;
    };
    
    // specializations for built-ins

    %define specialize_std_pair_on_first(T,CHECK,CONVERT_FROM,CONVERT_TO)

    template<class U> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2)
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                U* y;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                if (!CHECK(first))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                SWIG_ConvertPtr(second, (void **) &y, $descriptor(U *), 1);
                $1 = std::make_pair(CONVERT_FROM(first),y);
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $&1_descriptor, 1);
                $1 = *p;
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2)
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                U* y;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                if (!CHECK(first))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                SWIG_ConvertPtr(second, (void **) &y, $descriptor(U *), 1);
                temp = std::make_pair(CONVERT_FROM(first),y);
                $1 = &temp;
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $1_descriptor, 1);
                $1 = p;
            }
        }
        %typemap(out) pair<T,U> {
            $result = rb_ary_new2(2);
            U* y = new U($1.second);
            rb_ary_store($result,0,CONVERT_TO($1.first));
            rb_ary_store($result,1,
                         SWIG_NewPointerObj((void *) y, 
                                            $descriptor(U *), 1));
        }
        %typecheck(SWIG_TYPECHECK_MAP) pair<T,U> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    U* y;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (CHECK(first) &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const pair<T,U>&,
                                       const pair<T,U>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    U* y;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (CHECK(first) &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        pair();
        pair(T first, U second);
        pair(const pair& p);

        template <class U1, class U2> pair(const pair<U1, U2> &p);

        T first;
        U second;
    };
    %enddef

    %define specialize_std_pair_on_second(U,CHECK,CONVERT_FROM,CONVERT_TO)

    template<class T> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                SWIG_ConvertPtr(first, (void **) &x, $descriptor(T *), 1);
                if (!CHECK(second))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                $1 = std::make_pair(x,CONVERT_FROM(second));
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $&1_descriptor, 1);
                $1 = *p;
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                SWIG_ConvertPtr(first, (void **) &x, $descriptor(T *), 1);
                if (!CHECK(second))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                temp = std::make_pair(x,CONVERT_FROM(second));
                $1 = &temp;
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $1_descriptor, 1);
                $1 = p;
            }
        }
        %typemap(out) pair<T,U> {
            $result = rb_ary_new2(2);
            T* x = new T($1.first);
            rb_ary_store($result,0,
                         SWIG_NewPointerObj((void *) x, 
                                            $descriptor(T *), 1));
            rb_ary_store($result,1,CONVERT_TO($1.second));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    T* x;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        CHECK(second))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    T* x;
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        CHECK(second))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        pair();
        pair(T first, U second);
        pair(const pair& p);

        template <class U1, class U2> pair(const pair<U1, U2> &p);

        T first;
        U second;
    };
    %enddef

    %define specialize_std_pair_on_both(T,CHECK_T,CONVERT_T_FROM,CONVERT_T_TO,
                                        U,CHECK_U,CONVERT_U_FROM,CONVERT_U_TO)
    template<> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                if (!CHECK_T(first) || !CHECK_U(second))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                $1 = std::make_pair(CONVERT_T_FROM(first),
                                    CONVERT_U_FROM(second));
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $&1_descriptor, 1);
                $1 = *p;
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                VALUE first = RARRAY($input)->ptr[0];
                VALUE second = RARRAY($input)->ptr[1];
                if (!CHECK_T(first) || !CHECK_U(second))
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                temp = std::make_pair(CONVERT_T_FROM(first),
                                      CONVERT_U_FROM(second));
                $1 = &temp;
            } else {
                SWIG_ConvertPtr($input, (void **) &p, $1_descriptor, 1);
                $1 = p;
            }
        }
        %typemap(out) pair<T,U> {
            $result = rb_ary_new2(2);
            rb_ary_store($result,0,CONVERT_T_TO($1.first));
            rb_ary_store($result,1,CONVERT_U_TO($1.second));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cArray)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (CHECK_T(first) && CHECK_U(second))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (rb_obj_is_kind_of($input,rb_cHash)) {
                unsigned int size = RARRAY($input)->len;
                if (size != 2) {
                    /* not a pair */
                    $1 = 0;
                } else {
                    VALUE first = RARRAY($input)->ptr[0];
                    VALUE second = RARRAY($input)->ptr[1];
                    if (CHECK_T(first) && CHECK_U(second))
                        $1 = 1;
                    else
                        $1 = 0;
                }
            } else {
                /* wrapped map? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        pair();
        pair(T first, U second);
        pair(const pair& p);

        template <class U1, class U2> pair(const pair<U1, U2> &p);

        T first;
        U second;
    };
    %enddef


    specialize_std_pair_on_first(bool,SWIG_BOOL_P,
                                 SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_first(int,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(short,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(long,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(unsigned int,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(unsigned short,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(unsigned long,FIXNUM_P,
                                 FIX2INT,INT2NUM);
    specialize_std_pair_on_first(double,SWIG_FLOAT_P,
                                 SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_first(float,SWIG_FLOAT_P,
                                 SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_first(std::string,SWIG_STRING_P,
                                 SWIG_RB2STR,SWIG_STR2RB);

    specialize_std_pair_on_second(bool,SWIG_BOOL_P,
                                  SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_second(int,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(short,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(long,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(unsigned int,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(unsigned short,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(unsigned long,FIXNUM_P,
                                  FIX2INT,INT2NUM);
    specialize_std_pair_on_second(double,SWIG_FLOAT_P,
                                  SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_second(float,SWIG_FLOAT_P,
                                  SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_second(std::string,SWIG_STRING_P,
                                  SWIG_RB2STR,SWIG_STR2RB);

    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                bool,SWIG_BOOL_P,
                                SWIG_RB2BOOL,SWIG_BOOL2RB);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                unsigned int,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                unsigned short,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                unsigned long,FIXNUM_P,
                                FIX2INT,INT2NUM);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                double,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                float,SWIG_FLOAT_P,
                                SWIG_NUM2DBL,rb_float_new);
    specialize_std_pair_on_both(std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB,
                                std::string,SWIG_STRING_P,
                                SWIG_RB2STR,SWIG_STR2RB);
}
