# FindHiredis.cmake - Try to find the Hiredis library
# Once done this will define
#
#  HIREDIS_FOUND - System has Hiredis
#  HIREDIS_INCLUDE_DIRS - The Hiredis include directory
#  HIREDIS_LIBRARIES - The libraries needed to use Hiredis
#  HIREDIS_DEFINITIONS - Compiler switches required for using Hiredis

#SET(HIREDIS_DEFINITIONS ${PC_HIREDIS_CFLAGS_OTHER})
FIND_PACKAGE(PkgConfig REQUIRED)
PKG_CHECK_MODULES(HIREDIS REQUIRED NO_CMAKE_ENVIRONMENT_PATH hiredis)

SET(HIREDIS_DEFINITIONS)
FOREACH(FLAG ${HIREDIS_CFLAGS})
  IF(${FLAG} MATCHES "^-D.*")
   LIST(APPEND HIREDIS_DEFINITIONS ${FLAG})
  ENDIF()
ENDFOREACH()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Hiredis DEFAULT_MSG HIREDIS_LIBRARIES HIREDIS_INCLUDE_DIRS HIREDIS_DEFINITIONS)
MARK_AS_ADVANCED(HIREDIS_INCLUDE_DIRS HIREDIS_LIBRARIES HIREDIS_DEFINITIONS)
