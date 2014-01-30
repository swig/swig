exec("swigtest.start", -1);

// Char
if typeof(returnChar()) <> "string" then swigtesterror(); end
if returnChar() <> "a" then swigtesterror(); end
if typeof(returnSignedChar()) <> "int8" then swigtesterror(); end
if returnSignedChar() <> int8(42) then swigtesterror(); end
if typeof(returnUnsignedChar()) <> "uint8" then swigtesterror(); end
if returnUnsignedChar() <> uint8(42) then swigtesterror(); end

// Short
if typeof(returnShort()) <> "constant" then swigtesterror(); end
if returnShort() <> 42 then swigtesterror(); end
if typeof(returnUnsignedShort()) <> "uint16" then swigtesterror(); end
if returnUnsignedShort() <> uint16(42) then swigtesterror(); end

// Int
if typeof(returnInt()) <> "constant" then swigtesterror(); end
if returnInt() <> 42 then swigtesterror(); end
if typeof(returnUnsignedInt()) <> "uint32" then swigtesterror(); end
if returnUnsignedInt() <> uint32(42) then swigtesterror(); end

// Long
if typeof(returnLong()) <> "constant" then swigtesterror(); end
if returnLong() <> 42 then swigtesterror(); end
if typeof(returnUnsignedLong()) <> "uint32" then swigtesterror(); end
if returnUnsignedLong() <> uint32(42) then swigtesterror(); end

// Double & float
if typeof(returnDouble()) <> "constant" then swigtesterror(); end
if returnDouble() <> 42.42 then swigtesterror(); end
if typeof(returnFloat()) <> "constant" then swigtesterror(); end
if returnFloat() <> 42 then swigtesterror(); end



exec("swigtest.quit", -1);
