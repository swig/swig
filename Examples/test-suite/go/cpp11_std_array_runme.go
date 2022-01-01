package main

import "fmt"
import . "swigtests/cpp11_std_array"

// func ToArray6(array [6]int) ArrayInt6 {
//   var outputArray ArrayInt6
//   for i := 0; i < 6; i++ {
//     outputArray.Set(i, array[i])
//   }
//   return outputArray
// }

func CompareContainers(actual ArrayInt6, expected []int) error {
  if actual.Size() != len(expected) {
    return fmt.Errorf("Sizes are different: %d %d", actual.size(), len(expected))
  }
  for i := 0; i < actual.Size(); i++ {
	actualValue := actual.Get(i)
	expectedValue := expected[i]
	if actualValue != expectedValue {
	  return fmt.Errorf("Value is wrong for element %d. Expected %d got: %d", i, expectedValue, actualValue)
	}
  }
  if actual.isEmpty() {
	return fmt.Errorf("ai should not be empty")
  }
  return nil
}

func main() {
  ai := NewArrayInt6()
  ps := [6]int{0, 0, 0, 0, 0, 0}
  CompareContainers(ai, ps)

  vals := [6]int{10, 20, 30, 40, 50, 60}
  for i := 0; i < len(vals); i++ {
	ai.Set(i, vals[i])
  }
  CompareContainers(ai, vals);

  // Check return
  vals = [6]int{-2, -1, 0, 0, 1, 2}
  CompareContainers(ArrayOutVal(), vals);
  CompareContainers(ArrayOutConstRef(), vals);
  CompareContainers(ArrayOutRef(), vals);
  CompareContainers(ArrayOutPtr(), vals);

  // Check passing arguments
  vals = [6]int{9, 8, 7, 6, 5, 4}
  valsArrayInt6 := NewArrayInt6()
  for i := 0; i < len(vals); i++ {
	valsArrayInt6.Set(i, vals[i])
  }

  ai = ArrayInVal(valsArrayInt6);
  CompareContainers(ai, vals);

  ai = ArrayInConstRef(valsArrayInt6);
  CompareContainers(ai, vals);

  ai = NewArrayInt6(valsArrayInt6);
  cpp11_std_array.arrayInRef(ai);
  CompareContainers(ai, vals);

  ai = NewArrayInt6(valsArrayInt6);
  cpp11_std_array.arrayInPtr(ai);
  CompareContainers(ai, vals);

  // Fill
  ai.Fill(111)
  vals = [6]int{111, 111, 111, 111, 111, 111}
  CompareContainers(ai, vals);
}