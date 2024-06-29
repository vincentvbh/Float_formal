
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

int main(void){

    double a, b, c;
    fpr a_fpr, b_fpr, c_fpr;
    uint64_t a_int, b_int;

    hal_setup(CLOCK_FAST);

    a = rand_double();
    b = rand_double();

    memmove(&a_fpr, &a, sizeof(double));
    memmove(&b_fpr, &b, sizeof(double));

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();

        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c = a + b;
        c_fpr = fpr_add_new(a_fpr, b_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "fpr_add:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }
        assert(memcmp(&c, &c_fpr, sizeof(double)) == 0);

    }

    sprintf(out, "floating-point add test done!");
    hal_send_str(out);

    for(size_t i = 0; i < ITERATIONS; i++){

        a = rand_double();
        b = rand_double();

        memmove(&a_fpr, &a, sizeof(double));
        memmove(&b_fpr, &b, sizeof(double));

        c = a * b;
        c_fpr = fpr_mul_new(a_fpr, b_fpr);
        if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
            sprintf(out, "fpr_mul_new:\n%16llx\n%16llx\n\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
            hal_send_str(out);
        }

    }

    sprintf(out, "floating-point mul test done!");
    hal_send_str(out);

    // 200 6 a09e 667f 3bcd
    a_int = 6369051672525773 - ( (1ULL) << 52);
    a_int |= 0x2000000000000000;
    // 1ff 6 a09e 667f 3bcc
    b_int = 6369051672525772 - ( (1ULL) << 52);
    b_int |= 0x1ff0000000000000;

    memmove(&a, &a_int, sizeof(double));
    memmove(&b, &b_int, sizeof(double));
    memmove(&a_fpr, &a_int, sizeof(double));
    memmove(&b_fpr, &b_int, sizeof(double));

    c = a * b;
    c_fpr = fpr_mul_new(a_fpr, b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "fpr_mul_new:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    // ffe 6 a09e 667f 3bcd
    a_int = 6369051672525773 - ( (1ULL) << 52);
    a_int |= 0xffe0000000000000;
    // 0
    b_int = 0;

    memmove(&a, &a_int, sizeof(double));
    memmove(&b, &b_int, sizeof(double));
    memmove(&a_fpr, &a_int, sizeof(double));
    memmove(&b_fpr, &b_int, sizeof(double));

    c = a * b;
    c_fpr = fpr_mul_new(a_fpr, b_fpr);
    if(memcmp(&c, &c_fpr, sizeof(double)) != 0){
        sprintf(out, "fpr_mul_new:\n%16llx\n%16llx\n", *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        hal_send_str(out);
    }

    sprintf(out, "floating-point mul edge-case test done!");
    hal_send_str(out);


}




