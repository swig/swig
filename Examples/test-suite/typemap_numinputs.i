%module typemap_numinputs


%typemap(in, numinputs=1) (char *STR, int LEN)(int temp = 0)
{
  temp = 1;
  $2 = 0;
  $1 = 0;
}

%typemap(in) (int *OUTPUT)  (int temp = 0)
{
  temp = 2;
  $1 = &temp;
}

// Catch if a target language does not emit the check typemap of a parameter in or after a multi-argument 'in' typemap
%typemap(check) int LEN "undefined_error_means_check_typemap_LEN_not_emitted:;"
%typemap(check) int *OUTPUT "undefined_error_means_check_typemap_OUTPUT_not_emitted:;"

%typemap(argout) (int *OUTPUT)
{
  ++temp$argnum;
  if (0) goto undefined_error_means_check_typemap_LEN_not_emitted;
  if (0) goto undefined_error_means_check_typemap_OUTPUT_not_emitted;
}

%typemap(argout, numinputs=1) (char *STR, int LEN)
{
  ++temp$argnum;
}

%typemap(in) int hello
{
  $1 = 0;
}

%inline %{
  int this_breaks(int hello, char *STR, int LEN, int *OUTPUT)
  {
    return LEN;
  }
%}
