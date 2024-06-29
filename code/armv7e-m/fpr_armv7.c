
#include "fpr.h"

#include <assert.h>
#include <memory.h>
#include <stdio.h>

__attribute__((naked))
fpr
fpr_add_new(fpr x __attribute__((unused)), fpr y __attribute__((unused)))
{
    __asm__ (
    "push   { r4, r5, r6, r7, r8, r10, r11, lr }\n\t"
    "\n\t"
    "@ Make sure that the first operand (x) has the larger absolute\n\t"
    "@ value. This guarantees that the exponent of y is less than\n\t"
    "@ or equal to the exponent of x, and, if they are equal, then\n\t"
    "@ the mantissa of y will not be greater than the mantissa of x.\n\t"
    "@ However, if absolute values are equal and the sign of x is 1,\n\t"
    "@ then we want to also swap the values.\n\t"
    "ubfx   r4, r1, #0, #31  @ top word without sign bit\n\t"
    "ubfx   r5, r3, #0, #31  @ top word without sign bit\n\t"
    "subs   r7, r0, r2       @ difference in r7:r4\n\t"
    "sbcs   r4, r5\n\t"
    "orrs   r7, r4\n\t"
    "rsbs   r5, r7, #0\n\t"
    "orrs   r7, r5      @ bit 31 of r7 is 0 iff difference is zero\n\t"
    "bics   r6, r1, r7\n\t"
    "orrs   r6, r4      @ bit 31 of r6 is 1 iff the swap must be done\n\t"
    "\n\t"
    "@ Conditional swap\n\t"
    "eors   r4, r0, r2\n\t"
    "eors   r5, r1, r3\n\t"
    "ands   r4, r4, r6, asr #31\n\t"
    "ands   r5, r5, r6, asr #31\n\t"
    "eors   r0, r4\n\t"
    "eors   r1, r5\n\t"
    "eors   r2, r4\n\t"
    "eors   r3, r5\n\t"
    "\n\t"
    "@ Extract mantissa of x into r0:r1, exponent in r4, sign in r5\n\t"
    "ubfx   r4, r1, #20, #11   @ Exponent in r4 (without sign)\n\t"
    "addw   r5, r4, #2047 @ Get a carry to test r4 for zero\n\t"
    "lsrs   r5, #11       @ r5 is the mantissa implicit high bit\n\t"
    "bfc    r1, #20, #11  @ Clear exponent bits (not the sign)\n\t"
    "orrs   r1, r1, r5, lsl #20  @ Set mantissa high bit\n\t"
    "asrs   r5, r1, #31   @ Get sign bit (sign-extended)\n\t"
    "bfc    r1, #31, #1   @ Clear the sign bit\n\t"
    "\n\t"
    "@ Extract mantissa of y into r2:r3, exponent in r6, sign in r7\n\t"
    "ubfx   r6, r3, #20, #11   @ Exponent in r6 (without sign)\n\t"
    "addw   r7, r6, #2047 @ Get a carry to test r6 for zero\n\t"
    "lsrs   r7, #11       @ r7 is the mantissa implicit high bit\n\t"
    "bfc    r3, #20, #11  @ Clear exponent bits (not the sign)\n\t"
    "orrs   r3, r3, r7, lsl #20  @ Set mantissa high bit\n\t"
    "asrs   r7, r3, #31   @ Get sign bit (sign-extended)\n\t"
    "bfc    r3, #31, #1   @ Clear the sign bit\n\t"
    "\n\t"
    "@ Scale mantissas up by three bits.\n\t"
    "lsls   r1, #3\n\t"
    "orrs   r1, r1, r0, lsr #29\n\t"
    "lsls   r0, #3\n\t"
    "lsls   r3, #3\n\t"
    "orrs   r3, r3, r2, lsr #29\n\t"
    "lsls   r2, #3\n\t"
    "\n\t"
    "@ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "@ y: exponent=r6, sign=r7, mantissa=r2:r3 (scaled up 3 bits)\n\t"
    "\n\t"
    "@ At that point, the exponent of x (in r4) is larger than that\n\t"
    "@ of y (in r6). The difference is the amount of shifting that\n\t"
    "@ should be done on y. If that amount is larger than 59 then\n\t"
    "@ we clamp y to 0. We won't need y's exponent beyond that point,\n\t"
    "@ so we store that shift count in r6.\n\t"
    "subs   r6, r4, r6\n\t"
    "subs   r8, r6, #60\n\t"
    "ands   r2, r2, r8, asr #31\n\t"
    "ands   r3, r3, r8, asr #31\n\t"
    "\n\t"
    "@ Shift right r2:r3 by r6 bits. The shift count is in the 0..59\n\t"
    "@ range. r11 will be non-zero if and only if some non-zero bits\n\t"
    "@ were dropped.\n\t"
    "subs   r8, r6, #32\n\t"
    "bics   r11, r2, r8, asr #31\n\t"
    "ands   r2, r2, r8, asr #31\n\t"
    "bics   r10, r3, r8, asr #31\n\t"
    "orrs   r2, r2, r10\n\t"
    "ands   r3, r3, r8, asr #31\n\t"
    "ands   r6, r6, #31\n\t"
    "rsbs   r8, r6, #32\n\t"
    "lsls   r10, r2, r8\n\t"
    "orrs   r11, r11, r10\n\t"
    "lsrs   r2, r2, r6\n\t"
    "lsls   r10, r3, r8\n\t"
    "orrs   r2, r2, r10\n\t"
    "lsrs   r3, r3, r6\n\t"
    "\n\t"
    "@ If r11 is non-zero then some non-zero bit was dropped and the\n\t"
    "@ low bit of r2 must be forced to 1 ('sticky bit').\n\t"
    "rsbs   r6, r11, #0\n\t"
    "orrs   r6, r6, r11\n\t"
    "orrs   r2, r2, r6, lsr #31\n\t"
    "\n\t"
    "@ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "@ y: sign=r7, value=r2:r3 (scaled to same exponent as x)\n\t"
    "\n\t"
    "@ If x and y don't have the same sign, then we should negate r2:r3\n\t"
    "@ (i.e. subtract the mantissa instead of adding it). Signs of x\n\t"
    "@ and y are in r5 and r7, as full-width words. We won't need r7\n\t"
    "@ afterwards.\n\t"
    "eors   r7, r5    @ r7 = -1 if y must be negated, 0 otherwise\n\t"
    "eors   r2, r7\n\t"
    "eors   r3, r7\n\t"
    "subs   r2, r7\n\t"
    "sbcs   r3, r7\n\t"
    "\n\t"
    "@ r2:r3 has been shifted, we can add to r0:r1.\n\t"
    "adds   r0, r2\n\t"
    "adcs   r1, r3\n\t"
    "\n\t"
    "@ result: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "\n\t"
    "@ Normalize the result with some left-shifting to full 64-bit\n\t"
    "@ width. Shift count goes to r2, and exponent (r4) is adjusted.\n\t"
    "clz    r2, r0\n\t"
    "clz    r3, r1\n\t"
    "sbfx   r6, r3, #5, #1\n\t"
    "ands   r2, r6\n\t"
    "adds   r2, r2, r3\n\t"
    "subs   r4, r4, r2\n\t"
    "\n\t"
    "@ Shift r0:r1 to the left by r2 bits.\n\t"
    "subs   r7, r2, #32\n\t"
    "lsls   r7, r0, r7\n\t"
    "lsls   r1, r1, r2\n\t"
    "rsbs   r6, r2, #32\n\t"
    "orrs   r1, r1, r7\n\t"
    "lsrs   r6, r0, r6\n\t"
    "orrs   r1, r1, r6\n\t"
    "lsls   r0, r0, r2\n\t"
    "\n\t"
    "@ The exponent of x was in r4. The left-shift operation has\n\t"
    "@ subtracted some value from it, 8 in case the result has the\n\t"
    "@ same exponent as x. However, the high bit of the mantissa will\n\t"
    "@ add 1 to the exponent, so we only add back 7 (the exponent is\n\t"
    "@ added in because rounding might have produced a carry, which\n\t"
    "@ should then spill into the exponent).\n\t"
    "adds   r4, #7\n\t"
    "\n\t"
    "@ If the mantissa new mantissa is non-zero, then its bit 63 is\n\t"
    "@ non-zero (thanks to the normalizing shift). Otherwise, that bit\n\t"
    "@ is zero, and we should then set the exponent to zero as well.\n\t"
    "ands   r4, r4, r1, asr #31\n\t"
    "\n\t"
    "@ Shrink back the value to a 52-bit mantissa. This requires\n\t"
    "@ right-shifting by 11 bits; we keep a copy of the pre-shift\n\t"
    "@ low word in r3.\n\t"
    "movs   r3, r0\n\t"
    "lsrs   r0, #11\n\t"
    "orrs   r0, r0, r1, lsl #21\n\t"
    "lsrs   r1, #11\n\t"
    "\n\t"
    "@ Apply rounding.\n\t"
    "ubfx   r6, r3, #0, #9\n\t"
    "addw   r6, r6, #511\n\t"
    "orrs   r3, r6\n\t"
    "ubfx   r3, r3, #9, #3\n\t"
    "movs   r6, #0xC8\n\t"
    "lsrs   r6, r3\n\t"
    "ands   r6, #1\n\t"
    "adds   r0, r6\n\t"
    "adcs   r1, #0\n\t"
    "\n\t"
    "@ Plug in the exponent with an addition.\n\t"
    "adds   r4, r4, r1, lsr #20\n\t"
    "\n\t"
    "@ If the new exponent is negative or zero, then it underflowed\n\t"
    "@ and we must clear the whole mantissa and exponent.\n\t"
    "rsbs   r6, r4, #0\n\t"
    "ands   r0, r0, r6, asr #31\n\t"
    "ands   r1, r1, r6, asr #31\n\t"
    "ands   r4, r4, r6, asr #31\n\t"
    "@ Saturation\n\t"
    "rsbs   r6, r4, #2048\n\t"
    "subs   r6, r6, #2\n\t"
    "orrs   r0, r0, r6, asr #31\n\t"
    "orrs   r1, r1, r6, asr #31\n\t"
    "orrs   r4, r4, r6, asr #31\n\t"
    "subs   r4, r4, r6, lsr #31\n\t"
    "@ Combine the exponent and mantissa\n\t"
    "bfi    r1, r4, #20, #11\n\t"
    "\n\t"
    "@ Put back the sign. This is the sign of x: thanks to the\n\t"
    "@ conditional swap at the start, this is always correct.\n\t"
    "bfi    r1, r5, #31, #1\n\t"
    "\n\t"
    "pop    { r4, r5, r6, r7, r8, r10, r11, pc }\n\t"
    );
}

__attribute__((naked))
fpr
fpr_add(fpr x __attribute__((unused)), fpr y __attribute__((unused)))
{
    __asm__ (
    "push   { r4, r5, r6, r7, r8, r10, r11, lr }\n\t"
    "\n\t"
    "@ Make sure that the first operand (x) has the larger absolute\n\t"
    "@ value. This guarantees that the exponent of y is less than\n\t"
    "@ or equal to the exponent of x, and, if they are equal, then\n\t"
    "@ the mantissa of y will not be greater than the mantissa of x.\n\t"
    "@ However, if absolute values are equal and the sign of x is 1,\n\t"
    "@ then we want to also swap the values.\n\t"
    "ubfx   r4, r1, #0, #31  @ top word without sign bit\n\t"
    "ubfx   r5, r3, #0, #31  @ top word without sign bit\n\t"
    "subs   r7, r0, r2       @ difference in r7:r4\n\t"
    "sbcs   r4, r5\n\t"
    "orrs   r7, r4\n\t"
    "rsbs   r5, r7, #0\n\t"
    "orrs   r7, r5      @ bit 31 of r7 is 0 iff difference is zero\n\t"
    "bics   r6, r1, r7\n\t"
    "orrs   r6, r4      @ bit 31 of r6 is 1 iff the swap must be done\n\t"
    "\n\t"
    "@ Conditional swap\n\t"
    "eors   r4, r0, r2\n\t"
    "eors   r5, r1, r3\n\t"
    "ands   r4, r4, r6, asr #31\n\t"
    "ands   r5, r5, r6, asr #31\n\t"
    "eors   r0, r4\n\t"
    "eors   r1, r5\n\t"
    "eors   r2, r4\n\t"
    "eors   r3, r5\n\t"
    "\n\t"
    "@ Extract mantissa of x into r0:r1, exponent in r4, sign in r5\n\t"
    "ubfx   r4, r1, #20, #11   @ Exponent in r4 (without sign)\n\t"
    "addw   r5, r4, #2047 @ Get a carry to test r4 for zero\n\t"
    "lsrs   r5, #11       @ r5 is the mantissa implicit high bit\n\t"
    "bfc    r1, #20, #11  @ Clear exponent bits (not the sign)\n\t"
    "orrs   r1, r1, r5, lsl #20  @ Set mantissa high bit\n\t"
    "asrs   r5, r1, #31   @ Get sign bit (sign-extended)\n\t"
    "bfc    r1, #31, #1   @ Clear the sign bit\n\t"
    "\n\t"
    "@ Extract mantissa of y into r2:r3, exponent in r6, sign in r7\n\t"
    "ubfx   r6, r3, #20, #11   @ Exponent in r6 (without sign)\n\t"
    "addw   r7, r6, #2047 @ Get a carry to test r6 for zero\n\t"
    "lsrs   r7, #11       @ r7 is the mantissa implicit high bit\n\t"
    "bfc    r3, #20, #11  @ Clear exponent bits (not the sign)\n\t"
    "orrs   r3, r3, r7, lsl #20  @ Set mantissa high bit\n\t"
    "asrs   r7, r3, #31   @ Get sign bit (sign-extended)\n\t"
    "bfc    r3, #31, #1   @ Clear the sign bit\n\t"
    "\n\t"
    "@ Scale mantissas up by three bits.\n\t"
    "lsls   r1, #3\n\t"
    "orrs   r1, r1, r0, lsr #29\n\t"
    "lsls   r0, #3\n\t"
    "lsls   r3, #3\n\t"
    "orrs   r3, r3, r2, lsr #29\n\t"
    "lsls   r2, #3\n\t"
    "\n\t"
    "@ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "@ y: exponent=r6, sign=r7, mantissa=r2:r3 (scaled up 3 bits)\n\t"
    "\n\t"
    "@ At that point, the exponent of x (in r4) is larger than that\n\t"
    "@ of y (in r6). The difference is the amount of shifting that\n\t"
    "@ should be done on y. If that amount is larger than 59 then\n\t"
    "@ we clamp y to 0. We won't need y's exponent beyond that point,\n\t"
    "@ so we store that shift count in r6.\n\t"
    "subs   r6, r4, r6\n\t"
    "subs   r8, r6, #60\n\t"
    "ands   r2, r2, r8, asr #31\n\t"
    "ands   r3, r3, r8, asr #31\n\t"
    "\n\t"
    "@ Shift right r2:r3 by r6 bits. The shift count is in the 0..59\n\t"
    "@ range. r11 will be non-zero if and only if some non-zero bits\n\t"
    "@ were dropped.\n\t"
    "subs   r8, r6, #32\n\t"
    "bics   r11, r2, r8, asr #31\n\t"
    "ands   r2, r2, r8, asr #31\n\t"
    "bics   r10, r3, r8, asr #31\n\t"
    "orrs   r2, r2, r10\n\t"
    "ands   r3, r3, r8, asr #31\n\t"
    "ands   r6, r6, #31\n\t"
    "rsbs   r8, r6, #32\n\t"
    "lsls   r10, r2, r8\n\t"
    "orrs   r11, r11, r10\n\t"
    "lsrs   r2, r2, r6\n\t"
    "lsls   r10, r3, r8\n\t"
    "orrs   r2, r2, r10\n\t"
    "lsrs   r3, r3, r6\n\t"
    "\n\t"
    "@ If r11 is non-zero then some non-zero bit was dropped and the\n\t"
    "@ low bit of r2 must be forced to 1 ('sticky bit').\n\t"
    "rsbs   r6, r11, #0\n\t"
    "orrs   r6, r6, r11\n\t"
    "orrs   r2, r2, r6, lsr #31\n\t"
    "\n\t"
    "@ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "@ y: sign=r7, value=r2:r3 (scaled to same exponent as x)\n\t"
    "\n\t"
    "@ If x and y don't have the same sign, then we should negate r2:r3\n\t"
    "@ (i.e. subtract the mantissa instead of adding it). Signs of x\n\t"
    "@ and y are in r5 and r7, as full-width words. We won't need r7\n\t"
    "@ afterwards.\n\t"
    "eors   r7, r5    @ r7 = -1 if y must be negated, 0 otherwise\n\t"
    "eors   r2, r7\n\t"
    "eors   r3, r7\n\t"
    "subs   r2, r7\n\t"
    "sbcs   r3, r7\n\t"
    "\n\t"
    "@ r2:r3 has been shifted, we can add to r0:r1.\n\t"
    "adds   r0, r2\n\t"
    "adcs   r1, r3\n\t"
    "\n\t"
    "@ result: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits)\n\t"
    "\n\t"
    "@ Normalize the result with some left-shifting to full 64-bit\n\t"
    "@ width. Shift count goes to r2, and exponent (r4) is adjusted.\n\t"
    "clz    r2, r0\n\t"
    "clz    r3, r1\n\t"
    "sbfx   r6, r3, #5, #1\n\t"
    "ands   r2, r6\n\t"
    "adds   r2, r2, r3\n\t"
    "subs   r4, r4, r2\n\t"
    "\n\t"
    "@ Shift r0:r1 to the left by r2 bits.\n\t"
    "subs   r7, r2, #32\n\t"
    "lsls   r7, r0, r7\n\t"
    "lsls   r1, r1, r2\n\t"
    "rsbs   r6, r2, #32\n\t"
    "orrs   r1, r1, r7\n\t"
    "lsrs   r6, r0, r6\n\t"
    "orrs   r1, r1, r6\n\t"
    "lsls   r0, r0, r2\n\t"
    "\n\t"
    "@ The exponent of x was in r4. The left-shift operation has\n\t"
    "@ subtracted some value from it, 8 in case the result has the\n\t"
    "@ same exponent as x. However, the high bit of the mantissa will\n\t"
    "@ add 1 to the exponent, so we only add back 7 (the exponent is\n\t"
    "@ added in because rounding might have produced a carry, which\n\t"
    "@ should then spill into the exponent).\n\t"
    "adds   r4, #7\n\t"
    "\n\t"
    "@ If the mantissa new mantissa is non-zero, then its bit 63 is\n\t"
    "@ non-zero (thanks to the normalizing shift). Otherwise, that bit\n\t"
    "@ is zero, and we should then set the exponent to zero as well.\n\t"
    "ands   r4, r4, r1, asr #31\n\t"
    "\n\t"
    "@ Shrink back the value to a 52-bit mantissa. This requires\n\t"
    "@ right-shifting by 11 bits; we keep a copy of the pre-shift\n\t"
    "@ low word in r3.\n\t"
    "movs   r3, r0\n\t"
    "lsrs   r0, #11\n\t"
    "orrs   r0, r0, r1, lsl #21\n\t"
    "lsrs   r1, #11\n\t"
    "\n\t"
    "@ Apply rounding.\n\t"
    "ubfx   r6, r3, #0, #9\n\t"
    "addw   r6, r6, #511\n\t"
    "orrs   r3, r6\n\t"
    "ubfx   r3, r3, #9, #3\n\t"
    "movs   r6, #0xC8\n\t"
    "lsrs   r6, r3\n\t"
    "ands   r6, #1\n\t"
    "adds   r0, r6\n\t"
    "adcs   r1, #0\n\t"
    "\n\t"
    "@Plug in the exponent with an addition.\n\t"
    "adds   r1, r1, r4, lsl #20\n\t"
    "\n\t"
    "@ If the new exponent is negative or zero, then it underflowed\n\t"
    "@ and we must clear the whole mantissa and exponent.\n\t"
    "rsbs   r4, r4, #0\n\t"
    "ands   r0, r0, r4, asr #31\n\t"
    "ands   r1, r1, r4, asr #31\n\t"
    "\n\t"
    "@ Put back the sign. This is the sign of x: thanks to the\n\t"
    "@ conditional swap at the start, this is always correct.\n\t"
    "bfi    r1, r5, #31, #1\n\t"
    "\n\t"
    "pop    { r4, r5, r6, r7, r8, r10, r11, pc }\n\t"
    );
}

__attribute__((naked))
fpr
fpr_mul_new(fpr x __attribute__((unused)), fpr y __attribute__((unused)))
{
    __asm__ (
    "push   { r4, r5, r6, r7, r8, r9, r10, r11, lr }\n\t"
    "\n\t"
    "@ Extract mantissas: x.m = r4:r5, y.m = r6:r7\n\t"
    "@ r4 and r6 contain only 25 bits each.\n\t"
    "bics   r4, r0, #0xfe000000\n\t"
    "lsls   r5, r1, #7\n\t"
    "orrs   r5, r5, r0, lsr #25\n\t"
    "bics   r5, r5, #0xf8000000\n\t"
    "ubfx   r8, r1, #20, #11\n\t"
    "addw   r8, r8, #0x7ff\n\t"
    "lsrs   r8, #11\n\t"
    "orrs   r5, r5, r8, lsl #27\n\t"
    "bics   r6, r2, #0xfe000000\n\t"
    "lsls   r7, r3, #7\n\t"
    "orrs   r7, r7, r2, lsr #25\n\t"
    "bics   r7, r7, #0xf8000000\n\t"
    "ubfx   r8, r3, #20, #11\n\t"
    "addw   r8, r8, #0x7ff\n\t"
    "lsrs   r8, #11\n\t"
    "orrs   r7, r7, r8, lsl #27\n\t"
    "\n\t"
    "@ Perform product. Values are in the 2^52..2^53-1 range, so\n\t"
    "@ the product is at most 106-bit long. Of the low 50 bits,\n\t"
    "@ we only want to know if they are all zeros or not. Here,\n\t"
    "@ we get the top 56 bits in r10:r11, and r8 will be non-zero\n\t"
    "@ if and only if at least one of the low 50 bits is non-zero.\n\t"
    "umull  r8, r10, r4, r6      @ x0*y0\n\t"
    "lsls   r10, #7\n\t"
    "orrs   r10, r10, r8, lsr #25\n\t"
    "eors   r11, r11\n\t"
    "umlal  r10, r11, r4, r7     @ x0*y1\n\t"
    "umlal  r10, r11, r5, r6     @ x1*y0\n\t"
    "orrs   r8, r8, r10, lsl #7\n\t"
    "lsrs   r10, #25\n\t"
    "orrs   r10, r10, r11, lsl #7\n\t"
    "eors   r11, r11\n\t"
    "umlal  r10, r11, r5, r7     @ x1*y1\n\t"
    "\n\t"
    "@ Now r0, r2, r4, r5, r6 and r7 are free.\n\t"
    "@ If any of the low 50 bits was non-zero, then we force the\n\t"
    "@ low bit of r10 to 1.\n\t"
    "rsbs   r4, r8, #0\n\t"
    "orrs   r8, r8, r4\n\t"
    "orrs   r10, r10, r8, lsr #31\n\t"
    "\n\t"
    "@ r8 is free.\n\t"
    "@ r10:r11 contains the product in the 2^54..2^56-1 range. We\n\t"
    "@ normalize it to 2^54..2^55-1 (into r6:r7) with a conditional\n\t"
    "@ shift (low bit is sticky). r5 contains -1 if the shift was done,\n\t"
    "@ 0 otherwise.\n\t"
    "ands   r6, r10, #1\n\t"
    "lsrs   r5, r11, #23\n\t"
    "rsbs   r5, r5, #0\n\t"
    "orrs   r6, r6, r10, lsr #1\n\t"
    "orrs   r6, r6, r11, lsl #31\n\t"
    "lsrs   r7, r11, #1\n\t"
    "eors   r10, r10, r6\n\t"
    "eors   r11, r11, r7\n\t"
    "bics   r10, r10, r5\n\t"
    "bics   r11, r11, r5\n\t"
    "eors   r6, r6, r10\n\t"
    "eors   r7, r7, r11\n\t"
    "\n\t"
    "@ Compute aggregate exponent: ex + ey - 1023 + w\n\t"
    "@ (where w = 1 if the conditional shift was done, 0 otherwise)\n\t"
    "ubfx   r0, r1, #20, #11\n\t"
    "ubfx   r2, r3, #20, #11\n\t"
    "adds   r2, r0\n\t"
    "subw   r2, r2, #1023\n\t"
    "subs   r2, r5\n\t"
    "\n\t"
    "@ Compute the sign and put it to the 31th bit of r3\n\t"
    "eors   r3, r1, r3\n\t"
    "lsrs   r3, r3, #31\n\t"
    "@ Shift back to the normal 53-bit mantissa, with rounding.\n\t"
    "lsrs   r0, r6, #2\n\t"
    "orrs   r0, r0, r7, lsl #30\n\t"
    "lsrs   r1, r7, #2\n\t"
    "orrs   r7, r6, r6, lsr #2\n\t"
    "ands   r7, r7, r6, lsr #1\n\t"
    "ands   r7, #1\n\t"
    "adds   r0, r7\n\t"
    "adcs   r1, r1, #0\n\t"
    "adds   r2, r2, r1, lsr #21\n\t"
    "@ Zeroization\n\t"
    "orrs   r4, r0, r1\n\t"
    "rsbs   r5, r4, #0\n\t"
    "orrs   r4, r4, r5\n\t"
    "ands   r2, r2, r4, asr #31\n\t"
    "rsbs   r4, r2, #0\n\t"
    "ands   r0, r0, r4, asr #31\n\t"
    "ands   r1, r1, r4, asr #31\n\t"
    "ands   r2, r2, r4, asr #31\n\t"
    "@ Saturation\n\t"
    "rsbs   r4, r2, #2048\n\t"
    "subs   r4, r4, #2\n\t"
    "orrs   r0, r0, r4, asr #31\n\t"
    "orrs   r1, r1, r4, asr #31\n\t"
    "orrs   r2, r2, r4, asr #31\n\t"
    "subs   r2, r2, r4, lsr #31\n\t"
    "bfi    r1, r2, #20, #11\n\t"
    "bfi    r1, r3, #31, #1\n\t"
    "pop    { r4, r5, r6, r7, r8, r9, r10, r11, pc }\n\t"
    );
}

__attribute__((naked))
fpr
fpr_mul(fpr x __attribute__((unused)), fpr y __attribute__((unused)))
{
    __asm__ (
    "push   { r4, r5, r6, r7, r8, r10, r11, lr }\n\t"
    "\n\t"
    "@ Extract mantissas: x.m = r4:r5, y.m = r6:r7\n\t"
    "@ r4 and r6 contain only 25 bits each.\n\t"
    "bics   r4, r0, #0xFE000000\n\t"
    "lsls   r5, r1, #7\n\t"
    "orrs   r5, r5, r0, lsr #25\n\t"
    "orrs   r5, r5, #0x08000000\n\t"
    "bics   r5, r5, #0xF0000000\n\t"
    "bics   r6, r2, #0xFE000000\n\t"
    "lsls   r7, r3, #7\n\t"
    "orrs   r7, r7, r2, lsr #25\n\t"
    "orrs   r7, r7, #0x08000000\n\t"
    "bics   r7, r7, #0xF0000000\n\t"
    "\n\t"
    "@ Perform product. Values are in the 2^52..2^53-1 range, so\n\t"
    "@ the product is at most 106-bit long. Of the low 50 bits,\n\t"
    "@ we only want to know if they are all zeros or not. Here,\n\t"
    "@ we get the top 56 bits in r10:r11, and r8 will be non-zero\n\t"
    "@ if and only if at least one of the low 50 bits is non-zero.\n\t"
    "umull  r8, r10, r4, r6      @ x0*y0\n\t"
    "lsls   r10, #7\n\t"
    "orrs   r10, r10, r8, lsr #25\n\t"
    "eors   r11, r11\n\t"
    "umlal  r10, r11, r4, r7     @ x0*y1\n\t"
    "umlal  r10, r11, r5, r6     @ x1*y0\n\t"
    "orrs   r8, r8, r10, lsl #7\n\t"
    "lsrs   r10, #25\n\t"
    "orrs   r10, r10, r11, lsl #7\n\t"
    "eors   r11, r11\n\t"
    "umlal  r10, r11, r5, r7     @ x1*y1\n\t"
    "\n\t"
    "@ Now r0, r2, r4, r5, r6 and r7 are free.\n\t"
    "@ If any of the low 50 bits was non-zero, then we force the\n\t"
    "@ low bit of r10 to 1.\n\t"
    "rsbs   r4, r8, #0\n\t"
    "orrs   r8, r8, r4\n\t"
    "orrs   r10, r10, r8, lsr #31\n\t"
    "\n\t"
    "@ r8 is free.\n\t"
    "@ r10:r11 contains the product in the 2^54..2^56-1 range. We\n\t"
    "@ normalize it to 2^54..2^55-1 (into r6:r7) with a conditional\n\t"
    "@ shift (low bit is sticky). r5 contains -1 if the shift was done,\n\t"
    "@ 0 otherwise.\n\t"
    "ands   r6, r10, #1\n\t"
    "lsrs   r5, r11, #23\n\t"
    "rsbs   r5, r5, #0\n\t"
    "orrs   r6, r6, r10, lsr #1\n\t"
    "orrs   r6, r6, r11, lsl #31\n\t"
    "lsrs   r7, r11, #1\n\t"
    "eors   r10, r10, r6\n\t"
    "eors   r11, r11, r7\n\t"
    "bics   r10, r10, r5\n\t"
    "bics   r11, r11, r5\n\t"
    "eors   r6, r6, r10\n\t"
    "eors   r7, r7, r11\n\t"
    "\n\t"
    "@ Compute aggregate exponent: ex + ey - 1023 + w\n\t"
    "@ (where w = 1 if the conditional shift was done, 0 otherwise)\n\t"
    "@ But we subtract 1 because the injection of the mantissa high\n\t"
    "@ bit will increment the exponent by 1.\n\t"
    "lsls   r0, r1, #1\n\t"
    "lsls   r2, r3, #1\n\t"
    "lsrs   r0, #21\n\t"
    "addw   r4, r0, #0x7FF   @ save ex + 2047 in r4\n\t"
    "lsrs   r2, #21\n\t"
    "addw   r8, r2, #0x7FF   @ save ey + 2047 in r8\n\t"
    "adds   r2, r0\n\t"
    "subw   r2, r2, #1024\n\t"
    "subs   r2, r5\n\t"
    "\n\t"
    "@ r5 is free.\n\t"
    "@ Also, if either of the source exponents is 0, or the result\n\t"
    "@ exponent is 0 or negative, then the result is zero and the\n\t"
    "@ mantissa and the exponent shall be clamped to zero. Since\n\t"
    "@ r2 contains the result exponent minus 1, we test on r2\n\t"
    "@ being strictly negative.\n\t"
    "ands   r4, r8    @ if bit 11 = 0 then one of the exponents was 0\n\t"
    "mvns   r5, r2\n\t"
    "ands   r5, r5, r4, lsl #20\n\t"
    "ands   r2, r2, r5, asr #31\n\t"
    "ands   r6, r6, r5, asr #31\n\t"
    "ands   r7, r7, r5, asr #31\n\t"
    "\n\t"
    "@ Sign is the XOR of the sign of the operands. This is true in\n\t"
    "@ all cases, including very small results (exponent underflow)\n\t"
    "@ and zeros.\n\t"
    "eors   r1, r3\n\t"
    "bfc    r1, #0, #31\n\t"
    "\n\t"
    "@ Plug in the exponent.\n\t"
    "bfi    r1, r2, #20, #11\n\t"
    "\n\t"
    "@ r2 and r3 are free.\n\t"
    "@ Shift back to the normal 53-bit mantissa, with rounding.\n\t"
    "@ Mantissa goes into r0:r1. For r1, we must use an addition\n\t"
    "@ because the rounding may have triggered a carry, that should\n\t"
    "@ be added to the exponent.\n\t"
    "movs   r4, r6\n\t"
    "lsrs   r0, r6, #2\n\t"
    "orrs   r0, r0, r7, lsl #30\n\t"
    "adds   r1, r1, r7, lsr #2\n\t"
    "ands   r4, #0x7\n\t"
    "movs   r3, #0xC8\n\t"
    "lsrs   r3, r4\n\t"
    "ands   r3, #1\n\t"
    "adds   r0, r3\n\t"
    "adcs   r1, #0\n\t"
    "\n\t"
    "pop    { r4, r5, r6, r7, r8, r10, r11, pc }\n\t"
    );
}

#define FPR_NORM64(m, e)   do { \
        uint32_t nt; \
 \
        (e) -= 63; \
 \
        nt = (uint32_t)((m) >> 32); \
        nt = (nt | -nt) >> 31; \
        (m) ^= ((m) ^ ((m) << 32)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt << 5); \
 \
        nt = (uint32_t)((m) >> 48); \
        nt = (nt | -nt) >> 31; \
        (m) ^= ((m) ^ ((m) << 16)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt << 4); \
 \
        nt = (uint32_t)((m) >> 56); \
        nt = (nt | -nt) >> 31; \
        (m) ^= ((m) ^ ((m) <<  8)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt << 3); \
 \
        nt = (uint32_t)((m) >> 60); \
        nt = (nt | -nt) >> 31; \
        (m) ^= ((m) ^ ((m) <<  4)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt << 2); \
 \
        nt = (uint32_t)((m) >> 62); \
        nt = (nt | -nt) >> 31; \
        (m) ^= ((m) ^ ((m) <<  2)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt << 1); \
 \
        nt = (uint32_t)((m) >> 63); \
        (m) ^= ((m) ^ ((m) <<  1)) & ((uint64_t)nt - 1); \
        (e) += (int)(nt); \
    } while (0)

fpr
fpr_scaled(int64_t i, int sc)
{
    /*
     * To convert from int to float, we have to do the following:
     *  1. Get the absolute value of the input, and its sign
     *  2. Shift right or left the value as appropriate
     *  3. Pack the result
     *
     * We can assume that the source integer is not -2^63.
     */
    int s, e;
    uint32_t t;
    uint64_t m;

    /*
     * Extract sign bit.
     * We have: -i = 1 + ~i
     */
    s = (int)((uint64_t)i >> 63);
    i ^= -(int64_t)s;
    i += s;

    /*
     * For now we suppose that i != 0.
     * Otherwise, we set m to i and left-shift it as much as needed
     * to get a 1 in the top bit. We can do that in a logarithmic
     * number of conditional shifts.
     */
    m = (uint64_t)i;
    e = 9 + sc;
    FPR_NORM64(m, e);

    /*
     * Now m is in the 2^63..2^64-1 range. We must divide it by 512;
     * if one of the dropped bits is a 1, this should go into the
     * "sticky bit".
     */
    m |= ((uint32_t)m & 0x1FF) + 0x1FF;
    m >>= 9;

    /*
     * Corrective action: if i = 0 then all of the above was
     * incorrect, and we clamp e and m down to zero.
     */
    t = (uint32_t)((uint64_t)(i | -i) >> 63);
    m &= -(uint64_t)t;
    e &= -(int)t;

    /*
     * Assemble back everything. The FPR() function will handle cases
     * where e is too low.
     */
    return FPR(s, e, m);
}

uint64_t
fpr_expm_p63(fpr x, fpr ccs)
{
    /*
     * Polynomial approximation of exp(-x) is taken from FACCT:
     *   https://eprint.iacr.org/2018/1234
     * Specifically, values are extracted from the implementation
     * referenced from the FACCT article, and available at:
     *   https://github.com/raykzhao/gaussian
     * Here, the coefficients have been scaled up by 2^63 and
     * converted to integers.
     *
     * Tests over more than 24 billions of random inputs in the
     * 0..log(2) range have never shown a deviation larger than
     * 2^(-50) from the true mathematical value.
     */
    static const uint64_t C[] = {
        0x00000004741183A3u,
        0x00000036548CFC06u,
        0x0000024FDCBF140Au,
        0x0000171D939DE045u,
        0x0000D00CF58F6F84u,
        0x000680681CF796E3u,
        0x002D82D8305B0FEAu,
        0x011111110E066FD0u,
        0x0555555555070F00u,
        0x155555555581FF00u,
        0x400000000002B400u,
        0x7FFFFFFFFFFF4800u,
        0x8000000000000000u
    };

    uint64_t z, y;
    unsigned u;
    uint32_t z0, z1, y0, y1;
    uint64_t a, b;
    uint64_t ty, tz;

    y = C[0];
    z = (uint64_t)fpr_trunc(fpr_mul(x, fpr_ptwo63)) << 1;
    for (u = 1; u < (sizeof C) / sizeof(C[0]); u ++) {
        /*
         * Compute product z * y over 128 bits, but keep only
         * the top 64 bits.
         *
         * TODO: On some architectures/compilers we could use
         * some intrinsics (__umulh() on MSVC) or other compiler
         * extensions (unsigned __int128 on GCC / Clang) for
         * improved speed; however, most 64-bit architectures
         * also have appropriate IEEE754 floating-point support,
         * which is better.
         */
        uint64_t c;

        z0 = (uint32_t)z;
        z1 = (uint32_t)(z >> 32);
        y0 = (uint32_t)y;
        y1 = (uint32_t)(y >> 32);
        a = ((uint64_t)z0 * (uint64_t)y1)
            + (((uint64_t)z0 * (uint64_t)y0) >> 32);
        b = ((uint64_t)z1 * (uint64_t)y0);
        c = (a >> 32) + (b >> 32);
        c += (((uint64_t)(uint32_t)a + (uint64_t)(uint32_t)b) >> 32);
        c += (uint64_t)z1 * (uint64_t)y1;
        y = C[u] - c;
    }


    /*
     * The scaling factor must be applied at the end. Since y is now
     * in fixed-point notation, we have to convert the factor to the
     * same format, and do an extra integer multiplication.
     */
    z = (uint64_t)fpr_trunc(fpr_mul(ccs, fpr_ptwo63)) << 1;
    z0 = (uint32_t)z;
    z1 = (uint32_t)(z >> 32);
    y0 = (uint32_t)y;
    y1 = (uint32_t)(y >> 32);
    a = ((uint64_t)z0 * (uint64_t)y1)
        + (((uint64_t)z0 * (uint64_t)y0) >> 32);
    b = ((uint64_t)z1 * (uint64_t)y0);
    y = (a >> 32) + (b >> 32);
    y += (((uint64_t)(uint32_t)a + (uint64_t)(uint32_t)b) >> 32);
    y += (uint64_t)z1 * (uint64_t)y1;

    return y;
}








