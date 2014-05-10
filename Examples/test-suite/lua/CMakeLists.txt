find_package ( Lua51 )
find_program ( LUA_EXECUTABLE NAMES lua )

if (LUA51_FOUND AND LUA_EXECUTABLE)

  set ( lua_test_environment 
        "LUA_PATH=${CMAKE_CURRENT_SOURCE_DIR}/?.lua"
        "LUA_CPATH=${CMAKE_CURRENT_BINARY_DIR}/?.so"
      )

  include_directories(${LUA_INCLUDE_DIR})
  test_language(lua ".lua" ${LUA_EXECUTABLE})
endif ()