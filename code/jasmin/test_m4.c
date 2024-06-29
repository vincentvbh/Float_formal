
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>

#include "fpr.h"

#include "hal.h"

#define ITERATIONS 100000

char out[128];

static
double rand_double(void){
    double t;
    t = (double)rand() / (double)RAND_MAX;
    if(rand() & 1){
        t = -t;
    }
    return t;
}

static
int64_t rand_int64(void){
    int64_t t;
    t = rand();
    t = (t << 32) | rand();
    if(rand() & 1){
        t = -t;
    }
    return t;
}

extern
void __fadd_32_export(fpr*, fpr*, fpr*);

extern
void __fsub_32_export(fpr*, fpr*, fpr*);

extern
void __fmul_32_export(fpr*, fpr*, fpr*);

extern
void __fsqr_32_export(fpr*, fpr*);

extern
void __fhalf_32_export(fpr*, fpr*);

extern
void __ftrunc_32_export(int64_t*, fpr*);

extern
void __ffloor_32_export(int64_t*, fpr*);

extern
void __ffromint64_32_export(fpr*, int64_t*);

extern
void __fixedmul_64x64_export(uint64_t*, uint64_t*, uint64_t*);

extern
void __polyeval_horn_export(uint64_t*, uint64_t*);

extern
void __fexpm_p63_export(uint64_t*, fpr*, fpr*);

int main(void){

    double a, b, c, d;
    fpr a_fpr, b_fpr, c_fpr, d_fpr;
    uint64_t a_uint, b_uint, c_uint, d_uint;
    int64_t a_int, b_int, c_int, d_int;

    (void)a; (void)b; (void)c; (void)d;
    (void)a_fpr; (void)b_fpr; (void)c_fpr; (void)d_fpr;
    (void)a_uint; (void)b_uint; (void)c_uint; (void)d_uint;
    (void)a_int; (void)b_int; (void)c_int; (void)d_int;

    hal_setup(CLOCK_FAST);

    for(size_t i = 0; i < 32; i++){
        hal_send_str("================================");
    }

// ================================

    hal_send_str("__mul_64x64 test start!");

    for(size_t i = 0; i < ITERATIONS; i++){

        a_uint = (uint64_t)rand_int64();
        b_uint = (uint64_t)rand_int64();

        c_uint = mul_fixed64(a_uint, b_uint);

        __fixedmul_64x64_export(&d_uint, &a_uint, &b_uint);

        assert(memcmp(&c_uint, &d_uint, sizeof(c_uint)) == 0);

    }

    hal_send_str("__mul_64x64 test finished!");

// ================================

    hal_send_str("floating-point start!");

// ================================

        hal_send_str("fpr_expm_p63 test start!");

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();
        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c_uint = fpr_expm_p63(a_fpr, b_fpr);

        __fexpm_p63_export(&d_uint, &a_fpr, &b_fpr);

        assert(memcmp(&c_uint, &d_uint, sizeof(uint64_t)) == 0);

    }

    hal_send_str("fpr_expm_p63 test end!");

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();

        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c = a + b;
        c_fpr = fpr_add(a_fpr, b_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "fpr_add:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }
        assert(memcmp(&c, &c_fpr, sizeof(double)) == 0);
        __fadd_32_export(&c_fpr, &a_fpr, &b_fpr);
        assert(memcmp(&c, &c_fpr, sizeof(double)) == 0);

    }

    sprintf(out, "floating-point add test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();

        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c = a - b;
        __fsub_32_export(&c_fpr, &a_fpr, &b_fpr);
        assert(memcmp(&c, &c_fpr, sizeof(double)) == 0);

    }

    sprintf(out, "floating-point sub test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();

        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c = a * b;
        c_fpr = fpr_mul(a_fpr, b_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "fpr_mul:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

        __fmul_32_export(&c_fpr, &a_fpr, &b_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "__fmul_32_export:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point mul test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();

        memmove(&a_fpr, &a, sizeof(double));

        c = a * a;
        c_fpr = fpr_mul(a_fpr, a_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "fpr_mul:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

        __fsqr_32_export(&c_fpr, &a_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "__fmul_32_export:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point sqr test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();

        memmove(&a_fpr, &a, sizeof(double));

        c = a / 2.0;

        __fhalf_32_export(&c_fpr, &a_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "__fmul_32_export:\n%16llx\n%16llx\n%16llx\n\n", *(uint64_t*)&a, *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point half test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        a *= 200000.0;
        memmove(&a_fpr, &a, sizeof(double));
        a_uint = (uint64_t)fpr_trunc(a_fpr);
        __ftrunc_32_export(&c_int, &a_fpr);

        if(memcmp(&a_uint, &c_int, sizeof(double)) != 0){
            sprintf(out, "floating-point trunc:\n\n%lld\n%lld\n", *(int64_t*)&a_uint, c_int);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point trunc test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        a *= 200000.0;
        memmove(&a_fpr, &a, sizeof(double));
        a_uint = (uint64_t)fpr_floor(a_fpr);
        __ffloor_32_export(&c_int, &a_fpr);

        if(memcmp(&a_uint, &c_int, sizeof(int64_t)) != 0){
            sprintf(out, "floating-point floor:\n\n%lld\n%lld\n", *(int64_t*)&a_uint, c_int);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point floor test done!");
    hal_send_str(out);

// ================================

    for(size_t i = 0; i < ITERATIONS; i++){

        a_uint = (uint64_t)rand_int64();
        a_fpr = fpr_of((int64_t)a_uint);
        __ffromint64_32_export(&c_fpr, (int64_t*)&a_uint);

        if(memcmp(&a_fpr, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "int64_t to floating-point:\n%16llx\n%16llx\n", *(uint64_t*)&a_fpr, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

    }

    sprintf(out, "int64_t to floating-point test done!");
    hal_send_str(out);

// ================================

    // 200 6 a09e 667f 3bcd
    a_uint = 6369051672525773 - ( (1ULL) << 52);
    a_uint |= 0x2000000000000000;
    // 1ff 6 a09e 667f 3bcc
    b_uint = 6369051672525772 - ( (1ULL) << 52);
    b_uint |= 0x1ff0000000000000;

    memmove(&a, &a_uint, sizeof(double));
    memmove(&b, &b_uint, sizeof(double));
    memmove(&a_fpr, &a_uint, sizeof(double));
    memmove(&b_fpr, &b_uint, sizeof(double));

    c = a * b;
    c_fpr = fpr_mul(a_fpr, b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "fpr_mul:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    __fmul_32_export(&c_fpr, &a_fpr, &b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "__fmul_32_export:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    // 200 6 a09e 667f 3bcd
    a_uint = 6369051672525773 - ( (1ULL) << 52);
    a_uint |= 0xffe0000000000000;
    // 1ff 6 a09e 667f 3bcc
    b_uint = 0;

    memmove(&a, &a_uint, sizeof(double));
    memmove(&b, &b_uint, sizeof(double));
    memmove(&a_fpr, &a_uint, sizeof(double));
    memmove(&b_fpr, &b_uint, sizeof(double));

    c = a * b;
    c_fpr = fpr_mul(a_fpr, b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "fpr_mul:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    __fmul_32_export(&c_fpr, &a_fpr, &b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "__fmul_32_export:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    sprintf(out, "floating-point mul edge-case test done!");
    hal_send_str(out);

// ================================

    a = 0.0;
    memmove(&a_fpr, &a, sizeof(double));
    a_uint = fpr_trunc(a_fpr);
    __ftrunc_32_export(&c_int, &a_fpr);

    if(memcmp(&a_uint, &c_int, sizeof(double)) != 0){
        sprintf(out, "floating-point trunc:\n\n%lld\n%lld\n", *(int64_t*)&a_uint, c_int);
        hal_send_str(out);
    }

    sprintf(out, "floating-point trunc edge-case test done!");
    hal_send_str(out);

// ================================

    a = 0.0;
    memmove(&a_fpr, &a, sizeof(double));
    a_uint = fpr_floor(a_fpr);
    __ffloor_32_export(&c_int, &a_fpr);

    if(memcmp(&a_uint, &c_int, sizeof(double)) != 0){
        sprintf(out, "floating-point floor:\n\n%lld\n%lld\n", *(int64_t*)&a_uint, c_int);
        hal_send_str(out);
    }

    sprintf(out, "floating-point floor edge-case test done!");
    hal_send_str(out);

// ================================






}

