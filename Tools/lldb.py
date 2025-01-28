# User-defined commands for easier debugging of SWIG in lldb
#
# This file can be "included" using:
# > command script import ..path../swig/Tools/lldb.py
#
# Then you can use the following commands:
# > swigprint swigobject [hashexpandcount]
# > locswigprint swigobject [hashexpandcount]

import lldb
import shlex

def swigprint(debugger, command, result, internal_dict):
        """
        Displays any SWIG DOH object
        Usage: swigprint swigobject [hashexpandcount]
        swigobject      - The object to display.
        hashexpandcount - Number of nested Hash types to expand (default is 1). See Swig_set_max_hash_expand() to change default.
        """
        args = shlex.split(command)
        var = args[0]
        expand_count = -1 if args.__len__() < 2 else int(args[1])
        res = lldb.SBCommandReturnObject()
        debugger.GetCommandInterpreter().HandleCommand(f'p Swig_to_string({var}, {expand_count}))', res)
        print(res.GetOutput().replace('\\n', '\n'))

def locswigprint(debugger, command, result, internal_dict):
        """
        Displays any SWIG DOH object prefixed with file and line location
        Usage: locswigprint swigobject [hashexpandcount]
        swigobject      - The object to display.
        hashexpandcount - Number of nested Hash types to expand (default is 1). See Swig_set_max_hash_expand() to change default.
        """
        args = shlex.split(command)
        var = args[0]
        expand_count = -1 if args.__len__() < 2 else int(args[1])
        res = lldb.SBCommandReturnObject()
        debugger.GetCommandInterpreter().HandleCommand(f'p Swig_to_string_with_location({var}, {expand_count}))', res)
        print(res.GetOutput().replace('\\n', '\n'))

def __lldb_init_module(debugger, internal_dict):
        debugger.HandleCommand("command script add -h \"Displays any SWIG DOH object\" -f " + __name__ + ".swigprint swigprint")
        debugger.HandleCommand("command script add -h \"Displays any SWIG DOH object prefixed with file and line location\" -f " + __name__ + ".locswinprint locswigprint")
