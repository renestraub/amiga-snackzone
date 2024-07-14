*****************************************************************************
**                                                                         **
**   PPDecrunch  -  Eine Datei PowerPacker-decrunchen auf sich selber      **
**                                                                         **
**   Parameter :  A0.L :  Adresse                                          **
**                D0.L :  Länge der gecrunchten Daten                      **
**                                                                         **
**   Resultat  :  nix                                                      **
**                                                                         **
*****************************************************************************

		IDNT	PPDecrunch
		SECTION	text,CODE

		INCLUDE	"MyExec.i"

		XDEF	PPDecrunch
		XDEF	PPDecrunch2
		XREF	CopyMemFunc
		XREF	RawPrintfFunc

PPDecrunch:	movem.l	d0-d7/a0-a5,-(SP)
		lea	Efficiency(PC),a5	; A5: Pointer to efficiency
		move.l	a0,-(SP)		; Buffer für später
		lea	PP_SAVEMARGIN(a0),a3	; A3: Destination
		move.l	a3,-(SP)		; Quelle für später

		move.l	(a0)+,-(SP)		; Decrunchte Grösse für später

		move.l	(a0)+,(a5) 		; Efficiency eintragen
		lea	-8(a0,d0.l),a0		; A0: Source-Ende

		move.l	a6,-(SP)
		bsr	Decrunch
		movea.l	(SP)+,a6

		move.l	(SP)+,d0		; Decrunchte Grösse
		movea.l	(SP)+,a0		; Quelle
		movea.l	(SP)+,a1		; Ziel

		jsr	meb_CopyMem(a6)		; runterschieben

		bsr	CopyMemFunc

		move.l	a6,-(sp)
		movem.l	(SP)+,d0-d7/a0-a5
		rts

; A0 -> Buffer, D0 -> Length


PPDecrunch2:	movem.l	d0-d7/a0-a6,-(SP)

		move.l	-4(a0,d0.l),d1
		lsr.l	#8,d1			: D1 = FileLänge

		lea	Efficiency(PC),a5	; A5: Pointer to efficiency
		move.l	4(a0),(a5)		; 0(a0)=PP20, 4(a0)=Eff

		move.l	a0,a3
		add.l	#PP_SAVEMARGIN,a3	; A3:DecrunchBuffer
		add.l	d0,a0			; A0:End

		movem.l	d0-d7/a0-a6,-(sp)
		bsr	Decrunch
		movem.l	(sp)+,d0-d7/a0-a6

		move.l	a3,a0			; Source
		move.l	a0,a1
		sub.l	#PP_SAVEMARGIN,a1	; Destination
		move.l	d1,d0			; Length
		bsr	CopyMemFunc

		movem.l	(SP)+,d0-d7/a0-a6
		rts


****************************************************************************
*                                                                          *
*  PowerPacker Decrunch assembler subroutine V2.0 (reentrant !)            *
*  DESTROYS ALL REGISTERS!                                                 *
*                                                                          *
*  call as:                                                                *
*     pp_DecrunchBuffer (endcrun, buffer, &efficiency, coloraddr);         *
*  with:                                                                   *
*  A0 endcrun    : UBYTE * just after last byte of crunched file           *
*  A3 buffer     : UBYTE * to memory block to decrunch in                  *
*  A5 &efficiency: ptr to Longword defining efficiency of crunched file    *
*                                                                          *
*  NOTE:                                                                   *
*     Decrunch a few bytes higher (safety margin) than the crunched file   *
*     to decrunch in the same memory space. (8 bytes suffice)              *
*                                                                          *
****************************************************************************

Decrunch:	moveq	#3,d6
		moveq	#7,d7
		moveq	#1,d5
		move.l	a3,a2			; remember start of file
		move.l	-(a0),d1		; get file length and empty bits
		tst.b	d1
		beq.b	NoEmptyBits

		bsr.b	ReadBit			; this will always get the next long (D5 = 1)
		subq.b	#1,d1
		lsr.l	d1,d5			; get rid of empty bits
NoEmptyBits:
		lsr.l	#8,d1
		add.l	d1,a3			; a3 = endfile
LoopCheckCrunch:
		bsr.b	ReadBit			; check if crunch or normal
		bcs.b	CrunchedBytes
NormalBytes:
		moveq	#0,d2
Read2BitsRow:
		moveq	#1,d0
		bsr.b	ReadD1
		add.w	d1,d2
		cmp.w	d6,d1
		beq.b	Read2BitsRow
ReadNormalByte:
		moveq	#7,d0
		bsr.b	ReadD1
		move.b	d1,-(a3)
		dbf	d2,ReadNormalByte
		cmp.l	a3,a2
		bcs.b	CrunchedBytes
		rts
ReadBit:
		lsr.l	#1,d5			; this will set X if d5 becomes zero
		beq.b	GetNextLong
		rts
GetNextLong:
		move.l	-(a0),d5
		roxr.l	#1,d5			; X-bit set by lsr above
		rts
ReadD1sub:
		subq.w	#1,d0
ReadD1:
		moveq	#0,d1
ReadBits:
		lsr.l	#1,d5			; this will set X if d5 becomes zero
		beq.b	GetNext
RotX:
		roxl.l	#1,d1
		dbf	d0,ReadBits
		rts
GetNext:
		move.l	-(a0),d5
		roxr.l	#1,d5			; X-bit set by lsr above
		bra.b	RotX
CrunchedBytes:
		moveq	#1,d0
		bsr.b	ReadD1			; read code
		moveq	#0,d0
		move.b	0(a5,d1.w),d0		; get number of bits of offset
		move.w	d1,d2			; d2 = code = length-2
		cmp.w	d6,d2			; if d2 = 3 check offset bit and read length
		bne.b	ReadOffset
		bsr.b	ReadBit			; read offset bit (long/short)
		bcs.b	LongBlockOffset
		moveq	#7,d0
LongBlockOffset:
		bsr.b	ReadD1sub
		move.w	d1,d3			; d3 = offset
Read3BitsRow:
		moveq	#2,d0
		bsr.b	ReadD1
		add.w	d1,d2			; d2 = length-1
		cmp.w	d7,d1			; cmp with #7
		beq.b	Read3BitsRow
		bra.b	DecrunchBlock
ReadOffset:
		bsr.b	ReadD1sub		; read offset
		move.w	d1,d3			; d3 = offset
DecrunchBlock:
		addq.w	#1,d2
DecrunchBlockLoop:
		move.b	0(a3,d3.w),-(a3)
		dbf	d2,DecrunchBlockLoop
EndOfLoop:
		cmp.l	a3,a2
		bcs	LoopCheckCrunch
		rts


;;Fmt:		dc.b	"Decrunching to 0x%08lx len %ld (%lx)",13,10
;;Fmt2:		dc.b	"Crunching : A0 %08lx A3 %08lx A5 %08lx",13,10

Efficiency:	dc.l	0

		END

