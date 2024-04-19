
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>

#include "fpr.h"

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
int test_smallness(fpr x){

    fpr e = (x >> 52) & 0x7ff;
    fpr m = x & 0xfffffffffffff;

    if( (1 <= e) && (e <= 1022) ){
        if( (1 <= m) && (m <= 0xffffffffffffe) ){
            return 1;
        }
    }

    return 0;

}

// return b leading to zeroization of a * b which is
// actually a non-zero small number by construction
// if we can't find one, return -1 instead
static
int retrieve_zeroization(fpr *b, fpr a){

    uint64_t t;

    __uint128_t a128, b128, t128;

    if(test_smallness(a) == 0)
        return -1;

    a128 = (1ULL << 52) + (a & 0xfffffffffffff);
    t128 = 1; t128 <<= 105;
    b128 = t128 / a128;

    if( a128 * b128 + (1ULL << 51) < t128)
        return -1;

    t = ( 1023 - ((a >> 52) & 0x7ff) ) << 52;
    t |= b128 - (1ULL << 52);
    *b = t;

    return 1;

}


int main(void){

    double a, b, c;
    fpr a_fpr, b_fpr, c_fpr;

    for(size_t i = 0; i < 1024; i++){
        a_fpr = fpr_gm_tab[i];
        if(retrieve_zeroization(&b_fpr, a_fpr) == 1){
            memmove(&a, &a_fpr, sizeof(double));
            memmove(&b, &b_fpr, sizeof(double));
            c = a * b;
            c_fpr = fpr_mul(a_fpr, b_fpr);
            printf("%16llx, %16llx: %16llx, %16llx\n", *(uint64_t*)&a_fpr, *(uint64_t*)&b_fpr,
                                                       *(uint64_t*)&c, *(uint64_t*)&c_fpr);
        }
    }



}

