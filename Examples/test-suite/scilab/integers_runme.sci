exec loader.sce;

if signed_char_identity(-13) <> -13 then pause, end
if unsigned_char_identity(251) <> 251 then pause, end
if signed_short_identity(-31000) <> -31000 then pause, end
if unsigned_short_identity(61000) <> 61000 then pause, end
if signed_int_identity(42) <> 42 then pause, end
if unsigned_int_identity(123456) <> 123456 then pause, end
if signed_long_identity(65537) <> 65537 then pause, end
if unsigned_long_identity(654321) <> 654321 then pause, end

exit

