
(*

cv -v -jobs 24 -isafety -no_carry_constraint -slicing __fadd.cl
Parsing CryptoLine file:        [OK]        0.002001 seconds
Checking well-formedness:       [OK]        0.000601 seconds

Procedure __cswap_f64
---------------------
Transforming to SSA form:       [OK]        0.000020 seconds
Normalizing specification:      [OK]        0.000023 seconds
Rewriting assignments:          [OK]        0.000003 seconds
Verifying program safety:
     Cut 0
         Round 1 (0 safety conditions, timeout = 300 seconds)
     Overall            [OK]        0.000010 seconds
Verifying range assertions:     [OK]        0.051984 seconds
Verifying range specification:      [OK]        0.099272 seconds
Rewriting value-preserved casting:  [OK]        0.000011 seconds
Verifying algebraic assertions:     [OK]        0.000012 seconds
Verifying algebraic specification:  [OK]        0.000004 seconds
Procedure verification:         [OK]        0.151404 seconds

Procedure __split_f64
---------------------
Transforming to SSA form:       [OK]        0.000035 seconds
Normalizing specification:      [OK]        0.000042 seconds
Rewriting assignments:          [OK]        0.000020 seconds
Verifying program safety:
     Cut 0
         Round 1 (0 safety conditions, timeout = 300 seconds)
     Overall            [OK]        0.000013 seconds
Verifying range assertions:     [OK]        0.014424 seconds
Verifying range specification:      [OK]        0.014397 seconds
Rewriting value-preserved casting:  [OK]        0.000007 seconds
Verifying algebraic assertions:     [OK]        0.000013 seconds
Verifying algebraic specification:  [OK]        0.000004 seconds
Procedure verification:         [OK]        0.029037 seconds

Procedure main
--------------
Transforming to SSA form:       [OK]        0.000206 seconds
Normalizing specification:      [OK]        0.000349 seconds
Rewriting assignments:          [OK]        0.000209 seconds
Verifying program safety:
     Cut 0
         Round 1 (6 safety conditions, timeout = 300 seconds)
         Safety condition #5    [OK]
         Safety condition #0    [OK]
         Safety condition #2    [OK]
         Safety condition #1    [OK]
         Safety condition #4    [OK]
         Safety condition #3    [OK]
     Overall            [OK]        0.032037 seconds
Verifying range assertions:     [OK]        53.730055 seconds
Verifying range specification:      [OK]        0.000021 seconds
Rewriting value-preserved casting:  [OK]        0.000033 seconds
Verifying algebraic assertions:     [OK]        0.000175 seconds
Verifying algebraic specification:  [OK]        0.000014 seconds
Procedure verification:         [OK]        53.763452 seconds

Summary
-------
Verification result:            [OK]        53.946560 seconds

*)

(*
// assume 0 <= n <= 32
inline
fn __ulsh_32x2_inline(reg u32 lo hi, inline int n) -> reg u32, reg u32 {

    if(n >= 32){
        hi = lo;
        lo = 0;
        n -= 32;
    }

    hi = #LSL(hi, n);
    hi |= (lo >> (32 - n));
    lo = #LSL(lo, n);

    return lo, hi;

}

inline
fn __shrd_32_inline(reg u32 lo hi, inline int n) -> reg u32 {

    if(n >= 32){
        lo = hi;
        hi = 0;
        n -= 32;
    }

    lo = #LSR(lo, n);
    lo |= (hi << (32 - n));

    return lo;

}

// flag == 0 or -1
inline
fn __cset_32(reg u32 a b flag) -> reg u32 {
    b ^= a;
    b &= flag;
    a ^= b;
    return a;
}

inline
fn __cswap_32(reg u32 a b flag) -> reg u32, reg u32 {
    reg u32 t;
    t = a ^ b;
    t &= flag;
    a ^= t;
    b ^= t;
    return a, b;
}

inline
fn __czero_32(reg u32 a flag) -> reg u32 {
    reg u32 t;
    t = a & flag;
    a ^= t;
    return a;
}

inline
fn __add_64x32(reg u32 lo hi a) -> reg u32, reg u32 {
    reg bool cflag;
    cflag, _, lo = #ADDS(lo, a);
    hi = #ADC(hi, 0, cflag);
    return lo, hi;
}

inline
fn __addi_64x32(reg u32 lo hi, inline int i) -> reg u32, reg u32 {
    reg bool cflag;
    cflag, _, lo = #ADDS(lo, i);
    hi = #ADC(hi, 0, cflag);
    return lo, hi;
}

inline
fn __neg_32x2(reg u32 lo hi) -> reg u32, reg u32 {

    lo = !lo; hi = !hi;
    lo, hi = __addi_64x32(lo, hi, 1);
    return lo, hi;

}
 *)

proc __cswap_f64(uint32 xlo, uint32 xhi, uint32 ylo, uint32 yhi;
                 uint32 xplo, uint32 xphi, uint32 yplo, uint32 yphi) =
{
    true && true
}


(* fn __cswap_const32(reg u32 xlo xhi ylo yhi) -> reg u32, reg u32, reg u32, reg u32 { *)

(*     reg u32 t0 t1 diff;
    reg u32 swap swaplo;
    reg u32 xuhi yuhi;
    reg u32 nylo nyhi;
    reg u32 difflo diffhi;

    reg bool cflag; *)

    (* xuhi = #UBFX(xhi, 0, 31); *)
    shls discard t xhi 1;
    shrs xuhi discard t 1;
    (* yuhi = #UBFX(yhi, 0, 31); *)
    shls discard t yhi 1;
    shrs yuhi discard t 1;

    join xu xuhi xlo;
    join yu yuhi ylo;


    (* nylo = !ylo; *)
    not nylo@uint32 ylo;
    (* nyhi = !yuhi; *)
    not nyhi@uint32 yuhi;
    (* nylo, nyhi = __addi_64x32(nylo, nyhi, 1); *)
    adds carry nylo nylo 1@uint32;
    adcs discard nyhi nyhi 0@uint32 carry;

    (* cflag, _, difflo = #ADDS(xlo, nylo); *)
    adds carry difflo xlo nylo;
    (* diffhi = #ADC(xuhi, nyhi, cflag); *)
    adcs discard diffhi xuhi nyhi carry;

    (* swap = diffhi >> 31; *)
    shrs swap discard diffhi 31;

    (* t0 = #RSB(difflo, 0); *)
    subs discard t0 0@uint32 difflo;
    (* t0 |= difflo; *)
    or t0@uint32 t0 difflo;
    (* t0 >>= 31; *)
    shrs t0 discard t0 31;
    (* t0 = !t0; *)
    not t0@uint32 t0;
    (* t1 = #RSB(diffhi, 0); *)
    subs discard t1 0@uint32 diffhi;
    (* t1 |= diffhi; *)
    or t1@uint32 t1 diffhi;
    (* t1 >>= 31; *)
    shrs t1 discard t1 31;
    (* t1 = !t1; *)
    not t1@uint32 t1;

    (* t0 &= t1; *)
    and t0@uint32 t0 t1;
    (* t0 &= xhi >> 31; *)
    shrs t discard xhi 31;
    and t0@uint32 t0 t;

    (* swap |= t0; *)
    or swap@uint32 swap t0;

    (* swap = #RSB(swap, 0); *)
    subs discard swap 0@uint32 swap;


    (* xlo, ylo = __cswap_32(xlo, ylo, swap); *)
    (* xhi, yhi = __cswap_32(xhi, yhi, swap); *)

    xor t@uint32 xlo ylo;
    and t@uint32 t swap;
    xor xplo@uint32 xlo t;
    xor yplo@uint32 ylo t;

    xor t@uint32 xhi yhi;
    and t@uint32 t swap;
    xor xphi@uint32 xhi t;
    xor yphi@uint32 yhi t;

    assert true && or[and[swap = 0@32, xplo = xlo, xphi = xhi, yplo = ylo, yphi = yhi],
                      and[swap = (-1)@32, xplo = ylo, xphi = yhi, yplo = xlo, yphi = xhi]];

    (* return xlo, xhi, ylo, yhi; *)

(* } *)


{
    true &&
        or[and[or[limbs 32 [xlo, xhi & 0x7fffffff@32] < limbs 32 [ylo, yhi & 0x7fffffff@32],
                  and[limbs 32 [xlo, xhi & 0x7fffffff@32] = limbs 32 [ylo, yhi & 0x7fffffff@32],
                        (xhi & 0x80000000@32) = 0x80000000@32]],
               and[xplo = ylo, xphi = yhi, yplo = xlo, yphi = xhi]],
           and[~or[limbs 32 [xlo, xhi & 0x7fffffff@32] < limbs 32 [ylo, yhi & 0x7fffffff@32],
                  and[limbs 32 [xlo, xhi & 0x7fffffff@32] = limbs 32 [ylo, yhi & 0x7fffffff@32],
                        (xhi & 0x80000000@32) = 0x80000000@32]],
               and[xplo = xlo, xphi = xhi, yplo = ylo, yphi = yhi]]]
}

proc __split_f64(uint32 xlo, uint32 xhi, uint32 ylo, uint32 yhi;
                 uint32 sxp, uint32 exp, uint32 xplo, uint32 xphi,
                 uint32 syp, uint32 eyp, uint32 yplo, uint32 yphi) =
{
    true && true
}

(* fn __split_const32(reg u32 xlo xhi ylo yhi) -> reg u32, reg u32, reg u32, reg u32, reg u32, reg u32, reg u32, reg u32 { *)

(*     reg u32 sx ex sy ey;
    reg u32 t; *)

    mov oxlo xlo;
    mov oxhi xhi;
    mov oylo ylo;
    mov oyhi yhi;

    (* sx = xhi >> 31; *)
    shrs sx discard xhi 31;
    (* ex = #UBFX(xhi, 20, 11); *)
    shls discard t xhi 1;
    shrs ex discard t 21;
    (* xhi = #UBFX(xhi, 0, 20); *)
    shls discard t xhi 12;
    shrs xhi discard t 12;

    (* t = #RSB(ex, 0); *)
    subs discard t 0@uint32 ex;
    (* t |= ex; *)
    or t@uint32 t ex;
    (* t >>= 31; *)
    shrs t discard t 31;
    (* t = #RSB(t, 0); *)
    subs discard t 0@uint32 t;
    (* xlo &= t; *)
    and xlo@uint32 xlo t;
    (* xhi &= t; *)
    and xhi@uint32 xhi t;
    (* t = #RSB(t, 0); *)
    subs discard t 0@uint32 t;
    (* xhi |= t << 20; *)
    shls discard tt t 20;
    or xhi@uint32 xhi tt;
    (* xhi <<= 3; *)
    shls discard xhi xhi 3;
    (* xhi |= xlo >> 29; *)
    shrs tt discard xlo 29;
    or xhi@uint32 xhi tt;
    (* xlo <<= 3; *)
    shls discard xlo xlo 3;
    (* ex -= 1078; *)
    subs discard ex ex 1078@uint32;

    assert true && and[oxhi & 0x80000000@32 = sx * (2**31)@32, (oxhi & 0x7ff00000@32) = (ex + 1078@32) * (2**20)@32];

    assert true && or[and[oxhi & 0x7ff00000@32 = 0@32, xlo = 0@32, xhi = 0@32],
                      and[~(oxhi & 0x7ff00000@32 = 0@32),
                            limbs 32 [xlo, xhi] =
                            (((limbs 32 [oxlo, oxhi]) & 0xfffffffffffff@64) | 0x10000000000000@64) * 8@64]];

    (* sy = yhi >> 31; *)
    shrs sy discard yhi 31;
    (* ey = #UBFX(yhi, 20, 11); *)
    shls discard t yhi 1;
    shrs ey discard t 21;
    (* yhi = #UBFX(yhi, 0, 20); *)
    shls discard t yhi 12;
    shrs yhi discard t 12;

    (* t = #RSB(ey, 0); *)
    subs discard t 0@uint32 ey;
    (* t |= ey; *)
    or t@uint32 t ey;
    (* t >>= 31; *)
    shrs t discard t 31;
    (* t = #RSB(t, 0); *)
    subs discard t 0@uint32 t;
    (* ylo &= t; *)
    and ylo@uint32 ylo t;
    (* yhi &= t; *)
    and yhi@uint32 yhi t;
    (* t = #RSB(t, 0); *)
    subs discard t 0@uint32 t;
    (* yhi |= t << 20; *)
    shls discard tt t 20;
    or yhi@uint32 yhi tt;
    (* yhi <<= 3; *)
    shls discard yhi yhi 3;
    (* yhi |= ylo >> 29; *)
    shrs tt discard ylo 29;
    or yhi@uint32 yhi tt;
    (* ylo <<= 3; *)
    shls discard ylo ylo 3;
    (* ey -= 1078; *)
    subs discard ey ey 1078@uint32;

    assert true && and[oyhi & 0x80000000@32 = sy * (2**31)@32, (oyhi & 0x7ff00000@32) = (ey + 1078@32) * (2**20)@32];

    assert true && or[and[oyhi & 0x7ff00000@32 = 0@32, ylo = 0@32, yhi = 0@32],
                      and[~(oyhi & 0x7ff00000@32 = 0@32),
                            limbs 32 [ylo, yhi] =
                            (((limbs 32 [oylo, oyhi]) & 0xfffffffffffff@64) | 0x10000000000000@64) * 8@64]];

    mov sxp sx;
    mov exp ex;

    mov xplo xlo;
    mov xphi xhi;
    mov xlo oxlo;
    mov xhi oxhi;

    mov syp sy;
    mov eyp ey;

    mov yplo ylo;
    mov yphi yhi;
    mov ylo oylo;
    mov yhi oyhi;

    (* return sx, ex, xlo, xhi, sy, ey, ylo, yhi; *)

(* } *)

{
    true &&
        and[xhi & 0x80000000@32 = sxp * (2**31)@32, (xhi & 0x7ff00000@32) = (exp + 1078@32) * (2**20)@32,
            or[and[xhi & 0x7ff00000@32 = 0@32, xplo = 0@32, xphi = 0@32],
                      and[~(xhi & 0x7ff00000@32 = 0@32),
                            limbs 32 [xplo, xphi] =
                            (((limbs 32 [xlo, xhi]) & 0xfffffffffffff@64) | 0x10000000000000@64) * 8@64]],
            yhi & 0x80000000@32 = syp * (2**31)@32, (yhi & 0x7ff00000@32) = (eyp + 1078@32) * (2**20)@32,
            or[and[yhi & 0x7ff00000@32 = 0@32, yplo = 0@32, yphi = 0@32],
                      and[~(yhi & 0x7ff00000@32 = 0@32),
                            limbs 32 [yplo, yphi] =
                            (((limbs 32 [ylo, yhi]) & 0xfffffffffffff@64) | 0x10000000000000@64) * 8@64]]

        ]
}



(* ================================================================ *)

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

(* ================================================================ *)


inline __cswap_f64(r0, r1, r2, r3, xlo, xhi, ylo, yhi);

assert true && and[limbs 32 [xlo, xhi] = src0, limbs 32 [ylo, yhi] = src1];

(* ================================================================ *)

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

shls discard xm m0 3;
shls discard ym m1 3;

(* ================================================================ *)

inline __split_f64(xlo, xhi, ylo, yhi, sxp, exp, xplo, xphi, syp, eyp, yplo, yphi);

mov xlo xplo;
mov xhi xphi;
mov ylo yplo;
mov yhi yphi;

assert true && and[(uext s0 31) = sxp, (uext e0 21) = exp + 1078@32, xm = limbs 32 [xlo, xhi],
                   (uext s1 31) = syp, (uext e1 21) = eyp + 1078@32, ym = limbs 32 [ylo, yhi]];

(* ================================================================ *)

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

assert true && or[and[rbit = 0@64, sticky = 0@64], and[~(rbit = 0@64), sticky = 1@64]];

(* ================================================================ *)


(* fn __cshift_const32(reg u32 ex ey ylo yhi) -> reg u32, reg u32 { *)

(*     reg u32 cc t tlo thi;
    reg u32 sticky mask; *)

    (* cc = ex - ey; *)
    subs discard cc exp eyp;

    (* // mask = [cc > 59] *)
    (* mask = #RSB(cc, 59); *)
    subs discard mask 59@uint32 cc;
    (* mask >>= 31; *)
    shrs mask discard mask 31;
    (* mask -= 1; *)
    subs discard mask mask 1@uint32;
    (* ylo &= mask; *)
    and ylo@uint32 ylo mask;
    (* yhi &= mask; *)
    and yhi@uint32 yhi mask;
    (* cc &= 63; *)
    and cc@uint32 cc 63@uint32;

    (* mask = #SBFX(cc, 5, 1); *)
    shrs t discard cc 5;
    and t@uint32 t 1@uint32;
    subs discard mask 0@uint32 t;
    (* sticky = __cset_32(zero, ylo, mask); *)
    xor t@uint32 0@uint32 ylo;
    and t@uint32 t mask;
    xor stickyp@uint32 0@uint32 t;
    (* ylo = __cset_32(ylo, yhi, mask); *)
    xor t@uint32 ylo yhi;
    and t@uint32 t mask;
    xor ylo@uint32 ylo t;
    (* yhi = __czero_32(yhi, mask); *)
    and t@uint32 yhi mask;
    xor yhi@uint32 yhi t;
    (* cc &= 31; *)
    and cc@uint32 cc 31@uint32;
    (* t = #RSB(cc, 32); *)
    subs discard t 32@uint32 cc;
    assert true && and[1@32 <= t, t <= 32@32];

    (* mask = ylo << t; *)
    shl mask ylo t;
    (* sticky |= mask; *)
    or stickyp@uint32 stickyp mask;

    assert true && or[and[sticky = 0@64, stickyp = 0@32], and[~(sticky = 0@64), ~(stickyp = 0@32)]];

    (* ylo >>= cc; *)
    shr ylo ylo cc;
    (* t = yhi << t; *)
    shl t yhi t;
    (* ylo |= t; *)
    or ylo@uint32 ylo t;
    (* yhi >>= cc; *)
    shr yhi yhi cc;
    (* t = #RSB(sticky, 0); *)
    subs discard t 0@uint32 stickyp;
    (* t |= sticky; *)
    or t@uint32 t stickyp;
    (* ylo |= t >> 31; *)
    shrs tt discard t 31;
    or ylo@uint32 ylo tt;

    assert true && ym2 = limbs 32 [ylo, yhi];

    (* return ylo, yhi; *)

(* } *)

(* ================================================================ *)

(* negate ym if the signs are different *)

xor ts@uint1 s0 s1;
not t@uint64 ym2;
adds discard t t 1@uint64;
adds carry discard ts 1@uint1;
cmov ym3 carry t ym2;

(* add the mantissas *)

adds discard trm xm ym3;

(* ================================================================ *)

(* fn __caddsub_const32(reg u32 xlo xhi ylo yhi sx sy) -> reg u32, reg u32 { *)

(*     reg u32 tlo, thi;
    reg u32 t; *)

    (* tlo = ylo; thi = yhi; *)
    mov tlo ylo;
    mov thi yhi;
    (* tlo, thi = __neg_32x2(tlo, thi); *)
    not tlo@uint32 tlo;
    not thi@uint32 thi;
    adds cflag tlo tlo 1@uint32;
    adcs discard thi thi 0@uint32 cflag;

    (* t = sx ^ sy; *)
    xor t@uint32 sxp syp;
    (* t = #RSB(t, 0); *)
    subs discard t 0@uint32 t;
    (* ylo = __cset_32(ylo, tlo, t); *)
    xor tlo@uint32 tlo ylo;
    and tlo@uint32 tlo t;
    xor ylo@uint32 ylo tlo;
    (* yhi = __cset_32(yhi, thi, t); *)
    xor thi@uint32 thi yhi;
    and thi@uint32 thi t;
    xor yhi@uint32 yhi thi;
    (* xlo, xhi = __add_64x32(xlo, xhi, ylo); *)
    adds cflag xlo xlo ylo;
    adcs discard xhi xhi 0@uint32 cflag;
    (* xhi += yhi; *)
    adds discard xhi xhi yhi;

    (* return xlo, xhi; *)

(* } *)

    assert true && trm = limbs 32 [xlo, xhi];

(* ================================================================ *)

(* shift to the range [2**63, 2**64) *)

cast uint32 txe e0;

assert true && txe = exp + 1078@32;

mov tm trm;
mov te 0@uint32;

shls hi lo tm 32;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 32@uint32 0@uint32;
adds discard te te t;

mov _te32 te;

shls hi lo tm 16;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 16@uint32 0@uint32;
adds discard te te t;

mov _te16 te;

shls hi lo tm 8;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 8@uint32 0@uint32;
adds discard te te t;

mov _te8 te;

shls hi lo tm 4;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 4@uint32 0@uint32;
adds discard te te t;

mov _te4 te;

shls hi lo tm 2;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 2@uint32 0@uint32;
adds discard te te t;

mov _te2 te;

shls hi lo tm 1;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

mov _te1 te;

shls hi lo tm 1;
cast uint64 hi hi;
not hi@uint64 hi;
adds carry discard hi 1@uint64;
cmov tm carry lo tm;
cmov t carry 1@uint32 0@uint32;
adds discard te te t;

assert true && or[and[trm = 0@64, t = 1@32], and[~(trm = 0@64), t = 0@32]];

mov trm0 tm;
subs discard txe txe te;

assert true && or[trm0 = 0@64, (2**63)@64 <= trm0];

(* ================================================================ *)
(*
inline
fn __normalize_32(reg u32 lo hi e, inline int i) -> reg u32, reg u32, reg u32 {

    reg u32 zero t adde;
    reg u32 tlo thi;

    zero = hi >> (32 - i);
    t = #RSB(zero, 0);
    zero |= t;
    zero >>= 31;
    adde = i;
    adde *= zero;
    e += adde;
    tlo = lo; thi = hi;
    tlo, thi = __ulsh_32x2_inline(tlo, thi, i);
    zero -= 1;
    lo = __cset_32(lo, tlo, zero);
    hi = __cset_32(hi, thi, zero);

    return lo, hi, e;

}
 *)
(* fn __normalize_64_const32(reg u32 xlo xhi ex) -> reg u32, reg u32, reg u32 { *)

(*     reg u32 zero t;
    reg u32 adde; *)


    assert true && trm = limbs 32 [xlo, xhi];

    mov acce 0@uint32;

    (* ex -= 63; *)
    subs discard exp exp 63@uint32;

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* // conditionally shift 16 bits *)
    (* // decide if we want to apply them *)
    (* zero = xhi; *)
    mov zero xhi;
    (* t = #RSB(xhi, 0); *)
    subs discard t 0@uint32 xhi;
    (* zero |= t; *)
    or zero@uint32 zero t;
    (* zero >>= 31; *)
    shrs zero discard zero 31;
    (* adde = 32; *)
    mov adde 32@uint32;
    (* adde *= zero; *)
    mul adde adde zero;
    (* // add 32 if [xhi != 0] *)
    (* ex += adde; *)
    adds discard exp exp adde;
    (* // assign xlo, xhi = tlo, thi if [xhi == 0] *)
    (* zero -= 1; *)
    subs discard zero zero 1@uint32;
    (* xhi = __cset_32(xhi, xlo, zero); *)
    xor t@uint32 xhi xlo;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;
    (* xlo = __czero_32(xlo, zero); *)
    and t@uint32 xlo zero;
    xor xlo@uint32 xlo t;

    adds discard acce acce adde;
    assert true && _te32 + acce = 32@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], and[xlo = 0@32, xhi = xlo_o]];

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* xlo, xhi, ex = __normalize_32(xlo, xhi, ex, 16); *)
    shrs zero discard xhi 16;
    subs discard t 0@uint32 zero;
    or zero@uint32 zero t;
    shrs zero discard zero 31;
    mov adde 16@uint32;
    mul adde adde zero;
    adds discard exp exp adde;
    mov tlo xlo;
    mov thi xhi;
    shls discard thi thi 16;
    shrs t discard tlo 16;
    or thi@uint32 thi t;
    shls discard tlo tlo 16;
    subs discard zero zero 1@uint32;
    xor t@uint32 xlo tlo;
    and t@uint32 t zero;
    xor xlo@uint32 xlo t;
    xor t@uint32 xhi thi;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;

    adds discard acce acce adde;
    assert true && _te16 + acce = 48@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], limbs 32 [xlo, xhi] = limbs 32 [xlo_o, xhi_o] * (2**16)@64];

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* xlo, xhi, ex = __normalize_32(xlo, xhi, ex, 8); *)
    shrs zero discard xhi 24;
    subs discard t 0@uint32 zero;
    or zero@uint32 zero t;
    shrs zero discard zero 31;
    mov adde 8@uint32;
    mul adde adde zero;
    adds discard exp exp adde;
    mov tlo xlo;
    mov thi xhi;
    shls discard thi thi 8;
    shrs t discard tlo 24;
    or thi@uint32 thi t;
    shls discard tlo tlo 8;
    subs discard zero zero 1@uint32;
    xor t@uint32 xlo tlo;
    and t@uint32 t zero;
    xor xlo@uint32 xlo t;
    xor t@uint32 xhi thi;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;

    adds discard acce acce adde;
    assert true && _te8 + acce = 56@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], limbs 32 [xlo, xhi] = limbs 32 [xlo_o, xhi_o] * (2**8)@64];

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* xlo, xhi, ex = __normalize_32(xlo, xhi, ex, 4); *)
    shrs zero discard xhi 28;
    subs discard t 0@uint32 zero;
    or zero@uint32 zero t;
    shrs zero discard zero 31;
    mov adde 4@uint32;
    mul adde adde zero;
    adds discard exp exp adde;
    mov tlo xlo;
    mov thi xhi;
    shls discard thi thi 4;
    shrs t discard tlo 28;
    or thi@uint32 thi t;
    shls discard tlo tlo 4;
    subs discard zero zero 1@uint32;
    xor t@uint32 xlo tlo;
    and t@uint32 t zero;
    xor xlo@uint32 xlo t;
    xor t@uint32 xhi thi;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;

    adds discard acce acce adde;
    assert true && _te4 + acce = 60@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], limbs 32 [xlo, xhi] = limbs 32 [xlo_o, xhi_o] * (2**4)@64];

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* xlo, xhi, ex = __normalize_32(xlo, xhi, ex, 2); *)
    shrs zero discard xhi 30;
    subs discard t 0@uint32 zero;
    or zero@uint32 zero t;
    shrs zero discard zero 31;
    mov adde 2@uint32;
    mul adde adde zero;
    adds discard exp exp adde;
    mov tlo xlo;
    mov thi xhi;
    shls discard thi thi 2;
    shrs t discard tlo 30;
    or thi@uint32 thi t;
    shls discard tlo tlo 2;
    subs discard zero zero 1@uint32;
    xor t@uint32 xlo tlo;
    and t@uint32 t zero;
    xor xlo@uint32 xlo t;
    xor t@uint32 xhi thi;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;

    adds discard acce acce adde;
    assert true && _te2 + acce = 62@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], limbs 32 [xlo, xhi] = limbs 32 [xlo_o, xhi_o] * (2**2)@64];

    mov xlo_o xlo;
    mov xhi_o xhi;
    (* xlo, xhi, ex = __normalize_32(xlo, xhi, ex, 1); *)
    shrs zero discard xhi 31;
    subs discard t 0@uint32 zero;
    or zero@uint32 zero t;
    shrs zero discard zero 31;
    mov adde 1@uint32;
    mul adde adde zero;
    adds discard exp exp adde;
    mov tlo xlo;
    mov thi xhi;
    shls discard thi thi 1;
    shrs t discard tlo 31;
    or thi@uint32 thi t;
    shls discard tlo tlo 1;
    subs discard zero zero 1@uint32;
    xor t@uint32 xlo tlo;
    and t@uint32 t zero;
    xor xlo@uint32 xlo t;
    xor t@uint32 xhi thi;
    and t@uint32 t zero;
    xor xhi@uint32 xhi t;

    adds discard acce acce adde;
    assert true && _te1 + acce = 63@32;

    assert true && or[and[xlo = xlo_o, xhi = xhi_o], limbs 32 [xlo, xhi] = limbs 32 [xlo_o, xhi_o] * (2**1)@64];

    (* return xlo, xhi, ex; *)

    assert true && trm0 = limbs 32 [xlo, xhi];
    assert true && or[and[trm0 = 0@64, txe = exp + 1077@32], and[~(trm0 = 0@64), txe = exp + 1078@32]];

    assert true && or[limbs 32 [xlo, xhi] = 0@64, limbs 32 [xlo, xhi] >= (2**63)@64];

(* } *)

(* ================================================================ *)

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

(* ================================================================ *)

(* fn __scale_const32(reg u32 xlo xhi ex) -> reg u32, reg u32, reg u32 { *)

(*     reg u32 sticky;
    reg u32 c; *)

    (* c = 0x1ff; *)
    mov c 0x1ff@uint32;

    (* sticky = xlo & c; *)
    and stickyp@uint32 xlo c;
    (* sticky += c; *)
    adds discard stickyp stickyp c;
    (* xlo |= sticky; *)
    or xlo@uint32 xlo stickyp;
    (* xlo = __shrd_32_inline(xlo, xhi, 9); *)
    shrs xlo discard xlo 9;
    shls discard t xhi 23;
    or xlo@uint32 xlo t;
    (* xhi >>= 9; *)
    shrs xhi discard xhi 9;
    (* ex += 9; *)
    adds discard exp exp 9@uint32;

    (* return xlo, xhi, ex; *)

    assert true && or[limbs 32 [xlo, xhi] = 0@64,
                   and[(2**54)@64 <= limbs 32 [xlo, xhi], limbs 32 [xlo, xhi] < (2**55)@64]];

(* } *)

(* fn __fpr_const32(reg u32 s e lo hi) -> reg u32, reg u32 { *)

(*     reg u32 t mask;
    reg u32 zero; *)

    (* // zero = [lo == 0 && hi == 0] *)
    (* t = #RSB(lo, 0); *)
    subs discard t 0@uint32 xlo;
    (* t |= lo; *)
    or t@uint32 t xlo;
    (* t = !t; *)
    not t@uint32 t;
    (* mask = #RSB(hi, 0); *)
    subs discard mask 0@uint32 xhi;
    (* mask |= hi; *)
    or mask@uint32 mask xhi;
    (* mask = !mask; *)
    not mask@uint32 mask;
    (* mask &= t; *)
    and mask@uint32 mask t;
    (* zero = mask >> 31; *)
    shrs zero discard mask 31;

    assert true && or[and[limbs 32 [xlo, xhi] = 0@64, zero = 1@32],
                      and[~(limbs 32 [xlo, xhi] = 0@64)], zero = 0@32];

    (* zero = #RSB(zero, 0); *)
    subs discard zero 0@uint32 zero;

    (* e += 1076; *)
    adds discard exp exp 1076@uint32;

    (* e = __czero_32(e, zero); *)
    and t@uint32 exp zero;
    xor exp@uint32 exp t;

    (* // mask = [(lo & 7) == 3 or 6 or 7] *)
    (* mask = lo | (lo >> 2); *)
    shrs t discard xlo 2;
    or mask@uint32 xlo t;
    (* mask &= lo >> 1; *)
    shrs t discard xlo 1;
    and mask@uint32 mask t;
    (* mask &= 1; *)
    and mask@uint32 mask 1@uint32;

    (* lo = __shrd_32_inline(lo, hi, 2); *)
    shrs xlo discard xlo 2;
    shls discard t xhi 30;
    or xlo@uint32 xlo t;
    (* hi >>= 2; *)
    shrs xhi discard xhi 2;
    (* lo, hi = __add_64x32(lo, hi, mask); *)
    adds carry xlo xlo mask;
    adcs discard xhi xhi 0@uint32 carry;

    (* // zeroization *)
    (* e += hi >> 20; *)
    shrs t discard xhi 20;
    adds discard exp exp t;
    (* zero = #RSB(e, 0); *)
    subs discard zero 0@uint32 exp;
    (* zero = #ASR(zero, 31); *)
    sars zero discard zero 31;
    (* zero = !zero; *)
    not zero@uint32 zero;
    (* lo = __czero_32(lo, zero); *)
    and t@uint32 xlo zero;
    xor xlo@uint32 xlo t;
    (* hi = __czero_32(hi, zero); *)
    and t@uint32 xhi zero;
    xor xhi@uint32 xhi t;
    (* e = __czero_32(e, zero); *)
    and t@uint32 exp zero;
    xor exp@uint32 exp t;

    (* // saturation *)
    (* sat = #RSB(e, 2048); *)
    subs discard sat 2048@uint32 exp;
    (* sat -= 2; *)
    subs discard sat sat 2@uint32;
    (* lo |= sat >>s 31; *)
    sars t discard sat 31;
    or xlo@uint32 xlo t;
    (* hi |= sat >>s 31; *)
    sars t discard sat 31;
    or xhi@uint32 xhi t;
    (* e |= sat >>s 31; *)
    sars t discard sat 31;
    or exp@uint32 exp t;
    (* e -= sat >> 31; *)
    shrs t discard sat 31;
    subs discard exp exp t;

    (* hi = #UBFX(hi, 0, 20); *)
    shls discard t xhi 12;
    shrs xhi discard t 12;
    (* hi |= e << 20; *)
    shls discard t exp 20;
    or xhi@uint32 xhi t;
    (* hi <<= 1; *)
    shls discard xhi xhi 1;
    (* hi >>= 1; *)
    shrs xhi discard xhi 1;
    (* hi |= s << 31; *)
    shls discard t sxp 31;
    or xhi@uint32 xhi t;

    (* return lo, hi; *)

    assert true && limbs 32 [xlo, xhi] = tr1;

(* } *)

(* ================================================================ *)


{
    true && true
}

