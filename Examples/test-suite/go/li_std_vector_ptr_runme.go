package main

import . "./li_std_vector_ptr"

func main() {
	ip1 := MakeIntPtr(11)
	ip2 := MakeIntPtr(22)
	vi := NewIntPtrVector()
	vi.Add(ip1)
	vi.Add(ip2)
	DisplayVector(vi)
}
