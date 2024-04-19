#ifndef FLOAT_FFT_H
#define FLOAT_FFT_H

#include "interval.h"

#include <stdint.h>
#include <stddef.h>

extern struct interval twiddle_interval[2048];

typedef struct { double v; } fpr;

fpr FPR(double v);
fpr fpr_of(int64_t i);

extern fpr fpr_q;
extern fpr fpr_inverse_of_q;
extern fpr fpr_inv_2sqrsigma0;
extern fpr fpr_inv_sigma[11];
extern fpr fpr_sigma_min[11];
extern fpr fpr_log2;
extern fpr fpr_inv_log2;
extern fpr fpr_bnorm_max;
extern fpr fpr_zero;
extern fpr fpr_one;
extern fpr fpr_two;
extern fpr fpr_onehalf;
extern fpr fpr_invsqrt2;
extern fpr fpr_invsqrt8;
extern fpr fpr_ptwo31;
extern fpr fpr_ptwo31m1;
extern fpr fpr_mtwo31m1;
extern fpr fpr_ptwo63m1;
extern fpr fpr_mtwo63m1;
extern fpr fpr_ptwo63;

int64_t fpr_rint(fpr x);
int64_t fpr_floor(fpr x);
int64_t fpr_trunc(fpr x);

fpr fpr_add(fpr x, fpr y);
fpr fpr_sub(fpr x, fpr y);
fpr fpr_neg(fpr x);
fpr fpr_half(fpr x);
fpr fpr_double(fpr x);
fpr fpr_mul(fpr x, fpr y);
fpr fpr_sqr(fpr x);
fpr fpr_inv(fpr x);
fpr fpr_div(fpr x, fpr y);

extern fpr fpr_gm_tab[2048];
extern fpr fpr_p2_tab[11];

void FFT(fpr *f, unsigned logn);
void iFFT(fpr *f, unsigned logn);
void poly_mul_fft(fpr *a, fpr *b, unsigned logn);

void FFT_interval(struct interval *f, unsigned logn);

/*
 * Rules for complex number macros:
 * --------------------------------
 *
 * Operand order is: destination, source1, source2...
 *
 * Each operand is a real and an imaginary part.
 *
 * All overlaps are allowed.
 */

/*
 * Addition of two complex numbers (d = a + b).
 */
#define FPC_ADD(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        fpr fpct_re, fpct_im; \
        fpct_re = fpr_add(a_re, b_re); \
        fpct_im = fpr_add(a_im, b_im); \
        (d_re) = fpct_re; \
        (d_im) = fpct_im; \
    } while (0)

#define FPC_INTERVAL_ADD(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        struct interval fpct_re, fpct_im; \
        interval_ring.addZ(&fpct_re, &a_re, &b_re); \
        interval_ring.addZ(&fpct_im, &a_im, &b_im); \
        (d_re) = fpct_re; \
        (d_im) = fpct_im; \
    } while (0)

/*
 * Subtraction of two complex numbers (d = a - b).
 */
#define FPC_SUB(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        fpr fpct_re, fpct_im; \
        fpct_re = fpr_sub(a_re, b_re); \
        fpct_im = fpr_sub(a_im, b_im); \
        (d_re) = fpct_re; \
        (d_im) = fpct_im; \
    } while (0)

#define FPC_INTERVAL_SUB(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        struct interval fpct_re, fpct_im; \
        interval_ring.subZ(&fpct_re, &a_re, &b_re); \
        interval_ring.subZ(&fpct_im, &a_im, &b_im); \
        (d_re) = fpct_re; \
        (d_im) = fpct_im; \
    } while (0)

/*
 * Multplication of two complex numbers (d = a * b).
 */
#define FPC_MUL(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        fpr fpct_a_re, fpct_a_im; \
        fpr fpct_b_re, fpct_b_im; \
        fpr fpct_d_re, fpct_d_im; \
        fpct_a_re = (a_re); \
        fpct_a_im = (a_im); \
        fpct_b_re = (b_re); \
        fpct_b_im = (b_im); \
        fpct_d_re = fpr_sub( \
            fpr_mul(fpct_a_re, fpct_b_re), \
            fpr_mul(fpct_a_im, fpct_b_im)); \
        fpct_d_im = fpr_add( \
            fpr_mul(fpct_a_re, fpct_b_im), \
            fpr_mul(fpct_a_im, fpct_b_re)); \
        (d_re) = fpct_d_re; \
        (d_im) = fpct_d_im; \
    } while (0)


#define FPC_INTERVAL_MUL(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        struct interval fpct_a_re, fpct_a_im; \
        struct interval fpct_b_re, fpct_b_im; \
        struct interval fpct_d_re, fpct_d_im; \
        struct interval t; \
        fpct_a_re = (a_re); \
        fpct_a_im = (a_im); \
        fpct_b_re = (b_re); \
        fpct_b_im = (b_im); \
        interval_ring.mulZ(&fpct_d_re, &fpct_a_re, &fpct_b_re); \
        interval_ring.mulZ(&t, &fpct_a_im, &fpct_b_im); \
        interval_ring.subZ(&fpct_d_re, &fpct_d_re, &t); \
        interval_ring.mulZ(&fpct_d_im, &fpct_a_re, &fpct_b_im); \
        interval_ring.mulZ(&t, &fpct_a_im, &fpct_b_re); \
        interval_ring.addZ(&fpct_d_im, &fpct_d_im, &t); \
        (d_re) = fpct_d_re; \
        (d_im) = fpct_d_im; \
    } while (0)


/*
 * Squaring of a complex number (d = a * a).
 */
#define FPC_SQR(d_re, d_im, a_re, a_im)   do { \
        fpr fpct_a_re, fpct_a_im; \
        fpr fpct_d_re, fpct_d_im; \
        fpct_a_re = (a_re); \
        fpct_a_im = (a_im); \
        fpct_d_re = fpr_sub(fpr_sqr(fpct_a_re), fpr_sqr(fpct_a_im)); \
        fpct_d_im = fpr_double(fpr_mul(fpct_a_re, fpct_a_im)); \
        (d_re) = fpct_d_re; \
        (d_im) = fpct_d_im; \
    } while (0)

/*
 * Inversion of a complex number (d = 1 / a).
 */
#define FPC_INV(d_re, d_im, a_re, a_im)   do { \
        fpr fpct_a_re, fpct_a_im; \
        fpr fpct_d_re, fpct_d_im; \
        fpr fpct_m; \
        fpct_a_re = (a_re); \
        fpct_a_im = (a_im); \
        fpct_m = fpr_add(fpr_sqr(fpct_a_re), fpr_sqr(fpct_a_im)); \
        fpct_m = fpr_inv(fpct_m); \
        fpct_d_re = fpr_mul(fpct_a_re, fpct_m); \
        fpct_d_im = fpr_mul(fpr_neg(fpct_a_im), fpct_m); \
        (d_re) = fpct_d_re; \
        (d_im) = fpct_d_im; \
    } while (0)

/*
 * Division of complex numbers (d = a / b).
 */
#define FPC_DIV(d_re, d_im, a_re, a_im, b_re, b_im)   do { \
        fpr fpct_a_re, fpct_a_im; \
        fpr fpct_b_re, fpct_b_im; \
        fpr fpct_d_re, fpct_d_im; \
        fpr fpct_m; \
        fpct_a_re = (a_re); \
        fpct_a_im = (a_im); \
        fpct_b_re = (b_re); \
        fpct_b_im = (b_im); \
        fpct_m = fpr_add(fpr_sqr(fpct_b_re), fpr_sqr(fpct_b_im)); \
        fpct_m = fpr_inv(fpct_m); \
        fpct_b_re = fpr_mul(fpct_b_re, fpct_m); \
        fpct_b_im = fpr_mul(fpr_neg(fpct_b_im), fpct_m); \
        fpct_d_re = fpr_sub( \
            fpr_mul(fpct_a_re, fpct_b_re), \
            fpr_mul(fpct_a_im, fpct_b_im)); \
        fpct_d_im = fpr_add( \
            fpr_mul(fpct_a_re, fpct_b_im), \
            fpr_mul(fpct_a_im, fpct_b_re)); \
        (d_re) = fpct_d_re; \
        (d_im) = fpct_d_im; \
    } while (0)

#endif

