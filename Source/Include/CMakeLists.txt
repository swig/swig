configure_file(swigconfig.h.in swigconfig.h)
target_include_directories(Swig_swig PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        )

# generate swigwarn.swg
file(READ swigwarn.h SWIG_WARN_H)
string(REGEX REPLACE "#define WARN([^ \\t]*)[ \\t]*([0-9]+)" "%define SWIGWARN\\1 \\2 %enddef" SWIG_WARN_SWG ${SWIG_WARN_H})
file(WRITE ${PROJECT_BINARY_DIR}/Lib/swigwarn.swg ${SWIG_WARN_SWG})
