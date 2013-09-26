exec("swigtest.start", -1);

if typeof(returnSignedChar()) <> "int8" then swigtesterror(); end
if returnSignedChar() <> int8(42) then swigtesterror(); end
if typeof(returnUnsignedChar()) <> "uint8" then swigtesterror(); end
if returnUnsignedChar() <> uint8(42) then swigtesterror(); end
if typeof(returnChar()) <> "string" then swigtesterror(); end
if returnChar() <> "a" then swigtesterror(); end

if typeof(returnShortAsInt16()) <> "int16" then swigtesterror(); end
if returnShortAsInt16() <> int16(42) then swigtesterror(); end
if typeof(returnSignedShortAsInt16()) <> "int16" then swigtesterror(); end
if returnSignedShortAsInt16() <> int16(42) then swigtesterror(); end
if typeof(returnUnsignedShort()) <> "uint16" then swigtesterror(); end
if returnUnsignedShort() <> uint16(42) then swigtesterror(); end

if typeof(returnIntAsInt32()) <> "int32" then swigtesterror(); end
if returnIntAsInt32() <> int32(42) then swigtesterror(); end
if typeof(returnSignedIntAsInt32()) <> "int32" then swigtesterror(); end
if returnSignedIntAsInt32() <> int32(42) then swigtesterror(); end
if typeof(returnLongAsInt32()) <> "int32" then swigtesterror(); end
if returnLongAsInt32() <> int32(42) then swigtesterror(); end
if typeof(returnSignedLongAsInt32()) <> "int32" then swigtesterror(); end
if returnSignedLongAsInt32() <> int32(42) then swigtesterror(); end
if typeof(returnUnsignedInt()) <> "uint32" then swigtesterror(); end
if returnUnsignedInt() <> uint32(42) then swigtesterror(); end
if typeof(returnUnsignedLong()) <> "uint32" then swigtesterror(); end
if returnUnsignedLong() <> uint32(42) then swigtesterror(); end

if typeof(returnDouble()) <> "constant" then swigtesterror(); end
if returnDouble() <> 42.42 then swigtesterror(); end
if typeof(returnFloat()) <> "constant" then swigtesterror(); end
if returnFloat() <> 42 then swigtesterror(); end



exec("swigtest.quit", -1);
