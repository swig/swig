
find_package ( JNI )
find_package ( JAVA )

if (JNI_FOUND AND Java_FOUND)

  include_directories ( ${JNI_INCLUDE_DIRS} )
  
  test_language(java ".java" ${Java_JAVA_EXECUTABLE} )
  
  
  
  
endif ()