# QuickJS Readme notes

To run the QuickJS javascript, you may need to include the QJS include directory using the Ilibrary directory.

Ex:

`./swig -javascript -qjs -c++ -ILib/javascript/qjs/ Examples/javascript/simple/example.i`

The result will be a file with the `*_wrap.c*` files suffix.

