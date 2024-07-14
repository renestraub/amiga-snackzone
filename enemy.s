ENEMY_S:
		INCLUDE	"MyExec.i"
		INCLUDE	"RelCustom.i"
		INCLUDE	"DrawBob.i"
		INCLUDE	"Enemy.i"
		INCLUDE	"Level.i"
		INCLUDE	"RonnyMove.i"
		INCLUDE	"Bobs.i"
		INCLUDE	"Definitions.i"
		
		XREF	_MyExecBase

		SECTION Program,CODE

*************************************************************************

InitEnemyList:	movem.l	d0-d1/a0-a2,-(sp)
		move.w	_LevelX,d0

		move.l	_ActLevelPtr,a2
		move.l	lv_EnemyRight(A2),a0

.Loop:		move.w	sb_XPos(a0),d1
		cmp.w	d1,d0 xpos,levelx
		blo.s	1$

		move.l	a0,a1
		move.l	a1,_LEnemyListPtr
		lea	sb_SIZEOF(A1),a1
		move.l	a1,_REnemyListPtr

1$:		and.w	#~(SBF_VISIBLE|SBF_SHOOT),sb_Flags(A0)

		lea	sb_SIZEOF(A0),a0

		cmp.w	#LISTEND,sb_XPos(a0)
		bne.s	.Loop

		movem.l	(sp)+,d0-d1/a0-a2
		rts

*****************************************************************************
	
* D0=Bob
MyAddBob:	movem.l	d1/a0-a2,-(sp)

		move.l	_MyExecBase,a6
 		SYSJSR	AddBob
		move.l	d0,a0

		movem.l	(sp)+,d1/a0-a2
		rts

***************************************************************************

UpDateClip:	movem.l	d0-d2/a0,-(sp)
		move.w	_LevelX,d0			* Level Coordinate
		move.w	d0,d1
		add.w	#368+8,d1			* Right Edge
		add.w	#16,d0

		move.l	_MyExecBase,a6
		lea	meb_BobList(a6),a0
2$:		move.l	bob_NextBob(A0),a0		* Next Bob
		move.l	bob_NextBob(A0),d2
		beq.s	1$				* No more Bobs -->

		move.w	#CLIPF_ALL,bob_ClipFlags(a0)	* Clip in all Directions
		clr.w	bob_ClipY(a0)
		move.w	#ScrHeight,bob_ClipY2(a0)
		move.w	d0,bob_ClipX(a0)		* New Right Border
		move.w	d1,bob_ClipX2(a0)		* New Right Border
		bra.s	2$

1$:		movem.l	(sp)+,d0-d2/a0
		rts

***************************************************************************

_UpDateBobs:	movem.l	d0-d7/a0-a6,-(sp)
		lea	custom,a5
		move.l	_MyExecBase,a6
		lea	meb_BobList(a6),a0

2$:		move.l	bob_NextBob(A0),a0		* Next Bob
		move.l	bob_NextBob(A0),d2
		beq.s	1$				* No more Bobs -->

		lea	_ViewBitmStr,a1
		SYSCALL	DrawOneBob
		lea	_ViewBitmStr,a1
		SYSCALL	RestoreOneBob

		lea	_DrawBitmStr,a1
		SYSCALL	DrawOneBob
		lea	_DrawBitmStr,a1
		SYSCALL	RestoreOneBob
		
		bra.s	2$

1$:
		movem.l	(sp)+,d0-d7/a0-a6
		rts


*****************************************************************************

HandleEnemyList2:
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	_ActLevelPtr,a2
		move.l	lv_EnemyRight(A2),a0

.Loop:		move.w	sb_XPos(A0),d3			* Next XPos
		move.w	sb_YPos(A0),d2

		move.l	sb_Bob(A0),d0			* A1=BobStructure
		beq.s	.Next				* -->

		move.l	d0,a1
		bsr	MyAddBob			* Add this Bob
		move.l	d0,a1

	;;;	lea	sb_Flags(A0),a2			* Flags
	;;;	move.l	a2,bob_UserDataPtr(a1)		* Flags
		clr.w	bob_ClipX(A1)
		clr.w	bob_ClipY(A1)
		clr.w	bob_ClipX2(A1)
		clr.w	bob_ClipY2(A1)
		move.w	#CLIPF_ALL,bob_ClipFlags(A1)

		add.w	d3,bob_X(a1)			* XPos relativ to LevelX
		add.w	#368,bob_X(A1)			* Left Border
		move.w	d2,bob_Y(A1)

.Next:		lea	sb_SIZEOF(A0),a0

		cmp.w	#LISTEND,sb_XPos(a0)
		bne.s	.Loop

		movem.l	(sp)+,d0-d7/a0-a6
		rts

