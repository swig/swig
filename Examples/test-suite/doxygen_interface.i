%module doxygen_interface

%include "swiginterface.i"
%interface_impl(MyInterface)

%inline %{

/**
 * My interface
 */
class MyInterface {
public:
  /**
   * Example method to test interfaces.
   *
   * \param arg value
   * \return another value
   */
  virtual int testMethod(int arg) = 0;
  
  /**
   * Virtual destructor.
   */
  virtual ~MyInterface() {}
};

/// Concrete implementation for testing
class MyInterfaceImpl : public MyInterface {
public:
  virtual int testMethod(int arg) {
    return arg;
  }
  
  virtual ~MyInterfaceImpl() {}
};

%}
