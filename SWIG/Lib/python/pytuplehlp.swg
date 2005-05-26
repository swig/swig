/*
  Helper function to return output types, now we need to use a list
  instead of a tuple since all the other types
  (std::pair,std::vector,std::list,etc) return tuples.
*/

%fragment("t_output_helper","header") %{
SWIGINTERN PyObject*
t_output_helper(PyObject* target, PyObject* o) {
  if (!target) {
    target = o;
  } else if (target == Py_None) {  
    Py_DECREF(target);
    target = o;
  } else {
    if (!PyList_Check(target)) {
      PyObject *o2 = target;
      target = PyList_New(1);
      PyList_SetItem(target, 0, o2);
    }
    PyList_Append(target,o);
    Py_DECREF(o);
    }
  return target;
}
%}
