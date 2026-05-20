import li_std_map_enum


def check(a, b):
    if (a != b):
        raise RuntimeError("Not equal: ", a, b)


me = li_std_map_enum.MapEnum()

# Test __setitem__ and __getitem__
me.nums[li_std_map_enum.MapEnum.ten] = 100
me.nums[li_std_map_enum.MapEnum.twenty] = 200
me.nums[li_std_map_enum.MapEnum.thirty] = 300

check(me.nums[li_std_map_enum.MapEnum.ten], 100)
check(me.nums[li_std_map_enum.MapEnum.twenty], 200)
check(me.nums[li_std_map_enum.MapEnum.thirty], 300)

# Test has_key and erase
check(me.nums.has_key(li_std_map_enum.MapEnum.ten), True)
me.nums.erase(li_std_map_enum.MapEnum.ten)
check(me.nums.has_key(li_std_map_enum.MapEnum.ten), False)

# Test non-overloaded methods still work
check(me.nums.count(li_std_map_enum.MapEnum.twenty), 1)
check(me.nums.count(li_std_map_enum.MapEnum.ten), 0)
