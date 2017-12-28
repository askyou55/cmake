# FindCommon.cmake - Try to find the common library
# Once done this will define
#
#  COMMON_FOUND - System has common
#  COMMON_INCLUDE_DIRS - The common include directory
#  COMMON_LIBRARIES - The libraries needed to use common
#  COMMON_VERSION_STRING - the version of BZip2 found (since CMake 2.8.8)

FIND_PATH(COMMON_INCLUDE_DIRS NAMES common/macros.h
 HINTS /usr /usr/local /opt PATH_SUFFIXES include
)

FIND_LIBRARY(COMMON_BASE_LIBRARY NAMES common
 HINTS /usr /usr/local /opt
)

FIND_LIBRARY(COMMON_QT_LIBRARY NAMES common_qt
 HINTS /usr /usr/local /opt
)

FIND_LIBRARY(COMMON_EV_LIBRARY NAMES common_ev
 HINTS /usr /usr/local /opt
)

SET(COMMON_LIBRARIES ${COMMON_LIBRARIES} ${COMMON_BASE_LIBRARY})

IF(COMMON_QT_LIBRARY)
  SET(COMMON_LIBRARIES ${COMMON_LIBRARIES} ${COMMON_QT_LIBRARY})
ENDIF(COMMON_QT_LIBRARY)

IF(COMMON_EV_LIBRARY)
  FIND_PACKAGE(LibEv REQUIRED)
  SET(COMMON_EV_LIBRARIES ${COMMON_EV_LIBRARY} ${LIBEV_LIBRARIES})
  SET(COMMON_LIBRARIES ${COMMON_LIBRARIES} ${COMMON_EV_LIBRARIES})
ENDIF(COMMON_EV_LIBRARY)

IF(COMMON_INCLUDE_DIRS AND EXISTS "${COMMON_INCLUDE_DIRS}/common/config.h")
  FILE(STRINGS "${COMMON_INCLUDE_DIRS}/common/config.h" COMMON_CONFIG_H REGEX "^#define COMMON_VERSION_STRING \"[^\"]*\"$")
  STRING(REGEX REPLACE "^.*COMMON_VERSION_STRING \"(.*)\"" "\\1" COMMON_VERSION_STRING "${COMMON_CONFIG_H}")
ENDIF(COMMON_INCLUDE_DIRS AND EXISTS "${COMMON_INCLUDE_DIRS}/common/config.h")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(common REQUIRED_VARS COMMON_LIBRARIES COMMON_INCLUDE_DIRS VERSION_VAR COMMON_VERSION_STRING)
MARK_AS_ADVANCED(COMMON_INCLUDE_DIRS COMMON_LIBRARIES)

