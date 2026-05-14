# Toolchain configuration for ARM GCC
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# Toolchain prefix
set(TOOLCHAIN_PREFIX arm-none-eabi-)

# ---------------------------------------------------------------------------
# Toolchain directory resolution (priority: env var > well-known defaults)
# ---------------------------------------------------------------------------
if(DEFINED ENV{ARM_TOOLCHAIN_DIR})
    set(ARM_TOOLCHAIN_DIR "$ENV{ARM_TOOLCHAIN_DIR}")
    message(STATUS "ARM toolchain dir from ARM_TOOLCHAIN_DIR env: ${ARM_TOOLCHAIN_DIR}")
elseif(DEFINED ENV{GITHUB_ACTIONS} AND "$ENV{GITHUB_ACTIONS}" STREQUAL "true")
    # In CI the toolchain is on PATH - no explicit dir needed
    message(STATUS "Running in GitHub Actions: using arm-none-eabi toolchain from PATH")
elseif(CMAKE_HOST_WIN32)
    # Windows fallback default
    set(ARM_TOOLCHAIN_DIR "C:/NXP/S32DS.3.6.0/S32DS/build_tools/gcc_v6.3/gcc-6.3-arm32-eabi/bin")
    message(WARNING "ARM_TOOLCHAIN_DIR env not set. Falling back to default: ${ARM_TOOLCHAIN_DIR}")
else()
    # Linux/macOS: rely on PATH
    message(STATUS "ARM_TOOLCHAIN_DIR env not set. Assuming arm-none-eabi tools are on PATH.")
endif()

# Sysroot / newlib path (only needed when linking on Windows)
if(DEFINED ENV{GCC_LIB_PATH})
    set(GCC_LIB_PATH "$ENV{GCC_LIB_PATH}")
    message(STATUS "GCC lib/sysroot from GCC_LIB_PATH env: ${GCC_LIB_PATH}")
elseif(CMAKE_HOST_WIN32 AND DEFINED ARM_TOOLCHAIN_DIR)
    # Windows fallback
    get_filename_component(_tc_parent "${ARM_TOOLCHAIN_DIR}" DIRECTORY)
    set(GCC_LIB_PATH "${_tc_parent}/arm-none-eabi/newlib")
    message(WARNING "GCC_LIB_PATH env not set. Falling back to: ${GCC_LIB_PATH}")
endif()

# Required for CMake compiler checks with a bare-metal target
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ---------------------------------------------------------------------------
# Toolchain executables
# ---------------------------------------------------------------------------
if(DEFINED ARM_TOOLCHAIN_DIR)
    if(CMAKE_HOST_WIN32)
        set(_EXE ".exe")
    else()
        set(_EXE "")
    endif()

    foreach(_tool ar gcc g++ objcopy size)
        string(TOUPPER "${_tool}" _upper)
        string(REPLACE "+" "X" _upper "${_upper}")   # g++ -> GXX
    endforeach()

    set(CMAKE_AR            "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}ar${_EXE}")
    set(CMAKE_ASM_COMPILER  "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}gcc${_EXE}")
    set(CMAKE_C_COMPILER    "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}gcc${_EXE}")
    set(CMAKE_CXX_COMPILER  "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}g++${_EXE}")
    set(CMAKE_OBJCOPY       "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}objcopy${_EXE}")
    set(CMAKE_GSIZE_TOOL    "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}size${_EXE}")
    set(CMAKE_GSREC_TOOL    "${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}objcopy${_EXE}")
else()
    set(CMAKE_AR            "${TOOLCHAIN_PREFIX}ar")
    set(CMAKE_ASM_COMPILER  "${TOOLCHAIN_PREFIX}gcc")
    set(CMAKE_C_COMPILER    "${TOOLCHAIN_PREFIX}gcc")
    set(CMAKE_CXX_COMPILER  "${TOOLCHAIN_PREFIX}g++")
    set(CMAKE_OBJCOPY       "${TOOLCHAIN_PREFIX}objcopy")
    set(CMAKE_GSIZE_TOOL    "${TOOLCHAIN_PREFIX}size")
    set(CMAKE_GSREC_TOOL    "${TOOLCHAIN_PREFIX}objcopy")
endif()

# Verify key executables exist and warn if missing
foreach(_exe CMAKE_C_COMPILER CMAKE_CXX_COMPILER CMAKE_ASM_COMPILER CMAKE_AR CMAKE_OBJCOPY)
    if(NOT EXISTS "${${_exe}}")
        # Only warn (not fatal) because in CI the tools may be on PATH without full path
        message(WARNING "${_exe} not found at '${${_exe}}'. Ensure arm-none-eabi toolchain is installed and on PATH (or set ARM_TOOLCHAIN_DIR).")
    endif()
endforeach()

# ---------------------------------------------------------------------------
# Compiler / linker flags
# ---------------------------------------------------------------------------
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")

if(DEFINED GCC_LIB_PATH)
    set(SYSROOT_FLAG "--sysroot=${GCC_LIB_PATH}")
else()
    set(SYSROOT_FLAG "")
endif()

set(COMMON_FLAGS "${CPU_FLAGS} -fdata-sections -ffunction-sections -Wall ${SYSROOT_FLAG}")

set(CMAKE_C_FLAGS   "${COMMON_FLAGS}" CACHE INTERNAL "C compiler flags")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "C++ compiler flags")
set(CMAKE_ASM_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "ASM compiler flags")

set(CMAKE_EXE_LINKER_FLAGS
    "${CPU_FLAGS} -specs=nano.specs ${SYSROOT_FLAG} \
    -lc -lm -lnosys -Wl,-Map=${CMAKE_PROJECT_NAME}.map -Xlinker --gc-sections"
    CACHE INTERNAL "Linker flags")

# ---------------------------------------------------------------------------
# Search paths
# ---------------------------------------------------------------------------
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
