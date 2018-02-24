FUNCTION(VERSION_TO_2DIGIT_HEX DEC HEX)
  ### Loop until decimal
  WHILE(DEC GREATER 0)
    ### Nibble is the reminder of the division by 16
    MATH(EXPR NIBBLE "${DEC} % 16")
    ### New decimal is the division by 16
    MATH(EXPR DEC "${DEC} / 16")
    ### Convert ABCDEF
    IF(NIBBLE EQUAL 10)
      SET(RES "A${RES}")
    ELSEIF(NIBBLE EQUAL 11)
      SET(RES "B${RES}")
    ELSEIF(NIBBLE EQUAL 12)
      SET(RES "C${RES}")
    ELSEIF(NIBBLE EQUAL 13)
      SET(RES "D${RES}")
    ELSEIF(NIBBLE EQUAL 14)
      SET(RES "E${RES}")
    ELSEIF(NIBBLE EQUAL 15)
      SET(RES "F${RES}")
    ELSE()
      SET(RES "${NIBBLE}${RES}")
    ENDIF()
  ENDWHILE()
  IF(NOT RES)
    SET(RES "0")
  ENDIF(NOT RES)
  SET(${HEX} "0${RES}" PARENT_SCOPE)
ENDFUNCTION()

MACRO(SET_DESKTOP_TARGET)
  # Set default target to build (under win32 its allows console debug)
  IF(WIN32)
    SET(DESKTOP_TARGET WIN32)
  ELSEIF(APPLE)
    SET(DESKTOP_TARGET MACOSX_BUNDLE)
  ENDIF(WIN32)
ENDMACRO(SET_DESKTOP_TARGET)

FUNCTION(PROJECT_GET_GIT_VERSION PROJECT_GIT_VER)
  EXECUTE_PROCESS(COMMAND git rev-parse --short HEAD
                  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                  OUTPUT_VARIABLE PROJECT_GIT_TEMP_VERSION)
  STRING(REGEX REPLACE "(\r?\n)+$" "" PROJECT_GIT_TEMP_VERSION "${PROJECT_GIT_TEMP_VERSION}")
  MESSAGE(STATUS "${PROJECT_NAME} git version: ${PROJECT_GIT_TEMP_VERSION}")
  SET(${PROJECT_GIT_VER} ${PROJECT_GIT_TEMP_VERSION} PARENT_SCOPE)
ENDFUNCTION()

MACRO(DEFINE_DEFAULT_DEFINITIONS ENABLE_RTTI WERROR)
  SET(USE_RTTI ${ENABLE_RTTI})
  SET(USE_WERROR ${WERROR})
  ADD_DEFINITIONS(-DFASTO -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS)
  IF(WIN32)
    ADD_DEFINITIONS(
      -DNOMINMAX # do not define min() and max()
      -D_CRT_SECURE_NO_WARNINGS
      -D_CRT_NONSTDC_NO_WARNINGS
      -D_CRT_SECURE_NO_WARNINGS
      #-DWIN32_LEAN_AND_MEAN # remove obsolete things from windows headers
    )
  ENDIF(WIN32)

  IF(MSVC)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Zi")
  ENDIF(MSVC)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables")
  IF(NOT USE_RTTI)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
  ENDIF(NOT USE_RTTI)
  IF(USE_WERROR)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
  ENDIF(USE_WERROR)
  # -fvisibility-inlines-hidden -fno-threadsafe-statics -fno-rtti
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic -Wswitch-enum") # -Wconversion -Wunreachable-code-return
  IF(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.1)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wsuggest-override")
  ENDIF(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.1)
ENDMACRO(DEFINE_DEFAULT_DEFINITIONS)

MACRO(DEFINE_PROJECT_DEFINITIONS)

PROJECT_GET_GIT_VERSION(PROJECT_VERSION_GIT)
MATH(EXPR PROJECT_VERSION_NUMBER "(${PROJECT_VERSION_MAJOR}<<24)|(${PROJECT_VERSION_MINOR}<<16)|(${PROJECT_VERSION_PATCH}<<8)|(${PROJECT_VERSION_TWEAK})")

# PROJECT_NAME
# PROJECT_NAME_TITLE
# PROJECT_COPYRIGHT
# PROJECT_DOMAIN
# PROJECT_COMPANYNAME
# PROJECT_COMPANYNAME_DOMAIN
# PROJECT_VERSION
# PROJECT_NAME_LOWERCASE
# PROJECT_NAME_UPPERRCASE
# PROJECT_VERSION_GIT
# PROJECT_VERSION_MAJOR
# PROJECT_VERSION_MINOR
# PROJECT_VERSION_PATCH
# PROJECT_VERSION_TWEAK
# PROJECT_VERSION_NUMBER
# PROJECT_BUILD_TYPE_VERSION

ADD_DEFINITIONS(
  -DPROJECT_NAME="${PROJECT_NAME}"
  -DWCHAR_PROJECT_NAME="${PROJECT_NAME}"
  -DPROJECT_NAME_TITLE="${PROJECT_NAME_TITLE}"
  -DPROJECT_COPYRIGHT="${PROJECT_COPYRIGHT}"
  -DPROJECT_DOMAIN="${PROJECT_DOMAIN}"
  -DPROJECT_COMPANYNAME="${PROJECT_COMPANYNAME}"
  -DPROJECT_COMPANYNAME_DOMAIN="${PROJECT_COMPANYNAME_DOMAIN}"
  -DPROJECT_VERSION="${PROJECT_VERSION}"
  -DPROJECT_NAME_LOWERCASE="${PROJECT_NAME_LOWERCASE}"
  -DPROJECT_NAME_UPPERRCASE="${PROJECT_NAME_UPPERRCASE}"
  -DPROJECT_VERSION_GIT="${PROJECT_VERSION_GIT}"
  -D${PROJECT_NAME_UPPERRCASE}
  -DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
  -DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}
  -DPROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}
  -DPROJECT_VERSION_TWEAK=${PROJECT_VERSION_TWEAK}
  -DPROJECT_VERSION_NUMBER=${PROJECT_VERSION_NUMBER}
  -DPROJECT_BUILD_TYPE_VERSION="${PROJECT_BUILD_TYPE_VERSION}"
)
IF(PROJECT_BUILD_TYPE_VERSION STREQUAL "release")
  ADD_DEFINITIONS(-DPROJECT_BUILD_RELEASE)
ENDIF(PROJECT_BUILD_TYPE_VERSION STREQUAL "release")
ENDMACRO(DEFINE_PROJECT_DEFINITIONS)

MACRO(INSTALL_RUNTIME_LIBRARIES)
  # Install CRT
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION .)
  IF(MINGW)
    GET_FILENAME_COMPONENT(Mingw_Path ${CMAKE_CXX_COMPILER} PATH)
    FIND_LIBRARY(GCC_DW NAMES gcc_s_dw2-1 HINTS ${Mingw_Path})
    IF(GCC_DW)
      SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} ${GCC_DW})
    ENDIF(GCC_DW)
    FIND_LIBRARY(GCC_SEH NAMES gcc_s_seh-1 HINTS ${Mingw_Path})
    IF(GCC_SEH)
      SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} ${GCC_SEH})
    ENDIF(GCC_SEH)
    SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} ${Mingw_Path}/libstdc++-6.dll ${Mingw_Path}/libwinpthread-1.dll)
  ENDIF(MINGW)
  SET(CMAKE_INSTALL_SYSTEM_RUNTIME_COMPONENT RUNTIME)
  INCLUDE(InstallRequiredSystemLibraries)
ENDMACRO(INSTALL_RUNTIME_LIBRARIES)

FUNCTION(INSTALL_FILES_HIERARCHY)
  SET(options OPTIONAL)
  SET(multiValueArgs FILES)
  SET(oneValueArgs DESTINATION)

  CMAKE_PARSE_ARGUMENTS(INSTALL_FILES_HIERARCHY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  FOREACH(file ${INSTALL_FILES_HIERARCHY_FILES})
    GET_FILENAME_COMPONENT(dir ${file} DIRECTORY)
    INSTALL(FILES ${file} DESTINATION ${INSTALL_FILES_HIERARCHY_DESTINATION}/${dir})
  ENDFOREACH()
ENDFUNCTION()

FUNCTION(FIND_RUNTIME_LIBRARY OUT_VAR DLIB_NAMES)
  IF(MINGW)
    GET_FILENAME_COMPONENT(Mingw_Path ${CMAKE_CXX_COMPILER} PATH)
    FIND_LIBRARY(OUT_VAR_FIND_${OUT_VAR} NAMES ${${DLIB_NAMES}} HINTS ${Mingw_Path} $ENV{MSYS_ROOT}/usr/bin)
    IF(NOT OUT_VAR_FIND_${OUT_VAR})
      MESSAGE(WARNING "FIND_RUNTIME_LIBRARY not found ${OUT_VAR}")
    ELSE()
      MESSAGE(STATUS "FIND_RUNTIME_LIBRARY found ${OUT_VAR_FIND_${OUT_VAR}}")
    ENDIF()
    SET(${OUT_VAR} ${OUT_VAR_FIND_${OUT_VAR}} PARENT_SCOPE)
  ELSE()
    MESSAGE(FATAL_ERROR "Not implemented")
  ENDIF(MINGW)
ENDFUNCTION()

MACRO(ADD_DLIB_TO_POSTBUILD_STEP TARGET_NAME DLIB_NAME)
IF(MSVC OR APPLE)
  GET_TARGET_PROPERTY(dlib_location ${DLIB_NAME} LOCATION)
  GET_FILENAME_COMPONENT(dlib_targetdir ${dlib_location} PATH)
  SET(DLIB_DEBUG ${dlib_targetdir}/${CMAKE_SHARED_LIBRARY_PREFIX}${DLIB_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
  SET(DLIB_RELEASE ${dlib_targetdir}/${CMAKE_SHARED_LIBRARY_PREFIX}${DLIB_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
  ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD COMMAND
    ${CMAKE_COMMAND} -E copy $<$<CONFIG:Debug>:${DLIB_DEBUG}> $<$<NOT:$<CONFIG:Debug>>:${DLIB_RELEASE}>  $<TARGET_FILE_DIR:${TARGET_NAME}>
  )
ENDIF(MSVC OR APPLE)
ENDMACRO(ADD_DLIB_TO_POSTBUILD_STEP)

MACRO(INSTALL_DEBUG_INFO_FILE)
  IF(WIN32)
    #install pbd files
    FOREACH(buildCfg ${CMAKE_CONFIGURATION_TYPES})
      INSTALL(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${buildCfg}/${PROJECT_NAME}.pdb
        DESTINATION .
        CONFIGURATIONS ${buildCfg})
    ENDFOREACH(buildCfg ${CMAKE_CONFIGURATION_TYPES})
  ENDIF(WIN32)
  # TODO: add code for other platforms here
ENDMACRO(INSTALL_DEBUG_INFO_FILE)


MACRO(FIXUP_LIBS_IN_BUNDLE BUNDLE_NAME LIB_DIST)
    INSTALL(CODE "
      FILE(GLOB_RECURSE QTPLUGINS_FIXUP
      \"\${CMAKE_INSTALL_PREFIX}/*${CMAKE_SHARED_LIBRARY_SUFFIX}\")
      include(BundleUtilities)
      fixup_bundle(\"\${CMAKE_INSTALL_PREFIX}/${BUNDLE_NAME}\" \"\${QTPLUGINS_FIXUP}\" \"${LIB_DIST}\")
      " COMPONENT RUNTIME)
ENDMACRO(FIXUP_LIBS_IN_BUNDLE BUNDLE_PATH LIB_DIST)

FUNCTION(INSTALL_LIB_TO_BUNDLE BUNDLE_NAME LIB_PATH)
  GET_FILENAME_COMPONENT(LIB_DIR ${LIB_PATH} DIRECTORY)
  INSTALL(CODE "
        include(BundleUtilities)
        fixup_bundle(\"\${CMAKE_INSTALL_PREFIX}/${BUNDLE_NAME}\" \"\${LIB_PATH}\" \"${LIB_DIR}\")
        " COMPONENT RUNTIME)
ENDFUNCTION(INSTALL_LIB_TO_BUNDLE BUNDLE_PATH LIB_PATH)

FUNCTION(REGISTER_CHECK_STYLE_TARGET TARGET SOURCES)
  FIND_PROGRAM(CLANG_TIDY NAMES clang-tidy clang-tidy-3.9 clang-tidy-3.8 clang-tidy-3.7 clang-tidy-3.6 clang-tidy-3.5)
  IF (CLANG_TIDY)
    SET(CT_CHECK_FILES ${SOURCES})
    LIST(APPEND CT_CHECKS "-*")  # disable all default checks
    LIST(APPEND CT_CHECKS "google-*")  # enable google checks
    STRING(REPLACE ";" "," ALL_CHECKS "${CT_CHECKS}")
    ADD_CUSTOM_TARGET(${TARGET}
      COMMAND ${CLANG_TIDY} -p ${CMAKE_BINARY_DIR} -checks="${ALL_CHECKS}" ${CT_CHECK_FILES}
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
  ENDIF(CLANG_TIDY)
  FIND_PROGRAM(CLANG_FORMAT NAMES clang-format clang-format-3.9 clang-format-3.8 clang-format-3.7 clang-format-3.6 clang-format-3.5)
  IF (CLANG_FORMAT)
    SET(FORMAT_CHECK_FILES ${SOURCES})
    ADD_CUSTOM_TARGET(${TARGET}_format
      COMMAND ${CLANG_FORMAT} -i -style=file ${FORMAT_CHECK_FILES}
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
  ENDIF(CLANG_FORMAT)
ENDFUNCTION(REGISTER_CHECK_STYLE_TARGET)

FUNCTION(REGISTER_CHECK_INCLUDES_TARGET TARGET)
  FIND_PROGRAM(IWYI_PATH NAMES include-what-you-use iwyu)
  IF (IWYI_PATH)
    SET(IWYI_PATH_AND_OPTIONS ${IWYI_PATH})
    SET_PROPERTY(TARGET ${TARGET} PROPERTY CXX_INCLUDE_WHAT_YOU_USE ${IWYI_PATH_AND_OPTIONS})
  ENDIF(IWYI_PATH)
ENDFUNCTION(REGISTER_CHECK_INCLUDES_TARGET)

FUNCTION(STRIP_TARGET TARGET_NAME)
  IF(APPLE)
    SET(STRIP_OPTIONS -u -r -x)
  ELSE()
    SET(STRIP_OPTIONS --strip-unneeded)
  ENDIF(APPLE)
  ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND ${CMAKE_STRIP} ${STRIP_OPTIONS} $<TARGET_FILE:${TARGET_NAME}>
    COMMENT "Stripping target: ${TARGET_NAME}" VERBATIM)
ENDFUNCTION(STRIP_TARGET)

FUNCTION(GEN_START_SCRIPT FILE_NAME TARGET_NAME)
FILE(WRITE ${FILE_NAME} "#!/usr/bin/env bash

SOURCE=\"\${BASH_SOURCE[0]}\"
while [ -h \"$SOURCE\" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=\"$( cd -P \"$( dirname \"$SOURCE\" )\" && pwd )\"
  SOURCE=\"$(readlink \"$SOURCE\")\"
  [[ $SOURCE != /* ]] && SOURCE=\"$DIR/$SOURCE\" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCE_DIR=\"$( cd -P \"$( dirname \"$SOURCE\" )\" && pwd )\"
cd $SOURCE_DIR

export LD_LIBRARY_PATH=\"$SOURCE_DIR/../lib:$LD_LIBRARY_PATH\"

\"$SOURCE_DIR/${TARGET_NAME}\" $@")
ENDFUNCTION(GEN_START_SCRIPT)
