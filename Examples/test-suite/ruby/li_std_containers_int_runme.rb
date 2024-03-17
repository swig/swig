#!/usr/bin/env ruby

# Check std::vector and std::list behaves the same as Ruby iterable
# types (list)

require 'swig_assert'
require 'li_std_containers_int'

def failed(a, b, msg)
    # to_a() convert to array
    # convert to array, so we can call join().
    # join() join array element to string with a seperator.
    raise RuntimeError, msg+" ["+a.to_a().join(", ")+"] ["+b.to_a().join(", ")+"]"
end

def compare_sequences(a, b)
    # A start, out of range, may produce nil value
    # As long as vector behave as list, we do not care :-)
    if a == nil and b == nil then
        return
    end
    if a.size != b.size then
        failed(a, b, "different sizes")
    end
    a.each_index do |i|
        if a[i] != b[i] then
            failed(a, b, "elements are different")
        end
    end
end

def compare_containers(pythonlist, swigvector, swiglist)
    compare_sequences(pythonlist, swigvector)
    compare_sequences(pythonlist, swiglist)
end

# Check std::vector and std::list assignment behaves same as Ruby list
# assignment including exceptions
def container_insert_step(i, l, newval)
    ps = (1..6).to_a
    iv = Li_std_containers_int::Vector_int.new(ps)
    il = Li_std_containers_int::List_int.new(ps)

    # Ruby slice
    begin
        if l == nil then
            ps[i] = newval
        else
            ps[i,l] = newval
        end
        ps_error = nil
    rescue => e
        ps_error = e
    end

    begin
        if l == nil then
            iv[i] = newval
        else
            iv[i,l] = newval
        end
        iv_error = nil
    rescue => e
        iv_error = e
    end

    begin
        if l == nil then
            il[i] = newval
        else
            il[i,l] = newval
        end
        il_error = nil
    rescue => e
        il_error = e
    end

    if iv_error != nil and il_error == nil then
        raise RuntimeError, "ValueError std::vector<> fails while std::list<> pass: " + iv_error.to_s
    end
    if iv_error == nil and il_error != nil then
        raise RuntimeError, "ValueError std::vector<> pass while std::list<> fail: " + il_error.to_s
    end
    if ps_error != nil and iv_error == nil then
        raise RuntimeError, "ValueError C++ wrapper should fail like ruby: " + ps_error.to_s
    end
    if ps_error != nil and iv_error != nil and il_error != nil then
        compare_containers(ps, iv, il)
    end
end

# Check std::vector and std::list delete behaves same as Ruby list
# delete including exceptions
def container_delete(i, j)
    ps = (1..6).to_a
    iv = Li_std_containers_int::Vector_int.new(ps)
    il = Li_std_containers_int::List_int.new(ps)

    # Ruby slice
    begin
        if j == nil then
            ps[i] = nil
        else
            ps[i,(j - i)] = nil
        end
        ps_error = nil
    rescue => e
        ps_error = e
    end

    # std::vector<int>
    begin
        if j == nil then
            iv[i] = nil
        else
            iv[i,(j - i)] = nil
        end
        iv_error = nil
    rescue => e
        iv_error = e
    end

    # std::list<int>
    begin
        if j == nil then
            il[i] = nil
        else
            il[i,(j - i)] = nil
        end
        il_error = nil
    rescue => e
        il_error = e
    end

    if iv_error != nil and il_error == nil then
        raise RuntimeError, "ValueError std::vector<> fails while std::list<> pass: " + iv_error.to_s
    end
    if iv_error == nil and il_error != nil then
        raise RuntimeError, "ValueError std::vector<> pass while std::list<> fail: " + il_error.to_s
    end
    if ps_error != nil and iv_error == nil then
        raise RuntimeError, "ValueError C++ wrapper should fail like ruby: " + ps_error.to_s
    end
    if ps_error != nil and iv_error != nil and il_error != nil then
        compare_containers(ps, iv, il)
    end
end

ps = [0, 1, 2, 3, 4, 5]
iv = Li_std_containers_int::Vector_int.new(ps)
il = Li_std_containers_int::List_int.new(ps)

# Ruby use array[start, length]
# slices
compare_containers(ps[0,0], iv[0,0], il[0,0])
compare_containers(ps[1,0], iv[1,0], il[1,0])
compare_containers(ps[1,2], iv[1,2], il[1,2])
compare_containers(ps[2,2], iv[2,2], il[2,2])
compare_containers(ps[0,3], iv[0,3], il[0,3])
compare_containers(ps[3,3], iv[3,3], il[3,3])
compare_containers(ps[3,7], iv[3,7], il[3,7]) # beyond end of range

# before beginning of range (negative indexing)
compare_containers(ps[-1,6], iv[-1,6], il[-1,6])
compare_containers(ps[-2,6], iv[-2,6], il[-2,6])
compare_containers(ps[-5,6], iv[-5,6], il[-5,6])
compare_containers(ps[-6,6], iv[-6,6], il[-6,6])

# before beginning of range (negative indexing, negative index is >
# container size)
compare_containers(ps[-7,7], iv[-7,7], il[-7,7])
compare_containers(ps[-100,7], iv[-100,7], il[-100,7])

compare_containers(ps[3,9], iv[3,9], il[3,9])
compare_containers(ps[0,3], iv[0,3], il[0,3])
compare_containers(ps, iv, il)
compare_containers(ps[-3,9], iv[-3,9], il[-3,9])
compare_containers(ps[-6,9], iv[-6,9], il[-6,9])

# insert sequences (growing, shrinking and staying same size)
(-6..6).step do |start|
    # single element set/replace
    container_insert_step(start, nil, 111)
    (0..6).step do |len|
        container_insert_step(start, len, [111, 222, 333, 444, 555, 666, 777])
        container_insert_step(start, len, [111, 222, 333, 444, 555, 666])
        container_insert_step(start, len, [111, 222, 333, 444, 555])
        container_insert_step(start, len, [111, 222, 333, 444])
        container_insert_step(start, len, [111, 222, 333])
        container_insert_step(start, len, [111, 222])
        container_insert_step(start, len, [111])
        container_insert_step(start, len, [])
    end
end

# delete sequences (growing, shrinking and staying same size)
for start in [-102, -100, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 100, 102]
    # single element delete
    container_delete(start, nil)
    for vend in [-102, -100, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 100, 102]
        container_delete(start, vend)
    end
end
