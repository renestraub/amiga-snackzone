COLLISION_S:

		INCLUDE	"MyExec.i"
		INCLUDE	"collision.i"
		INCLUDE	"drawbob.i"
		INCLUDE "definitions.i"

		XREF	_MyExecBase,_EndFlag

*****************************************************************************
* Function	: HandleCollision						
* Parameters	: none
* Result	: none
*****************************************************************************

MyHandleCollision:
		movem.l	d0-d7/a0-a6,-(sp)
	;;	move.l	_MyExecBase,a6
		lea	meb_BobList(a6),a0
.MainBobLoop:	move.l	bob_NextBob(A0),a0
		tst.l	bob_NextBob(A0)			* A0=Kollision
		beq.s	.EndMainLoop			* auslösendes Bob

		bsr	MyCollOneBob

	*** Scheiss Cheat für SkaterGame ****

		cmp.b	#CHANGE_LEVEL,_EndFlag
		beq.s	.EndMainLoop
		
		bra.s	.MainBobLoop

.EndMainLoop:	movem.l	(sp)+,d0-d7/a0-a6
		rts

*****************************************************************************
* Function	: MyCollOneBob						
* Parameters	: A0=Bob
* Result	: none
*****************************************************************************

MyCollOneBob:	movem.l	d0-d7/a0-a6,-(sp)
		move.w	bob_HitMask(A0),d0		* Bob löst keine
		beq	.EndMainLoop			* Kollision aus

		movem.w	bob_CollX0(a0),d0-d3		* Koordinaten
		add.w	bob_AbsX(a0),d0
		add.w	bob_AbsY(a0),d1
		add.w	bob_AbsX(a0),d2
		add.w	bob_AbsY(a0),d3			* SourceBob

		move.l	_MyExecBase,a6
		lea	meb_BobList(a6),a1
.BobLoop:	move.l	bob_NextBob(A1),a1
		tst.l	bob_NextBob(A1)			* A1=Kollision
		beq	.EndMainLoop			* einfangendes Bob

		cmp.l	a0,a1				* Keine Kollision
		beq.s	.BobLoop			* mit sich selbst

.DoCollision:	move.w	bob_HitMask(A0),d4		* HitMask
		move.w	bob_MeMask(A1),d5		* MeMask
		and.w	d4,d5				* nicht über-
		beq.s	.BobLoop			* einstimmend -->

		movem.w	bob_CollX0(a1),d4-d7
		add.w	bob_AbsX(a1),d4
		add.w	bob_AbsY(a1),d5
		add.w	bob_AbsX(a1),d6			* Koordinaten
		add.w	bob_AbsY(a1),d7			* ZielBob

		cmp.w	d2,d4
		bgt.s	.BobLoop
		cmp.w	d0,d6
		blt.s	.BobLoop
		cmp.w	d3,d5
		bgt.s	.BobLoop
		cmp.w	d1,d7
		blt.s	.BobLoop

.Coll:		move.l	bob_CollHandler(A1),d4		* KollisionsHandler
		beq.s	.BobLoop			* nicht vorhanden -->

		movem.l	d0-d7/a0-a6,-(sp)		* Zur Sicherheit
		move.l	d4,a2
		move.l	_MyExecBase,a6			
		jsr	(A2)				* Handler Starten
		movem.l	(sp)+,d0-d7/a0-a6		* Zur Sicherheit	

	*** Scheiss Cheat für SkaterGame ****

		cmp.b	#CHANGE_LEVEL,_EndFlag
		beq.s	.EndMainLoop

		bra.s	.BobLoop

.EndMainLoop:	movem.l	(sp)+,d0-d7/a0-a6
		rts

