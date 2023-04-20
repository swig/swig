
%module(directors="1") example

%inline %{
// Helper functions for converting string arrays
#include <stdlib.h>
void *alloc_ptr_array(unsigned int len)
{
    return calloc(len, sizeof(void *));
}
void set_ptr_array(void *ain, unsigned int pos, void *val)
{
    void **a = (void **) ain;
    a[pos] = val;
}
void *get_ptr_array(void *ain, unsigned int pos)
{
    void **a = (void **) ain;
    return a[pos];
}
void free_ptr_array(void *ain)
{
    void **a = (void **) ain;
    unsigned int i;

    if (!a)
        return;
    for (i = 0; a[i]; i++) {
        free(a[i]);
    }
    free(a);
}
char *uintptr_to_string(void *in)
{
    return (char *) in;
}
void *string_to_uintptr(char *in)
{
    return strdup(in);
}
%}

// These typemaps convert between an array of strings in Go and a
// const char** that is NULL terminated in C++.
%typemap(gotype) (const char * const *) "[]string"
%typemap(imtype) (const char * const *) "uintptr"
%typemap(goin) (const char * const *) {
	if $input == nil || len($input) == 0 {
		$result = 0
	} else {
		$result = Alloc_ptr_array(uint(len($input) + 1))
		defer func() {
			Free_ptr_array($result)
		}()
		var i uint
		for i = 0; i < uint(len($input)); i++ {
			Set_ptr_array($result, i, String_to_uintptr($input[i]))
		}
	}
}
%typemap(in) (const char * const *) {
    $1 = (char **) $input;
}
%typemap(godirectorin) (const char * const *) {
	if ($input == 0) {
		$result = nil
	} else {
		var i uint
		for i = 0; ; i++ {
			var v uintptr = Get_ptr_array($input, i)
			if v == 0 {
				break
			}
		}
		if i == 0 {
			$result = nil
		} else {
			$result = make([]string, i)
			for i = 0; ; i++ {
				var v uintptr = Get_ptr_array($input, i)
				if v == 0 {
					break
				}
				$result[i] = Uintptr_to_string(v)
			}
		}
	}
}

%feature("director") callbacks;

%inline %{
    class callbacks {
    public:
	virtual bool call1(int v, const char * const *strarray);
	virtual ~callbacks() {}
    };

    bool check1(callbacks *c, int v, const char * const *strarray) {
	return c->call1(v, strarray);
    }

    bool callbacks::call1(int v, const char * const *strarray) {
        return false;
    }
%}
