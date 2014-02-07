exec("swigtest.start", -1);

// Negative values
if signed_char_identity(-1) <> -1 then swigtesterror(); end
if signed_short_identity(-1) <> -1 then swigtesterror(); end
if signed_int_identity(-1) <> -1 then swigtesterror(); end
if signed_long_identity(-1) <> -1 then swigtesterror(); end

// Overflow errors
ierr = execstr('signed_char_identity(2^8)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_short_identity(2^16)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_int_identity(2^32)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_long_identity(2^64)', 'errcatch');
if ierr <> 999 then swigtesterror(); end

// Value errors
ierr = execstr('signed_char_identity(100.2)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_short_identity(100.2)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_int_identity(100.2)', 'errcatch');
if ierr <> 999 then swigtesterror(); end
ierr = execstr('signed_long_identity(100.2)', 'errcatch');
if ierr <> 999 then swigtesterror(); end

exec("swigtest.quit", -1);
