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

%typemap(php4,in) double *INPUT(double temp)
{
	temp = (double) Z_DVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) float  *INPUT(float temp)
{
	temp = (float) Z_DVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) int	*INPUT(int temp)
{
	temp = (int) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) short	*INPUT(short temp)
{
	temp = (short) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) long	*INPUT(long temp)
{
	temp = (long) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) unsigned int	*INPUT(unsigned int temp)
{
	temp = (unsigned int) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) unsigned short *INPUT(unsigned short temp)
{
	temp = (unsigned short) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) unsigned long *INPUT(unsigned long temp)
{
	temp = (unsigned long) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,in) unsigned char *INPUT(unsigned char temp)
{
	temp = (unsigned char) Z_LVAL_P($source);
	$target = &temp;
}

%typemap(php4,ignore)	int	*OUTPUT(int temp),
			short	*OUTPUT(short temp),
			long	*OUTPUT(long temp),
			unsigned int	*OUTPUT(unsigned int temp),
			unsigned short	*OUTPUT(unsigned short temp),
			unsigned long	*OUTPUT(unsigned long temp),
			unsigned char	*OUTPUT(unsigned char temp),
			float		*OUTPUT(float temp),
			double		*OUTPUT(double temp)
{
  $target = &temp;
}

%typemap(php4,argout)	int	*OUTPUT,
			short	*OUTPUT,
			long	*OUTPUT,
			unsigned int	*OUTPUT,
			unsigned short	*OUTPUT,
			unsigned long	*OUTPUT,
			unsigned char	*OUTPUT
{

  RETURN_LONG(*($source));
}

%typemap(php4,argout)	float	*OUTPUT,
			double	*OUTPUT
{
  RETURN_DOUBLE(*($source));
}

%typemap(php4,in) int *BOTH = int *INPUT;
%typemap(php4,in) short *BOTH = short *INPUT;
%typemap(php4,in) long *BOTH = long *INPUT;
%typemap(php4,in) unsigned *BOTH = unsigned *INPUT;
%typemap(php4,in) unsigned short *BOTH = unsigned short *INPUT;
%typemap(php4,in) unsigned long *BOTH = unsigned long *INPUT;
%typemap(php4,in) unsigned char *BOTH = unsigned char *INPUT;
%typemap(php4,in) float *BOTH = float *INPUT;
%typemap(php4,in) double *BOTH = double *INPUT;

%typemap(php4,argout) int *BOTH = int *INPUT;
%typemap(php4,argout) short *BOTH = short *INPUT;
%typemap(php4,argout) long *BOTH = long *INPUT;
%typemap(php4,argout) unsigned short *BOTH = unsigned short *INPUT;
%typemap(php4,argout) unsigned long *BOTH = unsigned long *INPUT;
%typemap(php4,argout) unsigned char *BOTH = unsigned char *INPUT;
%typemap(php4,argout) float *BOTH = float *INPUT;
%typemap(php4,argout) double *BOTH = double *INPUT;

// REFERENCE
// Accept Php references as pointers

%typemap(php4,in) double *REFERENCE (double dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (double) (*$source)->value.dval;
  $target = &dvalue;
}

%typemap(php4,in) float *REFERENCE (float dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (float) (*$source)->value.dval;
  $target = &dvalue;
}

%typemap(php4,in) int *REFERENCE (int dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (int) (*$source)->value.lval;
  $target = &dvalue;
}

%typemap(php4,in) short *REFERENCE (short dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (short) (*$source)->value.lval;
  $target = &dvalue;
}

%typemap(php4,in) long *REFERENCE (long dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (long) (*$source)->value.lval;
  $target = &dvalue;
}

%typemap(php4,in) unsigned int *REFERENCE (unsigned int dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned int) (*$source)->value.lval;
  $target = &dvalue;
}

%typemap(php4,in) unsigned short *REFERENCE (unsigned short dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned short) $source->value.lval;
  $target = &dvalue;
}

%typemap(php4,in) unsigned long *REFERENCE (unsigned long dvalue)
{
  if(!ParameterPassedByReference(ht, argvi))
  {
	zend_error(E_WARNING, "Parameter wasn't passed by reference");
	RETURN_NULL();
  }

  dvalue = (unsigned long) $source->value.lval;
  $target = &dvalue;
}

%typemap(php4,argout) double *REFERENCE,
		      float  *REFERENCE
{
  $target->value.dval = (double)(*$arg);
  $target->type = IS_DOUBLE;
}

%typemap(php4,argout) int	*REFERENCE,
		      short	*REFERENCE,
		      long	*REFERENCE,
		      unsigned int *REFERENCE,
		      unsigned short *REFERENCE,
		      unsigned long *REFERENCE
{

  (*$arg)->value.lval = (long)(*$source);
  (*$arg)->type = IS_LONG;
}
