RONNYMOVE_S:
		INCLUDE	"MyExec.i"
		INCLUDE	"DrawBob.i"
		INCLUDE	"Definitions.i"
		INCLUDE	"Sfx.i"
		INCLUDE	"Panel.i"
		INCLUDE	"Scroll.i"
		INCLUDE	"Level.i"
		INCLUDE	"Flags1.i"
		INCLUDE	"Joystick.i"
		INCLUDE	"DosFileNames.i"
		INCLUDE	"RonnyMove.i"

		INCLUDE	"Game/ImmerBobs.i"

		XREF	_MyExecBase,_ImmerBobBase,_EndFlag

		SECTION Program,CODE

MAXCOUNT	EQU	2000

****************************************************************************

@LoadHero:	movem.l	d0-d7/a0-a6,-(sp)
		
		move.l	#_FN_RONNYBOB,d0
     		SYSJSR	LoadFastFile
		lea	NewRonnyBob+2(pc),a0
		move.l	d0,(A0)				* RonnyBob

		movem.l	(sp)+,d0-d7/a0-a6
		rts


****************************************************************************

InitMyBob:	movem.l	d0-d7/a0-a6,-(sp)
		lea	NewRonnyBob(pc),a1
		SYSJSR	AddBob				* Add my Bob
		move.l	d0,_MyBob
		move.l	d0,a0

		move.l	_ActLevelPtr,a1
		move.w	#RWALK,bob_Image(A0)		* Shape
		move.w	lv_LevelX(A1),d0
		move.w	d0,_LevelX			* LevelX
		move.w	lv_RonnyX(A1),bob_X(A0)
		move.w	lv_RonnyY(A1),bob_Y(A0)

		clr.b	_DuckFlag

		moveq	#1,d0
		move.b	d0,_DirX
		move.b	d0,_DirectionX

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************

NewMoveMyBob:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_MyBob,a4			* A4 = Bob

		bsr	SetSpeed

		bsr	GetJoy
		tst.b	d0
		beq.s	.DoesntMove

		add.w	#1,_SubCounter
		cmp.w	#MAXCOUNT,_SubCounter
		bne.s	.DoesntMove

		clr.w	_SubCounter
		move.w	d0,-(sp)
		moveq	#-1,d0
		bsr	@ChangeEnergy
		move.w	(sp)+,d0


.DoesntMove:	tst.b	_RightLock
		beq.s	.NoRLock			* Lock Rechts

		tst.b	d0
		bmi.s	.NoRLock

		clr.w	d0

.NoRLock:	tst.b	_LeftLock
		beq.s	.NoLLock

		tst.b	d0
		bpl.s	.NoLLock

		clr.w	d0
.NoLLock:
		move.b	_DirX,_LastDirX
		move.b	_DirY,_LastDirY
		move.b	d0,_DirX
		beq.s	.NoXDir
		move.b	d0,_DirectionX			* Letzte Richtung

.NoXDir:	move.b	d1,_DirY			* JoyStick-Abfrage
		beq.s	.NoYDir
		move.b	d1,_DirectionY

.NoYDir:	muls	_Speed,d0
		muls	_Speed,d1
		move.w	d0,_ScrollX
		move.w	d1,_ScrollY

		move.w	bob_X(a4),d0			* X-Position


	******  Bob steht auf Grund oder Wolke ******

.Steht:		move.w	bob_Y(a4),d0
		add.w	#$F,d0
		and.w	#$FFF0,d0
		subq.w	#1,d0
		move.w	d0,bob_Y(a4)			* Auf Boden setzen

	******	Ausweichbewegung ******

.Sprung:	clr.b	_AusweichFlag

		cmp.b	#-1,_DirY
		bne.s	.Ausweich1

	;;	move.w	#33,bob_Image(a4);
		move.w	#25,bob_Image(a4);

		clr.b	_DirX
		st.b	_AusweichFlag

		bra.s	.Ausweich2

.Ausweich1:	cmp.b	#1,_DirY
		bne.s	.Ausweich2

	;;	move.w	#32,bob_Image(a4);
		move.w	#24,bob_Image(a4);

		clr.b	_DirX
		st.b	_AusweichFlag

.Ausweich2:
	;;	cmp.b	#1,_DirY			* Joy nach unten
	;;	bne.s	.NichtDucken			* Nein -->

	;;	tst.b	_DuckFlag			* Schon geduckt
	;;	bne.s	.NichtDucken2			* JA -->

	;;	bsr	DuckenAnim			* Animatiom setzen
	;;	st.b	_DuckFlag
		
.NichtDucken2:
	;;	cmp.w	#LDUCK+3,bob_Image(A4)		* Bob in diesem Moment geduckt
	;;	beq.s	.Ducken2			* Nein -->
	;;	cmp.w	#RDUCK+3,bob_Image(A4)		* Bob in diesem Moment geduckt
	;;	bne.s	.NichtDucken			* Nein -->

.Ducken2:
	;;	bsr	GeducktAnim			* Bob bleibt unten


.NichtDucken:

	***** Links/Rechts Bewegungen ******

.HandleX:	;cmp.w	#180,bob_Y(A4)			***** DEBUG C5 *****
		;bgt	.NoScrScroll

		tst.b	_AusweichFlag
		bne	.NoScrScroll

		tst.b	_DuckFlag			* Bob geduckt
		bne	.NoScrScroll			* --> Keine Bewegung

.HandleX2:	lea	_LevelX,a1			* LevelX
		move.w	_ScrollX,d0			* X-Bewegung
		beq	.NoScrScroll
		bpl	.HandleRight			* Nach rechts

	***** Handles Left Movement *********

.ScrollLeft:	tst.b	_NoLeftFlag
		bne.s	.NoScrScrollX

		move.w	(A1),d1				* Actual LevelPos
		add.w	#172+32,d1			* LeftScrollBorder
		cmp.w	bob_X(a4),d1
		blt.s	.NoScrScrollX

		add.w	d0,(A1)				* Scroll Level 
		bpl.s	.NoScrScrollX
		clr.w	(A1)				* Left Border

.NoScrScrollX:	move.w	d0,d3
		tst.b	_NoLeftFlag
		beq.s	.Left1

		move.w	(A1),d1
		move.w	bob_X(A4),d2
		add.w	#60,d1
		cmp.w	d1,d2
		bgt.s	1$

		moveq	#0,d3
1$:

.Left1:		add.w	d3,bob_X(A4)			* Walk Left
		cmp.w	#52,bob_X(A4)
		bhi.s	.LeftBorder
		move.w	#52,bob_X(A4)

.LeftBorder:	bsr	MoveLeftRight			* Change Anim
		bra.s	.NoScrScroll

	***** Handles Right Movement *********

.HandleRight:
		move.w	d0,d3

		lea	_LevelX,a1
		move.w	(a1),d1				* Actual LevelPos
		add.w	#216-32,d1			* Right ScrollBorder
		cmp.w	bob_X(A4),d1			* 
		bhi.s	.NoScrScroll2			* No -->

		move.w	(A1),d2
		add.w	#368+320-16+4,d2
		cmp.w	_PixelSizeX,d2
		bhi.s	.NoScrScroll2

		add.w	d3,(a1)				* MoveScr to right

.NoScrScroll2:	tst.b	_NoRightFlag
		bne.s	.NoScrScroll

		move.w	bob_X(A4),d2
		add.w	#368+8-16-16,d2
		cmp.w	_PixelSizeX,d2
		bhi.s	.NoScrScroll

		add.w	d3,bob_X(A4)			* MoveBob to right
		bsr	MoveLeftRight			* Change Anim

.NoScrScroll:	movem.l	(sp)+,d0-d7/a0-a6
		rts

**************************************************************************

	IFD	fdskä
GeducktAnim:	lea	DuckenLeft2(pc),a1
		tst.b	_DirectionX
		bmi.s	.SetAnim
		lea	DuckenRight2(pc),a1
.SetAnim:	move.l	_MyBob,a0			* Bob
		moveq	#4,d0				* Speed
		move.l	_MyExecBase,a6
 		SYSJSR  SetAnimPrg
		rts

**************************************************************************

DuckenAnim:	clr.b	_WalkFlag
		lea	DuckenLeft(pc),a1

		tst.b	_DirectionX
		bmi.s	.SetAnim
		lea	DuckenRight(pc),a1
.SetAnim:	move.l	a4,a0				* Bob
		moveq	#4,d0				* Speed
		move.l	_MyExecBase,a6
 		SYSJSR  SetAnimPrg
		rts
	ENDC

**************************************************************************

MoveLeftRight:
		tst.b	_WalkFlag
		beq.s	.Animate

		;tst.b	_StairFlag
		;bne.s	.NoNewAnim

		move.b	_LastDirX,d0
		cmp.b	_DirX,d0
		beq.s	.NoNewAnim

.Animate:	lea	WalkLeft(pc),a1
		tst.b	_DirectionX			* Actual Direction
		bmi.s	.Left
		lea	WalkRight(pc),a1

.Left:		move.l	a4,a0				* Bob
		moveq	#4,d0				* Speed
		move.l	_MyExecBase,a6
 		SYSJSR  SetAnimPrg
.NoNewAnim:	rts

**************************************************************************

SetSpeed:	move.w	#SLOW,_Speed
		rts



**************** Bobs *******************************************************

**** RonnyBob ***************************************************************

NewRonnyBob:	SETDATA		0
		SETANIM		WalkRight
		SETFLAGS	BOBF_NORESTORE|BOBF_NODRAW|BOBF_NOANIM|BOBF_NOMOVE
		SETANIMSPEED	3
		SETID		RONNY_ID
		SETHITMASK	RONNY_COLL
	;;	SETMEMASK	RONNY_HITCOLL
	;;	SETCOLLHANDLER	FallHandler
		ENDE

WalkLeft:	POKEB		_WalkFlag,1
		dc.w		LWALK
		dc.w		LWALK+1
		dc.w		LWALK+2
		dc.w		LWALK+3
		dc.w		LWALK+4
		dc.w		LWALK+5
		dc.w		LWALK+6
		dc.w		LWALK+7
		dc.w		LWALK+8
		dc.w		LWALK+9
		dc.w		LWALK+10
		dc.w		LWALK+11
		LOOP

WalkRight:	POKEB		_WalkFlag,1
		dc.w		RWALK
		dc.w		RWALK+1
		dc.w		RWALK+2
		dc.w		RWALK+3
		dc.w		RWALK+4
		dc.w		RWALK+5
		dc.w		RWALK+6
		dc.w		RWALK+7
		dc.w		RWALK+8
		dc.w		RWALK+9
		dc.w		RWALK+10
		dc.w		RWALK+11
		LOOP


	IFD	fdslk

DuckenLeft:	POKEB		_WalkFlag,0
		dc.w		LDUCK+0
		dc.w		LDUCK+1
		dc.w		LDUCK+2
DuckenLeft2:	dc.w		LDUCK+3
		dc.w		LDUCK+3
		dc.w		LDUCK+3
		dc.w		LDUCK+2
		dc.w		LDUCK+1
		dc.w		LDUCK+0
		POKEB		_DuckFlag,0
		ENDE

DuckenRight:	POKEB		_WalkFlag,0
		dc.w		RDUCK+0
		dc.w		RDUCK+1
		dc.w		RDUCK+2
DuckenRight2:	dc.w		RDUCK+3
		dc.w		RDUCK+3
		dc.w		RDUCK+3
		dc.w		RDUCK+2
		dc.w		RDUCK+1
		dc.w		RDUCK+0
		POKEB		_DuckFlag,0
		ENDE

RonnyKO:	SoundFX	sfx_RonnyKO,4544,508,64		* Tschiip tschip

	ENDC

			SECTION	MyBSS,BSS

_MyBob:			ds.l	1		* MyBob
_BallonBobBase:		ds.l	1		* BallonBob

_Speed:			ds.w	1		* MyBob Speed
_ScrollX:		ds.w	1		* ScrollX
_ScrollY:		ds.w	1		* ScrollY
_NoCollisionTimer:	ds.w	1		* Timer for OFF-Collision
_ParalizeTimer:		ds.w	1		* Timer for Paralizing
_SubCounter:		ds.w	1

_DirectionX:		ds.b	1		* Letzt gewählte Richtung
_DirectionY:		ds.b	1		* Letzt gewählte Richtung
_DirX:			ds.b	1		* MoveDirection 
_DirY:			ds.b	1		* MoveDirection 
_LastDirX:		ds.b	1		* Last MoveDirection 
_LastDirY:		ds.b	1		* Last MoveDirection 
_DuckFlag:		ds.b	1		* Bob geduckt
_WalkFlag:		ds.b	1		* Bob is moving
_AusweichFlag:		ds.b	1
_NoLeftFlag:		ds.b	1
_NoRightFlag:		ds.b	1
_RightLock:		ds.b	1
_LeftLock:		ds.b	1
