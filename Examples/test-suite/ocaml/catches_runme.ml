open Swig
open Catches

let _  =
  try
    ignore (_test_catches '(1)); assert false
  with Failure s ->
    assert (s = "C++ int exception thrown, value: 1")

  try
    ignore (_test_catches '(2)); assert false
  with Failure s ->
    assert (s = "two")

  try
    ignore (_test_catches '(3)); assert false
  with Failure s ->
    assert (s = "C++ ThreeException const & exception thrown")

  try
    ignore (_test_exception_specification '(1)); assert false
  with Failure s ->
    assert (s = "C++ int exception thrown, value: 1")

  try
    ignore (_test_exception_specification '(2)); assert false
  with Failure s ->
    assert (s = "unknown exception")

  try
    ignore (_test_exception_specification '(3)); assert false
  with Failure s ->
    assert (s = "unknown exception")

  try
    ignore (_test_catches_all '(1)); assert false
  with Failure s ->
    assert (s = "unknown exception")
;;
