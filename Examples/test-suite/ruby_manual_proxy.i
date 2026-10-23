%module ruby_manual_proxy


%typemap(in, numinputs=0) SWIGTYPE ** ($*1_ltype temp) "$1 = &temp;"

%typemap(argout) SWIGTYPE **OUTPARAM {
  $result = SWIG_AppendOutput($result, SWIG_NewPointerObj(*$1, $*1_descriptor, 0));
}

%apply SWIGTYPE **OUTPARAM {
  svn_fs_t **
};

%typemap(check) svn_fs_t * {
  if (!$1) {
    svn_swig_rb_raise_svn_fs_already_close();
  }
}

%{
typedef struct svn_fs_t {
  char path[256];
} svn_fs_t;

void svn_fs_create(svn_fs_t **fs_p, const char *path) {
  svn_fs_t *fs = (svn_fs_t *)malloc(sizeof(svn_fs_t));
  strncpy(fs->path, path, 256);
  *fs_p = fs;
}
const char *svn_fs_path(svn_fs_t *fs) {
  return fs->path;
}
%}

typedef struct svn_fs_t svn_fs_t;
void svn_fs_create(svn_fs_t **fs_p, const char *path);
const char *svn_fs_path(svn_fs_t *fs);

%{
static void svn_swig_rb_raise_svn_fs_already_close(void) {
  rb_raise(rb_eIOError, "already closed");
}

static VALUE svn_fs_swig_rb_close(VALUE self) {
  void *ptr = 0;
  int res;

  res = SWIG_ConvertPtr(self, &ptr, NULL, 0);
  if (res != SWIG_OK) SWIG_Error(res, "Can't get C++ pointer");
  if (!ptr) {
    svn_swig_rb_raise_svn_fs_already_close();
  }

  res = SWIG_ConvertPtr(self, NULL, NULL, SWIG_POINTER_CLEAR);
  if (res != SWIG_OK) SWIG_Error(res, "Can't release C++ object");

  return Qnil;
}

/* The way hand written code invalidated a proxy before SWIG 4.5 introduced the TypedData
   wrapper. It is no longer the recommended approach, see svn_fs_swig_rb_close above, but it
   must not crash on any Ruby version, see #3512. */
static VALUE svn_fs_swig_rb_legacy_close(VALUE self) {
  DATA_PTR(self) = NULL;

  return Qnil;
}

static VALUE svn_fs_swig_rb_closed(VALUE self) {
  void *ptr = 0;
  int res;

  res = SWIG_ConvertPtr(self, &ptr, NULL, 0);
  if (res != SWIG_OK) SWIG_Error(res, "Can't get C++ pointer");
  return ptr ? Qfalse : Qtrue;
}
%}

%insert("init") %{
  {
    VALUE cSvnfs;
    cSvnfs = rb_const_get(_mSWIG, rb_intern("TYPE_p_svn_fs_t"));
    rb_define_method(cSvnfs, "close",
                     VALUEFUNC(svn_fs_swig_rb_close), 0);
    rb_define_method(cSvnfs, "legacy_close",
                     VALUEFUNC(svn_fs_swig_rb_legacy_close), 0);
    rb_define_method(cSvnfs, "closed?",
                     VALUEFUNC(svn_fs_swig_rb_closed), 0);
  }
%}
