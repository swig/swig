/*
 * typemaps for standard C++ string
 * Copyright (C) 2000 Tal Shalif <tal@slt.atr.co.jp>
 */
/* what type to use in java source code */
%typemap(java,jtype) const MyString & {String}

/* what is the corresponding jni type */
%typemap(java,jni) const MyString & {jstring}

/* how to convert the c++ type to the java type */
%typemap(java,out) const MyString & {
 $target = JCALL(NewStringUTF, jenv) $source->c_str());
}

/* how to convert java type to requested c++ type */
%typemap(java,in) const MyString & {
  $target = NULL;
  if($source != NULL) {
    /* get the String from the StringBuffer */
    char *p = (char *)jenv->GetStringUTFChars($source, 0);
    $target =  new string(p);
    /* free(p); HdH assuming string constructor makes a copy */
    JCALL(ReleaseStringUTFChars, jenv) $source, p);
  }
}
/* free resource once finished using */
%typemap(java,freearg) const MyString & {
  delete $target;
}

%typemap(java,jtype) MyString & = const MyString &;
%typemap(java,jni) MyString & = const MyString &;
%typemap(java,in) MyString & = const MyString &;
%typemap(java,out) MyString & = const MyString &;
%typemap(java,freearg) MyString & = const MyString &;


%typemap(python,in) const MyString & {
  if (PyString_Check ($source))
  {
    $target = new string((char *)PyString_AsString($source));
  }
  else
  {
    PyErr_SetString (PyExc_TypeError, "not a string");
    return NULL;
  }
}
%typemap(python,out) const MyString & {
  $target = PyString_FromString($source->c_str());
}
%typemap (python, freearg) const MyString & {
  delete $source;
}

%typemap(python,in) MyString & = const MyString &;
%typemap(python,out) MyString & = const MyString &;
%typemap(python,freearg) MyString & = const MyString &;

/* MyString_typemap.i ends here */
