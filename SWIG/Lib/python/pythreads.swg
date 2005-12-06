#if defined(SWIG_PYTHON_NO_THREADING)
#  if defined(SWIG_PYTHON_THREADING)
#    undef SWIG_PYTHON_THREADING
#  endif
#endif
#if defined(SWIG_PYTHON_THREADING) /* Threading support is enabled */
#  if !defined(SWIG_PYTHON_USE_GIL) && !defined(SWIG_PYTHON_NO_USE_GIL)
#    if (PY_VERSION_HEX >= 0x02030000) /* For 2.3 or later, use the PyGILState calls */
#      define SWIG_PYTHON_USE_GIL
#    endif
#  endif
#  if defined(SWIG_PYTHON_USE_GIL) /* Use PyGILState threads calls */
#    if !defined(SWIG_PYTHON_INITIALIZE_THREADING)
#      define SWIG_PYTHON_INITIALIZE_THREADING PyEval_InitThreads()
#    endif
#    ifdef __cplusplus
       class SWIG_Python_Thread_Block {
         bool status;
         PyGILState_STATE state;
       public:
         void begin() { if (!status) { state = PyGILState_Ensure(); status = true;} }
         void end() { if (status) { PyGILState_Release(state); status = false;} }
         SWIG_Python_Thread_Block() : status(false)  { begin(); }
         ~SWIG_Python_Thread_Block() { end(); }
       };
       class SWIG_Python_Thread_Allow {
         bool status;
         PyThreadState *save;
       public:
         void begin() { if (!status) { status = true; save = PyEval_SaveThread(); }}
         void end() { if (status) { PyEval_RestoreThread(save); status = false; }}
         SWIG_Python_Thread_Allow() : status(false) { begin(); }
         ~SWIG_Python_Thread_Allow() { end(); }
       };
#      define SWIG_PYTHON_THREAD_BEGIN_BLOCK   SWIG_Python_Thread_Block _swig_thread_block
#      define SWIG_PYTHON_THREAD_END_BLOCK     _swig_thread_block.end()
#      define SWIG_PYTHON_THREAD_BEGIN_ALLOW   SWIG_Python_Thread_Allow _swig_thread_allow
#      define SWIG_PYTHON_THREAD_END_ALLOW     _swig_thread_allow.end()
#    else /* C++ */
#      define SWIG_PYTHON_THREAD_BEGIN_BLOCK   PyGILState_STATE _swig_thread_allow = PyGILState_Ensure()
#      define SWIG_PYTHON_THREAD_END_BLOCK     PyGILState_Release(_swig_thread_allow)
#      define SWIG_PYTHON_THREAD_BEGIN_ALLOW   Py_BEGIN_ALLOW_THREADS
#      define SWIG_PYTHON_THREAD_END_ALLOW     Py_END_ALLOW_THREADS
#    endif
#  else /* Old thread way, not implemented, user must provide it */
#    if !defined(SWIG_PYTHON_INITIALIZE_THREADING)
#      define SWIG_PYTHON_INITIALIZE_THREADING
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
#  define SWIG_PYTHON_INITIALIZE_THREADING
#  define SWIG_PYTHON_THREAD_BEGIN_BLOCK
#  define SWIG_PYTHON_THREAD_END_BLOCK
#  define SWIG_PYTHON_THREAD_BEGIN_ALLOW
#  define SWIG_PYTHON_THREAD_END_ALLOW
#endif
