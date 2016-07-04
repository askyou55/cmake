IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  SET(OS_LINUX ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_LINUX -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  SET(OS_MACOSX ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_MACOSX -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  SET(OS_WINDOWS ON)
  SET(OS_WIN ON)
  ADD_DEFINITIONS(-D_WIN32 -DOS_WIN -DOS_WINDOWS)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  SET(OS_FREEBSD ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_FREEBSD -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  SET(OS_ANDROID ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_ANDROID -DOS_POSIX -DANDROID -DJabber)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "BlackBerry")
  SET(OS_BLACKBERRY ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_BLACKBERRY -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  SET(OS_IOS ON)
  SET(OS_POSIX ON)
  ADD_DEFINITIONS(-DOS_IOS -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "WindowsPhone")
  SET(OS_WINPHONE ON)
  ADD_DEFINITIONS(-DOS_WINPHONE -D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NON_CONFORMING_SWPRINTFS -D_XKEYCHECK_H -DGOOGLE_PROTOBUF_NO_THREAD_SAFETY -D_SCL_SECURE_NO_WARNINGS)
ELSE()
  MESSAGE(FATAL_ERROR "Not supported OS: ${CMAKE_SYSTEM_NAME}")
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

IF(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  SET(CMAKE_COMPILER_IS_CLANGCXX 1)
ENDIF(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")

IF(CMAKE_COMPILER_IS_CLANGCXX)
  ADD_DEFINITIONS(-DCOMPILER_CLANG)
ELSEIF(CMAKE_COMPILER_IS_GNUCXX)
  ADD_DEFINITIONS(-DCOMPILER_GCC)
  IF(MINGW)
    ADD_DEFINITIONS(-DCOMPILER_MINGW)
  ENDIF(MINGW)
ELSEIF(${CMAKE_CXX_COMPILER_ID} STREQUAL Intel)
  ADD_DEFINITIONS(-DCOMPILER_INTEL)
ELSEIF(${CMAKE_CXX_COMPILER_ID} STREQUAL MSVC)
  ADD_DEFINITIONS(-DCOMPILER_MSVC -DCOMPILER_MICROSOFT)
ELSE()
  MESSAGE(FATAL_ERROR "Not supported compiler id: ${CMAKE_CXX_COMPILER_ID}")
ENDIF(CMAKE_COMPILER_IS_CLANGCXX)

IF(USE_CXX_STANDART)
  ADD_DEFINITIONS(-DHAVE_CXX_STANDART)
  IF(NOT MSVC)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  ENDIF(NOT MSVC)

  IF(CMAKE_COMPILER_IS_CLANGCXX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")
  ENDIF(CMAKE_COMPILER_IS_CLANGCXX)
ENDIF(USE_CXX_STANDART)

FIND_PACKAGE(Threads)

#  CMAKE_THREAD_LIBS_INIT     - the thread library
#  CMAKE_USE_SPROC_INIT       - are we using sproc?
#  CMAKE_USE_WIN32_THREADS_INIT - using WIN32 threads?
#  CMAKE_USE_PTHREADS_INIT    - are we using pthreads
#  CMAKE_HP_PTHREADS_INIT     - are we using hp pthreads

IF(CMAKE_USE_PTHREADS_INIT)
  SET(USE_PTHREAD ON)
  ADD_DEFINITIONS(-DHAVE_PTHREAD)
ELSEIF(CMAKE_USE_WIN32_THREADS_INIT)
  SET(USE_WINTHREAD ON)
  ADD_DEFINITIONS(-DHAVE_WINTHREAD)
ENDIF(CMAKE_USE_PTHREADS_INIT)

MESSAGE(STATUS "CMAKE_USE_PTHREADS_INIT : ${CMAKE_USE_PTHREADS_INIT}")

MESSAGE(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
MESSAGE(STATUS "CMAKE_SYSTEM: ${CMAKE_SYSTEM}")
MESSAGE(STATUS "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")

IF (CMAKE_BUILD_TYPE)
  STRING(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_STABLE)
  MESSAGE(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE_STABLE}")
ENDIF(CMAKE_BUILD_TYPE)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/")
IF(NOT CMAKE_DEBUG_POSTFIX)
  SET(CMAKE_DEBUG_POSTFIX d)
ENDIF(NOT CMAKE_DEBUG_POSTFIX)
INCLUDE(projecthelper)
INCLUDE(utils)

FIND_PACKAGE(ZLIB)
IF(ZLIB_FOUND)
  ADD_DEFINITIONS(-DHAVE_ZLIB)
ENDIF(ZLIB_FOUND)

IF(BOOST_ENABLED)
  ADD_DEFINITIONS(-DBOOST_ENABLED)
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/integrate-boost.cmake)
  SET(Boost_USE_MULTITHREADED ON)
  SET(Boost_USE_STATIC_LIBS ON)
ENDIF(BOOST_ENABLED)

IF(PYTHON_ENABLED)
  ADD_DEFINITIONS(-DPYTHON_ENABLED)
ENDIF(PYTHON_ENABLED)

IF(QT_ENABLED)
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/integrate-qt.cmake)
  ADD_DEFINITIONS(-DQT_ENABLED)
ENDIF(QT_ENABLED)

IF(IPV6_ENABLED)
  ADD_DEFINITIONS(-DIPV6_ENABLED)
ENDIF(IPV6_ENABLED)

IF(DEVELOPER_ENABLE_TESTS)
  INCLUDE(testing)
  SETUP_TESTING()
ENDIF(DEVELOPER_ENABLE_TESTS)

IF(CHECK_STYLE)
  SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
ENDIF(CHECK_STYLE)

MACRO(ADD_APP_EXECUTABLE PROJ_NAME SOURCES LIBS)
  SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)

  SET(TARGET ${PROJ_NAME})
  ADD_EXECUTABLE(${TARGET} ${DESKTOP_TARGET} ${SOURCES})
  TARGET_LINK_LIBRARIES(${TARGET} ${LIBS})
ENDMACRO(ADD_APP_EXECUTABLE PROJ_NAME SOURCES LIBS)

MACRO(ADD_APP_STATIC_LIBRARY LIB_NAME SOURCES LIBS)
  SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)

  SET(TARGET_LIB ${LIB_NAME})
  ADD_LIBRARY(${TARGET_LIB} STATIC ${SOURCES})
  TARGET_LINK_LIBRARIES(${TARGET_LIB} ${LIBS})
ENDMACRO(ADD_APP_STATIC_LIBRARY LIB_NAME SOURCES LIBS)

MACRO(ADD_APP_SHARED_LIBRARY LIB_NAME SOURCES LIBS)
  SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)

  SET(TARGET_LIB ${LIB_NAME})
  ADD_LIBRARY(${TARGET_LIB} SHARED ${SOURCES})
  TARGET_LINK_LIBRARIES(${TARGET_LIB} ${LIBS})
ENDMACRO(ADD_APP_SHARED_LIBRARY LIB_NAME SOURCES LIBS)

MACRO(ADD_APP_LIBRARY_OBJECT LIB_NAME SOURCES LIBS LIB_OBJECTS)
  SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)

  SET(TARGET_LIB ${LIB_NAME})
  ADD_LIBRARY(${TARGET_LIB} STATIC ${SOURCES} ${LIB_OBJECTS})
  TARGET_LINK_LIBRARIES(${TARGET_LIB} ${LIBS})
ENDMACRO(ADD_APP_LIBRARY_OBJECT LIB_NAME SOURCES LIBS LIB_OBJECTS)
MESSAGE(STATUS "=============== Configuration loaded! ===============")
