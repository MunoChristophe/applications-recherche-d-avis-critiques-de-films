# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

find_package(PkgConfig)

set(_flutter_root "${FLUTTER_ROOT}")

# === Flutter Library ===
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}/"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}.lib")
add_custom_command(OUTPUT ${FLUTTER_LIBRARY}
  COMMAND ${CMAKE_COMMAND} -E echo "Placeholder"
)

set(PHONY_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/_phony_")
set_source_files_properties("${PHONY_OUTPUT}" PROPERTIES SYMBOLIC TRUE)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  "${PHONY_OUTPUT}"
)
add_custom_command(
  OUTPUT ${PHONY_OUTPUT}
  DEPENDS
  COMMAND ${CMAKE_COMMAND} -E echo "Building Flutter library..."
  VERBATIM
)

# === Wrapper sources ===
add_library(flutter_wrapper_app STATIC
  "cpp_client_wrapper/flutter_engine.cc"
  "cpp_client_wrapper/flutter_view_controller.cc"
)
apply_standard_settings(flutter_wrapper_app)
set_target_properties(flutter_wrapper_app PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")
target_source_dir_permissions(flutter_wrapper_app
  DIRECTORY "${WRAPPER_ROOT}/include"
  PUBLIC_HEADER
)
target_include_directories(flutter_wrapper_app PUBLIC
  "${WRAPPER_ROOT}/include"
)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_link_libraries(flutter_wrapper_app PUBLIC "d3d11.lib")
