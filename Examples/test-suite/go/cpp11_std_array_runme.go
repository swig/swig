package main

import "fmt"
import "swigtests/cpp11_std_array"

func ToArray6(array [6]int) cpp11_std_array.ArrayInt6 {
  var outputArray cpp11_std_array.ArrayInt6
  for i := 0; i < 6; i++ {
    outputArray.set(i, array[i])
  }
  return outputArray
}

func CompareContainers(actual cpp11_std_array.ArrayInt6, expected []int) error {
  if actual.size() != len(expected) {
    return fmt.Errorf("Sizes are different: %d %d", actual.size(), len(expected))
  }
  for i := 0; i < actual.size(); i++ {
	actualValue := actual.get(i)
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
  ai := cpp11_std_array.ArrayInt6()
  ps := [6]int{0, 0, 0, 0, 0, 0}
  CompareContainers(ai, ps)

  vals := [6]int{10, 20, 30, 40, 50, 60}
  for i := 0; i < len(vals); i++ {
	ai.set(i, vals[i])
  }
  CompareContainers(ai, vals);

  // Check return
  vals = [6]int{-2, -1, 0, 0, 1, 2}
  CompareContainers(cpp11_std_array.arrayOutVal(), vals);
  CompareContainers(cpp11_std_array.arrayOutConstRef(), vals);
  CompareContainers(cpp11_std_array.arrayOutRef(), vals);
  CompareContainers(cpp11_std_array.arrayOutPtr(), vals);

  // Check passing arguments
  vals = [6]int{9, 8, 7, 6, 5, 4}

  ai = cpp11_std_array.arrayInVal(ToArray6(vals));
  CompareContainers(ai, vals);

  ai = cpp11_std_array.arrayInConstRef(ToArray6(vals));
  CompareContainers(ai, vals);

  ai = cpp11_std_array.ArrayInt6(ToArray6(vals));
  cpp11_std_array.arrayInRef(ai);
  CompareContainers(ai, vals);

  ai = cpp11_std_array.ArrayInt6(ToArray6(vals));
  cpp11_std_array.arrayInPtr(ai);
  CompareContainers(ai, vals);

  // fill
  ai.fill(111)
  vals = [6]int{111, 111, 111, 111, 111, 111}
  compareContainers(ai, vals);
}