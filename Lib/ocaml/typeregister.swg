/* Code ripped from python implementation */
{
  static int       typeinit = 0;
  int       i;
  if (!typeinit) {
     SWIG_Ocaml_LookupTypePointer();
     for (i = 0; swig_types_initial[i]; i++) {
        swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
     }
     typeinit = 1;
  }
}
