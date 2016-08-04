file(GLOB ext_SRC "*.cxx" "*.cpp" "*.c")

include_directories(../../)

HHVM_EXTENSION($testcase ${ext_SRC})
HHVM_SYSTEMLIB($testcase ../ext_$testcase.php)
