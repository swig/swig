%module scilab_typemaps

%inline %{
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
    SCI_INT16_FROM_SHORT returnShortAsInt16()
    {
        return 42;
    }
    SCI_INT16_FROM_SIGNED_SHORT returnSignedShortAsInt16()
    {
        return (signed short) 42;
    }
    unsigned short returnUnsignedShort()
    {
        return (unsigned short) 42;
    }

    /* Scilab [u]int32 */
    SCI_INT32_FROM_INT returnIntAsInt32()
    {
        return 42;
    }
    SCI_INT32_FROM_LONG returnLongAsInt32()
    {
        return (long) 42;
    }
    SCI_INT32_FROM_SIGNED_INT returnSignedIntAsInt32()
    {
        return (signed int) 42;
    }
    SCI_INT32_FROM_SIGNED_LONG returnSignedLongAsInt32()
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
    int returnInt()
    {
        return 42;
    }
    signed int returnSignedInt()
    {
        return (signed int) 42;
    }
    long returnLong()
    {
        return (long) 42;
    }
    signed long returnSignedLong()
    {
        return (signed long) 42;
    }
    char returnChar()
    {
        return 'a';
    }
    short returnShort()
    {
        return (short) 42;
    }
    signed short returnSignedShort()
    {
        return (signed short) 42;
    }

%}

