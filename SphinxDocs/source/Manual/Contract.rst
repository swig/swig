Contracts
============

A common problem that arises when wrapping C libraries is that of
maintaining reliability and checking for errors. The fact of the matter
is that many C programs are notorious for not providing error checks.
Not only that, when you expose the internals of an application as a
library, it often becomes possible to crash it simply by providing bad
inputs or using it in a way that wasn't intended.

This chapter describes SWIG's support for software contracts. In the
context of SWIG, a contract can be viewed as a runtime constraint that
is attached to a declaration. For example, you can easily attach
argument checking rules, check the output values of a function and more.
When one of the rules is violated by a script, a runtime exception is
generated rather than having the program continue to execute.

The %contract directive
----------------------------

Contracts are added to a declaration using the %contract directive. Here
is a simple example:

.. container:: code

   ::

      %contract sqrt(double x) {
      require:
        x >= 0;
      ensure:
        sqrt >= 0;
      }

      ...
      double sqrt(double);

In this case, a contract is being added to the ``sqrt()`` function. The
``%contract`` directive must always appear before the declaration in
question. Within the contract there are two sections, both of which are
optional. The ``require:`` section specifies conditions that must hold
before the function is called. Typically, this is used to check argument
values. The ``ensure:`` section specifies conditions that must hold
after the function is called. This is often used to check return values
or the state of the program. In both cases, the conditions that must
hold must be specified as boolean expressions.

In the above example, we're simply making sure that sqrt() returns a
non-negative number (if it didn't, then it would be broken in some way).

Once a contract has been specified, it modifies the behavior of the
resulting module. For example:

.. container:: shell

   ::

      >>> example.sqrt(2)
      1.4142135623730951
      >>> example.sqrt(-2)
      Traceback (most recent call last):
        File "<stdin>", line 1, in ?
      RuntimeError: Contract violation: require: (arg1>=0)
      >>>

%contract and classes
--------------------------

The ``%contract`` directive can also be applied to class methods and
constructors. For example:

.. container:: code

   ::

      %contract Foo::bar(int x, int y) {
      require:
        x > 0;
      ensure:
        bar > 0;
      }

      %contract Foo::Foo(int a) {
      require:
        a > 0;
      }

      class Foo {
      public:
        Foo(int);
        int bar(int, int);
      };

The way in which ``%contract`` is applied is exactly the same as the
``%feature`` directive. Thus, any contract that you specified for a base
class will also be attached to inherited methods. For example:

.. container:: code

   ::

      class Spam : public Foo {
      public:
        int bar(int, int);    // Gets contract defined for Foo::bar(int, int)
      };

In addition to this, separate contracts can be applied to both the base
class and a derived class. For example:

.. container:: code

   ::

      %contract Foo::bar(int x, int) {
      require:
        x > 0;
      }

      %contract Spam::bar(int, int y) {
      require:
        y > 0;
      }

      class Foo {
      public:
        int bar(int, int);   // Gets Foo::bar contract.
      };

      class Spam : public Foo {
      public:
        int bar(int, int);   // Gets Foo::bar and Spam::bar contract
      };

When more than one contract is applied, the conditions specified in a
"require:" section are combined together using a logical-AND operation.
In other words conditions specified for the base class and conditions
specified for the derived class all must hold. In the above example,
this means that both the arguments to ``Spam::bar`` must be positive.

Constant aggregation and %aggregate_check
----------------------------------------------

Consider an interface file that contains the following code:

.. container:: code

   ::

      #define  UP     1
      #define  DOWN   2
      #define  RIGHT  3
      #define  LEFT   4

      void move(SomeObject *, int direction, int distance);

One thing you might want to do is impose a constraint on the direction
parameter to make sure it's one of a few accepted values. To do that,
SWIG provides an easy to use macro %aggregate_check() that works like
this:

.. container:: code

   ::

      %aggregate_check(int, check_direction, UP, DOWN, LEFT, RIGHT);

This merely defines a utility function of the form

.. container:: code

   ::

      int check_direction(int x);

That checks the argument x to see if it is one of the values listed.
This utility function can be used in contracts. For example:

.. container:: code

   ::

      %aggregate_check(int, check_direction, UP, DOWN, RIGHT, LEFT);

      %contract move(SomeObject *, int direction, in) {
      require:
        check_direction(direction);
      }

      #define  UP     1
      #define  DOWN   2
      #define  RIGHT  3
      #define  LEFT   4

      void move(SomeObject *, int direction, int distance);

Alternatively, it can be used in typemaps and other directives. For
example:

.. container:: code

   ::

      %aggregate_check(int, check_direction, UP, DOWN, RIGHT, LEFT);

      %typemap(check) int direction {
        if (!check_direction($1)) SWIG_exception(SWIG_ValueError, "Bad direction");
      }

      #define  UP     1
      #define  DOWN   2
      #define  RIGHT  3
      #define  LEFT   4

      void move(SomeObject *, int direction, int distance);

Regrettably, there is no automatic way to perform similar checks with
enums values. Maybe in a future release.

Notes
----------

Contract support was implemented by Songyan (Tiger) Feng and first
appeared in SWIG-1.3.20.
