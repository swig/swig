/* Helper function to return tuples */

%fragment("t_output_helper","header") %{
  static PyObject* t_output_helper(PyObject* target, PyObject* o) {
    PyObject*   o2;
    PyObject*   o3;
    
    if (!target) {                   
        target = o;
    } else if (target == Py_None) {  
        Py_DECREF(Py_None);
        target = o;
    } else {                         
        o2 = target;
        target = PyTuple_New(1);
        PyTuple_SetItem(target, 0, o2);

        o3 = PyTuple_New(1);            
        PyTuple_SetItem(o3, 0, o);      

        o2 = target;
        target = PySequence_Concat(o2, o3); 
        Py_DECREF(o2);                      
        Py_DECREF(o3);
    }
    return target;
}
%}
