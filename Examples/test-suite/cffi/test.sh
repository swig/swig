#!/bin/sh

#
# This script can be used to regenerate the bindings.lisp file using
# SWIG. 
#

swig -cffi -module operator_precedence -noswig-lisp -o operator_precedence.lisp ../operator_precedence.i
clisp operator_precedence_runme.lisp
