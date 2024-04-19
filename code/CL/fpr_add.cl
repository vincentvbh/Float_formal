
(*

cv -v -jobs 24 -isafety -no_carry_constraint -slicing fpr_add.cl
Parsing CryptoLine file:      [OK]     0.002615 seconds
Checking well-formedness:     [OK]     0.001362 seconds

Procedure main
--------------
Transforming to SSA form:     [OK]     0.000202 seconds
Normalizing specification:    [OK]     0.000263 seconds
Rewriting assignments:        [OK]     0.000086 seconds
Verifying program safety:
    Cut 0
        Round 1 (6 safety conditions, timeout = 300 seconds)
       Safety condition #4 [OK]
       Safety condition #3 [OK]
       Safety condition #5 [OK]
       Safety condition #2 [OK]
       Safety condition #1 [OK]
       Safety condition #0 [OK]
    Overall       [OK]     0.015195 seconds
Verifying range assertions:      [OK]     59.843497 seconds
Verifying range specification:      [OK]     0.000034 seconds
Rewriting value-preserved casting:  [OK]     0.000037 seconds
Verifying algebraic assertions:     [OK]     0.000200 seconds
Verifying algebraic specification:  [OK]     0.000017 seconds
Procedure verification:       [OK]     59.859832 seconds

Summary
-------
Verification result:       [OK]     59.863976 seconds

*)

proc main(uint1 s0, uint11 e0, uint52 m0, uint1 s1, uint11 e1, uint52 m1) =
{
    true
    &&
    and[
        or[and[e0 = 0@11, m0 = 0@52], and[0@11 < e0, e0 < 2047@11]],
        or[and[e1 = 0@11, m1 = 0@52], and[0@11 < e1, e1 < 2047@11]]
    ]
}


(* important notes: there are no instructions counting leading zeros in CryptoLine,
   we translate them into O(log n) many operations (where n is the number of bits of a value)
   based on the macro FPR_NORM64 in Falcon
 *)

(* we assume that r1 || r0 is the same as s0 || e0 || m0
   r0 and r1 are the actual input registers, but we specify the preconditions on s0, e0, and m0
*)
join t e0 m0;
join src0 s0 t;
spl r1 r0 src0 32;

join t e1 m1;
join src1 s1 t;
spl r3 r2 src1 32;

(* we assume that r3 || r2 is the same as s1 || e1 || m1
   r2 and r3 are the actual input registers, but we specify the preconditions on s1, e1, and m1
*)

join t0 e0 m0;
join t1 e1 m1;

(* swap to ensure that the absolute values of r1 || r0 is greater or equal to r3 || r2
   if the absolute values are the same, we swap if r1 || r0 is negative
*)

subb swap_bit t t0 t1;
subs discard nt@uint63 0@uint63 t;
or t@uint63 t nt;
shrs t discard t 62;
cast uint1 diffzero t;
not ndiffzero@uint1 diffzero;
and swap_same@uint1 ndiffzero s0;
or swap_final@uint1 swap_bit swap_same;

cmov t0 swap_final src1 src0;
cmov t1 swap_final src0 src1;
mov src0 t0;
mov src1 t1;

(* reconstruction *)

spl hi m0 src0 52;
spl s0 e0 hi 11;
spl hi m1 src1 52;
spl s1 e1 hi 11;

(* construct the right mantissas *)

cast uint64 m0 m0;
cast uint64 m1 m1;

subs discard t 0@uint11 e0;
or t@uint11 t e0;
shrs t discard t 10;
cast uint64 t t;
shls discard t t 52;
or m0@uint64 m0 t;

subs discard t 0@uint11 e1;
or t@uint11 t e1;
shrs t discard t 10;
cast uint64 t t;
shls discard t t 52;
or m1@uint64 m1 t;

(* scale the mantissa by 3 bits for rounding purpose *)

mul xm m0 8@uint64;
mul ym m1 8@uint64;

(* shifting ym *)

subs discard de e0 e1;

(* if the shift count is greater than 59 we zeroize ym *)

subb borrow discard 59@uint11 de;
cmov ym0 borrow 0@uint64 ym;

assert true && or[~(de > 59@11), ym0 = 0@64];

(* shift ym *)
cast uint64 de64 de;
subs discard cde64 64@uint64 de64;
shl rbit ym0 cde64;
shr ym1 ym0 de64;

(* compute the sticky bit based on the bits shift out *)

not t@uint64 rbit;
adds carry discard t 1@uint64;
cmov sticky carry 0@uint64 1@uint64;
or ym2@uint64 ym1 sticky;

(* negate ym if the signs are different *)

xor ts@uint1 s0 s1;
not t@uint64 ym2;
adds discard t t 1@uint64;
adds carry discard ts 1@uint1;
cmov ym3 carry t ym2;

(* add the mantissas *)

adds discard trm xm ym3;

(* shift to the range [2**63, 2**64) *)

cast uint32 txe e0;

mov tm trm;
mov te 0@uint32;

shls hi lo tm 32;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 32@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 16;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 16@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 8;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 8@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 4;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 4@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 2;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 2@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

mov trm0 tm;
subs discard txe txe te;

(* add the exponent by 7 in case we are going to shift the mantissa *)

adds discard txe1 txe 7@uint32;

(* zeroize the exponent if the resulting mantissa is 0 *)

adds carry discard trm0 (2**63)@uint64;
cmov txe2 carry txe1 0@uint32;

(* shift right by 11 bits *)

shrs trm1 low_m trm0 11;

cast uint32 low_m low_m;
split thi tlo low_m 9;

not t@uint32 tlo;
adds carry discard t 1@uint32;
cmov sticky carry 0@uint32 1@uint32;

or thi@uint32 thi sticky;

(* rounding *)

spl hi b0 thi 1;
spl hi b1 hi 1;
spl hi b2 trm1 1;

or t@uint1 b2 b0;
and roundbit@uint1 t b1;

cast uint64 roundbit roundbit;
adds discard trm2 trm1 roundbit;

join b0b1 b1 b0;
join last3bits b2 b0b1;

assert true && or[~(trm2 = 0@64), txe2 = 0@32];

(* compute the exponent *)

spl hi trm3 trm2 52;
cast uint32 hi hi;
adds discard txe3 txe2 hi;

assert true && and[0@32 <= hi, hi <= 2@32];
assert true && or[~(and[trm3 = 0@52, hi = 0@32]), and[txe3 = 0@32]];

(* zeroization *)
subs discard nzeroe 0@uint32 txe3;
shrs nzeroe discard nzeroe 31;
cast uint1 nzeroe nzeroe;
cmov txe4 nzeroe txe3 0@uint32;
cmov trm4 nzeroe trm3 0@uint52;

assert true && and[0@32 <= txe4, txe4 < (2**31)@32];
assert true && or[~(txe4 = 0@32), trm4 = 0@52];

(* saturation *)
subs discard sate 2046@uint32 txe4;
shrs sate discard sate 31;
cast uint1 sate sate;
cmov txe5 sate 2046@uint32 txe4;
cmov trm5 sate 0xfffffffffffff@uint52 trm4;

spl hi txe6 txe5 11;

(* assemble the exponent and mantissa *)

join tr0 txe6 trm5;
cast uint64 tr0 tr0;

(* assemble the sign, exponent, and mantissa *)

spl hi tr1 tr0 63;
join tr1 s0 tr1;

assert true && or[and[txe6 = 0@11, trm5 = 0@52], and[0@11 < txe6, txe6 < 2047@11]];

(* assembly below *)

(* ubfx   r4, r1, #0, #31  @ top word without sign bit *)
shls hi t r1 1;
shrs r4 lo t 1;
(* ubfx   r5, r3, #0, #31  @ top word without sign bit *)
shls hi t r3 1;
shrs r5 lo t 1;
(* subs   r7, r0, r2       @ difference in r7:r4 *)
subs carry r7 r0 r2;
(* sbcs   r4, r5 *)
sbcs carry r4 r4 r5 carry;
(* orrs   r7, r4 *)
or r7@uint32 r7 r4;
(* rsbs   r5, r7, #0 *)
subs discard r5 0@uint32 r7;
(* orrs   r7, r5      @ bit 31 of r7 is 0 iff difference is zero *)
or r7@uint32 r7 r5;
(* bics   r6, r1, r7 *)
not t@uint32 r7;
and r6@uint32 r1 t;
(* orrs   r6, r4      @ bit 31 of r6 is 1 iff the swap must be done *)
or r6@uint32 r6 r4;

(* @ Conditional swap *)
(* eors   r4, r0, r2 *)
xor r4@uint32 r0 r2;
(* eors   r5, r1, r3 *)
xor r5@uint32 r1 r3;
(* ands   r4, r4, r6, asr #31 *)
sars t lo r6 31;
and r4@uint32 r4 t;
(* ands   r5, r5, r6, asr #31 *)
sars t lo r6 31;
and r5@uint32 r5 t;
(* eors   r0, r4 *)
xor r0@uint32 r0 r4;
(* eors   r1, r5 *)
xor r1@uint32 r1 r5;
(* eors   r2, r4 *)
xor r2@uint32 r2 r4;
(* eors   r3, r5 *)
xor r3@uint32 r3 r5;

assert true && and[limbs 32 [r0, r1] = src0, limbs 32 [r2, r3] = src1];

(* @ Extract mantissa of x into r0:r1, exponent in r4, sign in r5 *)
(* ubfx   r4, r1, #20, #11   @ Exponent in r4 (without sign) *)
shls hi t r1 1;
shrs r4 lo t 21;
(* addw   r5, r4, #2047 @ Get a carry to test r4 for zero *)
adds discard r5 r4 2047@uint32;
(* lsrs   r5, #11       @ r5 is the mantissa implicit high bit *)
shrs r5 lo r5 11;
(* bfc    r1, #20, #11  @ Clear exponent bits (not the sign) *)
mov tlo (2**20)@uint32;
mov thi (2**31)@uint32;
sub t thi tlo;
not t@uint32 t;
and r1@uint32 r1 t;
(* orrs   r1, r1, r5, lsl #20  @ Set mantissa high bit *)
shls hi t r5 20;
or r1@uint32 r1 t;
(* asrs   r5, r1, #31   @ Get sign bit (sign-extended) *)
sars r5 lo r1 31;
(* bfc    r1, #31, #1   @ Clear the sign bit *)
mov t (2**31)@uint32;
sub t t 1@uint32;
and r1@uint32 r1 t;

assert true && limbs 32 [r0, r1] = m0;
assert true && r4 = (uext e0 21);
assert true && r5 = (sext s0 31);

(* @ Extract mantissa of y into r2:r3, exponent in r6, sign in r7 *)
(* ubfx   r6, r3, #20, #11   @ Exponent in r6 (without sign) *)
shls hi t r3 1;
shrs r6 lo t 21;
(* addw   r7, r6, #2047 @ Get a carry to test r6 for zero *)
adds discard r7 r6 2047@uint32;
(* lsrs   r7, #11       @ r7 is the mantissa implicit high bit *)
shrs r7 lo r7 11;
(* bfc    r3, #20, #11  @ Clear exponent bits (not the sign) *)
mov tlo (2**20)@uint32;
mov thi (2**31)@uint32;
sub t thi tlo;
not t@uint32 t;
and r3@uint32 r3 t;
(* orrs   r3, r3, r7, lsl #20  @ Set mantissa high bit *)
shls hi t r7 20;
or r3@uint32 r3 t;
(* asrs   r7, r3, #31   @ Get sign bit (sign-extended) *)
sars r7 lo r3 31;
(* bfc    r3, #31, #1   @ Clear the sign bit *)
mov t (2**31)@uint32;
sub t t 1@uint32;
and r3@uint32 r3 t;

assert true && limbs 32 [r2, r3] = m1;
assert true && r6 = (uext e1 21);
assert true && r7 = (sext s1 31);

(* @ Scale mantissas up by three bits. *)
(* lsls   r1, #3 *)
shls hi r1 r1 3;
(* orrs   r1, r1, r0, lsr #29 *)
shrs t lo r0 29;
or r1@uint32 r1 t;
(* lsls   r0, #3 *)
shls hi r0 r0 3;
(* lsls   r3, #3 *)
shls hi r3 r3 3;
(* orrs   r3, r3, r2, lsr #29 *)
shrs t lo r2 29;
or r3@uint32 r3 t;
(* lsls   r2, #3 *)
shls hi r2 r2 3;

assert true && limbs 32 [r0, r1] = xm;
assert true && limbs 32 [r2, r3] = ym;

(* @ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits) *)
(* @ y: exponent=r6, sign=r7, mantissa=r2:r3 (scaled up 3 bits) *)
(* @ At that point, the exponent of x (in r4) is larger than that *)
(* @ of y (in r6). The difference is the amount of shifting that *)
(* @ should be done on y. If that amount is larger than 59 then *)
(* @ we clamp y to 0. We won't need y's exponent beyond that point, *)
(* @ so we store that shift count in r6. *)
(* subs   r6, r4, r6 *)
subs discard r6 r4 r6;
(* subs   r8, r6, #60 *)
subs discard r8 r6 60@uint32;
(* ands   r2, r2, r8, asr #31 *)
sars t lo r8 31;
and r2@uint32 r2 t;
(* ands   r3, r3, r8, asr #31 *)
sars t lo r8 31;
and r3@uint32 r3 t;

assert true && or[~(de > 59@11), limbs 32 [r2, r3] = 0@64];

(* @ Shift right r2:r3 by r6 bits. The shift count is in the 0..59 *)
(* @ range. r11 will be non-zero if and only if some non-zero bits *)
(* @ were dropped. *)

assert true && r6 = (uext de 21);

(* subs   r8, r6, #32 *)
subs discard r8 r6 32@uint32;
(* bics   r11, r2, r8, asr #31 *)
sars t lo r8 31;
not t@uint32 t;
and r11@uint32 r2 t;
(* ands   r2, r2, r8, asr #31 *)
sars t lo r8 31;
and r2@uint32 r2 t;
(* bics   r10, r3, r8, asr #31 *)
sars t lo r8 31;
not t@uint32 t;
and r10@uint32 r3 t;
(* orrs   r2, r2, r10 *)
or r2@uint32 r2 r10;
(* ands   r3, r3, r8, asr #31 *)
sars t lo r8 31;
and r3@uint32 r3 t;
(* ands   r6, r6, #31 *)
and r6@uint32 r6 31@uint32;
(* rsbs   r8, r6, #32 *)
subs discard r8 32@uint32 r6;
(* lsls   r10, r2, r8 *)
shl r10 r2 r8;
(* orrs   r11, r11, r10 *)
or r11@uint32 r11 r10;
(* lsrs   r2, r2, r6 *)
shr r2 r2 r6;
(* lsls   r10, r3, r8 *)
shl r10 r3 r8;
(* orrs   r2, r2, r10 *)
or r2@uint32 r2 r10;
(* lsrs   r3, r3, r6 *)
shr r3 r3 r6;

assert true && ym1 = limbs 32 [r2, r3];

assert true && or[and[rbit = 0@64, r11 = 0@32], and[~(rbit = 0@64), ~(r11 = 0@32)]];

(* @ If r11 is non-zero then some non-zero bit was dropped and the *)
(* @ low bit of r2 must be forced to 1 ('sticky bit'). *)

(* rsbs   r6, r11, #0 *)
subs discard r6 0@uint32 r11;
(* orrs   r6, r6, r11 *)
or r6@uint32 r6 r11;
(* orrs   r2, r2, r6, lsr #31 *)
shrs t lo r6 31;
or r2@uint32 r2 t;

assert true && ym2 = limbs 32 [r2, r3];

(* @ x: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits) *)
(* @ y: sign=r7, value=r2:r3 (scaled to same exponent as x) *)
(* @ If x and y don't have the same sign, then we should negate r2:r3 *)
(* @ (i.e. subtract the mantissa instead of adding it). Signs of x *)
(* @ and y are in r5 and r7, as full-width words. We won't need r7 *)
(* @ afterwards. *)

(* eors   r7, r5    @ r7 = -1 if y must be negated, 0 otherwise *)
xor r7@uint32 r7 r5;
(* eors   r2, r7 *)
xor r2@uint32 r2 r7;
(* eors   r3, r7 *)
xor r3@uint32 r3 r7;
(* subs   r2, r7 *)
subs carry r2 r2 r7;
(* sbcs   r3, r7 *)
usbcs discard r3 r3 r7 carry;

assert true && ym3 = limbs 32 [r2, r3];

(* @ r2:r3 has been shifted, we can add to r0:r1. *)

(* adds   r0, r2 *)
adds carry r0 r0 r2;
(* adcs   r1, r3 *)
adcs discard r1 r1 r3 carry;

assert true && trm = limbs 32 [r0, r1];

assert true && and[(0)@64 <= trm, trm < (2**57)@64];

(* @ result: exponent=r4, sign=r5, mantissa=r0:r1 (scaled up 3 bits) *)

(* @ Normalize the result with some left-shifting to full 64-bit *)
(* @ width. Shift count goes to r2, and exponent (r4) is adjusted. *)

assert true && or[trm0 = 0@64, (2**63)@64 <= trm0];

(* clz    r2, r0 *)

mov tm r0;
mov te 0@uint32;

shls hi lo tm 16;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 16@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 8;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 8@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 4;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 4@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 2;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 2@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

mov r2 te;

(* clz    r3, r1 *)

mov tm r1;
mov te 0@uint32;

shls hi lo tm 16;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 16@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 8;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 8@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 4;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 4@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 2;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 2@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

shls hi lo tm 1;
cast uint32 hi hi;
not hi@uint32 hi;
adds carry discard hi 1@uint32;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

mov r3 te;

(* sbfx   r6, r3, #5, #1 *)
shls hi t r3 26;
sars r6 lo t 31;
(* ands   r2, r6 *)
and r2@uint32 r2 r6;
(* adds   r2, r2, r3 *)
adds discard r2 r2 r3;
(* subs   r4, r4, r2 *)
subs discard r4 r4 r2;

assert true && r4 = txe;

(* @ Shift r0:r1 to the left by r2 bits. *)
(* subs   r7, r2, #32 *)
subs discard r7 r2 32@uint32;
(* lsls   r7, r0, r7 *)
shl r7 r0 r7;
(* lsls   r1, r1, r2 *)
shl r1 r1 r2;

(* rsbs   r6, r2, #32 *)
subs discard r6 32@uint32 r2;
(* orrs   r1, r1, r7 *)
or r1@uint32 r1 r7;
(* lsrs   r6, r0, r6 *)
shr r6 r0 r6;

(* orrs   r1, r1, r6 *)
or r1@uint32 r1 r6;
(* lsls   r0, r0, r2 *)
shl r0 r0 r2;

assert true && limbs 32 [r0, r1] = trm0;

(* @ The exponent of x was in r4. The left-shift operation has *)
(* @ subtracted some value from it, 8 in case the result has the *)
(* @ same exponent as x. However, the high bit of the mantissa will *)
(* @ add 1 to the exponent, so we only add back 7 (the exponent is *)
(* @ added in because rounding might have produced a carry, which *)
(* @ should then spill into the exponent). *)

(* adds   r4, #7 *)
adds discard r4 r4 7@uint32;
(* @ If the mantissa new mantissa is non-zero, then its bit 63 is *)
(* @ non-zero (thanks to the normalizing shift). Otherwise, that bit *)
(* @ is zero, and we should then set the exponent to zero as well. *)

(* ands   r4, r4, r1, asr #31 *)
sars t lo r1 31;
and r4@uint32 r4 t;

assert true && r4 = txe2;

(* @ Shrink back the value to a 52-bit mantissa. This requires *)
(* @ right-shifting by 11 bits; we keep a copy of the pre-shift *)
(* @ low word in r3. *)

(* movs   r3, r0 *)
mov r3 r0;
(* lsrs   r0, #11 *)
shrs r0 lo r0 11;
(* orrs   r0, r0, r1, lsl #21 *)
shls hi t r1 21;
or r0@uint32 r0 t;
(* lsrs   r1, #11 *)
shrs r1 lo r1 11;

assert true && limbs 32 [r0, r1] = trm1;

(* @ Apply rounding. *)
(* ubfx   r6, r3, #0, #9 *)
shls hi t r3 23;
shrs r6 lo t 23;
(* addw   r6, r6, #511 *)
adds discard r6 r6 511@uint32;

assert true && or[and[sticky = 0@32, r6 < 512@32], and[sticky = 1@32, r6 >= 512@32]];

(* orrs   r3, r6 *)
or r3@uint32 r3 r6;
(* ubfx   r3, r3, #9, #3 *)
shls hi t r3 20;
shrs r3 lo t 29;

assert true && r3 = (uext last3bits 29);

(* movs   r6, #0xC8 *)
mov r6 200@uint32;
(* lsrs   r6, r3 *)
shr r6 r6 r3;

(* ands   r6, #1 *)
and r6@uint32 r6 1@uint32;

assert true && (uext r6 32) = roundbit;

(* adds   r0, r6 *)
adds carry r0 r0 r6;
(* adcs   r1, #0 *)
adcs discard r1 r1 0@uint32 carry;

(* @ Plug in the exponent with an addition. *)
(* adds   r4, r4, r1, lsr #20 *)
shrs t discard r1 20;
adds discard r4 r4 t;

(* @ If the new exponent is negative or zero, then it underflowed *)
(* @ and we must clear the whole mantissa and exponent. *)
(* rsbs   r6, r11, #0 *)
subs discard r6 0@uint32 r4;
(* ands   r0, r0, r6, asr #31 *)
sars t discard r6 31;
and r0@uint32 r0 t;
(* ands   r1, r1, r6, asr #31 *)
sars t discard r6 31;
and r1@uint32 r1 t;
(* ands   r4, r4, r6, asr #31 *)
sars t discard r6 31;
and r4@uint32 r4 t;
(* @ Saturation *)
(* rsbs   r6, r4, #2048 *)
subs discard r6 2048@uint32 r4;
(* subs   r6, r6, #2 *)
subs discard r6 r6 2@uint32;
(* orrs   r0, r0, r6, asr #31 *)
sars t discard r6 31;
or r0@uint32 r0 t;
(* orrs   r1, r1, r6, asr #31 *)
sars t discard r6 31;
or r1@uint32 r1 t;
(* orrs   r4, r4, r6, asr #31 *)
sars t discard r6 31;
or r4@uint32 r4 t;
(* subs   r4, r4, r6, lsr #31 *)
shrs t discard r6 31;
subs discard r4 r4 t;
(* @ Combine the exponent and mantissa *)

(* bfi    r1, r4, #20, #11 *)
mov tmask 0x7ff@uint32;
and t@uint32 r4 tmask;
shls discard t t 20;
shls discard tmask tmask 20;
not tmask@uint32 tmask;
and r1@uint32 r1 tmask;
or r1@uint32 r1 t;

(* @ Put back the sign. This is the sign of x: thanks to the *)
(* @ conditional swap at the start, this is always correct. *)
(* bfi    r1, r5, #31, #1 *)
mov tmask 0x1@uint32;
and t@uint32 r5 tmask;
shls discard t t 31;
shls discard tmask tmask 31;
not tmask@uint32 tmask;
and r1@uint32 r1 tmask;
or r1@uint32 r1 t;

assert true && limbs 32 [r0, r1] = tr1;


{
    true
    &&
    true
}








