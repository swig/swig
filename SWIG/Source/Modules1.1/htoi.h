/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

/**************************************************************************
 * class HTOI
 **************************************************************************/

class HTOI : public Language {
public :
  virtual void emit_node(Node *);
  virtual void main(int, char *argv[]);
  virtual void top(Node *); 

  /* SWIG directives */
  
  virtual void constantDirective(Node *n);
  virtual void includeDirective(Node *n);

  /* C/C++ parsing */
  
  virtual void cDeclaration(Node *n);
  virtual void externDeclaration(Node *n);
  virtual void enumDeclaration(Node *n);
  virtual void enumvalueDeclaration(Node *n);
  virtual void classDeclaration(Node *n);
  virtual void classforwardDeclaration(Node *n);
  virtual void constructorDeclaration(Node *n);
  virtual void destructorDeclaration(Node *n);
  virtual void accessDeclaration(Node *n);

};






