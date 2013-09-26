%module scilab_typemaps

%inline %{
    /* Scilab string */
    char returnChar()
    {
        return 'a';
    }

    /* Scilab [u]int8 */
    signed char returnSignedChar()
    {
        return (signed char)42;
    }
    unsigned char returnUnsignedChar()
    {
        return (unsigned char) 42;
    }

    /* Scilab [u]int16 */
    short returnShortAsInt16()
    {
        return 42;
    }
    signed short returnSignedShortAsInt16()
    {
        return (signed short) 42;
    }
    unsigned short returnUnsignedShort()
    {
        return (unsigned short) 42;
    }

    /* Scilab [u]int32 */
    int returnIntAsInt32()
    {
        return 42;
    }
    long returnLongAsInt32()
    {
        return (long) 42;
    }
    signed int returnSignedIntAsInt32()
    {
        return (signed int) 42;
    }
    signed long returnSignedLongAsInt32()
    {
        return (signed long) 42;
    }
    unsigned int returnUnsignedInt()
    {
        return (unsigned int) 42;
    }
    unsigned long returnUnsignedLong()
    {
        return (unsigned long) 42;
    }

    /* Scilab double */
    double returnDouble()
    {
        return 42.42;
    }
    float returnFloat()
    {
        return (float) 42;
    }
%}

