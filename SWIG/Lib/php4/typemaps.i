//
// SWIG Typemap library
// Richard Palmer
// Oct 3, 2001
//
// PHP4 implementation
//
//
// This library provides standard typemaps for modifying SWIG's behavior.
// With enough entries in this file, I hope that very few people actually
// ever need to write a typemap.
//

%typemap(in) double *INPUT(double temp)
{
	temp = (double) Z_DVAL_PP($input);
	$1 = &temp;
}

%typemap(in) float  *INPUT(float temp)
{
	temp = (float) Z_DVAL_PP($input);
	$1 = &temp;
}

%typemap(in) int	*INPUT(int temp)
{
	temp = (int) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) short	*INPUT(short temp)
{
	temp = (short) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) long	*INPUT(long temp)
{
	temp = (long) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) unsigned int	*INPUT(unsigned int temp)
{
	temp = (unsigned int) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) unsigned short *INPUT(unsigned short temp)
{
	temp = (unsigned short) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) unsigned long *INPUT(unsigned long temp)
{
	temp = (unsigned long) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in) unsigned char *INPUT(unsigned char temp)
{
	temp = (unsigned char) Z_LVAL_PP($input);
	$1 = &temp;
}

%typemap(in,numinputs=0)	int	*OUTPUT(int temp),
			short	*OUTPUT(short temp),
			long	*OUTPUT(long temp),
			unsigned int	*OUTPUT(unsigned int temp),
			unsigned short	*OUTPUT(unsigned short temp),
			unsigned long	*OUTPUT(unsigned long temp),
			unsigned char	*OUTPUT(unsigned char temp),
			float		*OUTPUT(float temp),
			double		*OUTPUT(double temp)
{
  $1 = &temp;
}

%typemap(argout)	int	*OUTPUT,
			short	*OUTPUT,
			long	*OUTPUT,
			unsigned int	*OUTPUT,
			unsigned short	*OUTPUT,
			unsigned long	*OUTPUT,
			unsigned char	*OUTPUT
{

  ZVAL_LONG($result,*($input));
}

%typemap(argout)	float	*OUTPUT,
			double	*OUTPUT
{
  ZVAL_DOUBLE($result,*($input));
}

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(argout) int *INOUT = int *OUTPUT;
%typemap(argout) short *INOUT = short *OUTPUT;
%typemap(argout) long *INOUT= long *OUTPUT;
%typemap(argout) unsigned short *INOUT= unsigned short *OUTPUT;
%typemap(argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(argout) float *INOUT = float *OUTPUT;
%typemap(argout) double *INOUT= double *OUTPUT;

// REFERENCE
// Accept Php references as pointers

%typemap(in) double *REFERENCE (double dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (double) (*$input)->value.dval;
  $1 = &dvalue;
}

%typemap(in) float *REFERENCE (float dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (float) (*$input)->value.dval;
  $1 = &dvalue;
}

%typemap(in) int *REFERENCE (int dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (int) (*$input)->value.lval;
  $1 = &dvalue;
}

%typemap(in) short *REFERENCE (short dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (short) (*$input)->value.lval;
  $1 = &dvalue;
}

%typemap(in) long *REFERENCE (long dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (long) (*$input)->value.lval;
  $1 = &dvalue;
}

%typemap(in) unsigned int *REFERENCE (unsigned int dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned int) (*$input)->value.lval;
  $1 = &dvalue;
}

%typemap(in) unsigned short *REFERENCE (unsigned short dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned short) $input->value.lval;
  $1 = &dvalue;
}

%typemap(in) unsigned long *REFERENCE (unsigned long dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned long) $input->value.lval;
  $1 = &dvalue;
}

%typemap(argout) double *REFERENCE,
		      float  *REFERENCE
{
  $1->value.dval = (double)(*$arg);
  $1->type = IS_DOUBLE;
}

%typemap(argout) int	*REFERENCE,
		      short	*REFERENCE,
		      long	*REFERENCE,
		      unsigned int *REFERENCE,
		      unsigned short *REFERENCE,
		      unsigned long *REFERENCE
{

  (*$arg)->value.lval = (long)(*$input);
  (*$arg)->type = IS_LONG;
}
