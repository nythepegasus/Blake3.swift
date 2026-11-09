#if __ARM_NEON__
#include "../../dependencies/BLAKE3/c/blake3_neon.c"
#endif

#if __x86_64__

#if __SSE2__
#include "../../dependencies/BLAKE3/c/blake3_sse2.c"
#endif
#ifndef __SSE4_1__
#define BLAKE3_NO_SSE41
#else
#include "../../dependencies/BLAKE3/c/blake3_sse41.c"
#endif
#ifndef __AVX2__
#define BLAKE3_NO_AVX2
#else
#include "../../dependencies/BLAKE3/c/blake3_avx2.c"
#endif
#ifndef __AVX512__
#define BLAKE3_NO_AVX512
#endif

#endif

#include <blake3.h>
#include "../../dependencies/BLAKE3/c/blake3.c"
#include "../../dependencies/BLAKE3/c/blake3_dispatch.c"
#include "../../dependencies/BLAKE3/c/blake3_portable.c"
