/* File : SimpleClass.h */

#ifndef simpleclass_SimpleClass_hh
#define simpleclass_SimpleClass_hh

//! Simple public struct; generate accessors for it
struct BasicStruct {
  int foo;
  double bar;
};

//===========================================================================//
/*!
 * \class SimpleClass
 * \brief Simple test class
 */
//===========================================================================//

class SimpleClass {
public:
  typedef int storage_type;
  typedef int multiple_type;

private:
  // >>> DATA

  int d_id;
  storage_type d_storage;

public:
  //! Constructor
  SimpleClass();

  //! Copy constructor
  SimpleClass(const SimpleClass &rhs);

  //! assignment
  SimpleClass &operator=(const SimpleClass &rhs);

  //! Other constructor
  explicit SimpleClass(double d);

  //! Destructor
  ~SimpleClass();

  //! Set the value
  void set(storage_type val);

  //! Multiply the value by 2
  void double_it();

  //! Access the value
  storage_type get() const;

  //! Access the ID
  int id() const { return d_id; }

  //! templated function
  template<class T>
  void action(T &val) {
    val *= d_storage;
  }

  //! Access the value, multiplied by some parameter
  storage_type get_multiplied(multiple_type multiple) const;
};

// Typemaps to make it a little more complicated
typedef SimpleClass *SC_Ptr;
typedef SimpleClass &SC_Ref;
typedef const SimpleClass &const_SC_Ref;

//! Free function
void print_value(const_SC_Ref c);

//! Return by new pointer
SC_Ptr emit_class(SimpleClass::storage_type val);

//! Return by value should be converted to set-by-reference
SimpleClass make_class(SimpleClass::storage_type val);

//! Return by reference
const_SC_Ref get_class();

//! Pass class as a parameter
void set_class_by_copy(SimpleClass c);

void print_struct(const BasicStruct &s);

/* ------------------------------------------------------------------------- */
#endif                                 // simpleclass_SimpleClass_hh


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
