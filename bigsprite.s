BIGSPRITE_S:

		INCLUDE	"MyExec.i"
		INCLUDE	"DrawBob.i"
		INCLUDE	"Copper.i"
		INCLUDE	"Level.i"
		INCLUDE	"Sprite.i"
		INCLUDE	"Gfx.i"
		INCLUDE	"RelCustom.i"

		XREF	_MyExecBase
		XDEF	_InitBigSprite,_ClearBigSprite,_BigSpriteHandler
		XDEF	_SpriteXPos

		XREF	_MoveFlag;

		SECTION Program,CODE_C

SPRHEIGHT:	EQU	98

****************************************************************************
* A0 = Screen
_InitBigSprite:	movem.l	d0-d7/a0-a6,-(sp)

		lea	_BigSprite,a2
		clr.l	(a2)

		move.l	a2,_ShowBigSpr
		move.l	a2,d0				* Sprite

		lea	sc_CopperList+cpr_Sprite0(a0),a1
		move.w	#sprpt,d1			* Custom Address
		moveq	#4-1,d3				* 8 Sprites
2$:		bsr	SetLongValue			* Set Sprite
		add.l	#(SPRHEIGHT+4)*4,d0
		dbf	d3,2$				* Repeat -->

		bsr	MergeCopper

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
* A0 = Screen
_ClearBigSprite:
		movem.l	d0-d7/a0-a6,-(sp)

		lea	sc_CopperList+cpr_Sprite0(a0),a1
		moveq	#0,d0				* Sprites to 0
		move.w	#sprpt,d1			* Custom Address
		moveq	#8-1,d3				* 8 Sprites
2$:		bsr	SetLongValue			* Set Sprite
		dbf	d3,2$				* Repeat -->

		bsr	MergeCopper

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
* A0 = Bob
_BigSpriteHandler:
		movem.l	d0-d7/a0-a5,-(sp)

		move.l	a0,_Bob				* Bob
		move.l	a0,d0
		tst.l	d0
		beq	.NoBob

		movem.l	d0-d7/a0-a6,-(sp)
		move.l	_Bob,a0
		move.l	_MyExecBase,a6
		SYSJSR	AnimateOneBob			* Let's Animate
.MoveIt:	
		move.l	_Bob,a0
		move.l	_MyExecBase,a6
		SYSJSR	MoveOneBob			* Let's Move
.NoAnimate:	movem.l	(sp)+,d0-d7/a0-a6

		move.l	_Bob,a0
		move.w	bob_Image(a0),d2
		tst.w	d2
		blt	.NoBob

		lsl.w	#2,d2
		lea	bob_AnimPtrs(a0),a2
		move.l	(a2,d2.w),a2
		move.l	a2,d2
		beq	.NoBob

		move.l	a2,a5

		move.w	bod_Height(A2),d2
		lea	bod_Images(A2),a1		* A1=Planes		
	
		move.l	_ShowBigSpr,a4			* SpriteData to draw in

		move.w	d2,d4
		lsl.w	#2,d4
		add.w	d4,a1

		lea	0*((SPRHEIGHT+4)*4)+4(A4),a2
		lea	2*((SPRHEIGHT+4)*4)+4(A4),a3
		bsr	CopyMap33

		lea	0*((SPRHEIGHT+4)*4)+6(A4),a2
		lea	2*((SPRHEIGHT+4)*4)+6(A4),a3		
		bsr	CopyMap33

		lea	1*((SPRHEIGHT+4)*4)+4(A4),a2
		lea	3*((SPRHEIGHT+4)*4)+4(A4),a3		
		bsr	CopyMap33

		lea	1*((SPRHEIGHT+4)*4)+6(A4),a2
		lea	3*((SPRHEIGHT+4)*4)+6(A4),a3		
		bsr	CopyMap33

.SetPosition:	move.l	a5,a2

		move.w	bob_X(A0),d0			* X-Pos
		move.w	bob_Y(A0),d1			* Y-Pos
		sub.w	bod_X0(A2),d0			* D0=X-Pos (Pixel)
		sub.w	bod_Y0(A2),d1			* D1=Y-Pos (Pixel)

		move.w	d0,_SpriteXPos

.PositionChanged:
		add.w	#$81,d0				* D0=X-Pos (Sprite)
		add.w	#$2C,d1				* D1=Y-Pos (Sprite)
		move.w	d1,d2
		add.w	#SPRHEIGHT,d2			* D2=EndY-Pos (Sprite)

		move.l	a4,a0				* Sprite
		bsr	SetSprPos

		lea	1*((SPRHEIGHT+4)*4)(A4),a0
		or.b	#$80,3(A0)
		bsr	SetSprPos

		addq.w	#8,d0
		addq.w	#8,d0
		lea	2*((SPRHEIGHT+4)*4)(A4),a0
		bsr	SetSprPos

		lea	3*((SPRHEIGHT+4)*4)(A4),a0
		or.b	#$80,3(A0)
		bsr	SetSprPos

.NoBob:		movem.l	(sp)+,d0-d7/a0-a5
		rts

****************************************************************************

CopyMap33:	move.w	d2,d1
		subq.w	#1,d1
		moveq	#64,d7

.Copy:		cmp.w	#16,d1
		blo	.SmallCopy

		move.w	(A1)+,(A2)
		move.w	(A1)+,(A3)
		move.w	(A1)+,4(A2)
		move.w	(A1)+,4(A3)
		move.w	(A1)+,8(A2)
		move.w	(A1)+,8(A3)
		move.w	(A1)+,12(A2)
		move.w	(A1)+,12(A3)
		move.w	(A1)+,16(A2)
		move.w	(A1)+,16(A3)
		move.w	(A1)+,20(A2)
		move.w	(A1)+,20(A3)
		move.w	(A1)+,24(A2)
		move.w	(A1)+,24(A3)
		move.w	(A1)+,28(A2)
		move.w	(A1)+,28(A3)
		move.w	(A1)+,32(A2)
		move.w	(A1)+,32(A3)
		move.w	(A1)+,36(A2)
		move.w	(A1)+,36(A3)
		move.w	(A1)+,40(A2)
		move.w	(A1)+,40(A3)
		move.w	(A1)+,44(A2)
		move.w	(A1)+,44(A3)
		move.w	(A1)+,48(A2)
		move.w	(A1)+,48(A3)
		move.w	(A1)+,52(A2)
		move.w	(A1)+,52(A3)
		move.w	(A1)+,56(A2)
		move.w	(A1)+,56(A3)
		move.w	(A1)+,60(A2)
		move.w	(A1)+,60(A3)

		add.w	d7,a2
		add.w	d7,a3

		subq.w	#8,d1
		subq.w	#8,d1
		bra	.Copy

.SmallCopy:	move.w	(A1)+,(A2)
		move.w	(A1)+,(A3)
		addq.l	#4,a2
		addq.l	#4,a3
.EndCopy:	dbf	d1,.SmallCopy

		moveq	#SPRHEIGHT,d1			* SpriteHöhe
		sub.w	d2,d1				* Rest Höhe
		bra.s	.EndClear

.Clear:		clr.w	(A2)
		clr.w	(A3)
		addq.l	#4,a2
		addq.l	#4,a3
.EndClear:	dbf	d1,.Clear			* Rest löschen
		rts

****************************************************************************

		SECTION	MyBSS,BSS_C

_Bob:		ds.l	1
_ShowBigSpr:	ds.l	1

_SpriteXPos:	ds.w	1
_BigSprite:	ds.w	4*(SPRHEIGHT+4)*4		* Buffer for PlayerSprite1
