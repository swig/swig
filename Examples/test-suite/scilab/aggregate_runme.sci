exec("swigtest.start", -1);

if UP_get()<>int32(1) then swigtesterror(); end
if typeof(UP_get())<>"int32" then swigtesterror(); end

if DOWN_get()<>int32(2) then swigtesterror(); end
if typeof(DOWN_get())<>"int32" then swigtesterror(); end

if LEFT_get()<>int32(3) then swigtesterror(); end
if typeof(LEFT_get())<>"int32" then swigtesterror(); end

if RIGHT_get()<>int32(4) then swigtesterror(); end
if typeof(RIGHT_get())<>"int32" then swigtesterror(); end

// TODO: move is a Scilab function...
//result = move(UP_get());
//result = move(DOWN_get());
//result = move(LEFT_get());
//result = move(RIGHT_get());

exec("swigtest.quit", -1);
