cmake_minimum_required(VERSION 3.10)
project(s32_template_benchmarks)

# -----------------------------------------------------------------------
# Sample benchmark: bench_hello
# -----------------------------------------------------------------------
add_executable(bench_hello
    bench_hello.cpp
)

target_link_libraries(bench_hello
    benchmark::benchmark_main
)
