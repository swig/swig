/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */

%fragment("SWIG_AsArgcArgv","header",fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN char**
SWIG_AsArgcArgv(PyObject* input,
		swig_type_info* ppchar_info,
		size_t* argc, int* owner)
{  
  char **argv = 0;
  size_t i = 0;
  if (SWIG_ConvertPtr(input, (void **)&argv, ppchar_info, 0) != SWIG_OK) {
    int list = 0;
    PyErr_Clear();
    list = PyList_Check(input);
    if (list || PyTuple_Check(input)) {
      *argc = list ? PyList_Size(input) : PyTuple_Size(input);
      argv = %new_array(*argc + 1, char*);
      *owner = 1;
      for (; i < *argc; ++i) {
	PyObject *obj = list ? PyList_GetItem(input,i) : PyTuple_GetItem(input,i);
	char *cptr = 0; size_t size = 0; int alloc = 0;
	if (SWIG_AsCharPtrAndSize(obj, &cptr, &size, &alloc) == SWIG_OK) {
	  if (cptr && size) {
	    argv[i] = (alloc == SWIG_NEWOBJ) ? cptr : %new_copy_array(cptr, size, char);
	  } else {
	    argv[i] = 0;
	  }
	} else {
	  SWIG_Error(SWIG_TypeError,"list or tuple must contain strings only");
	}	
      }
      argv[i] = 0;
      return argv;
    } else {
      *argc = 0;
      SWIG_Error(SWIG_TypeError,"a list or tuple is expected");
      return 0;
    }
  } else {
    /* seems dangerous, but the user asked for it... */
    while (argv[i] != 0) ++i;
    *argc = i;
    owner = 0;
    return argv;
  }
}
}

/*
  This typemap works with either a char**, a python list or a python
  tuple
 */

%typemap(in,noblock=0,fragment="SWIG_AsArgcArgv") (int ARGC, char **ARGV) (char **argv = 0, size_t argc = 0, int owner= 0) {
  argv = SWIG_AsArgcArgv($input, $descriptor(char**), &argc, &owner);
  if (!argv) { 
    $1 = 0; $2 = 0;
    %argument_fail(SWIG_TypeError, "int ARGC, char **ARGV", $argnum);
  } else {  
    $1 = ($1_ltype) argc;
    $2 = ($2_ltype) argv;
  }
}

%typemap(freearg,noblock=1) (int ARGC, char **ARGV)  {
  if (owner$argnum) {
    size_t i = argc$argnum;
    while (i) {
      %delete_array(argv$argnum[--i]);
    }
    %delete_array(argv$argnum);
  }
}

