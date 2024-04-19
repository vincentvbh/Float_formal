	.thumb
	.syntax unified
	.global	___fexpm_p63_export
	.global	__fexpm_p63_export
___fexpm_p63_export:
__fexpm_p63_export:
	push	{lr}
	SUB 	r12, sp, #28
	BIC 	r12, r12, #3
	STR 	sp, [r12, #24]
	MOV 	sp, r12
	STR 	r9, [sp]
	STR 	r8, [sp, #4]
	STR 	r7, [sp, #8]
	STR 	r6, [sp, #12]
	STR 	r5, [sp, #16]
	STR 	r4, [sp, #20]
	LDR 	r3, [r1]
	LDR 	r1, [r1, #4]
	LDR 	r12, [r2]
	LDR 	r2, [r2, #4]
	SUB 	sp, sp, #12
	bl  	L__fexpm_p63$1
L__fexpm_p63_export$1:
	ADD 	sp, sp, #8
	STR 	r1, [r0]
	STR 	r2, [r0, #4]
	LDR 	r9, [sp]
	LDR 	r8, [sp, #4]
	LDR 	r7, [sp, #8]
	LDR 	r6, [sp, #12]
	LDR 	r5, [sp, #16]
	LDR 	r4, [sp, #20]
	LDR 	sp, [sp, #24]
	pop 	{pc}
	.global	___polyeval_horn_export
	.global	__polyeval_horn_export
___polyeval_horn_export:
__polyeval_horn_export:
	push	{lr}
	SUB 	r12, sp, #20
	BIC 	r12, r12, #3
	STR 	sp, [r12, #16]
	MOV 	sp, r12
	STR 	r7, [sp]
	STR 	r6, [sp, #4]
	STR 	r5, [sp, #8]
	STR 	r4, [sp, #12]
	LDR 	r2, [r1]
	LDR 	r1, [r1, #4]
	bl  	L__polyeval_horn$1
L__polyeval_horn_export$1:
	STR 	r1, [r0]
	STR 	r3, [r0, #4]
	LDR 	r7, [sp]
	LDR 	r6, [sp, #4]
	LDR 	r5, [sp, #8]
	LDR 	r4, [sp, #12]
	LDR 	sp, [sp, #16]
	pop 	{pc}
	.global	___fixedmul_64x64_export
	.global	__fixedmul_64x64_export
___fixedmul_64x64_export:
__fixedmul_64x64_export:
	push	{lr}
	SUB 	r12, sp, #12
	BIC 	r12, r12, #3
	STR 	sp, [r12, #8]
	MOV 	sp, r12
	STR 	r5, [sp]
	STR 	r4, [sp, #4]
	LDR 	r3, [r1]
	LDR 	r1, [r1, #4]
	LDR 	r12, [r2]
	LDR 	r2, [r2, #4]
	UMULL	r4, lr, r3, r12
	UMULL	r5, r4, r1, r2
	UMULL	r3, r2, r3, r2
	ADDs	r3, lr, r3
	ADCs	r2, r5, r2
	ADC 	lr, r4, #0
	UMULL	r12, r1, r12, r1
	ADDs	r3, r3, r12
	ADCs	r1, r2, r1
	ADC 	r2, lr, #0
	STR 	r1, [r0]
	STR 	r2, [r0, #4]
	LDR 	r5, [sp]
	LDR 	r4, [sp, #4]
	LDR 	sp, [sp, #8]
	pop 	{pc}
	.global	___ffromint64_32_export
	.global	__ffromint64_32_export
___ffromint64_32_export:
__ffromint64_32_export:
	push	{lr}
	SUB 	r12, sp, #24
	BIC 	r12, r12, #3
	STR 	sp, [r12, #20]
	MOV 	sp, r12
	STR 	r9, [sp]
	STR 	r8, [sp, #4]
	STR 	r6, [sp, #8]
	STR 	r5, [sp, #12]
	STR 	r4, [sp, #16]
	LDR 	r2, [r1]
	LDR 	r1, [r1, #4]
	SUB 	sp, sp, #4
	bl  	L__ffromint64_32$1
L__ffromint64_32_export$1:
	STR 	r4, [r0]
	STR 	r6, [r0, #4]
	LDR 	r9, [sp]
	LDR 	r8, [sp, #4]
	LDR 	r6, [sp, #8]
	LDR 	r5, [sp, #12]
	LDR 	r4, [sp, #16]
	LDR 	sp, [sp, #20]
	pop 	{pc}
	.global	___ffloor_32_export
	.global	__ffloor_32_export
___ffloor_32_export:
__ffloor_32_export:
	push	{lr}
	SUB 	r12, sp, #16
	BIC 	r12, r12, #3
	STR 	sp, [r12, #12]
	MOV 	sp, r12
	STR 	r6, [sp]
	STR 	r5, [sp, #4]
	STR 	r4, [sp, #8]
	LDR 	r4, [r1]
	LDR 	r6, [r1, #4]
	SUB 	sp, sp, #4
	bl  	L__ffloor_32$1
L__ffloor_32_export$1:
	STR 	r1, [r0]
	STR 	r2, [r0, #4]
	LDR 	r6, [sp]
	LDR 	r5, [sp, #4]
	LDR 	r4, [sp, #8]
	LDR 	sp, [sp, #12]
	pop 	{pc}
	.global	___ftrunc_32_export
	.global	__ftrunc_32_export
___ftrunc_32_export:
__ftrunc_32_export:
	push	{lr}
	SUB 	r12, sp, #16
	BIC 	r12, r12, #3
	STR 	sp, [r12, #12]
	MOV 	sp, r12
	STR 	r6, [sp]
	STR 	r5, [sp, #4]
	STR 	r4, [sp, #8]
	LDR 	r4, [r1]
	LDR 	r6, [r1, #4]
	bl  	L__ftrunc_32$1
L__ftrunc_32_export$1:
	STR 	r3, [r0]
	STR 	r12, [r0, #4]
	LDR 	r6, [sp]
	LDR 	r5, [sp, #4]
	LDR 	r4, [sp, #8]
	LDR 	sp, [sp, #12]
	pop 	{pc}
	.global	___fhalf_32_export
	.global	__fhalf_32_export
___fhalf_32_export:
__fhalf_32_export:
	push	{lr}
	SUB 	r12, sp, #8
	BIC 	r12, r12, #3
	STR 	sp, [r12, #4]
	MOV 	sp, r12
	STR 	r4, [sp]
	LDR 	r2, [r1]
	LDR 	r1, [r1, #4]
	bl  	L__fhalf_32$1
L__fhalf_32_export$1:
	STR 	r2, [r0]
	STR 	r1, [r0, #4]
	LDR 	r4, [sp]
	LDR 	sp, [sp, #4]
	pop 	{pc}
	.global	___fsqr_32_export
	.global	__fsqr_32_export
___fsqr_32_export:
__fsqr_32_export:
	push	{lr}
	SUB 	r12, sp, #28
	BIC 	r12, r12, #3
	STR 	sp, [r12, #24]
	MOV 	sp, r12
	STR 	r9, [sp]
	STR 	r8, [sp, #4]
	STR 	r7, [sp, #8]
	STR 	r6, [sp, #12]
	STR 	r5, [sp, #16]
	STR 	r4, [sp, #20]
	LDR 	r12, [r1]
	LDR 	r4, [r1, #4]
	SUB 	sp, sp, #4
	bl  	L__fsqr_32$1
L__fsqr_32_export$1:
	STR 	r4, [r0]
	STR 	r6, [r0, #4]
	LDR 	r9, [sp]
	LDR 	r8, [sp, #4]
	LDR 	r7, [sp, #8]
	LDR 	r6, [sp, #12]
	LDR 	r5, [sp, #16]
	LDR 	r4, [sp, #20]
	LDR 	sp, [sp, #24]
	pop 	{pc}
	.global	___fmul_32_export
	.global	__fmul_32_export
___fmul_32_export:
__fmul_32_export:
	push	{lr}
	SUB 	r12, sp, #28
	BIC 	r12, r12, #3
	STR 	sp, [r12, #24]
	MOV 	sp, r12
	STR 	r9, [sp]
	STR 	r8, [sp, #4]
	STR 	r7, [sp, #8]
	STR 	r6, [sp, #12]
	STR 	r5, [sp, #16]
	STR 	r4, [sp, #20]
	LDR 	r12, [r1]
	LDR 	r4, [r1, #4]
	LDR 	r5, [r2]
	LDR 	r2, [r2, #4]
	SUB 	sp, sp, #4
	bl  	L__fmul_32$1
L__fmul_32_export$1:
	STR 	r4, [r0]
	STR 	r6, [r0, #4]
	LDR 	r9, [sp]
	LDR 	r8, [sp, #4]
	LDR 	r7, [sp, #8]
	LDR 	r6, [sp, #12]
	LDR 	r5, [sp, #16]
	LDR 	r4, [sp, #20]
	LDR 	sp, [sp, #24]
	pop 	{pc}
	.global	___fsub_32_export
	.global	__fsub_32_export
___fsub_32_export:
__fsub_32_export:
	push	{lr}
	SUB 	r12, sp, #32
	BIC 	r12, r12, #3
	STR 	sp, [r12, #28]
	MOV 	sp, r12
	STR 	r10, [sp]
	STR 	r9, [sp, #4]
	STR 	r8, [sp, #8]
	STR 	r7, [sp, #12]
	STR 	r6, [sp, #16]
	STR 	r5, [sp, #20]
	STR 	r4, [sp, #24]
	LDR 	r3, [r1]
	LDR 	r12, [r1, #4]
	LDR 	r4, [r2]
	LDR 	r1, [r2, #4]
	SUB 	sp, sp, #4
	bl  	L__fsub_32$1
L__fsub_32_export$1:
	STR 	r4, [r0]
	STR 	r6, [r0, #4]
	LDR 	r10, [sp]
	LDR 	r9, [sp, #4]
	LDR 	r8, [sp, #8]
	LDR 	r7, [sp, #12]
	LDR 	r6, [sp, #16]
	LDR 	r5, [sp, #20]
	LDR 	r4, [sp, #24]
	LDR 	sp, [sp, #28]
	pop 	{pc}
	.global	___fadd_32_export
	.global	__fadd_32_export
___fadd_32_export:
__fadd_32_export:
	push	{lr}
	SUB 	r12, sp, #32
	BIC 	r12, r12, #3
	STR 	sp, [r12, #28]
	MOV 	sp, r12
	STR 	r10, [sp]
	STR 	r9, [sp, #4]
	STR 	r8, [sp, #8]
	STR 	r7, [sp, #12]
	STR 	r6, [sp, #16]
	STR 	r5, [sp, #20]
	STR 	r4, [sp, #24]
	LDR 	r3, [r1]
	LDR 	r12, [r1, #4]
	LDR 	r4, [r2]
	LDR 	r1, [r2, #4]
	SUB 	sp, sp, #4
	bl  	L__fadd_32$1
L__fadd_32_export$1:
	STR 	r4, [r0]
	STR 	r6, [r0, #4]
	LDR 	r10, [sp]
	LDR 	r9, [sp, #4]
	LDR 	r8, [sp, #8]
	LDR 	r7, [sp, #12]
	LDR 	r6, [sp, #16]
	LDR 	r5, [sp, #20]
	LDR 	r4, [sp, #24]
	LDR 	sp, [sp, #28]
	pop 	{pc}
L__fexpm_p63$1:
	STR 	lr, [sp]
	STR 	r12, [sp, #4]
	STR 	r2, [sp, #8]
	MOV 	r5, #0
	MOV 	r2, #0
	MOVT	r2, #17376
	MOV 	r12, r3
	MOV 	r4, r1
	SUB 	sp, sp, #4
	bl  	L__fmul_32$1
L__fexpm_p63$6:
	bl  	L__ftrunc_32$1
L__fexpm_p63$5:
	LSL 	r1, r12, #1
	ORR 	r1, r1, r3, lsr #31
	LSL 	r2, r3, #1
	bl  	L__polyeval_horn$1
L__fexpm_p63$4:
	MOV 	r5, #0
	MOV 	r2, #0
	MOVT	r2, #17376
	LDR 	r12, [sp, #4]
	LDR 	r4, [sp, #8]
	STR 	r1, [sp, #8]
	STR 	r3, [sp, #4]
	SUB 	sp, sp, #4
	bl  	L__fmul_32$1
L__fexpm_p63$3:
	bl  	L__ftrunc_32$1
L__fexpm_p63$2:
	LSL 	r1, r12, #1
	ORR 	r1, r1, r3, lsr #31
	LSL 	r2, r3, #1
	LDR 	r3, [sp, #8]
	LDR 	r12, [sp, #4]
	UMULL	r4, lr, r3, r2
	UMULL	r5, r4, r12, r1
	UMULL	r3, r1, r3, r1
	ADDs	r3, lr, r3
	ADCs	r1, r5, r1
	ADC 	lr, r4, #0
	UMULL	r12, r2, r2, r12
	ADDs	r3, r3, r12
	ADCs	r1, r1, r2
	ADC 	r2, lr, #0
	pop 	{pc}
L__polyeval_horn$1:
	LDR 	r3, glob_data+40
	LDR 	r12, glob_data+44
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+48
	LDR 	r5, glob_data+52
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+56
	LDR 	r5, glob_data+60
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+64
	LDR 	r5, glob_data+68
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+72
	LDR 	r5, glob_data+76
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+80
	LDR 	r5, glob_data+84
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+88
	LDR 	r5, glob_data+92
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+96
	LDR 	r5, glob_data+100
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+104
	LDR 	r5, glob_data+108
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+112
	LDR 	r5, glob_data+116
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+120
	LDR 	r5, glob_data+124
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r7, r12, r2, r12
	ADDs	r4, r4, r7
	ADCs	r12, r6, r12
	ADC 	r5, r5, #0
	UMULL	r6, r3, r3, r1
	ADDs	r4, r4, r6
	ADCs	r3, r12, r3
	ADC 	r12, r5, #0
	LDR 	r4, glob_data+128
	LDR 	r5, glob_data+132
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	ADDs	r3, r4, r3
	ADC 	r12, r5, r12
	UMULL	r5, r4, r2, r3
	UMULL	r6, r5, r1, r12
	UMULL	r12, r2, r2, r12
	ADDs	r12, r4, r12
	ADCs	r2, r6, r2
	ADC 	r4, r5, #0
	UMULL	r3, r1, r3, r1
	ADDs	r3, r12, r3
	ADCs	r1, r2, r1
	ADC 	r2, r4, #0
	LDR 	r3, glob_data+136
	LDR 	r12, glob_data+140
	MVN 	r1, r1
	MVN 	r2, r2
	ADDs	r1, r1, #1
	ADC 	r2, r2, #0
	ADDs	r1, r3, r1
	ADC 	r3, r12, r2
	bx  	lr
L__ffromint64_32$1:
	STR 	lr, [sp]
	UBFX	r9, r1, #31, #1
	RSB 	r3, r9, #0
	EOR 	r2, r2, r3
	EOR 	r1, r1, r3
	ADDs	r12, r2, r9
	ADC 	r4, r1, #0
	MOV 	r8, #9
	bl  	L__normalize_64_const32$1
L__ffromint64_32$3:
	UBFX	r1, r6, #0, #9
	ADDw	r1, r1, #511
	ORR 	r1, r6, r1
	LSR 	r1, r1, #9
	ORR 	r2, r1, r12, lsl #23
	LSR 	r12, r12, #9
	bl  	L__fpr_const32$1
L__ffromint64_32$2:
	pop 	{pc}
L__ffloor_32$1:
	STR 	lr, [sp]
	bl  	L__ftrunc_32$1
L__ffloor_32$2:
	ASR 	r1, r6, #31
	MOV 	r2, r1
	ADDs	r1, r3, r1
	ADC 	r2, r12, r2
	pop 	{pc}
L__ftrunc_32$1:
	UBFX	r1, r6, #31, #1
	UBFX	r2, r6, #20, #11
	UBFX	r3, r6, #0, #20
	MOV 	r12, #1
	LSL 	r12, r12, #30
	ORR 	r3, r12, r3, lsl #10
	ORR 	r12, r3, r4, lsr #22
	LSL 	r4, r4, #10
	MOVw	r3, #1085
	SUB 	r2, r3, r2
	AND 	r3, r2, #63
	CMP 	r3, #32
	bcc 	L__ftrunc_32$2
	MOV 	r4, r12
	MOV 	r12, #0
	SUB 	r3, r3, #32
L__ftrunc_32$2:
	RSB 	r5, r3, #32
	LSR 	r4, r4, r3
	LSL 	r5, r12, r5
	ORR 	r4, r4, r5
	LSR 	r3, r12, r3
	SUB 	r2, r2, #64
	LSR 	r2, r2, #31
	RSB 	r2, r2, #0
	AND 	r12, r4, r2
	AND 	r2, r3, r2
	RSB 	r3, r1, #0
	EOR 	r12, r12, r3
	EOR 	r2, r2, r3
	ADDs	r3, r12, r1
	ADC 	r12, r2, #0
	bx  	lr
L__fhalf_32$1:
	UBFX	r3, r1, #31, #1
	UBFX	r12, r1, #20, #11
	UBFX	r1, r1, #0, #20
	SUB 	r12, r12, #1
	RSB 	r4, r12, #0
	AND 	r2, r2, r4, asr #31
	AND 	r1, r1, r4, asr #31
	AND 	r12, r12, r4, asr #31
	ORR 	r1, r1, r12, lsl #20
	ORR 	r1, r1, r3, lsl #31
	bx  	lr
L__fsqr_32$1:
	STR 	lr, [sp]
	MOV 	r5, r12
	MOV 	r2, r4
	SUB 	sp, sp, #4
	bl  	L__fmul_32$1
L__fsqr_32$2:
	pop 	{pc}
L__fmul_32$1:
	STR 	lr, [sp]
	bl  	L__split25_const$1
L__fmul_32$5:
	EOR 	r9, r1, r4
	ADD 	r1, r3, r7
	SUBw	r1, r1, #2100
	bl  	L__mul25_const$1
L__fmul_32$4:
	bl  	L__normalize_53_sticky_const$1
L__fmul_32$3:
	bl  	L__fpr_const32$1
L__fmul_32$2:
	pop 	{pc}
L__fsub_32$1:
	STR 	lr, [sp]
	UBFX	r2, r1, #31, #1
	EOR 	r2, r2, #1
	LSL 	r1, r1, #1
	LSR 	r1, r1, #1
	ORR 	r1, r1, r2, lsl #31
	SUB 	sp, sp, #4
	bl  	L__fadd_32$1
L__fsub_32$2:
	pop 	{pc}
L__fadd_32$1:
	STR 	lr, [sp]
	bl  	L__cswap_const32$1
L__fadd_32$8:
	bl  	L__split_const32$1
L__fadd_32$7:
	bl  	L__cshift_const32$1
L__fadd_32$6:
	bl  	L__caddsub_const32$1
L__fadd_32$5:
	bl  	L__normalize_64_const32$1
L__fadd_32$4:
	bl  	L__scale_const32$1
L__fadd_32$3:
	bl  	L__fpr_const32$1
L__fadd_32$2:
	pop 	{pc}
L__normalize_53_sticky_const$1:
	ORR 	r2, r3, r2
	MOV 	r3, #4294967295
	ADDs	r2, r2, r3
	MOV 	r2, #0
	ADC 	r2, r2, #0
	ORR 	r2, r12, r2
	UBFX	r3, r4, #23, #1
	AND 	r12, r2, r3
	LSR 	r2, r2, r3
	ORR 	r2, r2, r12
	AND 	r12, r3, r4
	ORR 	r2, r2, r12, lsl #31
	LSR 	r12, r4, r3
	ADD 	r3, r1, r3
	bx  	lr
L__mul25_const$1:
	UMULL	r3, r2, r12, r5
	LSL 	r2, r2, #7
	ORR 	r2, r2, r3, lsr #25
	UBFX	r3, r3, #0, #25
	UMULL	r4, r12, r12, r8
	LSL 	r12, r12, #7
	ORR 	r12, r12, r4, lsr #25
	UBFX	r4, r4, #0, #25
	ADD 	r2, r2, r4
	UMULL	r5, r4, r6, r5
	LSL 	r4, r4, #7
	ORR 	r4, r4, r5, lsr #25
	UBFX	r5, r5, #0, #25
	ADD 	r2, r2, r5
	ADD 	r12, r4, r12
	ADD 	r12, r12, r2, lsr #25
	UBFX	r2, r2, #0, #25
	MOV 	r4, #0
	UMLAL	r12, r4, r6, r8
	bx  	lr
L__split25_const$1:
	LSR 	r1, r4, #31
	UBFX	r3, r4, #20, #11
	LSL 	r4, r4, #7
	ORR 	r4, r4, r12, lsr #25
	UBFX	r12, r12, #0, #25
	UBFX	r4, r4, #0, #27
	RSB 	r6, r3, #0
	LSR 	r6, r6, #31
	ORR 	r6, r4, r6, lsl #27
	LSR 	r4, r2, #31
	UBFX	r7, r2, #20, #11
	LSL 	r2, r2, #7
	ORR 	r2, r2, r5, lsr #25
	UBFX	r5, r5, #0, #25
	UBFX	r2, r2, #0, #27
	RSB 	r8, r7, #0
	LSR 	r8, r8, #31
	ORR 	r8, r2, r8, lsl #27
	bx  	lr
L__fpr_const32$1:
	RSB 	r1, r2, #0
	ORR 	r1, r1, r2
	MVN 	r1, r1
	RSB 	r4, r12, #0
	ORR 	r4, r4, r12
	MVN 	r4, r4
	AND 	r1, r4, r1
	LSR 	r1, r1, #31
	RSB 	r1, r1, #0
	ADDw	r3, r3, #1076
	AND 	r1, r3, r1
	EOR 	r1, r3, r1
	ORR 	r3, r2, r2, lsr #2
	AND 	r3, r3, r2, lsr #1
	AND 	r3, r3, #1
	LSR 	r2, r2, #2
	ORR 	r2, r2, r12, lsl #30
	LSR 	r12, r12, #2
	ADDs	r2, r2, r3
	ADC 	r3, r12, #0
	ADD 	r1, r1, r3, lsr #20
	RSB 	r12, r1, #0
	ASR 	r12, r12, #31
	MVN 	r12, r12
	AND 	r4, r2, r12
	EOR 	r2, r2, r4
	AND 	r4, r3, r12
	EOR 	r3, r3, r4
	AND 	r12, r1, r12
	EOR 	r1, r1, r12
	RSB 	r12, r1, #2048
	SUB 	r12, r12, #2
	ORR 	r4, r2, r12, asr #31
	ORR 	r2, r3, r12, asr #31
	ORR 	r1, r1, r12, asr #31
	SUB 	r1, r1, r12, lsr #31
	UBFX	r2, r2, #0, #20
	ORR 	r1, r2, r1, lsl #20
	LSL 	r1, r1, #1
	LSR 	r1, r1, #1
	ORR 	r6, r1, r9, lsl #31
	bx  	lr
L__scale_const32$1:
	MOVw	r1, #511
	AND 	r2, r6, r1
	ADD 	r1, r2, r1
	ORR 	r1, r6, r1
	LSR 	r1, r1, #9
	ORR 	r2, r1, r12, lsl #23
	LSR 	r12, r12, #9
	ADD 	r3, r3, #9
	bx  	lr
L__normalize_64_const32$1:
	SUB 	r1, r8, #63
	MOV 	r2, r4
	RSB 	r3, r4, #0
	ORR 	r2, r2, r3
	LSR 	r2, r2, #31
	MOV 	r3, #32
	MUL 	r3, r3, r2
	ADD 	r1, r1, r3
	SUB 	r2, r2, #1
	EOR 	r3, r12, r4
	AND 	r3, r3, r2
	EOR 	r3, r4, r3
	AND 	r2, r12, r2
	EOR 	r2, r12, r2
	LSR 	r12, r3, #16
	RSB 	r4, r12, #0
	ORR 	r12, r12, r4
	LSR 	r12, r12, #31
	MOV 	r4, #16
	MUL 	r4, r4, r12
	ADD 	r1, r1, r4
	MOV 	r4, r2
	MOV 	r5, r3
	LSL 	r5, r5, #16
	ORR 	r5, r5, r4, lsr #16
	LSL 	r4, r4, #16
	SUB 	r12, r12, #1
	EOR 	r4, r4, r2
	AND 	r4, r4, r12
	EOR 	r2, r2, r4
	EOR 	r4, r5, r3
	AND 	r12, r4, r12
	EOR 	r3, r3, r12
	LSR 	r12, r3, #24
	RSB 	r4, r12, #0
	ORR 	r12, r12, r4
	LSR 	r12, r12, #31
	MOV 	r4, #8
	MUL 	r4, r4, r12
	ADD 	r1, r1, r4
	MOV 	r4, r2
	MOV 	r5, r3
	LSL 	r5, r5, #8
	ORR 	r5, r5, r4, lsr #24
	LSL 	r4, r4, #8
	SUB 	r12, r12, #1
	EOR 	r4, r4, r2
	AND 	r4, r4, r12
	EOR 	r2, r2, r4
	EOR 	r4, r5, r3
	AND 	r12, r4, r12
	EOR 	r3, r3, r12
	LSR 	r12, r3, #28
	RSB 	r4, r12, #0
	ORR 	r12, r12, r4
	LSR 	r12, r12, #31
	MOV 	r4, #4
	MUL 	r4, r4, r12
	ADD 	r1, r1, r4
	MOV 	r4, r2
	MOV 	r5, r3
	LSL 	r5, r5, #4
	ORR 	r5, r5, r4, lsr #28
	LSL 	r4, r4, #4
	SUB 	r12, r12, #1
	EOR 	r4, r4, r2
	AND 	r4, r4, r12
	EOR 	r2, r2, r4
	EOR 	r4, r5, r3
	AND 	r12, r4, r12
	EOR 	r3, r3, r12
	LSR 	r12, r3, #30
	RSB 	r4, r12, #0
	ORR 	r12, r12, r4
	LSR 	r12, r12, #31
	MOV 	r4, #2
	MUL 	r4, r4, r12
	ADD 	r1, r1, r4
	MOV 	r4, r2
	MOV 	r5, r3
	LSL 	r5, r5, #2
	ORR 	r5, r5, r4, lsr #30
	LSL 	r4, r4, #2
	SUB 	r12, r12, #1
	EOR 	r4, r4, r2
	AND 	r4, r4, r12
	EOR 	r2, r2, r4
	EOR 	r4, r5, r3
	AND 	r12, r4, r12
	EOR 	r12, r3, r12
	LSR 	r3, r12, #31
	RSB 	r4, r3, #0
	ORR 	r3, r3, r4
	LSR 	r4, r3, #31
	MOV 	r3, #1
	MUL 	r3, r3, r4
	ADD 	r3, r1, r3
	MOV 	r1, r2
	MOV 	r5, r12
	LSL 	r5, r5, #1
	ORR 	r5, r5, r1, lsr #31
	LSL 	r1, r1, #1
	SUB 	r4, r4, #1
	EOR 	r1, r1, r2
	AND 	r1, r1, r4
	EOR 	r6, r2, r1
	EOR 	r1, r5, r12
	AND 	r1, r1, r4
	EOR 	r12, r12, r1
	bx  	lr
L__caddsub_const32$1:
	MOV 	r3, r1
	MOV 	r12, r2
	MVN 	r3, r3
	MVN 	r12, r12
	ADDs	r3, r3, #1
	ADC 	r12, r12, #0
	EOR 	r4, r9, r10
	RSB 	r4, r4, #0
	EOR 	r3, r3, r1
	AND 	r3, r3, r4
	EOR 	r1, r1, r3
	EOR 	r3, r12, r2
	AND 	r3, r3, r4
	EOR 	r2, r2, r3
	ADDs	r12, r7, r1
	ADC 	r1, r6, #0
	ADD 	r4, r1, r2
	bx  	lr
L__cshift_const32$1:
	MOV 	r1, #0
	SUB 	r2, r8, r2
	RSB 	r3, r2, #59
	LSR 	r3, r3, #31
	SUB 	r3, r3, #1
	AND 	r12, r12, r3
	AND 	r3, r4, r3
	AND 	r2, r2, #63
	SBFX	r4, r2, #5, #1
	EOR 	r5, r12, r1
	AND 	r5, r5, r4
	EOR 	r1, r1, r5
	EOR 	r5, r3, r12
	AND 	r5, r5, r4
	EOR 	r12, r12, r5
	AND 	r4, r3, r4
	EOR 	r3, r3, r4
	AND 	r2, r2, #31
	RSB 	r4, r2, #32
	LSL 	r5, r12, r4
	ORR 	r1, r1, r5
	LSR 	r12, r12, r2
	LSL 	r4, r3, r4
	ORR 	r12, r12, r4
	LSR 	r2, r3, r2
	RSB 	r3, r1, #0
	ORR 	r1, r3, r1
	ORR 	r1, r12, r1, lsr #31
	bx  	lr
L__split_const32$1:
	LSR 	r9, r3, #31
	UBFX	r1, r3, #20, #11
	UBFX	r2, r3, #0, #20
	RSB 	r3, r1, #0
	ORR 	r3, r3, r1
	LSR 	r3, r3, #31
	RSB 	r3, r3, #0
	AND 	r12, r6, r3
	AND 	r2, r2, r3
	RSB 	r3, r3, #0
	ORR 	r2, r2, r3, lsl #20
	LSL 	r2, r2, #3
	ORR 	r6, r2, r12, lsr #29
	LSL 	r7, r12, #3
	SUBw	r8, r1, #1078
	LSR 	r10, r5, #31
	UBFX	r1, r5, #20, #11
	UBFX	r2, r5, #0, #20
	RSB 	r3, r1, #0
	ORR 	r3, r3, r1
	LSR 	r3, r3, #31
	RSB 	r3, r3, #0
	AND 	r12, r4, r3
	AND 	r2, r2, r3
	RSB 	r3, r3, #0
	ORR 	r2, r2, r3, lsl #20
	LSL 	r2, r2, #3
	ORR 	r4, r2, r12, lsr #29
	LSL 	r12, r12, #3
	SUBw	r2, r1, #1078
	bx  	lr
L__cswap_const32$1:
	UBFX	r2, r12, #0, #31
	UBFX	r5, r1, #0, #31
	MVN 	r6, r4
	MVN 	r5, r5
	ADDs	r6, r6, #1
	ADC 	r5, r5, #0
	ADDs	r6, r3, r6
	ADC 	r2, r2, r5
	LSR 	r5, r2, #31
	RSB 	r7, r6, #0
	ORR 	r6, r7, r6
	LSR 	r6, r6, #31
	MVN 	r6, r6
	RSB 	r7, r2, #0
	ORR 	r2, r7, r2
	LSR 	r2, r2, #31
	MVN 	r2, r2
	AND 	r2, r6, r2
	AND 	r2, r2, r12, lsr #31
	ORR 	r2, r5, r2
	RSB 	r2, r2, #0
	EOR 	r5, r3, r4
	AND 	r5, r5, r2
	EOR 	r6, r3, r5
	EOR 	r4, r4, r5
	EOR 	r3, r12, r1
	AND 	r2, r3, r2
	EOR 	r3, r12, r2
	EOR 	r5, r1, r2
	bx  	lr
	.p2align	5
glob_data:
	.byte	-62
	.byte	-69
	.byte	-125
	.byte	-63
	.byte	-117
	.byte	79
	.byte	-61
	.byte	63
	.byte	117
	.byte	122
	.byte	31
	.byte	-65
	.byte	1
	.byte	114
	.byte	-12
	.byte	63
	.byte	-2
	.byte	-126
	.byte	43
	.byte	101
	.byte	71
	.byte	21
	.byte	-9
	.byte	63
	.byte	-17
	.byte	57
	.byte	-6
	.byte	-2
	.byte	66
	.byte	46
	.byte	-26
	.byte	63
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	-32
	.byte	67
	.byte	-93
	.byte	-125
	.byte	17
	.byte	116
	.byte	4
	.byte	0
	.byte	0
	.byte	0
	.byte	6
	.byte	-4
	.byte	-116
	.byte	84
	.byte	54
	.byte	0
	.byte	0
	.byte	0
	.byte	10
	.byte	20
	.byte	-65
	.byte	-36
	.byte	79
	.byte	2
	.byte	0
	.byte	0
	.byte	69
	.byte	-32
	.byte	-99
	.byte	-109
	.byte	29
	.byte	23
	.byte	0
	.byte	0
	.byte	-124
	.byte	111
	.byte	-113
	.byte	-11
	.byte	12
	.byte	-48
	.byte	0
	.byte	0
	.byte	-29
	.byte	-106
	.byte	-9
	.byte	28
	.byte	104
	.byte	-128
	.byte	6
	.byte	0
	.byte	-22
	.byte	15
	.byte	91
	.byte	48
	.byte	-40
	.byte	-126
	.byte	45
	.byte	0
	.byte	-48
	.byte	111
	.byte	6
	.byte	14
	.byte	17
	.byte	17
	.byte	17
	.byte	1
	.byte	0
	.byte	15
	.byte	7
	.byte	85
	.byte	85
	.byte	85
	.byte	85
	.byte	5
	.byte	0
	.byte	-1
	.byte	-127
	.byte	85
	.byte	85
	.byte	85
	.byte	85
	.byte	21
	.byte	0
	.byte	-76
	.byte	2
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	64
	.byte	0
	.byte	72
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	127
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	-128
	.byte	-117
	.byte	79
	.byte	-61
	.byte	63
	.byte	-62
	.byte	-69
	.byte	-125
	.byte	-63
	.byte	1
	.byte	114
	.byte	-12
	.byte	63
	.byte	117
	.byte	122
	.byte	31
	.byte	-65
	.byte	71
	.byte	21
	.byte	-9
	.byte	63
	.byte	-2
	.byte	-126
	.byte	43
	.byte	101
	.byte	66
	.byte	46
	.byte	-26
	.byte	63
	.byte	-17
	.byte	57
	.byte	-6
	.byte	-2
	.byte	0
	.byte	0
	.byte	-32
	.byte	67
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	-61
	.byte	63
	.byte	-117
	.byte	79
	.byte	-125
	.byte	-63
	.byte	-62
	.byte	-69
	.byte	-12
	.byte	63
	.byte	1
	.byte	114
	.byte	31
	.byte	-65
	.byte	117
	.byte	122
	.byte	-9
	.byte	63
	.byte	71
	.byte	21
	.byte	43
	.byte	101
	.byte	-2
	.byte	-126
	.byte	-26
	.byte	63
	.byte	66
	.byte	46
	.byte	-6
	.byte	-2
	.byte	-17
	.byte	57
	.byte	-32
	.byte	67
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
