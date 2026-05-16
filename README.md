# S32K144 Firmware Template

Boilerplate CMake project for NXP **S32K144** (Cortex-M4F) firmware development.  
Includes a two-stage build system: ARM cross-compiled firmware **and** native host unit-tests via GoogleTest/CTest, with a GitHub Actions CI pipeline for both.

---

## Repository Layout

```
s32-template/
├── .github/
│   └── workflows/
│       └── ci.yml                         # CI: firmware build + host tests
├── .githooks/
│   └── pre-commit                         # Auto-formatter hook (uncrustify)
├── benchmarks/
│   ├── CMakeLists.txt                     # Google Benchmark target registration
│   └── bench_hello.cpp                    # Sample benchmark
├── cmake/
│   └── gcc_arm_eabi_toolchain.cmake       # ARM GCC toolchain (env-var driven)
├── doxygen/
│   └── Doxyfile                           # XML doc generation from src/
├── external/
│   ├── benchmark/                         # Google Benchmark submodule
│   └── googletest/                        # GoogleTest/GoogleMock submodule
├── src/
│   ├── app.c                              # Application code
│   ├── main.c                             # Firmware entry point
│   └── NXP/
│       ├── Generated_Code/                # S32 Design Studio generated config
│       │   ├── Cpu.c/.h
│       │   ├── FreeRTOSConfig.h
│       │   ├── clockMan1.c/.h
│       │   ├── pin_mux.c/.h
│       │   └── *_pal*.c/.h                # ADC, CAN, timing, UART PAL config
│       ├── Project_Settings/
│       │   ├── Linker_Files/              # S32K144 flash/RAM linker scripts
│       │   └── Startup_Code/              # startup_S32K144.S
│       └── SDK/
│           ├── platform/
│           │   ├── devices/               # Device headers and startup code
│           │   ├── drivers/               # S32K platform drivers
│           │   └── pal/                   # Peripheral abstraction layer
│           └── rtos/
│               ├── FreeRTOS_S32K/         # FreeRTOS kernel and ARM_CM4F port
│               └── osif/                  # OS integration layer
├── target_build/
│   └── CMakeLists.txt                     # Target firmware build entry point
├── tests/
│   ├── CMakeLists.txt                     # Test targets + CTest registration
│   └── test_hello.cpp                     # Sample GoogleTest
├── .gitignore
├── .gitmodules                            # Submodule definitions
├── .uncrustify.cfg                        # Formatter configuration
├── CMakeLists.txt                         # Native host tests + benchmarks build
├── LICENSE
└── README.md
```

---

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| `arm-none-eabi-gcc` | Target firmware compilation | [xPack ARM GCC](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack) or `brew install --cask gcc-arm-embedded` |
| `cmake` ≥ 3.10 | Build system | `brew install cmake` |
| `gcc` / `g++` | Host test compilation | Xcode CLI tools: `xcode-select --install` |
| `uncrustify` | Pre-commit code formatter | `brew install uncrustify` |
| `doxygen` *(optional)* | Documentation generation | `brew install doxygen` |

---

## First-Time Setup

```bash
# 1. Clone and initialise GoogleTest submodule
git clone <repo-url> s32-template
cd s32-template
git submodule update --init --recursive

# 2. Activate the version-controlled pre-commit hook
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

---

## Building the Target Firmware (ARM)

The ARM toolchain directory is resolved from the `ARM_TOOLCHAIN_DIR` environment variable.  
In CI (GitHub Actions) `arm-none-eabi-gcc` is on `PATH` and no variable is needed.

```bash
# Set the toolchain location (xPack example – adjust to your installation)
export ARM_TOOLCHAIN_DIR=/path/to/arm-none-eabi/bin

mkdir -p build_target
cd build_target
cmake ../target_build \
  -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc_arm_eabi_toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

**Outputs** (inside `build_target/`):

| File | Description |
|------|-------------|
| `s32_template.elf` | ELF binary + debug symbols |
| `s32_template.hex` | Intel HEX (for flash programmers) |
| `s32_template.s19` | Motorola SREC |
| `s32_template.map` | Linker map |

> **Note:** The target build links NXP SDK startup sources from
> `src/NXP/SDK/platform/devices/startup.c` and
> `src/NXP/SDK/platform/devices/S32K144/startup/system_S32K144.c`.

---

## Building & Running Host Tests

Host tests compile with the native system GCC (no cross-compiler needed).

```bash
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
ctest -V
```

Expected output:

```
100% tests passed, 0 tests failed out of 2
Total Test time (real) =   0.57 sec
```

### Adding a New Test

1. Create `tests/test_<module>.cpp`
2. Add the executable to `tests/CMakeLists.txt`:

```cmake
add_executable(test_mymodule test_mymodule.cpp)
target_link_libraries(test_mymodule gtest gtest_main)
gtest_discover_tests(test_mymodule)
```

---

## Pre-Commit Hook

The hook runs `uncrustify` on all `.c/.h/.cpp/.hpp` files under `src/` (except `main.c`) and auto-commits any formatting changes before your commit proceeds.

```bash
# Activate once per clone
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

The hook is stored in `.githooks/` and is version-controlled — no manual copy to `.git/hooks/` is required.

---

## Doxygen Documentation

```bash
cd doxygen
doxygen Doxyfile
# XML output written to doxygen/xml/
```

---

## CI Pipeline

`.github/workflows/ci.yml` runs on every push/PR to `main`:

| Job | Runner | What it does |
|-----|--------|--------------|
| `build-firmware` | `ubuntu-latest` | Installs `gcc-arm-none-eabi`, configures + builds target firmware |
| `build-tests` | `ubuntu-latest` | Builds GoogleTest + test binaries, runs `ctest -V` |

---

## Toolchain Environment Variables

| Variable | Description | Default behaviour if unset |
|----------|-------------|--------------------------|
| `ARM_TOOLCHAIN_DIR` | Path to `arm-none-eabi-*` binaries | Uses tools from `PATH` (suitable for CI) |
| `GCC_LIB_PATH` | Sysroot/newlib path (Windows only) | Derived from `ARM_TOOLCHAIN_DIR` on Windows |
