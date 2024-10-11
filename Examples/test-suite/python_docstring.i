%module python_docstring

// Test indentation when using the docstring feature.
// Checks tabs and spaces as input for indentation.

%feature("docstring") docstring1 %{
  line 1
line 2

  
    
line 3
%}

%feature("docstring") docstring2 %{
line 1
  line 2
  
      
    
  line 3
  %}

%feature("docstring") docstring3 %{
    line 1
      line 2

          
        
      line 3
      %}

%feature("docstring") docstring4 %{
	line 1
	  line 2
	
	      
	    
	  line 3
	  %}

%feature("docstring") docstring5
%{	line 1
	  line 2
	
	      
	    
	  line 3
	  %}

%feature("docstring") docstring6
{
	line 1
	  line 2
	
	      
	    
	  line 3
}

%feature("docstring") docstring7
{
line 1
line 2
line 3
}

%feature("docstring") docstringA
%{    first line
    second line%}

%feature("docstring") docstringB
%{		first line
		second line%}

%feature("docstring") docstringC
%{  first line
  second line%}

%feature("docstring") docstringW "one line docs"
%feature("docstring") docstringX "  one line docs leading whitespace"
%feature("docstring") docstringY "one line docs trailing whitespace\t  "
%feature("docstring") docstringZ "\tone line docs whitespace  \t"

%inline %{
struct DocStrings {
  void docstring1() {}
  void docstring2() {}
  void docstring3() {}
  void docstring4() {}
  void docstring5() {}
  void docstring6() {}
  void docstring7() {}
  void docstringA() {}
  void docstringB() {}
  void docstringC() {}
  void docstringW() {}
  void docstringX() {}
  void docstringY() {}
  void docstringZ() {}
};
%}
