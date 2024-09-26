/*
 *
 * C++ type : STL deque
 * Scilab type : matrix (for primitive types) or list (for pointer types)
 *
*/

#define %swig_deque_methods(Type...) %swig_sequence_methods(Type)
#define %swig_deque_methods_val(Type...) %swig_sequence_methods_val(Type);

%include <std/std_deque.i>
