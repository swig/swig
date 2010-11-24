/* ------------------------------------------------------------
 * goruntime.swg
 *
 * Go runtime code for the various generated files.
 * ------------------------------------------------------------ */

%insert(runtime) %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { char *p; int n; } _gostring_;
typedef struct { void* array; unsigned int len; unsigned int cap; } _goslice_;

%}

#ifndef SWIGGO_GCCGO
/* Boilerplate for C/C++ code when using 6g/8g.  This code is compiled
   with gcc.  */
%insert(runtime) %{

#define swiggo_size_assert_eq(x, y, name) typedef char name[(x-y)*(x-y)*-2+1];
#define swiggo_size_assert(t, n) swiggo_size_assert_eq(sizeof(t), n, swiggo_sizeof_##t##_is_not_##n)

swiggo_size_assert(char, 1)
swiggo_size_assert(short, 2)
swiggo_size_assert(int, 4)
typedef long long swiggo_long_long;
swiggo_size_assert(swiggo_long_long, 8)
swiggo_size_assert(float, 4)
swiggo_size_assert(double, 8)

extern
#ifdef __cplusplus
"C"
#endif
void crosscall2(void (*fn)(void *, int), void *, int);

extern
#ifdef __cplusplus
"C"
#endif
void _swig_gc_allocate(void *, int);
static void *_swig_allocate(int len) {
  struct {
    int len;
    void *ret;
  } a;
  a.len = len;
  crosscall2(_swig_gc_allocate, &a, (int) sizeof a);
  return a.ret;
}

extern
#ifdef __cplusplus
"C"
#endif
void _swig_gc_makegostring(void *, int);
static _gostring_ _swig_makegostring(const char *p, size_t l) {
  struct {
    const char *p;
    int l;
    _gostring_ ret;
  } a;
  a.p = p;
  a.l = l;
  crosscall2(_swig_gc_makegostring, &a, (int) sizeof a);
  return a.ret;
}

extern
#ifdef __cplusplus
"C"
#endif
void _swig_gc_gopanic(void *, int);
static void _swig_gopanic(const char *p) {
  struct {
    const char *p;
    int l;
  } a;
  a.p = p;
  a.l = strlen(p);
  crosscall2(_swig_gc_gopanic, &a, (int) sizeof a);
}

%}

/* Boilerplate for C code when using 6g/8g.  This code is compiled
   with 6c/8c.  */
%insert(gc_header) %{
#include "runtime.h"
#include "cgocall.h"

#pragma dynimport initcgo initcgo "libcgo.so"
#pragma dynimport libcgo_thread_start libcgo_thread_start "libcgo.so"
#pragma dynimport libcgo_set_scheduler libcgo_set_scheduler "libcgo.so"

#ifdef _64BIT
#define SWIG_PARM_SIZE 8
#else
#define SWIG_PARM_SIZE 4
#endif
%}

/* 6g/8g C boilerplate that is only needed once in a program.  This
   only gets added to the file if nothing is imported.  */
%insert(gc_once) %{

extern void ·_swig_internal_allocate(void);
#pragma dynexport _swig_gc_allocate _swig_gc_allocate
void _swig_gc_allocate(void *a, int32 n) {
	runtime·cgocallback(·_swig_internal_allocate, a, n);
}

void ·_swig_allocatememory(int32 len, byte *ret) {
	ret = runtime·mal(len);
	FLUSH(&ret);
}

extern void ·_swig_internal_makegostring(void);
#pragma dynexport _swig_gc_makegostring _swig_gc_makegostring
void _swig_gc_makegostring(void *a, int32 n) {
	runtime·cgocallback(·_swig_internal_makegostring, a, n);
}

void ·_swig_allocatestring(byte *p, int32 l, String ret) {
	ret.str = runtime·mal(l+1);
	runtime·mcpy(ret.str, p, l);
	ret.len = l;
	FLUSH(&ret);
}

extern void ·_swig_internal_gopanic(void);
#pragma dynexport _swig_gc_gopanic _swig_gc_gopanic
void _swig_gc_gopanic(void *a, int32 n) {
	runtime·cgocallback(·_swig_internal_gopanic, a, n);
}

%}

/* Go code that is only needed once in a program.  This is only added
   to the file if nothing is imported.  */
%insert(go_once) %{
func _swig_allocatememory(int) *byte
func _swig_internal_allocate(len int) *byte {
	return _swig_allocatememory(len)
}

func _swig_allocatestring(*byte, int) string
func _swig_internal_makegostring(p *byte, l int) string {
	return _swig_allocatestring(p, l)
}

func _swig_internal_gopanic(p *byte, l int) {
	panic(_swig_allocatestring(p, l))
}
%}

#else

/* Boilerplate for C/C++ code when using gccgo.  */
%insert(runtime) %{
#define SWIGGO_GCCGO

extern
#ifdef __cplusplus
"C"
#endif
void *__go_alloc (size_t);

static void *_swig_allocate(int len) {
  return __go_alloc(len);
}

static _gostring_ _swig_makegostring(const char *p, size_t l) {
  _gostring_ ret;
  ret.p = (char*)__go_alloc(l);
  memcpy(ret.p, p, l);
  ret.n = l;
  return ret;
}

extern
#ifdef __cplusplus
"C"
#endif
void __go_panic_msg(const char *);
#define _swig_gopanic __go_panic_msg

%}

#endif

%insert(runtime) %{
#define SWIG_contract_assert(expr, msg) \
  if (!(expr)) { _swig_gopanic(msg); } else
%}

