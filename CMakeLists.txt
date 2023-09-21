cmake_minimum_required(VERSION 3.15)
# CMake version compatibility
# TODO: Remove when cmake 3.25 is commonly distributed
if (POLICY CMP0140)
	cmake_policy(SET CMP0140 NEW)
endif ()
# TODO: Remove when cmake 3.20 is commonly distributed
if (POLICY CMP0118)
	cmake_policy(SET CMP0118 NEW)
endif ()

#[==============================================================================================[
#                                    Basic project definition                                   #
]==============================================================================================]


file(STRINGS configure.ac line LIMIT_COUNT 1 REGEX "AC_INIT\\(.*\\)")
if (line MATCHES "AC_INIT\\(\\[(.*)\\],[ \t]*\\[(.*)\\],[ \t]*\\[(.*)\\]\\)")
	set(PROJECT_VERSION ${CMAKE_MATCH_2})
	set(PROJECT_HOMEPAGE_URL ${CMAKE_MATCH_3})
else ()
	message(SEND_ERROR "Could not parse version from configure.ac")
endif ()

project(Swig
		VERSION ${PROJECT_VERSION}
		HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL}
		LANGUAGES C CXX)

# Back-porting to PROJECT_IS_TOP_LEVEL to older cmake
# TODO: Remove when requiring cmake >= 3.21
if (NOT DEFINED Swig_IS_TOP_LEVEL)
	if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
		set(PROJECT_IS_TOP_LEVEL ON)
	else ()
		set(PROJECT_IS_TOP_LEVEL OFF)
	endif ()
endif ()

# TODO: Set appropriate standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
#set(CMAKE_CXX_STANDARD 11)
#set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_CXX_EXTENSIONS ON)

if (NOT DEFINED CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif ()

#[==============================================================================================[
#                                            Options                                            #
]==============================================================================================]

option(SWIG_PCRE "Swig: Enable PCRE" ON)
option(SWIG_TESTS "Swig: Build unit tests" ${PROJECT_IS_TOP_LEVEL})
option(SWIG_SHARED_LIBS "Swig: Build as a shared library" ${PROJECT_IS_TOP_LEVEL})
option(SWIG_INSTALL "Swig: Install project" ${PROJECT_IS_TOP_LEVEL})
option(SWIG_TEST_COVERAGE "Swig: Test with coverage" OFF)
mark_as_advanced(SWIG_TEST_COVERAGE)

#[==============================================================================================[
#                                     Project configuration                                     #
]==============================================================================================]

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

include(MimickAutotools)
include(FetchContent)


if (SWIG_INSTALL)
	include(GNUInstallDirs)
	include(CMakePackageConfigHelpers)
	if (WIN32)
		set(SWIG_LIB bin/Lib)
	else ()
		set(SWIG_LIB ${CMAKE_INSTALL_DATADIR}/swig/${Swig_VERSION})
	endif ()
endif ()

#[==============================================================================================[
#                                       External packages                                       #
]==============================================================================================]

# Include third-party libraries
set(swig_dependencies "")
find_package(BISON REQUIRED)
if (SWIG_PCRE)
	find_package(PCRE2 REQUIRED)
	set(HAVE_PCRE 1)
	include_directories(${PCRE2_INCLUDE_DIRS})
endif ()
FetchContent_MakeAvailable(${swig_dependencies})

#[==============================================================================================[
#                                        Main definition                                        #
]==============================================================================================]

# Main targets
add_executable(Swig_swig)
set_target_properties(Swig_swig PROPERTIES
		OUTPUT_NAME swig
		EXPORT_NAME swig)

# Actual definitions
add_subdirectory(Source)

# Note: bug https://discourse.cmake.org/t/bug-with-generated-file-and-target-sources-private/5262
# https://gitlab.kitware.com/cmake/cmake/-/issues/18399
if (CMAKE_VERSION VERSION_LESS 3.20)
	set_property(SOURCE ${CMAKE_CURRENT_BINARY_DIR}/Source/CParse/parser.c PROPERTY GENERATED 1)
endif ()

add_subdirectory(Lib)

if (SWIG_TESTS)
	enable_testing()
	add_subdirectory(Examples)
endif ()

#[==============================================================================================[
#                                       Install or Export                                       #
]==============================================================================================]

# Installation
if (SWIG_INSTALL)
	write_basic_package_version_file(
			${CMAKE_CURRENT_BINARY_DIR}/SwigConfigVersion.cmake
			VERSION ${PROJECT_VERSION}
			COMPATIBILITY SameMajorVersion)
	configure_package_config_file(
			cmake/SwigConfig.cmake.in
			SwigConfig.cmake
			INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Swig)
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SwigConfigVersion.cmake
			${CMAKE_CURRENT_BINARY_DIR}/SwigConfig.cmake
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Swig
			COMPONENT Swig_Development)
	install(EXPORT SwigTargets
			FILE SwigTargets.cmake
			NAMESPACE Swig::
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Swig
			COMPONENT Swig_Development)
	export(EXPORT SwigTargets
			FILE SwigTargets.cmake
			NAMESPACE Swig::)
endif ()

# Make project available for FetchContent
if (NOT PROJECT_IS_TOP_LEVEL)
	# Set variables for FetchContent
	# All variables have to be consistent with SwigConfig.cmake

	# Propagate variables
	if (CMAKE_VERSION VERSION_LESS 3.25)
		# TODO: Remove when cmake 3.25 is commonly distributed
		set(Swig_VERSION ${Swig_VERSION} PARENT_SCOPE)
		set(Swig_VERSION_MAJOR ${Swig_VERSION_MAJOR} PARENT_SCOPE)
		set(Swig_VERSION_MINOR ${Swig_VERSION_MINOR} PARENT_SCOPE)
		set(Swig_VERSION_PATCH ${Swig_VERSION_PATCH} PARENT_SCOPE)
		set(Swig_VERSION_TWEAK ${Swig_VERSION_TWEAK} PARENT_SCOPE)
	else ()
		return(PROPAGATE
				Swig_VERSION
				Swig_VERSION_MAJOR
				Swig_VERSION_MINOR
				Swig_VERSION_PATCH
				Swig_VERSION_TWEAK
		)
	endif ()
endif ()
