%module scilab_typemaps

%inline %{
// Char
char returnChar()
{
	return 'a';
}
signed char returnSignedChar()
{
	return (signed char)42;
}
unsigned char returnUnsignedChar()
{
	return (unsigned char) 42;
}

// Short
short returnShort()
{
	return 42;
}
unsigned short returnUnsignedShort()
{
	return (unsigned short) 42;
}

// Int
int returnInt()
{
	return 42;
}

unsigned int returnUnsignedInt()
{
	return (unsigned int) 42;
}

// Long
long returnLong()
{
	return (long) 42;
}
unsigned long returnUnsignedLong()
{
	return (unsigned long) 42;
}


// Double & float
double returnDouble()
{
	return 42.42;
}
float returnFloat()
{
	return (float) 42;
}
%}

