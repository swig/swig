SWIG and C++17
================

Introduction
----------------

This chapter gives you a brief overview about the SWIG implementation of
the C++17 standard. There isn't much in C++17 that affects SWIG,
however, work has only just begun on adding C++17 support.

**Compatibility note:** SWIG-4.0.0 is the first version to support any
C++17 features.

Core language changes
-------------------------

Nested namespace definitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++17 offers a more concise syntax for defining namespaces. SWIG has
support for nested namespace definitions such as:

.. container:: code

   ::

      namespace A::B::C {
        ...
      }

This is the equivalent to the C++98 namespace definitions:

.. container:: code

   ::

      namespace A {
        namespace B {
          namespace C {
            ...
          }
        }
      }

UTF-8 character literals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++17 added UTF-8 (u8) character literals. These are of type char.
Example:

.. container:: code

   ::

      char a = u8'a';

Hexadecimal floating literals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++17 added hexadecimal floating literals. For example:

.. container:: code

   ::

      double f = 0xF.68p2;

Standard library changes
----------------------------
