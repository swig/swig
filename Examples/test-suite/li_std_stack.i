/**
 * @file   std_stack.i
 * @author gga
 * @date   Sun May  6 01:52:44 2007
 * 
 * @brief  test of std::stack
 * 
 * 
 */

%module li_std_stack

%include std_stack.i


%template( IntStack ) std::stack< int >;
