COPPER_S:
		INCLUDE	"MyExec.i"
		INCLUDE "Gfx.i"
		INCLUDE	"Copper.i"
		INCLUDE	"RelCustom.i"
		INCLUDE	"Definitions.i"

Modulo:		EQU	ScrWidth-42

		SECTION	Program,CODE

*****************************************************************************
@CopyColorMap:	; a0 = colormap
		lea	ColorTab,a1		* ColorMap
1$:		move.w	(A0)+,d0		* Color
		cmp.w	#-1,d0			* End
		beq.s	2$			* yes -->
		move.w	d0,(A1)+		* set color
		bra.s	1$			* loop -->
2$:		rts

*****************************************************************************
@SetColors:	; A0=Colors  A1=Copper  D0=NumColors
		movem.l	d0/a0/a1,-(sp)
		bra.s	2$
1$:		move.w	(A0)+,(A1)+
2$:		dbf	d0,1$
		movem.l	(sp)+,d0/a0/a1
		rts

*****************************************************************************
@SetPointers:	; A0=Picture  A1=Copper  D0=PlaneSize D1=NumPlanes
		movem.l	d1/d2/a0/a1,-(sp)
		bra.s	2$
1$:		move.l	a0,d2
		move.w	d2,6(A1)
		swap	d2
		move.w	d2,2(A1)
		add.l	d0,a0
		addq	#8,a1
2$:		dbf	d1,1$
		movem.l	(sp)+,d1/d2/a0/a1
		rts

*****************************************************************************

@SetCopperList:	movem.l	d0-d7/a0-a6,-(sp)
		lea	custom,a5
		move.l	a0,cop1lc(a5)
		movem.l	(sp)+,d0-d7/a0-a6
		rts


*****************************************************************************

@FadeOutCopper:	movem.l	d0-d7/a0-a6,-(sp)
		lea	FadeOutCopp(pc),a1
		bra.s	FadeIt

*****************************************************************************

@FadeInCopper:	movem.l	d0-d7/a0-a6,-(sp)
		lea	FadeInCopp(pc),a1

FadeIt:		moveq	#16,d1
.FadeOut:	moveq	#120,d0				* Speed

		jsr	RasterDelay			* Delay()
		jsr	(A1)

		dbf	d1,.FadeOut
		movem.l	(sp)+,d0-d7/a0-a6
		rts

*****************************************************************************

FadeOutCopp:	movem.l	d0-d7/a0-a6,-(SP)
		lea	CopperList,a2

.Loop:		move.w	(A2)+,d0
		cmp.w	#$FFFF,d0
		beq.s	.Ende

		btst	#0,d0
		bne.s	.NoCMove

		cmp.w	#$180,d0
		blt.s	.NoColor
		cmp.w	#$180+64,d0
		bgt.s	.NoColor

		moveq.l	#0,d1			; ZielRegister
		move.w	(a2),d2			; SourceFarbe
		moveq.l	#0,d3			; ZielFarbe

		bsr	FadeSub

		move.w	d1,(A2)+
		bra.s	.Loop

.NoColor:
.NoCMove:	addq.l	#2,a2
		bra.s	.Loop

.Ende:		movem.l	(sp)+,d0-d7/a0-a6
		rts


*****************************************************************************

FadeInCopp:	movem.l	d0-d7/a0-a6,-(SP)
		lea	CopperList,a2
		lea	ColorTab,a3

.Loop:		move.w	(A2)+,d0
		cmp.w	#$FFFF,d0
		beq.s	.Ende

		btst	#0,d0
		bne.s	.NoCMove

		cmp.w	#$180,d0
		blt.s	.NoColor
		cmp.w	#$180+64,d0
		bgt.s	.NoColor

		moveq.l	#0,d1			; ZielRegister
		move.w	(a2),d2			; SourceFarbe
		move.w	(a3)+,d3		; ZielFarbe

		bsr	FadeSub

		move.w	d1,(A2)+
		bra.s	.Loop

.NoColor:
.NoCMove:	addq.l	#2,a2
		bra.s	.Loop

.Ende:		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************

FadeSub:	moveq.l	#3-1,d4			; je 3 Nibbles

.FadeLoop:	move.w	d2,d5
		move.w	d3,d6
		and.w	#$F,d5			; SourceNibble
		and.w	#$F,d6			; DestNibble
		bsr.s	NibbleFade
		ror.w	#4,d5
		or.w	d5,d1
		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d3
		dbf	d4,.FadeLoop
		rts

NibbleFade:	cmp.b	d5,d6
		beq.s	2$
		bhi.s	1$
		subq.b	#1,d5
		bra.s	2$
1$:		addq.b	#1,d5
2$:		rts

****************************************************************************

		SECTION	__MERGED,DATA

_CopperList:
CopperList:	ccwait	$0221,$fffe

		cmove	$0200,bplcon0
		cmove	$0581,diwstrt
		cmove	$2CC1,diwstop
		cmove	$0038-8,ddfstrt
		cmove	$00D0,ddfstop

CopperSprites:	cmovel	$0000,sprpt+00
		cmovel	$0000,sprpt+04
		cmovel	$0000,sprpt+08
		cmovel	$0000,sprpt+12
		cmovel	$0000,sprpt+16
		cmovel	$0000,sprpt+20
		cmovel	$0000,sprpt+24
		cmovel	$0000,sprpt+28

		cmove	$0000,color+00				* ColorMap
		cmove	$0000,color+02
		cmove	$0000,color+04
		cmove	$0000,color+06
		cmove	$0000,color+08
		cmove	$0000,color+10
		cmove	$0000,color+12
		cmove	$0000,color+14
		cmove	$0000,color+16
		cmove	$0000,color+18
		cmove	$0000,color+20
		cmove	$0000,color+22
		cmove	$0000,color+24
		cmove	$0000,color+26
		cmove	$0000,color+28
		cmove	$0000,color+30
		cmove	$0000,color+32
		cmove	$0000,color+34
		cmove	$0000,color+36
		cmove	$0000,color+38
		cmove	$0000,color+40
		cmove	$0000,color+42
		cmove	$0000,color+44
		cmove	$0000,color+46
		cmove	$0000,color+48
		cmove	$0000,color+50
		cmove	$0000,color+52
		cmove	$0000,color+54
		cmove	$0000,color+56
		cmove	$0000,color+58
		cmove	$0000,color+60
		cmove	$0000,color+62

BitMapPtrs:	cmovel	$0000,bpl1pt				* Pointers to BitMap
		cmovel	$0000,bpl2pt
		cmovel	$0000,bpl3pt
		cmovel	$0000,bpl4pt
		cmovel	$0000,bpl5pt

		ccwait	$2921,$FFFE
		cmove	$5200,bplcon0

c_bplcon1:	cmove	$0000,bplcon1
		cmove	Modulo,bpl1mod
		cmove	Modulo,bpl2mod

		ccwait	$2C21,$FFFE
		cmove	$0000,color+18
		ccwait	$2D21,$FFFE
		cmove	$0000,color+18
		ccwait	$2E21,$FFFE
		cmove	$0000,color+18

		ccwait	$3421,$FFFE
		cmove	$0000,color+18
		ccwait	$3521,$FFFE
		cmove	$0000,color+18
		ccwait	$3621,$FFFE
		cmove	$0000,color+18

		ccwait	$3C21,$FFFE
		cmove	$0000,color+18
		ccwait	$3D21,$FFFE
		cmove	$0000,color+18
		ccwait	$3E21,$FFFE
		cmove	$0000,color+18

		ccwait	$4421,$FFFE
		cmove	$0000,color+18
		ccwait	$4521,$FFFE
		cmove	$0000,color+18
		ccwait	$4621,$FFFE
		cmove	$0000,color+18

		ccwait	$4C21,$FFFE
		cmove	$0000,color+18
		ccwait	$4D21,$FFFE
		cmove	$0000,color+18
		ccwait	$4E21,$FFFE
		cmove	$0000,color+18

		ccwait	$5421,$FFFE
		cmove	$0000,color+18
		ccwait	$5521,$FFFE
		cmove	$0000,color+18
		ccwait	$5621,$FFFE
		cmove	$0000,color+18

		ccwait	$5C21,$FFFE
		cmove	$0000,color+18
		ccwait	$5D21,$FFFE
		cmove	$0000,color+18
		ccwait	$5E21,$FFFE
		cmove	$0000,color+18

		ccwait	$6421,$FFFE
		cmove	$0000,color+18
		ccwait	$6521,$FFFE
		cmove	$0000,color+18
		ccwait	$6621,$FFFE
		cmove	$0000,color+18

		ccwait	$6C21,$FFFE
		cmove	$0000,color+18
		ccwait	$6D21,$FFFE
		cmove	$0000,color+18
		ccwait	$6E21,$FFFE
		cmove	$0000,color+18

		ccwait	$7421,$FFFE
		cmove	$0000,color+18
		ccwait	$7521,$FFFE
		cmove	$0000,color+18
		ccwait	$7621,$FFFE
		cmove	$0000,color+18

		ccwait	$7C21,$FFFE
		cmove	$0000,color+18
		ccwait	$7D21,$FFFE
		cmove	$0000,color+18
		ccwait	$7E21,$FFFE
		cmove	$0000,color+18

		ccwait	$8421,$FFFE
		cmove	$0000,color+18
		ccwait	$8521,$FFFE
		cmove	$0000,color+18
		ccwait	$8621,$FFFE
		cmove	$0000,color+18

		ccwait	$8C21,$FFFE
		cmove	$0000,color+18
		ccwait	$8D21,$FFFE
		cmove	$0000,color+18
		ccwait	$8E21,$FFFE
		cmove	$0000,color+18

		ccwait	$9421,$FFFE
		cmove	$0000,color+18
		ccwait	$9521,$FFFE
		cmove	$0000,color+18
		ccwait	$9621,$FFFE
		cmove	$0000,color+18

		ccwait	$9C21,$FFFE
		cmove	$0000,color+18
		ccwait	$9D21,$FFFE
		cmove	$0000,color+18
		ccwait	$9E21,$FFFE
		cmove	$0000,color+18

		ccwait	$a421,$FFFE
		cmove	$0000,color+18
		ccwait	$a521,$FFFE
		cmove	$0000,color+18
		ccwait	$a621,$FFFE
		cmove	$0000,color+18

		ccwait	$aC21,$FFFE
		cmove	$0000,color+18
		ccwait	$aD21,$FFFE
		cmove	$0000,color+18
		ccwait	$aE21,$FFFE
		cmove	$0000,color+18

		ccwait	$b421,$FFFE
		cmove	$0000,color+18
		ccwait	$b521,$FFFE
		cmove	$0000,color+18
		ccwait	$b621,$FFFE
		cmove	$0000,color+18

		ccwait	$bC21,$FFFE
		cmove	$0000,color+18
		ccwait	$bD21,$FFFE
		cmove	$0000,color+18
		ccwait	$bE21,$FFFE
		cmove	$0000,color+18

		ccwait	$c421,$FFFE
		cmove	$0000,color+18
		ccwait	$c521,$FFFE
		cmove	$0000,color+18
		ccwait	$c621,$FFFE
		cmove	$0000,color+18

		ccwait	$cC21,$FFFE
		cmove	$0000,color+18
		ccwait	$cD21,$FFFE
		cmove	$0000,color+18
		ccwait	$cE21,$FFFE
		cmove	$0000,color+18

		ccwait	$d421,$FFFE
		cmove	$0000,color+18
		ccwait	$d521,$FFFE
		cmove	$0000,color+18
		ccwait	$d621,$FFFE
		cmove	$0000,color+18

		ccwait	$dC21,$FFFE
		cmove	$0000,color+18
		ccwait	$dD21,$FFFE
		cmove	$0000,color+18
		ccwait	$dE21,$FFFE
		cmove	$0000,color+18

	**** Ende des SpielPlayfields ****

		ccwait	$e321,$FFFE
		cmove	$0200,bplcon0			* Bitplanes OFF
		cmove	$0020,dmacon			* Sprite DMA-Aus

		cmove	$0000,color			* Schwarze Zwischenzeile

	*** Das Panel ***

_PanelPtrs:	cmovel	$0000,bpl1pt			* Pointers to BitMap
		cmovel	$0000,bpl2pt
		cmovel	$0000,bpl3pt
		cmovel	$0000,bpl4pt
		cmovel	$0000,bpl5pt
		cmovel	$0000,bpl6pt

		cmove	$0000,bplcon1
		cmove	$0024,bplcon2
		cmove	$0000,bpl1mod
		cmove	$0000,bpl2mod
		cmove	$0038,ddfstrt
		cmove	$00D0,ddfstop

		cmove	$0000,color+00			* PanelColorMap
		cmove	$0000,color+02
		cmove	$0000,color+04
		cmove	$0000,color+06
		cmove	$0000,color+08
		cmove	$0000,color+10
		cmove	$0000,color+12
		cmove	$0000,color+14
		cmove	$0000,color+16
		cmove	$0000,color+18
		cmove	$0000,color+20
		cmove	$0000,color+22
		cmove	$0000,color+24
		cmove	$0000,color+26
		cmove	$0000,color+28
		cmove	$0000,color+30

		cmove	$0000,color+32
		cmove	$0000,color+34
		cmove	$0000,color+36
		cmove	$0000,color+38
		cmove	$0000,color+40
		cmove	$0000,color+42
		cmove	$0000,color+44
		cmove	$0000,color+46
		cmove	$0000,color+48
		cmove	$0000,color+50
		cmove	$0000,color+52
		cmove	$0000,color+54
		cmove	$0000,color+56
		cmove	$0000,color+58
		cmove	$0000,color+60
		cmove	$0000,color+62

		ccwait	$e401,$FFFE
		cmove	$6200,bplcon0

		cmove	$0000,$0144
		cmove	$0000,$0146
		cmove	$0000,$014c
		cmove	$0000,$014e
		cmove	$0000,$0154
		cmove	$0000,$0156
		cmove	$0000,$015c
		cmove	$0000,$015e
		cmove	$0000,$0164
		cmove	$0000,$0166
		cmove	$0000,$016c
		cmove	$0000,$016e
		cmove	$0000,$0174
		cmove	$0000,$0176
		cmove	$0000,$017c
		cmove	$0000,$017e			* Clear ALL SpriteDATA

		ccwait	$C021,$FFFE
		cmove	$8010,intreq			* Copper INT

		ccwait	$FC21,$FFFE

;;		ccwait	$FFDF,$FFFE			* PAL Wait
;;		ccwait	$0421,$FFFE

		cmove	$8020,dmacon			* Sprite DMA On
		cmove	$0000,color
		cmove	$0200,bplcon0
		cend


BlackCopper:	cmove	$0200,bplcon0
		cmove	$0000,color
		cend


		SECTION	MyBss,BSS

ColorTab:	ds.w	32				* Die Spielfarben
		ds.w	72+1-3				* Der Hintergrund
_PanelColors:	ds.w	32

		ds.w	32				* Nur Reserve !!!!


****************************************************************************
