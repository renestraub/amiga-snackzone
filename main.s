*****************************************************************************
*                                                                           *
*  SnackZone V1.02    	                           Created     : 15.12.1992 *
*  ---------------                                 Last Change : 14.04.1993 *
*                                                                           *
*  Modification History                                                     *
*                                                                           *
*  15.12.1992 RHS Created this File                                         *
*  20.12.1992 RHS Run's nearly under SYSSTART                               *
*  10.01.1993 RHS Run's under SYSSTART                                      *
*  25.01.1993 RHS Grosse Anpassungen für SnackZone                          *
*  22.02.1993 RHS Level wechseln & neues Bob				    *
*                                                                           *
*****************************************************************************

_LVOSupervisor:	EQU	-30

		XDEF	_NoInt,_ImmerBobBase,_EndFlag,_Para,_ActBitmap
		XDEF	@DelayBlank,Delay2Blanks,FreeBobs
		XDEF	_SkateFlag
		XDEF	_LVOSupervisor,_Processor

		XREF	_MyExecBase,@GetCPUType
		XREF	@OutOfEnergyEnd,@GameWon

		INCLUDE "DosFilenames.i"		* FileNames
		INCLUDE "MyExec.i"			* Includes für EXEC
		INCLUDE "Relcustom.i"			* AmigaCustomChips
		INCLUDE "Constants.i"			* AmigaConstants
		INCLUDE	"Definitions.i"			* Global definitions
		INCLUDE	"DrawBob.i"			* Bob Routine
		INCLUDE "Gfx.i"				* Gfx

		INCLUDE	"Copper.i"
		INCLUDE	"Menu.i"
		INCLUDE	"Scroll.i"
		INCLUDE	"Level.i"
		INCLUDE	"Enemy.i"
		INCLUDE	"Panel.i"
		INCLUDE	"Sprite.i"
		INCLUDE	"RonnyMove.i"

		INCLUDE	"Joystick.i"
		INCLUDE	"Collision.i"
		INCLUDE	"Sound.i"
		INCLUDE	"Bobs.i"

		INCLUDE	"Flags1.i"

		SECTION Program,CODE

NOSOUND:

Main:		move.l	a6,_MyExecBase			* SystemBase
		lea	custom,a5			* AMIGA-Customchips

;		move.w	#$7FFF,intreq(A5)
;		move.w	#$C000+INTF_PORTS,intena(A5)	* Enable MasterInt+KeyInt
;		move.w	#$87C0,dmacon(A5)		* Enable DMA|BITMAP|COPPER|BLITTER|BLITTERNASTY|SPRITES
;		bset.b	#1,$bfe001			* Filter OFF

		bsr	@GetCPUType
		move.w	d0,_Processor

		lea	BlackCopper,a0
		bsr	@SetCopperList

		bsr	InitGfx				* Gfx initialisieren

		bsr	_LoadSound			* Initiate SoundPlayer
		moveq	#5,d0
		bsr	_StartSong			* Start Song 0

		lea	IntHandler(pc),a0
		move.l	a0,meb_VBLIntVector(a6)		* Vertical Blank
		lea	CopperInt(pc),a0
		move.l	a0,meb_CopperIntVector(a6)	* Copper Interrupt

		st.b	_NoInt				* keine Interrupt
		st.b	_MusicFlag

		lea	CheatText(pc),a0
 		SYSJSR  SetCheatText			* Sets Cheat Text	

		move.l	$dff006,d0
		move.l	$dff006,d1
 		SYSJSR  Randomize			* for 'Random'

	** MUSS DAS HIER SEIN ?? **

		lea	_DrawBitmStr,a0
		SYSJSR	InitDrawBob			* Init BobRoutine

		bsr	HauptLader			* Alles laden

ReStart:	st.b	_NoInt				* Interrupt sperren

		bsr	@Menu				* Menuauswahl
		SYSCALL	CheckMem

		lea	custom,a5			
		bsr	@InitGame			* ActLevel = 0

		moveq	#2,d0
		bsr	_StartSong			* Start Song 0

		SYSCALL	CheckMem
		bsr	@LoadLevel			* Load Level
		bsr	@InitPanel			* Reset Bonus
		SYSCALL	CheckMem


NewLevel:	clr.b	_NoInt
		clr.b	_FlipFlag
		bsr	_FlipScreen		

		lea	BlackCopper,a0			* Black Screen
		bsr	@SetCopperList
		bsr	InitMyBob			* Setup Bob
		bsr	InitSprite			* Setup Sprite
		bsr	@CreateLevel			* Init Level

		bsr	InitEnemyList			* Reset EnemyList
		bsr	HandleEnemyList2		* Set some new Enemies

		clr.b	_EndFlag			* Game runs
		clr.b	_NoInt				* Enable Int
		st.b	_GameFlag
		lea	_ViewBitmStr,a1
		move.l	a1,_ActBitmap			* Actual BitmStr

		bsr	Delay2Blanks

	;; Das ist aber komisch

		lea	_DrawBitmStr,a1
		SYSJSR	RestoreBobList			* Restore Bobs
		lea	_DrawBitmStr,a1
		SYSJSR	DrawBobList			* Restore Bobs
		bsr	_FlipScreen			* FlipIt

		lea	_DrawBitmStr,a1
		SYSJSR	RestoreBobList			* Restore Bobs
		lea	_DrawBitmStr,a1
		SYSJSR	DrawBobList			* Restore Bobs
		bsr	_FlipScreen			* FlipIt

		bsr	UpDateClip			* Set new Clip-Coords

		lea	_DrawBitmStr,a1
		SYSJSR	RestoreBobList			* Restore Bobs
		lea	_DrawBitmStr,a1
		SYSJSR	DrawBobList			* Restore Bobs
		bsr	_FlipScreen			* FlipIt

		bsr	@UpDatePanel

		lea	CopperList,a0			* Set our CopperList
		bsr	@FadeOutCopper
		bsr	@SetCopperList
		bsr	@FadeInCopper			* Screen einfaden

MainLoop:	bsr	Delay2Blanks

		SYSCALL	CheckMem

		SYSJSR	GetKey				* Fuer's EXIT

		cmp.b	#27,d0
		bne	.NoEscape

		move.b	#ABORT_GAME,_EndFlag
.NoEscape:

;		btst	#6,$bfe001
;		bne	1$

;		move.b	#OUT_OF_ENERGY,_EndFlag
;		move.b	#GAME_WON,_EndFlag

1$:		lea	_DrawBitmStr,a1
		SYSJSR	RestoreBobList			* Restore Bobs

		bsr	@UpDatePanel

		clr.w	_PfeilStrobe
		clr.w	_PfeilFlag
		bsr	MyHandleCollision		* Bob-Collision
		bsr	@CheckGate			* Change the current Level
		move.w	#-1,_PfeilStrobe

	 	bsr	UpDateClip			* Set new Clip-Coords

		lea	_DrawBitmStr,a1
     		SYSJSR	DrawBobList			* Draw Bobs

		bsr	_FlipScreen			* FlipIt

	;;	clr.w	_PfeilStrobe
	;;	bsr	@CheckGate			* Change the current Level
	;;	move.w	#-1,_PfeilStrobe

		tst.b	_EndFlag			* End
		beq	MainLoop

Exit:		bsr	DelayBlank			* Warten bis Copper kommt
		bsr	DelayBlank

		st.b	_NoInt				* Int ausschalten
		clr.b	_GameFlag			* GameEnde

		bsr	@FadeOutCopper			* Jetzt wirds dunkel
		bsr	FreeBobs			* Allen Speicher freigeben

		cmp.b	#CHANGE_LEVEL,_EndFlag
		beq.s	.ChangeLevel
		
		*** Game End ***

		cmp.b	#OUT_OF_ENERGY,_EndFlag
		bne.s	.Energy

		bsr	@OutOfEnergyEnd
		bsr	@FreeGame
		bra	ReStart

.Energy:	cmp.b	#GAME_WON,_EndFlag
		bne.s	.NotGamewon

		bsr	@GameWon
		bsr	@FreeGame
		bra	ReStart
	
.NotGamewon:	bsr	@FreeGame
		bra	ReStart


.ChangeLevel:	move.l	_NextLevelPtr,_ActLevelPtr
		clr.l	_NextLevelPtr
		SYSCALL	CheckMem
		bsr	@LoadLevel			* Load Level and Init
		SYSCALL	CheckMem
		bra	NewLevel			* Nächster Level

**** VBlank *******************************************************************

IntHandler:	movem.l	d0-d7/a0-a6,-(sp)
		lea	custom,a5			* CustomBase
		move.l	_MyExecBase,a6

		addq.l	#1,_VBCounter			* Increase VBCounter

.NoMain:

	IFD	SOUND
		tst.b	_NoKeyFlag			* Main is asking for KEY
		bne.s	.NoKey				* -->

		move.b	meb_ActualASCIIKey(a6),d0
		cmp.b	#'m',d0				* Musik
		bne.s	.NoMusicToggle			* ein-/ausschalten

		not.b	_MusicFlag
		move.w	#$F,dmacon(A5)			* Sound DMA aus

		move.b	#0,meb_ActualASCIIKey(a6)
	ENDC

.NoMusicToggle:	
.NoKey:		tst.b	_NoInt
		bne.s	.NoInt

		addq.l	#1,_GameTimer

.NoInt:		tst.b	_MusicFlag
		beq.s	.NoSound

		nop
		bsr	_SoundPlayer			* Play that funky music

.NoSound:
.NoVBlank:	movem.l	(sp)+,d0-d7/a0-a6
		rts

**** Copper *******************************************************************

CopperInt:	movem.l	d0-d7/a0-a6,-(sp)
		lea	custom,a5

		tst.b	_NoInt
		bne.s	.NoInt

		bsr	@SoftScroll			* Scroll

		tst.b	_SkateFlag
		bne.s	.NoInt

		bsr	NewMoveMyBob			* Move my Bob
		bsr	SpriteHandler

.NoInt:		movem.l	(sp)+,d0-d7/a0-a6
		rts

**************************************************************************

@DelayBlank:
DelayBlank:	movem.l	d0/d1,-(sp)
		move.l	_VBCounter,d1			* Current VBCnt
.Wait:		
	;;	SYSJSR  GetKey
		cmp.l	_VBCounter,d1			* didn't changed
		beq.s	.Wait				* yet -->
		movem.l	(sp)+,d0/d1
		rts

***************************************************************************

Delay2Blanks:	move.l	d1,-(sp)
		move.l	_VBCounter,d1
		sub.l	_OldVBCounter,d1

		cmp.w	#2,d1
		bge.s	2$

		moveq	#2,d1

2$:		move.l	_OldVBCounter,d0		* Current VBCnt
		add.w	d1,d0
1$:		cmp.l	_VBCounter,d0			* didn't changed
		bgt.s	1$				* yet -->

		move.l	_VBCounter,_OldVBCounter

		bsr	DelayBlank
		move.l	(sp)+,d1
		rts

****************************************************************************

HauptLader:	movem.l	d0-d7/a0-a6,-(sp)

		bsr	@LoadHero

		move.l	#_FN_IMMERBOBS,d0
     		SYSJSR	LoadFile
		move.l	d0,_ImmerBobBase		* ImmerBobs

		bsr	@LoadPanel
		bsr	@SetPanel			* Load Panel

.LowMem:	movem.l	(sp)+,d0-d7/a0-a6
		rts
**************************************************************************

FreeBobs:	move.l	a0,-(sp)
.MainBobLoop:	lea	meb_BobList(a6),a0
		move.l	bob_NextBob(A0),a0
		tst.l	bob_NextBob(A0)			* A0=Kollision
		beq.s	.EndMainLoop			* auslösendes Bob

		bsr	RemoveOneBob
		bra.s	.MainBobLoop

.EndMainLoop:	move.l	(sp)+,a0
		rts


RemoveOneBob:	movem.l	d0/a0-a2,-(sp)

		move.l	bob_LastSaveBuffer(A0),a1
		move.l	bob_LastLastSaveBuffer(A0),a2

		cmp.l	a1,a2
		bgt.s	.Clear

		move.l	a2,a1				* Change LastSaveBuffer
		move.l	a1,d0
		beq.s	.NoBuffer

.Clear:		move.l	_MyExecBase,a6
 		SYSJSR  FreeMem			* Free Buffer (A1)
.NoBuffer:	move.l	a0,a1				* BobStruktur
 		SYSJSR  Remove			* Node entfernen (A1)
 		SYSJSR  FreeMem			* freeen
		movem.l	(sp)+,d0/a0-a2
		rts

**************** vorhandenen Speicher abfragen *******************************

		CNOP	0,2

SnackText:	dc.b	"SNACKZONE V0.54",0
GameOverText:	dc.b	"GAME OVER",0

CheatText:	dc.b	$20,$24,$03,$0a,$07,$09,$05,$01,0
		   ;     A   G   3   0   7   9   5   1

		CNOP	0,2
		
************************************************************************************

			SECTION	MyBSS,BSS

_ImmerBobBase:		ds.l	1		* BaseAddress for ImmerBobs
_VBCounter:		ds.l	1		* VerticalBlank Counter
_OldVBCounter:		ds.l	1		* VerticalBlank Counter
_ActBitmap:		ds.l	1

_Processor:		ds.w	1		* Proc running on
_Para:			ds.w	PARASIZE	* ParameterStack


_EndFlag:		ds.b	1		* EndFlag
_NoInt:			ds.b	1		* Disable Interrupt
_MusicFlag:		ds.b	1		* MusicFlag
_NoKeyFlag:		ds.b	1		* Keine Key abfragen aus INT
_GameFlag:		ds.b	1		* Game on/off
_SkateFlag:		ds.b	1		* SkaterGame on/off
