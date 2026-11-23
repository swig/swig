from swig_test_utils import swig_check

import li_std_map_enum

me = li_std_map_enum.MapEnum()

# Test __setitem__ and __getitem__
me.nums[li_std_map_enum.MapEnum.ten] = 100
me.nums[li_std_map_enum.MapEnum.twenty] = 200
me.nums[li_std_map_enum.MapEnum.thirty] = 300

swig_check(me.nums[li_std_map_enum.MapEnum.ten], 100)
swig_check(me.nums[li_std_map_enum.MapEnum.twenty], 200)
swig_check(me.nums[li_std_map_enum.MapEnum.thirty], 300)

# Test has_key and erase
swig_check(me.nums.has_key(li_std_map_enum.MapEnum.ten), True)
me.nums.erase(li_std_map_enum.MapEnum.ten)
swig_check(me.nums.has_key(li_std_map_enum.MapEnum.ten), False)

# Test non-overloaded methods still work
swig_check(me.nums.count(li_std_map_enum.MapEnum.twenty), 1)
swig_check(me.nums.count(li_std_map_enum.MapEnum.ten), 0)
