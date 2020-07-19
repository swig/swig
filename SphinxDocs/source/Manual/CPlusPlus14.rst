SWIG and C++14
================

Introduction
----------------

This chapter gives you a brief overview about the SWIG implementation of
the C++14 standard. There isn't much in C++14 that affects SWIG,
however, work has only just begun on adding C++14 support.

**Compatibility note:** SWIG-4.0.0 is the first version to support any
C++14 features.

Core language changes
-------------------------

Binary integer literals
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C++14 added binary integer literals and SWIG supports these. Example:

.. container:: code

   ::

      int b = 0b101011;

Standard library changes
----------------------------
