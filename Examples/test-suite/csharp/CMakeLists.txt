find_program ( MCS_EXECUTABLE NAMES mcs )
if (MCS_EXECUTABLE)
  test_language(csharp ".cs" ${MCS_EXECUTABLE})
endif ()