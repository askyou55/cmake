FIND_PACKAGE(PythonInterp 3 REQUIRED)
IF(APPLE)
  EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "${FASTOGT_CMAKE_MODULES_DIR}/scripts/fastogtsign.py" sign \"$ENV{SIGNING_IDENTITY}\" "${CMAKE_INSTALL_PREFIX}/${EXECUTABLE_NAME}")
ELSEIF(WIN32)
  EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "${FASTOGT_CMAKE_MODULES_DIR}/scripts/fastogtsign.py" sign FastoGT "${CMAKE_INSTALL_PREFIX}/${EXECUTABLE_NAME}")
ENDIF(APPLE)