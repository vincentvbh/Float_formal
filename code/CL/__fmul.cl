
(*

cv -v -jobs 24 -isafety -no_carry_constraint -slicing __fmul.cl
Parsing CryptoLine file:        [OK]        0.000929 seconds
Checking well-formedness:       [OK]        0.000605 seconds

Procedure main
--------------
Transforming to SSA form:       [OK]        0.000135 seconds
Normalizing specification:      [OK]        0.000170 seconds
Rewriting assignments:          [OK]        0.000056 seconds
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
     Overall            [OK]        0.044000 seconds
Verifying range assertions:     [OK]        57.041148 seconds
Verifying range specification:      [OK]        0.000245 seconds
Rewriting value-preserved casting:  [OK]        0.000019 seconds
Verifying algebraic assertions:     [OK]        0.021107 seconds
Verifying algebraic specification:  [OK]        0.000021 seconds
Procedure verification:         [OK]        57.107053 seconds

Summary
-------
Verification result:            [OK]        57.108668 seconds

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

(* ================================================================ *)

mov xlo r0;
mov xhi r1;
mov ylo r2;
mov yhi r3;

(* ================================================================ *)

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

(* ================================================================ *)

(* fn __split25_const(reg u32 xlo xhi ylo yhi) -> reg u32, reg u32, reg u32, reg u32, reg u32, reg u32, reg u32, reg u32 { *)

(*     reg u32 sx ex sy ey;
    reg u32 t; *)

    (* sx = xhi >> 31; *)
    shrs sx discard xhi 31;
    (* ex = #UBFX(xhi, 20, 11); *)
    shls discard t xhi 1;
    shrs ex discard t 21;
    (* xhi <<= 7; *)
    shls discard xhi xhi 7;
    (* xhi |= xlo >> 25; *)
    shrs t discard xlo 25;
    or xhi@uint32 xhi t;
    (* xlo = #UBFX(xlo, 0, 25); *)
    shls discard t xlo 7;
    shrs xlo discard t 7;
    (* xhi = #UBFX(xhi, 0, 27); *)
    shls discard t xhi 5;
    shrs xhi discard t 5;
    (* t = #RSB(ex, 0); *)
    subs discard t 0@uint32 ex;
    (* t >>= 31; *)
    shrs t discard t 31;
    (* xhi |= t << 27; *)
    shls discard tt t 27;
    or xhi@uint32 xhi tt;

    assert true && and[sx = (uext s0 31), ex = (uext e0 21), xlo = lo0, xhi = hi0];
    assume and[xlo = lo0, xhi = hi0] && true;

    (* sy = yhi >> 31; *)
    shrs sy discard yhi 31;
    (* ey = #UBFX(yhi, 20, 11); *)
    shls discard t yhi 1;
    shrs ey discard t 21;
    (* yhi <<= 7; *)
    shls discard yhi yhi 7;
    (* yhi |= ylo >> 25; *)
    shrs t discard ylo 25;
    or yhi@uint32 yhi t;
    (* ylo = #UBFX(ylo, 0, 25); *)
    shls discard t ylo 7;
    shrs ylo discard t 7;
    (* yhi = #UBFX(yhi, 0, 27); *)
    shls discard t yhi 5;
    shrs yhi discard t 5;
    (* t = #RSB(ey, 0); *)
    subs discard t 0@uint32 ey;
    (* t >>= 31; *)
    shrs t discard t 31;
    (* yhi |= t << 27; *)
    shls discard tt t 27;
    or yhi@uint32 yhi tt;

    assert true && and[sy = (uext s1 31), ey = (uext e1 21), ylo = lo1, yhi = hi1];
    assume and[ylo = lo1, yhi = hi1] && true;


    (* return sx, ex, xlo, xhi, sy, ey, ylo, yhi; *)

(* } *)

    (* prods = sx ^ sy; *)
    xor prods@uint32 sx sy;
    (* // 2 * (1023 + 52) - 50 = 2100 *)
    (* prode = ex + ey; *)
    adds discard prode ex ey;
    (* prode -= 2100; *)
    subs discard prode prode 2100@uint32;

(* fn __mul25_const(reg u32 xlo xhi ylo yhi) -> reg u32, reg u32, reg u32, reg u32 { *)

(*     reg u32 prodlo prodhi;
    reg u32 stickylo stickyhi;
    reg u32 reslo reshi;
    reg u32 t; *)

    (* stickyhi, stickylo = #UMULL(xlo, ylo); *)
    mull stickyhi stickylo xlo ylo;
    assert prod0 = limbs 32 [stickylo, stickyhi] && true;
    assume true && prod0 = limbs 32 [stickylo, stickyhi];
    (* stickyhi <<= 7; *)
    shls discard stickyhi stickyhi 7;
    (* stickyhi |= stickylo >> 25; *)
    shrs t discard stickylo 25;
    or stickyhi@uint32 stickyhi t;
    assert true && stickyhi = philo;
    assume stickyhi = philo && true;
    (* stickylo = #UBFX(stickylo, 0, 25); *)
    shls discard t stickylo 7;
    shrs stickylo discard t 7;
    assert true && (uext stickylo 32) = prod0 & 0x1ffffff@64;

    (* reshi, reslo = #UMULL(xlo, yhi); *)
    mull reshi reslo xlo yhi;
    assert prod1 = limbs 32 [reslo, reshi] && true;
    assume true && prod1 = limbs 32 [reslo, reshi];
    (* reshi <<= 7; *)
    shls discard reshi reshi 7;
    (* reshi |= reslo >> 25; *)
    shrs t discard reslo 25;
    or reshi@uint32 reshi t;
    (* t = #UBFX(reslo, 0, 25); *)
    shls discard tt reslo 7;
    shrs t discard tt 7;
    (* stickyhi += t; *)
    adds discard stickyhi stickyhi t;

    (* prodhi, prodlo = #UMULL(xhi, ylo); *)
    mull prodhi prodlo xhi ylo;
    assert prod2 = limbs 32 [prodlo, prodhi] && true;
    assume true && prod2 = limbs 32 [prodlo, prodhi];
    (* prodhi <<= 7; *)
    shls discard prodhi prodhi 7;
    (* prodhi |= prodlo >> 25; *)
    shrs t discard prodlo 25;
    or prodhi@uint32 prodhi t;
    (* t = #UBFX(prodlo, 0, 25); *)
    shls discard tt prodlo 7;
    shrs t discard tt 7;
    (* stickyhi += t; *)
    adds discard stickyhi stickyhi t;
    (* prodlo = prodhi + reshi; *)
    adds discard prodlo prodhi reshi;

    (* prodlo += stickyhi >> 25; *)
    shrs t discard stickyhi 25;
    adds discard prodlo prodlo t;
    (* stickyhi = #UBFX(stickyhi, 0, 25); *)
    shls discard t stickyhi 7;
    shrs stickyhi discard t 7;

    assert true && (uext stickyhi 32) = pnewmid & 0x1ffffff@64;

    (* prodhi = 0; *)
    mov prodhi 0@uint32;
    (* prodlo, prodhi = #UMLAL(prodlo, prodhi, xhi, yhi); *)
    mull thi tlo xhi yhi;
    assert prod3 = limbs 32 [tlo, thi] && true;
    assume true && prod3 = limbs 32 [tlo, thi];
    adds carry prodlo prodlo tlo;
    adcs discard prodhi prodhi thi carry;

    assert true && pnewhi = limbs 32 [prodlo, prodhi];

    spl hi50 lo50 r 50;
    spl lohi25 lolo25 lo50 25;

    assert true && and[stickylo = (uext lolo25 7), stickyhi = (uext lohi25 7)];

    (* return prodlo, prodhi, stickylo, stickyhi; *)

(* } *)

(* ================================================================ *)

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

(* ================================================================ *)

(* fn __normalize_53_sticky_const(reg u32 prode prodlo prodhi stickylo stickyhi) -> reg u32, reg u32, reg u32 { *)

(*     reg u32 tsticky t0 t1;
    reg bool cflag; *)

    mov ostickylo stickylo;
    mov ostickyhi stickyhi;

    (* stickylo |= stickyhi; *)
    or stickylo@uint32 stickylo stickyhi;

    (* t0 = 0xffffffff; *)
    mov t0 0xffffffff@uint32;
    (* cflag, _, stickylo = #ADDS(stickylo, t0); *)
    adds cflag stickylo stickylo t0;
    (* t0 = 0; *)
    mov t0 0@uint32;
    (* // t0 is one if [stickylo != 0 /\ stickyhi != 0] *)
    (* t0 = #ADC(t0, 0, cflag); *)
    adcs discard t0 t0 0@uint32 cflag;
    assert true && or[and[t0 = 1@32, or[~(ostickylo = 0@32), ~(ostickyhi = 0@32)]],
                      and[t0 = 0@32, ostickylo = 0@32, ostickyhi = 0@32]];
    (* prodlo |= t0; *)
    or prodlo@uint32 prodlo t0;

    (* // t0 = 1 iff prodhi >= 2**23 *)
    (* t0 = #UBFX(prodhi, 23, 1); *)
    shls discard t prodhi 8;
    shrs t0 discard t 31;
    assert true && or[and[t0 = 1@32, (2**23)@32 <= prodhi],
                      and[t0 = 0@32, prodhi < (2**23)@32]];
    assert true && t0 = (uext shift_sticky 31);

    (* tsticky = prodlo & t0; *)
    and prodsticky@uint32 prodlo t0;
    (* prodlo >>= t0; *)
    shr prodlo prodlo t0;
    (* prodlo |= tsticky; *)
    or prodlo@uint32 prodlo prodsticky;

    (* t1 = t0 & prodhi; *)
    and t1@uint32 t0 prodhi;
    (* prodlo |= t1 << 31; *)
    shls discard t t1 31;
    or prodlo@uint32 prodlo t;

    (* prodhi >>= t0; *)
    shr prodhi prodhi t0;
    (* prode += t0; *)
    adds discard prode prode t0;

    assert true && limbs 32 [prodlo, prodhi] = tsticky;

    (* return prode, prodlo, prodhi; *)

(* } *)

(* ================================================================ *)

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

(* ================================================================ *)
assert true && prode + 2100@32 = re + 1023@32;
(* ================================================================ *)

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

(* ================================================================ *)

(* fn __fpr_const32(reg u32 s e lo hi) -> reg u32, reg u32 { *)

(*     reg u32 t mask;
    reg u32 zero; *)
(*
    mov prodlo 0@uint32;
    mov prodhi 0@uint32;
    mov prode 0@uint32;
    mov prods 0@uint32; *)

    (* // zero = [lo == 0 && hi == 0] *)
    (* t = #RSB(lo, 0); *)
    subs discard t 0@uint32 prodlo;
    (* t |= lo; *)
    or t@uint32 t prodlo;
    (* t = !t; *)
    not t@uint32 t;
    (* mask = #RSB(hi, 0); *)
    subs discard mask 0@uint32 prodhi;
    (* mask |= hi; *)
    or mask@uint32 mask prodhi;
    (* mask = !mask; *)
    not mask@uint32 mask;
    (* mask &= t; *)
    and mask@uint32 mask t;
    (* zero = mask >> 31; *)
    shrs zero discard mask 31;

    assert true && or[and[limbs 32 [prodlo, prodhi] = 0@64, zero = 1@32],
                      and[~(limbs 32 [prodlo, prodhi] = 0@64)], zero = 0@32];

    (* zero = #RSB(zero, 0); *)
    subs discard zero 0@uint32 zero;

    (* e += 1076; *)
    adds discard prode prode 1076@uint32;

    (* e = __czero_32(e, zero); *)
    and t@uint32 prode zero;
    xor prode@uint32 prode t;

    (* // mask = [(lo & 7) == 3 or 6 or 7] *)
    (* mask = lo | (lo >> 2); *)
    shrs t discard prodlo 2;
    or mask@uint32 prodlo t;
    (* mask &= lo >> 1; *)
    shrs t discard prodlo 1;
    and mask@uint32 mask t;
    (* mask &= 1; *)
    and mask@uint32 mask 1@uint32;

    (* lo = __shrd_32_inline(lo, hi, 2); *)
    shrs prodlo discard prodlo 2;
    shls discard t prodhi 30;
    or prodlo@uint32 prodlo t;
    (* hi >>= 2; *)
    shrs prodhi discard prodhi 2;
    (* lo, hi = __add_64x32(lo, hi, mask); *)
    adds carry prodlo prodlo mask;
    adcs discard prodhi prodhi 0@uint32 carry;

    (* // zeroization *)
    (* e += hi >> 20; *)
    shrs t discard prodhi 20;
    adds discard prode prode t;
    (* zero = #RSB(e, 0); *)
    subs discard zero 0@uint32 prode;
    (* zero = #ASR(zero, 31); *)
    sars zero discard zero 31;
    (* zero = !zero; *)
    not zero@uint32 zero;
    (* lo = __czero_32(lo, zero); *)
    and t@uint32 prodlo zero;
    xor prodlo@uint32 prodlo t;
    (* hi = __czero_32(hi, zero); *)
    and t@uint32 prodhi zero;
    xor prodhi@uint32 prodhi t;
    (* e = __czero_32(e, zero); *)
    and t@uint32 prode zero;
    xor prode@uint32 prode t;

    (* // saturation *)
    (* sat = #RSB(e, 2048); *)
    subs discard sat 2048@uint32 prode;
    (* sat -= 2; *)
    subs discard sat sat 2@uint32;
    (* lo |= sat >>s 31; *)
    sars t discard sat 31;
    or prodlo@uint32 prodlo t;
    (* hi |= sat >>s 31; *)
    sars t discard sat 31;
    or prodhi@uint32 prodhi t;
    (* e |= sat >>s 31; *)
    sars t discard sat 31;
    or prode@uint32 prode t;
    (* e -= sat >> 31; *)
    shrs t discard sat 31;
    subs discard prode prode t;

    (* hi = #UBFX(hi, 0, 20); *)
    and prodhi@uint32 prodhi 0xfffff@uint32;
    (* hi |= e << 20; *)
    shls discard t prode 20;
    or prodhi@uint32 prodhi t;
    (* hi <<= 1; *)
    shls discard prodhi prodhi 1;
    (* hi >>= 1; *)
    shrs prodhi discard prodhi 1;
    (* hi |= s << 31; *)
    shls discard t prods 31;
    or prodhi@uint32 prodhi t;

    assert true && limbs 32 [prodlo, prodhi] = res;

    (* return lo, hi; *)


(* } *)

(* ================================================================ *)

{
    true
    &&
    true
}



