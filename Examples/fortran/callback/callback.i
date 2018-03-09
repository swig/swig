/* File : callback.h */
%module callback

%include <std_string.i>

%{
#include "callback.h"
%}

// Wrap the included functions both as procedures *and* as callbacks
%feature("callback", name="enquote_cb") enquote;
%include "callback.h"

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
