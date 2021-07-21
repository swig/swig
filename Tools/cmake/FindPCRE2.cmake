# - Find PCRE2
# Perl Compatible Regular Expressions
# https://www.pcre.org/

# The following variables are set:
# PCRE2_FOUND - System has the PCRE library
# PCRE2_LIBRARIES - The PCRE library file
# PCRE2_INCLUDE_DIRS - The folder with the PCRE headers

find_library(PCRE2_LIBRARY NAMES pcre2 pcre2-8)
find_path(PCRE2_INCLUDE_DIR pcre2.h)

set (PCRE2_LIBRARIES ${PCRE2_LIBRARY})
set (PCRE2_INCLUDE_DIRS ${PCRE2_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PCRE2 DEFAULT_MSG PCRE2_LIBRARIES PCRE2_INCLUDE_DIRS)

mark_as_advanced (
  PCRE2_LIBRARY
  PCRE2_INCLUDE_DIR)
