/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

/**************************************************************************
 * $Header$
 *
 * csharp.h
 *
 * Header file for CSharp (C#) module.
 * 
 * Warning : this work is in progress and for test only.
 * 
 **************************************************************************/

/*******************************************************************************
 * C# (csharp) head file, csharp.h
 *
 * Written by Songyan Feng (Tiger)
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * songyanf@cs.uchicago.edu
 *
 *
 *******************************************************************************/

class CSHARP : public Language {
protected:
  void add_method(char *name, char *function, int kw);
  String *csharpcode(String *code, const String *indent);
public :
  // Don't change any of this
  virtual void main(int, char *argv[]);
  virtual int top(Node *); 
  virtual int functionWrapper(Node *);
  virtual int constantWrapper(Node *);
  virtual int variableWrapper(Node *);
  virtual int nativeWrapper(Node *);

  virtual int membervariableHandler(Node *);
  virtual int memberconstantHandler(Node *);
  virtual int memberfunctionHandler(Node *);
  virtual int constructorHandler(Node *);
  virtual int destructorHandler(Node *);
  virtual int classHandler(Node *);
  virtual int classforwardDeclaration(Node *);

  virtual int  insertDirective(Node *);
  virtual void import_start(char *);
  virtual void import_end();

};

#define PYSHADOW_MEMBER  0x2
