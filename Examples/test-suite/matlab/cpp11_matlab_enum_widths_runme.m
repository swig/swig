low = intmin('int64');
high = intmax('int64');
unsigned_high = intmax('uint64');
assert(isequal(cpp11_matlab_enum_widths.SignedWide_low, low));
assert(isequal(cpp11_matlab_enum_widths.SignedWide_high, high));
assert(isequal(cpp11_matlab_enum_widths.UnsignedWide_high, unsigned_high));
assert(isequal(cpp11_matlab_enum_widths.MAX_ENUM, unsigned_high));
assert(isequal(cpp11_matlab_enum_widths.ANONYMOUS_HIGH, unsigned_high));
assert(cpp11_matlab_enum_widths.EnumHolder.Code_high() == 65535);
assert(isequal(cpp11_matlab_enum_widths.signed_echo(low), low));
assert(isequal(cpp11_matlab_enum_widths.signed_ref(high), high));
assert(isequal(cpp11_matlab_enum_widths.unsigned_echo(unsigned_high), unsigned_high));
assert(cpp11_matlab_enum_widths.narrow_echo(uint8(255)) == 255);
assert(cpp11_matlab_enum_widths.signed32_echo(intmin('int32')) == intmin('int32'));
assert(cpp11_matlab_enum_widths.unsigned32_echo(intmax('uint32')) == intmax('uint32'));
assert(isequal(cpp11_matlab_enum_widths.flag_echo(1), uint64(1)));
assert(isequal(cpp11_matlab_enum_widths.flag_echo(0), uint64(0)));
assert(isequal(cpp11_matlab_enum_widths.pair_values({uint8(255), unsigned_high}), {uint64(255), unsigned_high}));
assert(cpp11_matlab_enum_widths.enum_storage_guard(uint8(255)));
assert(isequal(cpp11_matlab_enum_widths.wide_values({uint64(0), unsigned_high}), {uint64(0), unsigned_high}));
assert(isequal(cell2mat(cpp11_matlab_enum_widths.narrow_values({uint8(0), uint8(255)})), uint64([0, 255])));
v = cpp11_matlab_enum_widths.NarrowVector();
v.append(uint8(255));
assert(v.brace(0) == 255);
holder = cpp11_matlab_enum_widths.EnumHolder();
holder.narrow(uint8(128));
holder.wide(high);
assert(holder.narrow() == 128 && isequal(holder.wide(), high));
bad_values = {-1, 256, 1.5, NaN, Inf, 1+1i, [1, 2]};
for k = 1:numel(bad_values)
  failed = false;
  try
    cpp11_matlab_enum_widths.narrow_echo(bad_values{k});
  catch
    failed = true;
  end
  assert(failed);
  failed = false;
  try
    cpp11_matlab_enum_widths.narrow_values({bad_values{k}});
  catch
    failed = true;
  end
  assert(failed);
end
failed = false;
try
  cpp11_matlab_enum_widths.signed_echo(unsigned_high);
catch
  failed = true;
end
assert(failed);
failed = false;
try
  cpp11_matlab_enum_widths.unsigned_echo(int64(-1));
catch
  failed = true;
end
assert(failed);
delete(v);
delete(holder);
assert(isequal(cpp11_matlab_enum_widths.const_signed_echo(low), low));
callback = MatlabEnumDirector();
assert(isequal(cpp11_matlab_enum_widths.invoke_signed(callback, low), low));
assert(isequal(cpp11_matlab_enum_widths.invoke_signed(callback, high), high));
assert(isequal(cpp11_matlab_enum_widths.invoke_unsigned(callback, unsigned_high), unsigned_high));
callback.invalid = true;
failed = false;
try
  cpp11_matlab_enum_widths.invoke_signed(callback, low);
catch
  failed = true;
end
assert(failed);
failed = false;
try
  cpp11_matlab_enum_widths.invoke_unsigned(callback, unsigned_high);
catch
  failed = true;
end
assert(failed);
delete(callback);
