%module doxygen_autodoc_docstring

%feature("autodoc", 1);

%feature("docstring") ClassWithDocString "Class doc from docstring";
%feature("docstring") functionWithDocString "Function doc from docstring";
%feature("docstring") ClassWithDocStringAndDoxygenComment "Class doc from docstring overriding doxycomment";
%feature("docstring") functionWithDocStringAndDoxygenComment "Function doc from docstring overriding doxycomment";

%inline %{
class ClassWithoutDoxygenComment {};

void functionWithoutDoxygenComment(int number) {}

/**
 * Class doxygen comment
 */
class ClassWithDoxygenComment {};

/**
 * Function doxygen comment
 */
void functionWithDoxygenComment(int number) {}

class ClassWithDocString {};

void functionWithDocString(int number) {}

/**
 * Class doxygen comment
 */
class ClassWithDocStringAndDoxygenComment {};

/**
 * Function doxygen comment
 */
void functionWithDocStringAndDoxygenComment(int number) {}
%}


%feature("autodoc", ""); // clear autodoc

%feature("docstring") ClassWithDocStringAndDoxygenCommentNoAutodoc "Class doc from docstring overriding doxycomment (no autodoc)";
%feature("docstring") functionWithDocStringAndDoxygenCommentNoAutodoc "Function doc from docstring overriding doxycomment (no autodoc)";

%inline %{
/**
 * Class doxygen comment
 */
class ClassWithDocStringAndDoxygenCommentNoAutodoc {};

/**
 * Function doxygen comment
 */
void functionWithDocStringAndDoxygenCommentNoAutodoc(int number) {}

/**
 * Class doxygen comment 2
 */
class ClassWithDoxygenComment2 {};

/**
 * Function doxygen comment 2
 */
void functionWithDoxygenComment2(int number) {}
%}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

