
(*

cv -v -jobs 24 -isafety -no_carry_constraint -slicing fpr_mul_new.cl
Parsing CryptoLine file:        [OK]        0.000779 seconds
Checking well-formedness:       [OK]        0.000284 seconds

Procedure main
--------------
Transforming to SSA form:       [OK]        0.000104 seconds
Normalizing specification:      [OK]        0.000145 seconds
Rewriting assignments:          [OK]        0.000041 seconds
Verifying program safety:
     Cut 0
         Round 1 (10 safety conditions, timeout = 300 seconds)
         Safety condition #6    [OK]
         Safety condition #0    [OK]
         Safety condition #1    [OK]
         Safety condition #7    [OK]
         Safety condition #3    [OK]
         Safety condition #2    [OK]
         Safety condition #4    [OK]
         Safety condition #9    [OK]
         Safety condition #8    [OK]
         Safety condition #5    [OK]
     Overall            [OK]        0.055884 seconds
Verifying range assertions:     [OK]        5.253728 seconds
Verifying range specification:      [OK]        0.000026 seconds
Rewriting value-preserved casting:  [OK]        0.000034 seconds
Verifying algebraic assertions:     [OK]        0.022417 seconds
Verifying algebraic specification:  [OK]        0.000019 seconds
Procedure verification:         [OK]        5.332773 seconds

Summary
-------
Verification result:            [OK]        5.333913 seconds

*)

(* important notes: theer aer no instructions counting leading zeros in CryptoLine,
   we translate them into O(log n) many operations (wheer n is the number of bits of a value)
   based on the macro FPR_NORM64 in Falcon
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



(* we assume that r1 || r0 is the same as s0 || e0 || m0
   r0 and r1 are the actual input registers, but we specify the preconditions on s0, e0, and m0
*)
join t e0 m0;
join src0 s0 t;
spl r1 r0 src0 32;
adds carry t e0 2047@uint11;
cmov t carry (2**52)@uint64 0@uint64;
or src0@uint64 src0 t;
split hi src0 src0 53;

assert true && or[src0 = 0@64, and[(2**52)@64 <= src0, src0 <= (2**53 - 1)@64]];

(* we assume that r3 || r2 is the same as s1 || e1 || m1
   r2 and r3 are the actual input registers, but we specify the preconditions on s1, e1, and m1
*)
join t e1 m1;
join src1 s1 t;
spl r3 r2 src1 32;
adds carry t e1 2047@uint11;
cmov t carry (2**52)@uint64 0@uint64;
or src1@uint64 src1 t;
split hi src1 src1 53;

assert true && or[src1 = 0@64, and[(2**52)@64 <= src1, src1 <= (2**53 - 1)@64]];

(* start constructing all the intermediate values *)
mulj r src0 src1;
assert true && or[r = 0@128, and[(2**104)@128 <= r, r <= ((2**106)@128 - (2**54)@128 + 1@128)]];

(* construct the multilimb of src0 in boolean and introduce the corresponding algebraic equations *)
split hi0 lo0 src0 25;
spl t lo0 lo0 32;
spl t hi0 hi0 32;
assert true && src0 = (uext lo0 32) + (uext hi0 32) * (2**25)@64;
assume src0 = lo0 + hi0 * (2**25) && true;

(* construct the multilimb of src1 in boolean and introduce the corresponding algebraic equations *)
split hi1 lo1 src1 25;
spl t lo1 lo1 32;
spl t hi1 hi1 32;
assert true && src1 = (uext lo1 32) + (uext hi1 32) * (2**25)@64;
assume src1 = lo1 + hi1 * (2**25) && true;

(* construct the bit-accessible version of r *)
mulj prod0 lo0 lo1;
mulj prod1 lo0 hi1;
mulj prod2 lo1 hi0;
mulj prod3 hi0 hi1;
add pmid prod1 prod2;
assert true && pmid = prod1 + prod2;
assume pmid = prod1 + prod2 && true;
cast uint128 bit_r prod0;
mulj t pmid (2**25)@uint64;
add bit_r bit_r t;
mulj t prod3 (2**50)@uint64;
add bit_r bit_r t;

assert r = bit_r && true;
assume true && r = bit_r;

(* construct intermediate values for the multilimb *)
spl phi plo prod0 25;
spl phi philo phi 32;

cast uint64 t philo;
add pnewmid pmid t;
assert true && pnewmid = pmid + t;
assume pnewmid = pmid + t && true;

spl phi plo pnewmid 25;
spl phi pnewhilo phi 32;

cast uint64 t pnewhilo;
add pnewhi prod3 t;
assert true && pnewhi = prod3 + t;
assume pnewhi = prod3 + t && true;

(* make sure our construction is the same as the bitfield extraction *)
spl hi lo r 50;
spl hi t hi 64;
assert true && pnewhi = t;

(* construct values for the sticky bit operation *)

(* we construct the value where the 50th bit is the sticky bit *)
spl hi50 lo50 r 50;
spl hi50 t50 hi50 64;
assert true && pnewhi = t50;
not t@uint50 lo50;
adds discard t t 1@uint50;
or t@uint50 t lo50;
mov lo50orsum t;
spl t lo t 49;
cast uint64 t t;
or tsticky50@uint64 t50 t;

(* we construct the value where the 51th bit is the sticky bit *)
spl hi51 lo51 r 51;
spl hi51 t51 hi51 64;
not t@uint51 lo51;
adds discard t t 1@uint51;
or t@uint51 t lo51;
spl t lo t 50;
cast uint64 t t;
or tsticky51@uint64 t51 t;

(* we choose the right value here *)
spl hi lo tsticky50 55;
spl hi lo hi 1;
adds shift_sticky discard lo 1@uint1;
cmov tsticky shift_sticky tsticky51 tsticky50;

assert true && or[tsticky = 0@64, and[(2**54)@64 <= tsticky, tsticky < (2**55)@64]];

(* construct the right mantissa *)

(* round to nearest, to even if tie *)
spl hi lo tsticky 3;
spl b2 b0b1 lo 2;
spl b1 b0 b0b1 1;
or t@uint1 b0 b2;
and t@uint1 b1 t;
cast uint64 t t;
shrs rm64 lo tsticky 2;
add rm64 rm64 t;

assert true && or[rm64 = 0@64, and[(2**52)@64 <= rm64, rm64 <= (2**53)@64]];

(* construct the resulting exponent *)

(* sum up the exponents *)
cast uint32 te0 e0;
cast uint32 te1 e1;
add re te0 te1;

(* subtract 1023 since the exponents are biased *)
subs discard re re 1023@uint32;

(* add 1 due to the conditional shift of sticky bit computation*)
adcs discard re re 0@uint32 shift_sticky;

mov sume@uint32 re;

(* add 1 if the rm = 2**53 *)
spl hi rm52 rm64 52;
spl hi discard hi 1;
cast uint32 hi hi;
adds discard re re hi;

mov rounde@uint32 re;

cast uint12 rounde12 rounde;
assert true && or[and[(2**31)@32 <= rounde, (2**11)@12 <= rounde12], and[0@32 <= rounde, rounde < (2**12)@32]];

(* zeroization *)
adds zflag0 discard rm64 0xffffffffffffffff@uint64;
cmov re zflag0 re 0@uint32;

subs discard t 0@uint32 re;
shrs t discard t 31;
cast uint1 zflag1 t;
cmov rezero zflag1 re 0@uint32;
cmov rmzero zflag1 rm52 0@uint52;

(* saturation *)
subs discard t 2046@uint32 rezero;
shrs t discard t 31;
cast uint1 satflag t;
cmov resat satflag 2046@uint32 rezero;
cmov rmsat satflag 0xfffffffffffff@uint52 rmzero;

(* final exponent *)
spl discard resat11 resat 11;

(* final sign *)
xor rs@uint1 s0 s1;

join res resat11 rmsat;
join res rs res;

assert true && or[and[resat11 = 0@11, rmsat = 0@52], and[0@11 < resat11, resat11 < 2047@11]];

(* assembly below *)

(* bics   r4, r0, #0xfe000000 *)
not t@uint32 0xfe000000@uint32;
and r4@uint32 r0 t;
(* lsls   r5, r1, #7 *)
shls discard r5 r1 7;
(* orrs   r5, r5, r0, lsr #25 *)
shrs t discard r0 25;
or r5@uint32 r5 t;
(* bics   r5, r5, #0xf8000000 *)
not t@uint32 0xf8000000@uint32;
and r5@uint32 r5 t;
(* ubfx   r8, r1, #20, #11 *)
shls discard t r1 1;
shrs r8 discard t 21;
(* addw   r8, r8, #0x7ff *)
adds discard r8 r8 0x7ff@uint32;
(* lsrs   r8, #11 *)
shrs r8 discard r8 11;
(* orrs   r5, r5, r8, lsl #27 *)
shls discard t r8 27;
or r5@uint32 r5 t;

assert true && and[lo0 = r4, hi0 = r5];
assume and[lo0 = r4, hi0 = r5] && true;

(* bics   r6, r2, #0xfe000000 *)
not t@uint32 0xfe000000@uint32;
and r6@uint32 r2 t;
(* lsls   r7, r3, #7 *)
shls discard r7 r3 7;
(* orrs   r7, r7, r2, lsr #25 *)
shrs t discard r2 25;
or r7@uint32 r7 t;
(* bics   r7, r7, #0xf8000000 *)
not t@uint32 0xf8000000@uint32;
and r7@uint32 r7 t;
(* ubfx   r8, r3, #20, #11 *)
shls discard t r3 1;
shrs r8 discard t 21;
(* addw   r8, r8, #0x7ff *)
adds discard r8 r8 0x7ff@uint32;
(* lsrs   r8, #11 *)
shrs r8 discard r8 11;
(* orrs   r7, r7, r8, lsl #27 *)
shls discard t r8 27;
or r7@uint32 r7 t;

assert true && and[lo1 = r6, hi1 = r7];
assume and[lo1 = r6, hi1 = r7] && true;

(* @ Perform product. Values are in the 2^52..2^53-1 range, so *)
(* @ the product is at most 106-bit long. Of the low 50 bits, *)
(* @ we only want to know if they are all zeros or not. Here, *)
(* @ we get the top 56 bits in r10:r11, and r8 will be non-zero *)
(* @ if and only if at least one of the low 50 bits is non-zero. *)

(* umull  r8, r10, r4, r6      @ x0*y0 *)
mull r10 r8 r4 r6;

assert prod0 = limbs 32 [r8, r10] && true;
assume true && prod0 = limbs 32 [r8, r10];

(* lsls   r10, #7 *)
shls hi r10 r10 7;
(* orrs   r10, r10, r8, lsr #25 *)
shrs t lo r8 25;
or r10@uint32 r10 t;

assert true && r10 = philo;
assume r10 = philo && true;

(* eors   r11, r11 *)
mov r11 0@uint32;
(* umlal  r10, r11, r4, r7     @ x0*y1 *)
mull hi lo r4 r7;
adds carry r10 r10 lo;
adc r11 r11 hi carry;
(* umlal  r10, r11, r5, r6     @ x1*y0 *)
mull hi lo r5 r6;
adds carry r10 r10 lo;
adc r11 r11 hi carry;

assert pnewmid = limbs 32 [r10, r11] && true;
assume true && pnewmid = limbs 32 [r10, r11];

(* orrs   r8, r8, r10, lsl #7 *)
shls hi t r10 7;
or r8@uint32 r8 t;
(* lsrs   r10, #25 *)
shrs r10 lo r10 25;
(* orrs   r10, r10, r11, lsl #7 *)
shls hi t r11 7;
or r10@uint32 r10 t;

assert true && r10 = pnewhilo;
assume r10 = pnewhilo && true;

(* eors   r11, r11 *)
mov r11 0@uint32;
(* umlal  r10, r11, r5, r7     @ x1*y1 *)
mull hi lo r5 r7;
adds carry r10 r10 lo;
adc r11 r11 hi carry;

assert pnewhi = limbs 32 [r10, r11] && true;
assume true && pnewhi = limbs 32 [r10, r11];

(* @ If any of the low 50 bits was non-zero, then we force the *)
(* @ low bit of r10 to 1. *)

(* rsbs   r4, r8, #0 *)
subs discard r4 0@uint32 r8;
(* orrs   r8, r8, r4 *)
or r8@uint32 r8 r4;
(* orrs   r10, r10, r8, lsr #31 *)
shrs t lo r8 31;
or r10@uint32 r10 t;

join t r11 r10;
assert true && or[t = 0@64, and[(2**54)@64 <= t, t < (2**56)@64]];
assert true && t = tsticky50;

(* @ r10:r11 contains the product in the 2^54..2^56-1 range. We *)
(* @ normalize it to 2^54..2^55-1 (into r6:r7) with a conditional *)
(* @ shift (low bit is sticky). r5 contains -1 if the shift was done, *)
(* @ 0 otherwise. *)

(* ands   r6, r10, #1 *)
and r6@uint32 r10 1@uint32;
(* lsrs   r5, r11, #23 *)
shrs r5 lo r11 23;
(* rsbs   r5, r5, #0 *)
subs discard r5 0@uint32 r5;
(* orrs   r6, r6, r10, lsr #1 *)
shrs t lo r10 1;
or r6@uint32 r6 t;
(* orrs   r6, r6, r11, lsl #31 *)
shls hi t r11 31;
or r6@uint32 r6 t;
(* lsrs   r7, r11, #1 *)
shrs r7 lo r11 1;
(* eors   r10, r10, r6 *)
xor r10@uint32 r10 r6;
(* eors   r11, r11, r7 *)
xor r11@uint32 r11 r7;
(* bics   r10, r10, r5 *)
not t@uint32 r5;
and r10@uint32 r10 t;
(* bics   r11, r11, r5 *)
not t@uint32 r5;
and r11@uint32 r11 t;
(* eors   r6, r6, r10 *)
xor r6@uint32 r6 r10;
(* eors   r7, r7, r11 *)
xor r7@uint32 r7 r11;

join t r7 r6;
assert true && or[t = 0@64, and[(2**54)@64 <= t, t < (2**55)@64]];
assert true && t = tsticky;

assert true && or[and[r5 = 0@32, shift_sticky = 0@1], and[r5 = (-1)@32, shift_sticky = 1@1]];

(* @ Compute aggregate exponent: ex + ey - 1023 + w *)
(* @ (where w = 1 if the conditional shift was done, 0 otherwise) *)

(* ubfx   r0, r1, #20, #11 *)
shls discard t r1 1;
shrs r0 discard t 21;
(* ubfx   r2, r3, #20, #11 *)
shls discard t r3 1;
shrs r2 discard t 21;
(* adds   r2, r0 *)
adds discard r2 r2 r0;
(* subw   r2, r2, #1023 *)
subs discard r2 r2 1023@uint32;
(* subs   r2, r5 *)
subs discard r2 r2 r5;

assert true && r2 = sume;

(* @ Compute the sign and put it to the 31th bit of r3 *)
(* eors   r3, r1, r3 *)
xor r3@uint32 r1 r3;
(* lsrs   r3, r3, #31 *)
shrs r3 discard r3 31;

assert true && (uext rs 31) = r3;

(* @ Shift back to the normal 53-bit mantissa, with rounding. *)
(* lsrs   r0, r6, #2 *)
shrs r0 discard r6 2;
(* orrs   r0, r0, r7, lsl #30 *)
shls discard t r7 30;
or r0@uint32 r0 t;
(* lsrs   r1, r7, #2 *)
shrs r1 discard r7 2;
(* orrs   r7, r6, r6, lsr #2 *)
shrs t discard r6 2;
or r7@uint32 r6 t;
(* ands   r7, r7, r6, lsr #1 *)
shrs t discard r6 1;
and r7@uint32 r7 t;
(* ands   r7, #1 *)
and r7@uint32 r7 1@uint32;
(* adds   r0, r7 *)
adds carry r0 r0 r7;
(* adcs   r1, r1, #0 *)
adcs discard r1 r1 0@uint32 carry;
(* adds   r2, r2, r1, lsr #21 *)
shrs t discard r1 21;
adds discard r2 r2 t;

assert true && r2 = rounde;

(* @ Zeroization *)
(* orrs   r4, r0, r1 *)
or r4@uint32 r0 r1;
(* rsbs   r5, r4, #0 *)
subs discard r5 0@uint32 r4;
(* orrs   r4, r4, r5 *)
or r4@uint32 r4 r5;
(* ands   r2, r2, r4, asr #31 *)
sars t discard r4 31;
assert true && t = (sext zflag0 31);
and r2@uint32 r2 t;
(* rsbs   r4, r2, #0 *)
subs discard r4 0@uint32 r2;
(* ands   r0, r0, r4, asr #31 *)
sars t discard r4 31;
assert true && t = (sext zflag1 31);
and r0@uint32 r0 t;
(* ands   r1, r1, r4, asr #31 *)
sars t discard r4 31;
and r1@uint32 r1 t;
(* ands   r2, r2, r4, asr #31 *)
sars t discard r4 31;
and r2@uint32 r2 t;

assert true && r2 = rezero;

and t@uint32 r1 0xfffff@uint32;
assert true && limbs 32 [r0, t] = (uext rmzero 12);

(* @ Saturation *)
(* rsbs   r4, r2, #2048 *)
subs discard r4 2048@uint32 r2;
(* subs   r4, r4, #2 *)
subs discard r4 r4 2@uint32;
(* orrs   r0, r0, r4, asr #31 *)
sars t discard r4 31;
or r0@uint32 r0 t;
(* orrs   r1, r1, r4, asr #31 *)
sars t discard r4 31;
or r1@uint32 r1 t;
(* orrs   r2, r2, r4, asr #31 *)
sars t discard r4 31;
or r2@uint32 r2 t;
(* subs   r2, r2, r4, lsr #31 *)
shrs t discard r4 31;
subs discard r2 r2 t;

and t@uint32 r2 0x7ff@uint32;
assert true && t = resat;

and t@uint32 r1 0xfffff@uint32;
assert true && limbs 32 [r0, t] = (uext rmsat 12);

(* bfi    r1, r2, #20, #11 *)
mov tmask 0x7ff@uint32;
and t@uint32 r2 tmask;
shls discard t t 20;
shls discard tmask tmask 20;
not tmask@uint32 tmask;
and r1@uint32 r1 tmask;
or r1@uint32 r1 t;
(* bfi    r1, r3, #31, #1 *)
mov tmask 0x1@uint32;
and t@uint32 r3 tmask;
shls discard t t 31;
shls discard tmask tmask 31;
not tmask@uint32 tmask;
and r1@uint32 r1 tmask;
or r1@uint32 r1 t;

assert true && limbs 32 [r0, r1] = res;


{
    true
    &&
    true
}



