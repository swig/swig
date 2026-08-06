#if defined(SWIG_PYTHON_NO_THREADS)
#  if defined(SWIG_PYTHON_THREADS)
#    undef SWIG_PYTHON_THREADS
#  endif
#endif
#if defined(SWIG_PYTHON_THREADS) /* Threading support is enabled */
#  if !defined(SWIG_PYTHON_USE_GIL) && !defined(SWIG_PYTHON_NO_USE_GIL)
#    define SWIG_PYTHON_USE_GIL
#  endif
#  if defined(SWIG_PYTHON_USE_GIL) /* Use PyGILState threads calls */
#    if !defined(SWIG_PYTHON_INITIALIZE_THREADS)
#      if PY_VERSION_HEX < 0x03070000
#        define SWIG_PYTHON_INITIALIZE_THREADS PyEval_InitThreads()
#      else
#        define SWIG_PYTHON_INITIALIZE_THREADS
#      endif
#    endif
#    ifdef __cplusplus /* C++ code */
       /* Deferred error storage: when PyGILState_Ensure creates a temporary
        * thread state inside a SWIG_PYTHON_THREAD_BEGIN_ALLOW block, errors
        * set on that temporary state are lost when PyGILState_Release destroys
        * it. These globals bridge the transition: Block::end() saves the error
        * before release, and Allow::end() restores it after restore. */
       static PyObject *_swig_deferred_error_type = NULL;
       static PyObject *_swig_deferred_error_value = NULL;
       static PyObject *_swig_deferred_error_tb = NULL;

       class SWIG_Python_Thread_Block {
         bool status;
         PyGILState_STATE state;
       public:
         void end() {
           if (status) {
             status = false;
             if (state == PyGILState_UNLOCKED && PyErr_Occurred()) {
               PyErr_Fetch(&_swig_deferred_error_type, &_swig_deferred_error_value, &_swig_deferred_error_tb);
             }
             PyGILState_Release(state);
           }
         }
         SWIG_Python_Thread_Block() : status(true), state(PyGILState_Ensure()) {}
         ~SWIG_Python_Thread_Block() { end(); }
       };
       class SWIG_Python_Thread_Allow {
         bool status;
         PyThreadState *save;
       public:
         void end() {
           if (status) {
             status = false;
             PyEval_RestoreThread(save);
             if (_swig_deferred_error_type) {
               PyErr_Restore(_swig_deferred_error_type, _swig_deferred_error_value, _swig_deferred_error_tb);
               _swig_deferred_error_type = _swig_deferred_error_value = _swig_deferred_error_tb = NULL;
             }
           }
         }
         SWIG_Python_Thread_Allow() : status(true), save(PyEval_SaveThread()) {}
         ~SWIG_Python_Thread_Allow() { end(); }
       };
#      define SWIG_PYTHON_THREAD_BEGIN_BLOCK   SWIG_Python_Thread_Block _swig_thread_block
#      define SWIG_PYTHON_THREAD_END_BLOCK     _swig_thread_block.end()
#      define SWIG_PYTHON_THREAD_BEGIN_ALLOW   SWIG_Python_Thread_Allow _swig_thread_allow
#      define SWIG_PYTHON_THREAD_END_ALLOW     _swig_thread_allow.end()
#    else /* C code */
#      define SWIG_PYTHON_THREAD_BEGIN_BLOCK   PyGILState_STATE _swig_thread_block = PyGILState_Ensure()
#      define SWIG_PYTHON_THREAD_END_BLOCK     PyGILState_Release(_swig_thread_block)
#      define SWIG_PYTHON_THREAD_BEGIN_ALLOW   PyThreadState *_swig_thread_allow = PyEval_SaveThread()
#      define SWIG_PYTHON_THREAD_END_ALLOW     PyEval_RestoreThread(_swig_thread_allow)
#    endif
#  else /* Old thread way, not implemented, user must provide it */
#    if !defined(SWIG_PYTHON_INITIALIZE_THREADS)
#      define SWIG_PYTHON_INITIALIZE_THREADS
#    endif
#    if !defined(SWIG_PYTHON_THREAD_BEGIN_BLOCK)
#      define SWIG_PYTHON_THREAD_BEGIN_BLOCK
#    endif
#    if !defined(SWIG_PYTHON_THREAD_END_BLOCK)
#      define SWIG_PYTHON_THREAD_END_BLOCK
#    endif
#    if !defined(SWIG_PYTHON_THREAD_BEGIN_ALLOW)
#      define SWIG_PYTHON_THREAD_BEGIN_ALLOW
#    endif
#    if !defined(SWIG_PYTHON_THREAD_END_ALLOW)
#      define SWIG_PYTHON_THREAD_END_ALLOW
#    endif
#  endif
#else /* No thread support */
#  define SWIG_PYTHON_INITIALIZE_THREADS
#  define SWIG_PYTHON_THREAD_BEGIN_BLOCK
#  define SWIG_PYTHON_THREAD_END_BLOCK
#  define SWIG_PYTHON_THREAD_BEGIN_ALLOW
#  define SWIG_PYTHON_THREAD_END_ALLOW
#endif
