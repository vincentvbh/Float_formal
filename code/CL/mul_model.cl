
(*

cv -v -jobs 24 -isafety -no_carry_constraint -slicing mul_model.cl
Parsing CryptoLine file:        [OK]        0.001021 seconds
Checking well-formedness:       [OK]        0.000330 seconds

Procedure main
--------------
Transforming to SSA form:       [OK]        0.000133 seconds
Normalizing specification:      [OK]        0.000145 seconds
Rewriting assignments:          [OK]        0.000042 seconds
Verifying program safety:
     Cut 0
         Round 1 (7 safety conditions, timeout = 300 seconds)
         Safety condition #6    [OK]
         Safety condition #0    [OK]
         Safety condition #1    [OK]
         Safety condition #3    [OK]
         Safety condition #4    [OK]
         Safety condition #2    [OK]
         Safety condition #5    [OK]
     Overall            [OK]        0.055822 seconds
Verifying range assertions:     [OK]        1.292224 seconds
Verifying range specification:      [OK]        0.000013 seconds
Rewriting value-preserved casting:  [OK]        0.000011 seconds
Verifying algebraic assertions:     [OK]        0.142851 seconds
Verifying algebraic specification:  [OK]        0.000014 seconds
Procedure verification:         [OK]        1.491433 seconds

Summary
-------
Verification result:            [OK]        1.492938 seconds
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

mov mr rmsat;
mov er resat11;

join res resat11 rmsat;
join res rs res;

assert true && or[and[resat11 = 0@11, rmsat = 0@52], and[0@11 < resat11, resat11 < 2047@11]];

{
    true && true
}


