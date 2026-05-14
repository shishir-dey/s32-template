#include <benchmark/benchmark.h>
#include <cstring>
#include <vector>

/**
 * @brief Sample benchmark — replace with benchmarks of real firmware modules.
 *
 * Run with:
 *   ./build/benchmarks/bench_hello
 *   ./build/benchmarks/bench_hello --benchmark_format=json
 */

// -----------------------------------------------------------------------
// BM_Memcpy: measures raw memcpy throughput at various buffer sizes.
// A useful baseline when you start optimising data-movement routines.
// -----------------------------------------------------------------------
static void BM_Memcpy(benchmark::State &state)
{
    const std::size_t size = static_cast<std::size_t>(state.range(0));
    std::vector<char> src(size, 'A');
    std::vector<char> dst(size);

    for (auto _ : state) {
        std::memcpy(dst.data(), src.data(), size);
        benchmark::DoNotOptimize(dst.data());
    }

    state.SetBytesProcessed(
        static_cast<int64_t>(state.iterations()) * static_cast<int64_t>(size));
}
// Test with 64 B, 256 B, 1 kB, 4 kB — representative of typical MCU frame sizes
BENCHMARK(BM_Memcpy)->Arg(64)->Arg(256)->Arg(1024)->Arg(4096);

// -----------------------------------------------------------------------
// BM_VectorFill: measures cost of filling a vector — good proxy for
// buffer-initialisation patterns common in embedded middleware.
// -----------------------------------------------------------------------
static void BM_VectorFill(benchmark::State &state)
{
    const std::size_t size = static_cast<std::size_t>(state.range(0));

    for (auto _ : state) {
        std::vector<uint8_t> buf(size, 0xFF);
        benchmark::DoNotOptimize(buf.data());
    }

    state.SetItemsProcessed(
        static_cast<int64_t>(state.iterations()) * static_cast<int64_t>(size));
}
BENCHMARK(BM_VectorFill)->Arg(64)->Arg(256)->Arg(1024);
