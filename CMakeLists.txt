cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

# Find native compilers for host tests
find_program(HOST_C_COMPILER gcc)
find_program(HOST_CXX_COMPILER g++)

if(NOT HOST_C_COMPILER OR NOT HOST_CXX_COMPILER)
    message(FATAL_ERROR "Native GCC compilers not found. Please install GCC.")
endif()

message(STATUS "Using native compilers for tests: ${HOST_C_COMPILER}, ${HOST_CXX_COMPILER}")

# Set compilers for host tests - must be set before project()
set(CMAKE_C_COMPILER ${HOST_C_COMPILER})
set(CMAKE_CXX_COMPILER ${HOST_CXX_COMPILER})

# Project settings
project(s32_template_tests LANGUAGES C CXX)

# Enable testing
include(CTest)
enable_testing()

# Language standards
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define mock implementations for hardware-dependent code
add_compile_definitions(HOST_BUILD MOCK_HARDWARE)

# Add GoogleTest
add_subdirectory(external/googletest)
include(GoogleTest)

# Include directories for tests
include_directories(
    ${CMAKE_SOURCE_DIR}/external/googletest/googletest/include
    ${CMAKE_SOURCE_DIR}/external/googletest/googlemock/include
)

# Add tests directory
add_subdirectory(tests)

# ---------------------------------------------------------------------------
# Google Benchmark
# ---------------------------------------------------------------------------
# Disable benchmark's own tests and gtest integration to avoid conflicts
set(BENCHMARK_ENABLE_TESTING      OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS  OFF CACHE BOOL "" FORCE)
set(BENCHMARK_USE_BUNDLED_GOOGLETEST OFF CACHE BOOL "" FORCE)
add_subdirectory(external/benchmark)

# Add benchmarks directory
add_subdirectory(benchmarks)

message(STATUS "Configuration complete. Use 'cmake --build .' to build the tests.")
