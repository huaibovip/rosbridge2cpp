# Thanks to https://github.com/dmonopoly/gtest-cmake-example/blob/master/CMakeLists.txt
# for providing a basic SETup to use gtest in a cmake PROJECT
# Another solution would make use of ExternalProject_Add to downloads and installs
# googletest in the build/ dir:
# http://stackoverflow.com/questions/9689183/cmake-googletest/9695234#9695234
# However, this requires an active internet connection

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
OPTION(test "Build all tests." OFF) # Makes boolean 'test' available.

PROJECT(rosbridge2cpp)

SET(CMAKE_BUILD_TYPE "Release")
SET(CMAKE_CXX_FLAGS "-g -Wall")
ADD_DEFINITIONS(-DRAPIDJSON_HAS_STDSTRING=1)

IF(WIN32)
	ADD_DEFINITIONS(-std=c++11)
	SET(libbson-1.0_DIR "D:/ProgramData/vcpkg/packages/libbson_x86-windows/share/libbson-1.0")
	FIND_PACKAGE(libbson-1.0)
	SET(CMAKE_C_FLAGS "ws2_32.lib")
	OPTION(WINDOWS "WINDOWS_PLATFORM" ON)
ELSEIF(UNIX)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pthread")
	# FIND_PACKAGE(PkgConfig REQUIRED)
	# PKG_SEARCH_MODULE(BSON REQUIRED libbson-1.0)
ENDIF ()
# MESSAGE(STATUS ${BSON_INCLUDE_DIRS})

CONFIGURE_FILE (
		"${PROJECT_SOURCE_DIR}/include/client/socket_tcp_connection.h.in"
		"${PROJECT_SOURCE_DIR}/include/client/socket_tcp_connection.h"
)

add_subdirectory(libbson-1.5.3 BSON)

# ADD_DEFINITIONS(${BSON_CFLAGS_OTHER})
SET(LIBS ${LIBS})# ${BSON_LIBRARIES})

INCLUDE_DIRECTORIES(include 
${PROJECT_SOURCE_DIR}/libbson-1.5.3/src/bson 
${PROJECT_SOURCE_DIR}/libbson-1.5.3/src
${PROJECT_BINARY_DIR}/BSON/src/bson)# ${BSON_INCLUDE_DIRS})

ADD_EXECUTABLE( rosbridge2cpp-client
	src/client/client.cpp 
	src/client/socket_tcp_connection.cpp 
	src/ros_bridge.cpp 
	src/ros_topic.cpp 
	src/ros_service.cpp 
	src/ros_tf_broadcaster.cpp 
)

ADD_LIBRARY( rosbridge2cpp SHARED
	src/client/socket_tcp_connection.cpp 
	src/ros_bridge.cpp 
	src/ros_topic.cpp 
	src/ros_service.cpp 
	src/ros_tf_broadcaster.cpp
)

IF(WIN32)
	TARGET_LINK_LIBRARIES(rosbridge2cpp-client ${BSON_LIBRARIES} ws2_32)
	TARGET_LINK_LIBRARIES(rosbridge2cpp ${BSON_LIBRARIES} ws2_32)
ELSEIF(UNIX)
	TARGET_LINK_LIBRARIES(rosbridge2cpp-client bson_shared)# ${BSON_LIBRARIES})
	TARGET_LINK_LIBRARIES(rosbridge2cpp bson_shared)# ${BSON_LIBRARIES})
ENDIF()

#######################################################
## Install
#######################################################
SET(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

install (TARGETS rosbridge2cpp-client
		DESTINATION bin)

install (TARGETS rosbridge2cpp 
		LIBRARY DESTINATION lib)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/
		DESTINATION include)

#install (FILES cmake-examples.conf
#		DESTINATION etc)



#################################
## Testing
#################################
#if (test)
#	# This adds another subdirectory, which has 'PROJECT(gtest)'.
#	add_subdirectory(lib/googletest/googletest)
#
#	enable_testing()
#
#	# Include the gtest library. gtest_SOURCE_DIR is available due to
#	# 'PROJECT(gtest)' above.
#	include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})
#
#	##############
#	# Unit Tests
#	##############
#	add_executable(runUnitTests tests/tests.cpp)
#
#	# Standard linking to gtest stuff.
#	TARGET_LINK_LIBRARIES(runUnitTests gtest gtest_main rosbridge2cpp)
#
#	# Extra linking for the PROJECT.
#	#TARGET_LINK_LIBRARIES(runUnitTests PROJECT1_lib)
#
#	# This is so you can do 'make test' to see all your tests run, instead of
#	# manually running the executable runUnitTests to see those specific tests.
#  #add_test(NAME that-test-I-made COMMAND runUnitTests)
#
#	# You can also omit NAME and COMMAND. The second argument could be some other
#	# test executable.
#	add_test(that-other-test-I-made runUnitTests)
#endif()
