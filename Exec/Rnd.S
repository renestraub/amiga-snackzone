
		SECTION	text,CODE

		INCLUDE	"MyExec.i"

		XDEF	RandomizeFunc,RandomFunc


	*** Random initialisieren, D0/D1 :  Zufallswerte

RandomizeFunc:	movem.l	d0-d3,-(SP)
		add.l	d0,d1			; user seed in d0 (d1 too)
		move.l	d0,meb_LastRnd1(a6)	; save for next time through
		move.l	d1,meb_LastRnd2(a6)
		bsr.s	LongRnd
		movem.l	(SP)+,d0-d3
		rts


	*** Zufallszahl [0..D0.W] berechnen

RandomFunc:	movem.l	d1-d4,-(SP)
		move.w	d0,d4		; save upper limit
		beq.s	1$		; range of 0 returns 0 always
		bsr.s	LongRnd		; get a longword random number
		clr.w	d0		; use upper word (it's most random)
		swap	d0
		divu.w	d4,d0		; divide by range...
		clr.w	d0		; ...and use remainder for the value
		swap	d0		; result in D0.W
1$:		movem.l	(SP)+,d1-d4
		rts


LongRnd:	movem.l	meb_LastRnd1(a6),d0/d1 ; D0=LSB's, D1=MSB's of random number
		andi.b	#$0e,d0		; ensure upper 59 bits are an...
		ori.b	#$20,d0		; ...odd binary number
		move.l	d0,d2
		move.l	d1,d3
		add.l	d2,d2		; accounts for 1 of 17 left shifts
		addx.l	d3,d3		; [D2/D3] = RND*2
		add.l	d2,d0
		addx.l	d3,d1		; [D0/D1] = RND*3
		swap	d3		; shift [D2/D3] additional 16 times
		swap	d2
		move.w	d2,d3
		clr.w	d2
		add.l	d2,d0		; add to [D0/D1]
		addx.l	d3,d1
		movem.l	d0/d1,meb_LastRnd1(a6)	; save for next time through
		move.l	d1,d0		; most random part to D0
		rts


		END
