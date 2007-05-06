/**
 * @file   rubystdfunctors.swg
 * @date   Sun May  6 00:44:33 2007
 * 
 * @brief  This file provides unary and binary functors for STL
 *         containers, that will invoke a Ruby proc or method to do
 *         their operation.
 *
 *         You can use them in a swig file like:
 *
 *         %template< IntSet > std::set< int, RubyBinaryPredicate<> >;
 *
 *
 *         which will then allow calling them from Ruby either like:
 *  
 *            # order of set is defined by C++ default
 *            a = IntSet.new
 *
 *            # sort order defined by Ruby proc
 *            b = IntSet.new( proc { |a,b| a > b } )
 * 
 */

%include rubyclasses.swg

%{
/* This function can be used to check whether a proc or method or similarly
   callable function has been passed.  Usually used in a %typecheck. */
SWIGINTERN
int SWIG_Ruby_isCallable( VALUE proc )
{
  static VALUE call_id = rb_intern("call");
  if ( rb_respond_to( proc, call_id ) )
    return 1;
  return 0;
}

/* This function can be used to check the arity (number of arguments)
   a proc or method can take.  Usually used in a %typecheck.
   Valid arities will be that equal to minimal or those < 0
   which indicate a variable number of parameters at the end.
 */
SWIGINTERN
int SWIG_Ruby_arity( VALUE proc, int minimal )
{
  static VALUE arity_id = rb_intern("arity");
  if ( rb_respond_to( proc, arity_id ) )
    {
      VALUE num = rb_funcall( proc, arity_id, 0 );
      int arity = NUM2INT(num);
      if ( arity < 0 && (arity+1) < -minimal ) return 1;
      if ( arity == minimal ) return 1;
      return 1;
    }
  return 0;
}

%}


namespace swig {

  %apply GC_VALUE { UnaryPredicate, BinaryPredicate, UnaryFunction,
		      BinaryFunction };

  %typecheck(SWIG_TYPECHECK_POINTER,noblock=1) 
    UnaryPredicate, UnaryPredicate&, UnaryFunction, UnaryFunction&
  {
    $1 = SWIG_Ruby_isCallable($input) && SWIG_Ruby_arity($input, 1);
  }

  %typecheck(SWIG_TYPECHECK_POINTER,noblock=1) 
    BinaryPredicate, BinaryPredicate&, BinaryFunction, BinaryFunction& {
    $1 = SWIG_Ruby_isCallable($input) && SWIG_Ruby_arity($input, 2);
  }

  %typemap(in,noblock=1) UnaryFunction&, UnaryFunction {
    $1 = new swig::UnaryFunction<>($input);
  }
  %typemap(in,noblock=1) UnaryPredicate&, UnaryPredicate {
    $1 = new swig::UnaryPredicate<>($input);
  }

  %typemap(in,noblock=1)  BinaryFunction&, BinaryFunction {
    $1 = new swig::BinaryFunction<>($input);
  }
  %typemap(in,noblock=1) BinaryPredicate&, BinaryPredicate {
    $1 = new swig::BinaryPredicate<>($input);
  }


  %ignore BinaryFunction;
  struct BinaryFunction {};

  %ignore UnaryFunction;
  struct UnaryFunction {};

  %ignore BinaryPredicate;
  struct BinaryPredicate {};

  %ignore UnaryPredicate;
  struct UnaryPredicate {};

}


%{
namespace swig {

  static ID call_id = rb_intern("call");

  template <class _DefaultFunc = std::less<GC_VALUE> >
  struct BinaryPredicate : GC_VALUE, std::binary_function<GC_VALUE, GC_VALUE, bool>
  {
    BinaryPredicate(VALUE obj = Qnil) : GC_VALUE(obj) { }
    bool operator()(GC_VALUE arg1, GC_VALUE arg2) const
    {
      if (_obj != Qnil) {
        SWIG_RUBY_THREAD_BEGIN_BLOCK;
	VALUE res = rb_funcall( _obj, swig::call_id, 2, 
				VALUE(arg1), VALUE(arg2));
        SWIG_RUBY_THREAD_END_BLOCK;
        return RTEST(res);
      } else {
        return _DefaultFunc()(arg1, arg2);
      }
    }
  };

  template <class _DefaultFunc = std::less<GC_VALUE> >
  struct BinaryFunction : GC_VALUE, std::binary_function<GC_VALUE, GC_VALUE, GC_VALUE>
  {
    BinaryFunction(VALUE obj = Qnil) : GC_VALUE(obj) { }
    GC_VALUE operator()(GC_VALUE arg1, GC_VALUE arg2) const
    {
      if (_obj != Qnil) {
        SWIG_RUBY_THREAD_BEGIN_BLOCK;
	VALUE res = rb_funcall( _obj, swig::call_id, 2, 
				VALUE(arg1), VALUE(arg2));
        SWIG_RUBY_THREAD_END_BLOCK;
        return GC_VALUE(res);
      } else {
        return _DefaultFunc()(arg1, arg2);
      }
    }
  };


  struct UnaryPredicate : GC_VALUE, std::unary_function<GC_VALUE, bool>
  {
    UnaryPredicate(VALUE obj = Qnil) : GC_VALUE(obj) { }
    bool operator()(GC_VALUE arg1) const
    {
      SWIG_RUBY_THREAD_BEGIN_BLOCK;
      VALUE res = rb_funcall( _obj, swig::call_id, 1, VALUE(arg1));
      SWIG_RUBY_THREAD_END_BLOCK;
      return RTEST(res);
    }
  };

  struct UnaryFunction : GC_VALUE, std::unary_function<GC_VALUE, GC_VALUE>
  {
    UnaryFunction(VALUE obj = Qnil) : GC_VALUE(obj) { }
    GC_VALUE operator()(GC_VALUE arg1) const
    {
      SWIG_RUBY_THREAD_BEGIN_BLOCK;
      VALUE res = rb_funcall( _obj, swig::call_id, 1, VALUE(arg1));
      SWIG_RUBY_THREAD_END_BLOCK;
      return GC_VALUE(res);
    }
  };


}
%}


