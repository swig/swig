package main

import (
  "fmt"
  "swigtests/cpp11_std_array"
)

func CompareContainers(actual cpp11_std_array.ArrayInt6, expected [6]int) error {
  if int(actual.Size()) != len(expected) {
    return fmt.Errorf("Sizes are different: %d %d", actual.Size(), len(expected))
  }
  for i := 0; i < int(actual.Size()); i++ {
    actualValue := actual.Get(i)
    expectedValue := expected[i]
    if actualValue != expectedValue {
      return fmt.Errorf("Value is wrong for element %d. Expected %d got: %d", i, expectedValue, actualValue)
    }
  }
  if actual.IsEmpty() {
	  return fmt.Errorf("ai should not be empty")
  }
  return nil
}

func main() {
  ai := cpp11_std_array.NewArrayInt6()
  ps := [6]int{0, 0, 0, 0, 0, 0}
  CompareContainers(ai, ps)

  vals := [6]int{10, 20, 30, 40, 50, 60}
  for i := 0; i < len(vals); i++ {
    ai.Set(i, vals[i])
  }
  CompareContainers(ai, vals);

  // Check return
  vals = [6]int{-2, -1, 0, 0, 1, 2}
  CompareContainers(cpp11_std_array.ArrayOutVal(), vals);
  CompareContainers(cpp11_std_array.ArrayOutConstRef(), vals);
  CompareContainers(cpp11_std_array.ArrayOutRef(), vals);
  CompareContainers(cpp11_std_array.ArrayOutPtr(), vals);

  // Check passing arguments
  vals = [6]int{9, 8, 7, 6, 5, 4}
  valsArrayInt6 := cpp11_std_array.NewArrayInt6()
  for i := 0; i < len(vals); i++ {
    valsArrayInt6.Set(i, vals[i])
  }

  ai = cpp11_std_array.ArrayInVal(valsArrayInt6);
  CompareContainers(ai, vals);

  ai = cpp11_std_array.ArrayInConstRef(valsArrayInt6);
  CompareContainers(ai, vals);

  ai = cpp11_std_array.NewArrayInt6(valsArrayInt6);
  cpp11_std_array.ArrayInRef(ai);
  CompareContainers(ai, vals);

  ai = cpp11_std_array.NewArrayInt6(valsArrayInt6);
  cpp11_std_array.ArrayInPtr(ai);
  CompareContainers(ai, vals);

  // Fill
  ai.Fill(111)
  vals = [6]int{111, 111, 111, 111, 111, 111}
  CompareContainers(ai, vals);
}
