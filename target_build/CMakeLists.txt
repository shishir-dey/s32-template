# Target firmware build

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(s32_template_target LANGUAGES C CXX ASM)

# Toolchain configuration for target build
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/gcc_arm_eabi_toolchain.cmake")
include(${CMAKE_TOOLCHAIN_FILE})

# Ensure we're using the ARM toolchain
if(NOT CMAKE_C_COMPILER MATCHES "arm-none-eabi")
    message(FATAL_ERROR "ARM toolchain not properly configured. Check gcc_arm_eabi_toolchain.cmake")
endif()

message(STATUS "Using ARM toolchain for target: ${CMAKE_C_COMPILER}")

# Remove any macOS-specific flags that might be inherited
string(REPLACE "-arch" "" CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}")
string(REPLACE "-arch" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE "-arch" "" CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS}")

# Target settings
set(target_name "s32_template")

# Source directories (application + SDK device init files)
set(src_folder
    "${CMAKE_CURRENT_SOURCE_DIR}/../src"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/Project_Settings"
)

# SDK source files providing SystemInit and init_data_bss
set(sdk_src_files
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices/startup.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices/S32K144/startup/system_S32K144.c"
)

# ASM files
list(APPEND CMAKE_ASM_SOURCE_FILE_EXTENSIONS S asm inc)
set(asm_files "${CMAKE_CURRENT_SOURCE_DIR}/../src/Project_Settings/Startup_Code/startup_S32K144.S")
SET_SOURCE_FILES_PROPERTIES(${asm_files} PROPERTIES LANGUAGE ASM)

# Linker script
set(link_file "${CMAKE_CURRENT_SOURCE_DIR}/../src/Project_Settings/Linker_Files/S32K144_64_flash.ld")

# Preprocessor definitions for target
add_compile_definitions(
    CPU_S32K144HFT0VLLT
    S32K
    DEV_ERROR_DETECT
)

# SDK include directories
include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices/common"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices/S32K144/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src/SDK/platform/devices/S32K144/startup"
)

# Find source files for target (exclude SDK - those are added explicitly)
foreach(folder ${src_folder})
    include_directories(${folder})
    file(GLOB_RECURSE TEMP_SOURCES "${folder}/*.c" "${folder}/*.cpp")
    list(FILTER TEMP_SOURCES EXCLUDE REGEX ".*/SDK/.*")
    list(APPEND src_list ${TEMP_SOURCES})
endforeach()

# Add explicit SDK source files
list(APPEND src_list ${sdk_src_files})

# Add ASM files to source list
list(APPEND src_list ${asm_files})

# Create executable for target
set(EXECUTABLE ${target_name}.elf)
add_executable(${EXECUTABLE} ${src_list})

# Linker settings for target
target_link_options(${EXECUTABLE} PRIVATE -T ${link_file})

# Post-build commands for target
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_GSIZE_TOOL} ${EXECUTABLE}
    COMMAND ${CMAKE_GSREC_TOOL} -O srec ${EXECUTABLE} ${target_name}.s19
    COMMAND ${CMAKE_GSREC_TOOL} -O ihex ${EXECUTABLE} ${target_name}.hex
    COMMENT "Generating hex and s19 files"
)
