cmake_minimum_required(VERSION 3.10)

# Tests for the s32_template project
project(s32_template_tests_sub)

# -----------------------------------------------------------------------
# Sample GoogleTest test: HelloWorld
# -----------------------------------------------------------------------
add_executable(test_hello
    test_hello.cpp
)

target_link_libraries(test_hello
    gtest
    gtest_main
)

# Register with CTest - discovers all TEST() macros automatically
gtest_discover_tests(test_hello)
