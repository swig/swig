//
// SWIG typemaps for STL types
// Luigi Ballabio
// Apr 8, 2002
//
// MzScheme implementation

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
        if (SCHEME_STRINGP($input))
            $1 = std::string(SCHEME_STR_VAL($input));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (SCHEME_STRINGP($input)) {
            temp = std::string(SCHEME_STR_VAL($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = scheme_make_string($1.c_str());
    }

    %typemap(out) const string & {
        $result = scheme_make_string($1->c_str());
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
        /*
        %typemap(in) vector<T> {
            if (SCHEME_VECTORP($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                unsigned int size = SCHEME_VEC_SIZE($input);
                $1 = std::vector<T>(size);
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    (($1_type &)$1)[i] =
                        *((T*) SWIG_MustGetPtr(items[i],type,$argnum));
                }
            } else if (SCHEME_NULLP($input)) {
                $1 = std::vector<T>();
            } else if (SCHEME_PAIRP($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                Scheme_Object *head, *tail;
                $1 = std::vector<T>();
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    $1.push_back(*((T*)SWIG_MustGetPtr(head,type,$argnum)));
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp),
                     const vector<T>* (std::vector<T> temp) {
            if (SCHEME_VECTORP($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                unsigned int size = SCHEME_VEC_SIZE($input);
                temp = std::vector<T>(size);
                $1 = &temp;
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    temp[i] = *((T*) SWIG_MustGetPtr(items[i],type,$argnum));
                }
            } else if (SCHEME_NULLP($input)) {
                temp = std::vector<T>();
                $1 = &temp;
            } else if (SCHEME_PAIRP($input)) {
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                temp = std::vector<T>();
                $1 = &temp;
                Scheme_Object *head, *tail;
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    temp.push_back(*((T*) SWIG_MustGetPtr(head,type,$argnum)));
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<T> {
        swig_type_info* type = SWIG_TypeQuery(#T " *");
            $result = scheme_make_vector($1.size(),scheme_undefined);
            Scheme_Object** els = SCHEME_VEC_ELS($result);
            for (unsigned int i=0; i<$1.size(); i++) {
                T* x = new T((($1_type &)$1)[i]);
                els[i] = SWIG_MakePtr(x,type);
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
        %addmethods {
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
            if (SCHEME_VECTORP($input)) {
                unsigned int size = SCHEME_VEC_SIZE($input);
                $1 = std::vector<int>(size);
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    Scheme_Object* o = items[i];
                    if (SCHEME_INTP(o))
                        (($1_type &)$1)[i] = SCHEME_INT_VAL(o);
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<int>", 
                                          $argnum, argc, argv);
                }
            } else if (SCHEME_NULLP($input)) {
                $1 = std::vector<int>();
            } else if (SCHEME_PAIRP($input)) {
                Scheme_Object *head, *tail;
                $1 = std::vector<int>();
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    if (SCHEME_INTP(head))
                        $1.push_back(SCHEME_INT_VAL(head));
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<int>", 
                                          $argnum, argc, argv);
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<int>& (std::vector<int> temp),
                     const vector<int>* (std::vector<int> temp) {
            if (SCHEME_VECTORP($input)) {
                unsigned int size = SCHEME_VEC_SIZE($input);
                temp = std::vector<int>(size);
                $1 = &temp;
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    Scheme_Object* o = items[i];
                    if (SCHEME_INTP(o))
                        temp[i] = SCHEME_INT_VAL(o);
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<int>", 
                                          $argnum, argc, argv);
                }
            } else if (SCHEME_NULLP($input)) {
                temp = std::vector<int>();
                $1 = &temp;
            } else if (SCHEME_PAIRP($input)) {
                temp = std::vector<int>();
                $1 = &temp;
                Scheme_Object *head, *tail;
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    if (SCHEME_INTP(head))
                        temp.push_back(SCHEME_INT_VAL(head));
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<int>", 
                                          $argnum, argc, argv);
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<int> {
            $result = scheme_make_vector($1.size(),scheme_undefined);
            Scheme_Object** els = SCHEME_VEC_ELS($result);
            for (unsigned int i=0; i<$1.size(); i++)
                els[i] = scheme_make_integer_value((($1_type &)$1)[i]);
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
        %addmethods {
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
            if (SCHEME_VECTORP($input)) {
                unsigned int size = SCHEME_VEC_SIZE($input);
                $1 = std::vector<double>(size);
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    Scheme_Object* o = items[i];
                    if (SCHEME_REALP(o))
                        (($1_type &)$1)[i] = scheme_real_to_double(o);
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<double>", 
                                          $argnum, argc, argv);
                }
            } else if (SCHEME_NULLP($input)) {
                $1 = std::vector<double>();
            } else if (SCHEME_PAIRP($input)) {
                Scheme_Object *head, *tail;
                $1 = std::vector<double>();
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    if (SCHEME_REALP(head))
                        $1.push_back(scheme_real_to_double(head));
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<double>", 
                                          $argnum, argc, argv);
                }
            } else {
                $1 = *(($&1_type)
                       SWIG_MustGetPtr($input,$&1_descriptor,$argnum));
            }
        }
        %typemap(in) const vector<double>& (std::vector<double> temp),
                     const vector<double>* (std::vector<double> temp) {
            if (SCHEME_VECTORP($input)) {
                unsigned int size = SCHEME_VEC_SIZE($input);
                temp = std::vector<double>(size);
                $1 = &temp;
                Scheme_Object** items = SCHEME_VEC_ELS($input);
                for (unsigned int i=0; i<size; i++) {
                    Scheme_Object* o = items[i];
                    if (SCHEME_REALP(o))
                        temp[i] = scheme_real_to_double(o);
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<double>", 
                                          $argnum, argc, argv);
                }
            } else if (SCHEME_NULLP($input)) {
                temp = std::vector<double>();
                $1 = &temp;
            } else if (SCHEME_PAIRP($input)) {
                temp = std::vector<double>();
                $1 = &temp;
                Scheme_Object *head, *tail;
                tail = $input;
                while (!SCHEME_NULLP(tail)) {
                    head = scheme_car(tail);
                    tail = scheme_cdr(tail);
                    if (SCHEME_REALP(head))
                        temp.push_back(scheme_real_to_double(head));
                    else
                        scheme_wrong_type(FUNC_NAME, "vector<double>", 
                                          $argnum, argc, argv);
                }
            } else {
                $1 = ($1_ltype) SWIG_MustGetPtr($input,$1_descriptor,$argnum);
            }
        }
        %typemap(out) vector<double> {
            $result = scheme_make_vector($1.size(),scheme_undefined);
            Scheme_Object** els = SCHEME_VEC_ELS($result);
            for (unsigned int i=0; i<$1.size(); i++)
                els[i] = scheme_make_double((($1_type &)$1)[i]);
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
        %addmethods {
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

