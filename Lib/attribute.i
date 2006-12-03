/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * attribute.i
 *
 * SWIG library file for implementing attributes.
 * ----------------------------------------------------------------------------- */

/*

  The following macros convert a pair of set/get methods
  into a "native" attribute.

  Use %attribute when you have a pair of get/set methods
  like in:

      %attribute(A, int, a, get_a, set_a);
      				      
      struct A			      
      {    				      
        int get_a() const; 		      
        void set_a(int aa); 		      
      };				      

  If you don't provide a 'set' method, a 'read-only' attribute
  is generated, ie, like in:

      %attribute(A, int, c, get_c);


  Use %attribute_ref when you have const/non-const reference
  access methods, like in:

      %attribute_ref(A, int, b);	   
      				   
      struct A			   
      {    				   
        const int& b() const; 	   
        int& b(); 			   
      };				   
      				   
      %attribute_ref(B, int, c);	   
      				   
      struct B			   
      {    				   
        int& c(); 			   
      };                               

  You can also use

      %attribute_ref(class, type, refname, attr);
  
  if the internal C++ reference methods have a different name from the
  attribute you want.
  
  Then you can use the instances like:

      x = A() 			     
      x.a = 3        # calls A::set_a    
      print x.a      # calls A::get_a    
      				     
      x.b = 3        # calls A::b()      
      print x.b      # calls A::b() const

  NOTE: remember that if the type contains commas, such as
  'std::pair<int,int>', you need to use the macro like:

  %attribute_ref(A, %arg(std::pair<int,int>), pval);

  where %arg() 'normalize' the type to be understood as a single
  argument, otherwise the macro will get confused (see the 'cpp'
  documentation).

*/

/* we use a simple exception warning here */
%{
#include <stdio.h>
%}
#define %attribute_exception(code,msg) printf("%s\n",msg)

#ifndef %arg
#define %arg(x) x
#endif

#ifndef %mange
#define %mangle(Type...)  #@Type
#endif

%include <typemaps/attribute.swg>
