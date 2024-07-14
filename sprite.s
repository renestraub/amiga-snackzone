SPRITE_S:

		INCLUDE	"MyExec.i"
		INCLUDE	"DrawBob.i"
		INCLUDE	"Sprite.i"
		INCLUDE	"Copper.i"
		INCLUDE	"Level.i"
		INCLUDE	"RonnyMove.i"

		XREF	_MyExecBase

		SECTION Program,CODE

SPRHEIGHT:	EQU	48

****************************************************************************

InitSprite:	lea	_Sprite1,a1
		move.l	a1,_ShowSpr

		clr.w	_PfeilFlag
		clr.w	_PfeilState
		clr.w	_PfeilStrobe
		rts

****************************************************************************

ClearRonny:	movem.l	d0-d1/a0-a1,-(sp)
		lea	CopperSprites+2,a1
		suba.l	a0,a0
		bsr	SetLong
		bsr	SetLong

		bsr	SetLong
		bsr	SetLong
		bsr	SetLong
		bsr	SetLong

		bsr	SetLong
		bsr	SetLong

		movem.l	(sp)+,d0-d1/a0-a1
		rts

****************************************************************************

@ClearPfeil:	movem.l	d0-d7/a0-a6,-(sp)

		clr.l	_PfeilSprite1	
		clr.l	_PfeilSprite2	

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************

SpriteHandler:	movem.l	d0-d7/a0-a5,-(sp)

		move.l	_MyBob,a0			* MyBob
		move.l	a0,d0
		tst.l	d0
		beq	.NoBob

		movem.l	d0-d7/a0-a6,-(sp)

		tst.b	_AusweichFlag
		bne.s	.NoAnimate
		tst.b	_WalkFlag
		beq.s	.Animate
		tst.b	_DirX				* Wurde Bob bewegt
		beq.s	.NoAnimate			* Nein --> Keine Animation

.Animate:	move.l	_MyBob,a0
		move.l	_MyExecBase,a6
		SYSJSR	AnimateOneBob		* Let's Animate

.MoveIt:	move.l	_MyBob,a0
		move.l	_MyExecBase,a6
		SYSJSR	MoveOneBob		* Let's Move

.NoAnimate:	movem.l	(sp)+,d0-d7/a0-a6

		move.l	_MyBob,a0
		move.w	bob_Image(a0),d2
		tst.w	d2
		blt	.NoBob

		lsl.w	#2,d2
		lea	bob_AnimPtrs(a0),a2
		move.l	(a2,d2.w),a2
		move.l	a2,d2
		beq	.NoBob

		move.l	a2,a5

		move.w	bod_CollX0(A2),bob_CollX0(A0)
		move.w	bod_CollX1(A2),bob_CollX1(A0)
		move.w	bod_CollY0(A2),bob_CollY0(A0)
		move.w	bod_CollY1(A2),bob_CollY1(A0)	* CollisionRectangle

		move.w	bod_Height(A2),d2
		lea	bod_Images(A2),a1		* A1=Planes		
	
		move.l	_ShowSpr,a4			* SpriteData to draw in

	;	cmp.w	#16,bod_Width(A2)
	;	bhi.s	.TwoSprites

		lea	0*((SPRHEIGHT+4)*4)+4(A4),a2
		lea	2*((SPRHEIGHT+4)*4)+4(A4),a3
		bsr	CopyMap16
		lea	0*((SPRHEIGHT+4)*4)+6(A4),a2
		lea	2*((SPRHEIGHT+4)*4)+6(A4),a3		
		bsr	CopyMap16

		lea	1*((SPRHEIGHT+4)*4)+4(A4),a2
		lea	3*((SPRHEIGHT+4)*4)+4(A4),a3		
		bsr	CopyMap16
		lea	1*((SPRHEIGHT+4)*4)+6(A4),a2
		lea	3*((SPRHEIGHT+4)*4)+6(A4),a3		
		bsr	CopyMap16
	;	bra.s	.SetPosition			

;.TwoSprites:	lea	0*((SPRHEIGHT+4)*4)+4(A4),a2
;		lea	2*((SPRHEIGHT+4)*4)+4(A4),a3
;		bsr	CopyMap32
;		lea	0*((SPRHEIGHT+4)*4)+6(A4),a2
;		lea	2*((SPRHEIGHT+4)*4)+6(A4),a3		
;		bsr	CopyMap32

;		lea	1*((SPRHEIGHT+4)*4)+4(A4),a2
;		lea	3*((SPRHEIGHT+4)*4)+4(A4),a3		
;		bsr	CopyMap32
;		lea	1*((SPRHEIGHT+4)*4)+6(A4),a2
;		lea	3*((SPRHEIGHT+4)*4)+6(A4),a3		
;		bsr	CopyMap32

.SetPosition:	move.l	a5,a2
		move.w	bob_X(A0),d0			* X-Pos
		move.w	d0,d7
		move.w	bob_Y(A0),d1			* Y-Pos
		sub.w	bod_X0(A2),d0			* D0=X-Pos (Pixel)
		sub.w	bod_Y0(A2),d1			* D1=Y-Pos (Pixel)
		sub.w	_LevelX,d0
		add.w	#$81-16-16,d0			* D0=X-Pos (Sprite)
		add.w	#$4C-2-32-1,d1			* D1=Y-Pos (Sprite)
		move.w	d1,d2
		add.w	#SPRHEIGHT,d2			* D2=EndY-Pos (Sprite)

		cmp.w	#20,d1
		bgt	.DontShow

		clr.l	(A4)
		clr.l	1*((SPRHEIGHT+4)*4)(A4)
		clr.l	2*((SPRHEIGHT+4)*4)(A4)
		clr.l	3*((SPRHEIGHT+4)*4)(A4)
		bra	.EndShow

.DontShow:	move.l	a4,a0				* Sprite
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


		move.w	d7,d0
		sub.w	_LevelX,d0
		add.w	#$81-16-16-6,d0			* D0=X-Pos (Sprite)
		move.w	#150,d1

		tst.w	_PfeilStrobe
		beq.s	.DontSetFlag

		move.w	_PfeilFlag,_PfeilState

.DontSetFlag:	tst.w	_PfeilState
		bne.s	.ShowPfeil

		clr.w	d1

.ShowPfeil:	move.w	d1,d2
		add.w	#15,d2
		lea	_PfeilSprite1,a0
		bsr	SetSprPos

		lea	_PfeilSprite2,a0
		or.b	#$80,3(A0)
		bsr	SetSprPos

.EndShow:	bsr	SetMySprite

.NoBob:		movem.l	(sp)+,d0-d7/a0-a5
		rts

****************************************************************************

CopyMap16:	move.w	d2,d1
		bra.s	.EndCopy
.Copy:		move.w	(A1)+,(A2)
		clr.w	(A3)
		lea	4(A2),a2
		lea	4(A3),a3
.EndCopy:	dbf	d1,.Copy

		moveq	#SPRHEIGHT,d1			* SpriteHöhe
		sub.w	d2,d1				* Rest Höhe
		bra.s	.EndClear

.Clear:		clr.w	(A2)
		clr.w	(A3)
		lea	4(A2),a2
		lea	4(A3),a3
.EndClear:	dbf	d1,.Clear			* Rest löschen
		rts

**************************************************************************

SetMySprite:	movem.l	d0-d1/a0-a1,-(sp)
		lea	CopperSprites+2,a1

		lea	_PfeilSprite1,a0
		bsr.s	SetLong
		lea	_PfeilSprite2,a0
		bsr.s	SetLong

		move.l	_ShowSpr,a0
		moveq	#SPRHEIGHT+4,d1
		lsl.l	#2,d1

		bsr.s	SetLong
		add.l	d1,a0
		bsr.s	SetLong
		add.l	d1,a0
		bsr.s	SetLong
		add.l	d1,a0
		bsr.s	SetLong

	;;	suba.l	a0,a0

		lea	_LeerSprite,a0
		bsr.s	SetLong
		bsr.s	SetLong

		movem.l	(sp)+,d0-d1/a0-a1
		rts

****************************************************************************

SetLong:	move.l	a0,d0
		move.w	d0,4(A1)
		swap	d0
		move.w	d0,(A1)
		lea	8(A1),a1
		rts

****************************************************************************
* D0=X / D1=Y1 / D2=Y2 / A0=Sprite
SetSprPos:	movem.l	d0-d2/a0,-(sp)
		and.b	#%11111000,3(A0)

		btst	#0,d0
		beq.s	.XEven
		or.b	#1,3(A0)
.XEven:		asr	#1,d0
		move.b	d0,1(A0)

		cmp.w	#256,d1
		blt.s	.YStart
		or.b	#4,3(A0)
.YStart:	move.b	d1,(A0)

		cmp.w	#256,d2
		blt.s	.YStop
		or.b	#2,3(A0)
.YStop:		move.b	d2,2(A0)

.Not:		movem.l	(sp)+,d0-d2/a0
		rts


		SECTION	MyData,DATA


_LeerSprite:	dc.w	$0000,$0000
		dc.w	$0000,$0000

_PfeilSprite1:	dc.w	$0000,$0000	; Sprite 1
		dc.w	$0000,$0100
		dc.w	$0100,$0380
		dc.w	$0300,$07C0
		dc.w	$0780,$0FE0
		dc.w	$0FC0,$1FF0
		dc.w	$1FE0,$3FF8
		dc.w	$3FF0,$7FFC
		dc.w	$3FFC,$FBBE
		dc.w	$0780,$0FE0
		dc.w	$0780,$0FE0
		dc.w	$0780,$0FE0
		dc.w	$0780,$0FE0
		dc.w	$0400,$0FE0
		dc.w	$0000,$0FE0
		dc.w	$0000,$0000

_PfeilSprite2:	dc.w	$0000,$0000
		dc.w	$0100,$0000
		dc.w	$0380,$0000
		dc.w	$07C0,$0180
		dc.w	$0FE0,$03C0
		dc.w	$1FF0,$07E0
		dc.w	$3FF8,$0FF0
		dc.w	$7FFC,$1FF8
		dc.w	$C7C2,$3FFC
		dc.w	$0FE0,$07C0
		dc.w	$0FE0,$03C0
		dc.w	$0FE0,$03C0
		dc.w	$0FE0,$03C0
		dc.w	$0FE0,$07C0
		dc.w	$0FE0,$0000
		dc.w	$0000,$0000

		; End of Converter 3.54 source generation

		SECTION	MyBSS,BSS

_ShowSpr:	ds.l	1
_Sprite1:	ds.w	4*(SPRHEIGHT+16)*4		* Buffer for PlayerSprite1
_PfeilFlag:	ds.w	1
_PfeilState:	ds.w	1
_PfeilStrobe:	ds.w	1

