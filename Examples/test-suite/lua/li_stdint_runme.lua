local v=require("li_stdint")

assert(v.int8_td(127) == 127)
assert(v.int8_td(-128) == -128)
assert(v.int16_td(32767) == 32767)
assert(v.int16_td(-32767) == -32767)
assert(v.int32_td(42) == 42)
assert(v.int32_td(-42) == -42)
assert(v.int64_td(42) == 42)
assert(v.int64_td(-42) == -42)

assert(v.uint8_td(255) == 255)
assert(v.uint8_td(0) == 0)
assert(v.uint16_td(65535) == 65535)
assert(v.uint16_td(0) == 0)
assert(v.uint32_td(42) == 42)
assert(v.uint32_td(0) == 0)
assert(v.uint64_td(42) == 42)
assert(v.uint64_td(0) == 0)

assert(v.int_fast8_td(127) == 127)
assert(v.int_fast8_td(-128) == -128)
assert(v.int_fast16_td(32767) == 32767)
assert(v.int_fast16_td(-32767) == -32767)
assert(v.int_fast32_td(42) == 42)
assert(v.int_fast32_td(-42) == -42)
assert(v.int_fast64_td(42) == 42)
assert(v.int_fast64_td(-42) == -42)

assert(v.uint_fast8_td(255) == 255)
assert(v.uint_fast8_td(0) == 0)
assert(v.uint_fast16_td(65535) == 65535)
assert(v.uint_fast16_td(0) == 0)
assert(v.uint_fast32_td(42) == 42)
assert(v.uint_fast32_td(0) == 0)
assert(v.uint_fast64_td(42) == 42)
assert(v.uint_fast64_td(0) == 0)

assert(v.int_least8_td(127) == 127)
assert(v.int_least8_td(-128) == -128)
assert(v.int_least16_td(32767) == 32767)
assert(v.int_least16_td(-32767) == -32767)
assert(v.int_least32_td(42) == 42)
assert(v.int_least32_td(-42) == -42)
assert(v.int_least64_td(42) == 42)
assert(v.int_least64_td(-42) == -42)

assert(v.uint_least8_td(255) == 255)
assert(v.uint_least8_td(0) == 0)
assert(v.uint_least16_td(65535) == 65535)
assert(v.uint_least16_td(0) == 0)
assert(v.uint_least32_td(42) == 42)
assert(v.uint_least32_td(0) == 0)
assert(v.uint_least64_td(42) == 42)
assert(v.uint_least64_td(0) == 0)

local stdi = v.StdI()
stdi.int8_member = -128
stdi.int16_member = -32767
stdi.int32_member = -2147483648
stdi.int64_member = -9e+18
stdi.uint8_member = 255
stdi.uint16_member = 65535
stdi.uint32_member = 4294967295
stdi.uint64_member = 18e+18
assert(stdi.int8_member == -128)
assert(stdi.int16_member == -32767)
assert(stdi.int32_member == -2147483648)
assert(stdi.int64_member == -9e+18)
assert(stdi.uint8_member == 255)
assert(stdi.uint16_member == 65535)
assert(stdi.uint32_member == 4294967295)
assert(stdi.uint64_member == 18e+18)

local stdif = v.StdIf()
stdif.int_fast8_member = -128
stdif.int_fast16_member = -32767
stdif.int_fast32_member = -2147483648
stdif.int_fast64_member = -9e+18
stdif.uint_fast8_member = 255
stdif.uint_fast16_member = 65535
stdif.uint_fast32_member = 4294967295
stdif.uint_fast64_member = 18e+18
assert(stdif.int_fast8_member == -128)
assert(stdif.int_fast16_member == -32767)
assert(stdif.int_fast32_member == -2147483648)
assert(stdif.int_fast64_member == -9e+18)
assert(stdif.uint_fast8_member == 255)
assert(stdif.uint_fast16_member == 65535)
assert(stdif.uint_fast32_member == 4294967295)
assert(stdif.uint_fast64_member == 18e+18)

local stdil = v.StdIl()
stdil.int_least8_member = -128
stdil.int_least16_member = -32767
stdil.int_least32_member = -2147483648
stdil.int_least64_member = -9e+18
stdil.uint_least8_member = 255
stdil.uint_least16_member = 65535
stdil.uint_least32_member = 4294967295
stdil.uint_least64_member = 18e+18
assert(stdil.int_least8_member == -128)
assert(stdil.int_least16_member == -32767)
assert(stdil.int_least32_member == -2147483648)
assert(stdil.int_least64_member == -9e+18)
assert(stdil.uint_least8_member == 255)
assert(stdil.uint_least16_member == 65535)
assert(stdil.uint_least32_member == 4294967295)
assert(stdil.uint_least64_member == 18e+18)
