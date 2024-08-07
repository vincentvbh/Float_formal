
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
    "asrs   r4, r1, #20\n\t"
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
