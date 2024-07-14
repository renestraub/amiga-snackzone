
		INCLUDE	"myexec.i"
		INCLUDE	"gfx.i"
		INCLUDE	"relcustom.i"
		INCLUDE	"level.i"
		INCLUDE	"scroll.i"
		INCLUDE	"enemy.i"
		INCLUDE	"copper.i"
		INCLUDE	"definitions.i"
		INCLUDE	"drawbob.i"
		INCLUDE	"sound.i"
		INCLUDE	"panel.i"
		INCLUDE	"sprite.i"
		INCLUDE	"joystick.i"

		INCLUDE	"Game/SkaterBobs.i"

		XREF	_ImmerBobBase,_EndFlag,_ActBitmap
		XREF	@DelayBlank,Delay2Blanks,FreeBobs
		XREF	@SetUpLevel,_UpDateBobs
		XREF	_SkateFlag,_NoInt
		XREF	_Level7Tab
		XREF	_SpeedObject

		XREF	_StarterSelect1,_StarterSelect2,_StarterSelect3
		XREF	@Select

		XDEF	@SkaterGame


ZIEL_X		EQU	2640
;;ZIEL_X		EQU	840

@SkaterGame:	movem.l	d0-d7/a0-a6,-(sp)
		lea	custom,a5	

		clr.l	bob_CollHandler(A1)

		st.b	_SkateFlag

		bsr	@FadeOutCopper
		bsr	ClearRonny
		bsr	FreeBobs

		moveq	#1,d0
		bsr	_StartSong

	**** Level laden ****

		move.l	_LevelBase,OldLevelBase
		move.l	#LevelName,d0
		SYSCALL	LoadFastFile
		move.l	d0,_LevelBase

	**** Char Laden ****

		move.l	#CharName,d0
		move.l	_CharBase,a0
		SYSCALL	ReadFile

	**** Panel Laden ****

		move.l	#PanelGameName,d0
		move.l	_PanelBase,a0
		SYSCALL	ReadFile

		move.l	_PanelBase,a0
		add.l	#4800,a0
		move.l	#960,d0
		SYSCALL	ClearMem
		
		clr.b	_FlipFlag
		clr.b	EndSkate			* Game runs
		clr.b	HeroZiel
		clr.b	EnemyZiel
		clr.b	HeroEnd
		clr.b	EnemyEnd

		lea	_SpeedObject,a0
		clr.w	ro_value(a0)
		clr.w	ro_actvalue(a0)
		move.w	#-1,ro_lastvalue(a0)

		bsr	@InitSkaterPanel
		bsr	@UpDateSkaterPanel
		bsr	@UpDateSkaterPanel

		move.w	#30,_LevelX

		bsr	_FlipScreen		
		bsr	@CreateLevel			* Init Level

		lea	_ViewBitmStr,a1
		move.l	a1,_ActBitmap			* Actual BitmStr

		bsr	Delay2Blanks

		lea	CopperList,a0			* Set our CopperList
		bsr	@SetCopperList

	**** Bob laden ****

		move.l	#SkateBobs,d0
		SYSCALL	LoadFile
		move.l	d0,SkateBobBase

		lea	HeroSkate(pc),a1
		SYSCALL	AddBob
		move.l	d0,Hero_Bob

		lea	EnemySkate(pc),a1
		SYSCALL	AddBob
		move.l	d0,Enemy_Bob

		lea	StarterSkate(pc),a1
		SYSCALL	AddBob
		move.l	d0,Starter_Bob

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

		bsr	@FadeInCopper			* Screen einfaden

		lea	_StarterSelect1,a0
		suba.l	a1,a1
		bsr	@Select

		lea	_StarterSelect2,a0
		suba.l	a1,a1
		bsr	@Select

		lea	_StarterSelect3,a0
		suba.l	a1,a1
		bsr	@Select

		clr.b	HeroCnt
		clr.b	HeroChangeCnt

MainLoop:	bsr	Delay2Blanks

		move.l	Hero_Bob,a0
		move.w	bob_X(a0),d0
		sub.w	#190,d0
		move.w	d0,_LevelX

		SYSJSR	GetKey				* Fuer's EXIT
		cmp.b	#27,d0
		bne.s	.NoEscape

		move.b	#ABORT_GAME,EndSkate

.NoEscape:	tst.b	HeroZiel
		bne	.NoShaking

		addq.b	#1,HeroCnt
		cmp.b	#25,HeroCnt
		bne.s	1$

		clr.b	HeroCnt

		moveq	#0,d0
		move.b	HeroChangeCnt,d0
		addq.w	#2,d0

	;;;	moveq	#20,d0			** DEBUG ***

		lsl.w	#3,d0
		lea	_SpeedObject,a0
		move.w	d0,ro_value(a0)

		move.w	ro_actvalue(a0),d0
		lsr.w	#6,d0
		addq.w	#1,d0
		move.l	Hero_Bob,a0
		move.w	d0,bob_MoveStep(a0)

		moveq	#5,d1
		sub.w	d0,d1
		move.b	d1,bob_AnimSpeed(a0)
		clr.b	bob_AnimSpeedCounter(a0)

		clr.b	HeroChangeCnt

1$:		bsr	GetJoy
		move.b	d0,HeroDirX		
		cmp.b	HeroLastDirX,d0
		beq.s	.NoChange

		addq.b	#1,HeroChangeCnt
		move.b	d0,HeroLastDirX

.NoChange:
.NoShaking:	lea	_DrawBitmStr,a1
		SYSJSR	RestoreBobList			* Restore Bobs

.NoColl: 	bsr	UpDateClip			* Set new Clip-Coords

		bsr	@UpDateSkaterPanel

		lea	_DrawBitmStr,a1
		SYSJSR	DrawBobList			* Draw Bobs

		bsr	_FlipScreen			* FlipIt

		tst.b	HeroEnd
		beq	MainLoop
		tst.b	EnemyEnd
		bne.s	Exit
		cmp.b	#ABORT_GAME,EndSkate		* End
		bne	MainLoop			* yes -->

	**** Ende ****

Exit:		bsr	Delay2Blanks			* Warten bis Copper kommt

		st.b	_NoInt

		cmp.b	#ABORT_GAME,EndSkate
		beq	5$


4$:		moveq	#0,d1
6$:		move.w	#300,d0
		bsr	RasterDelay

		addq.w	#1,d1
		cmp.w	#150,d1
		beq	5$

		SYSCALL	GetKey
		bsr	CheckJoy
		bne.s	6$

	*** Zeugs freigeben ****

5$:		bsr	@FadeOutCopper			* Jetzt wirds dunkel
		bsr	FreeBobs			* Allen Speicher freigeben

		move.l	_LevelBase,a1
		SYSCALL	FreeMem
		move.l	OldLevelBase,_LevelBase

	**** Die alten Panel/Level/Chars wieder einladen ****

		move.l	SkateBobBase,a1
		SYSCALL	FreeMem

		move.l	#CharName1,d0
		move.l	_CharBase,a0
		SYSCALL	ReadFile

		move.l	#LevelName6,d0
		move.l	_LevelBase,a0
		SYSCALL	ReadFile
	
		move.l	#PanelName,d0
		move.l	_PanelBase,a0
		SYSCALL	ReadFile

		bsr	@InvalidPanel
		bsr	@UpDatePanel
		bsr	@UpDatePanel

	**** Und den Level rekonstruieren *****

		clr.b	_SkateFlag

		move.b	#CHANGE_LEVEL,_EndFlag

		lea	_Level7Tab,a0
		move.w	#160,lv_LevelX(A0)
		move.w	#300,lv_RonnyX(A0)
		move.l	a0,_NextLevelPtr

		moveq	#2,d0
		bsr	_StartSong

		movem.l	(sp)+,d0-d7/a0-a6
		moveq	#0,d0
		move.b	EndSkate,d0

		move.b	#HERO_WINS,d0
		rts



HeroHandler:	movem.l	d0-d7/a0-a6,-(sp)

		move.w	bob_X(a0),d1
		sub.w	#190,d1
		cmp	#ZIEL_X,d1
		blo.s	.NotZiel

		clr.l	bob_Handler(a0)
		st.b	HeroZiel

		cmp.b	#ENEMY_WINS,EndSkate	* Enemy schon im Ziel ?
		beq.s	.EnemyWon

		move.b	#HERO_WINS,EndSkate

.EnemyWon:	lea	AuslaufMove1(pc),a1
		moveq	#1,d0
		moveq	#2,d1
		SYSCALL	SetMovePrg

		lea	AuslaufAnimWin(pc),a1

		cmp.b	#HERO_WINS,EndSkate
		beq.s	1$

		lea	AuslaufAnimLoose(pc),a1

1$:		moveq	#2,d0
		SYSCALL	SetAnimPrg

.NotZiel:	movem.l	(sp)+,d0-d7/a0-a6
		rts



EnemyHandler:	movem.l	d0-d7/a0-a6,-(sp)

		move.w	bob_X(a0),d1
		sub.w	#190,d1
		cmp	#ZIEL_X+30,d1
		blo.s	.NotZiel

		clr.l	bob_Handler(a0)
		st.b	EnemyZiel

		cmp.b	#HERO_WINS,EndSkate	* Enemy schon im Ziel ?
		beq.s	.HeroWon

		move.b	#ENEMY_WINS,EndSkate

.HeroWon:	lea	AuslaufMove2(pc),a1
		moveq	#1,d0
		moveq	#2,d1
		SYSCALL	SetMovePrg

		lea	AuslaufAnimWin(pc),a1

		cmp.b	#ENEMY_WINS,EndSkate
		beq.s	1$

		lea	AuslaufAnimLoose(pc),a1

1$:		moveq	#2,d0
		SYSCALL	SetAnimPrg

.NotZiel:	movem.l	(sp)+,d0-d7/a0-a6
		rts



AuslaufAnimWin:	dc.w		11
		ENDE

AuslaufAnimLoose:
		dc.w		10
		ENDE

AuslaufMove1:	RIGHT		50
		POKEB		HeroEnd,1
		ENDE

AuslaufMove2:	RIGHT		50
		POKEB		EnemyEnd,1
		ENDE


HeroSkate:	SETDATA		SkateBob0,SkateBobBase
		SETY		140
		SETX		220
		SETCLIP		0,0,0,0,CLIPF_ALL
		SETANIM		1$
		SETANIMSPEED	4
		SETMOVE		2$
		SETMOVESTEP	1
		SETPRI		32
		SETHANDLER	HeroHandler
		ENDE

1$:		ANIMTO		0,9
		LOOP

2$:		RIGHT		1
		LOOP


EnemySkate:	SETDATA		SkateBob15,SkateBobBase
		SETY		110
		SETX		250
		SETCLIP		0,0,0,0,CLIPF_ALL
		SETANIM		1$
		SETMOVE		2$
		SETHANDLER	EnemyHandler
		ENDE

1$:		ANIMTO		0,9
		LOOP

2$:		SETANIMSPEED	4
		SETMOVESTEP	1
		RIGHT		20

		SETANIMSPEED	3
		SETMOVESTEP	2
		RIGHT		40

		SETANIMSPEED	2
		SETMOVESTEP	3
		RIGHT		80

		SETANIMSPEED	3
		SETMOVESTEP	2
		RIGHT		100

		SETANIMSPEED	2
		SETMOVESTEP	3
		RIGHT		60

		SETANIMSPEED	3
		SETMOVESTEP	2

3$:		RIGHT		1
		GOTO		3$
		ENDE


StarterSkate:	SETDATA		SkateBob12,SkateBobBase
		SETY		90
		SETX		280
		SETCLIP		0,0,0,0,CLIPF_ALL
		SETANIM		1$
		SETANIMSPEED	10
		SETPRI		-32
		ENDE

1$:		ANIMTO		0,2
		ENDE



LevelName:	dc.b	"Level20",0
LevelName6:	dc.b	"Level6",0
CharName:	dc.b	"Char20",0
CharName1:	dc.b	"Char1",0
PanelGameName:	dc.b	"SkatingPanel",0
PanelName:	dc.b	"Panel",0
SkateBobs:	dc.b	"SkaterBobs",0


		SECTION	MyBSS,BSS

OldLevelBase:	ds.l	1
SkateBobBase:	ds.l	1
Starter_Bob:	ds.l	1
Hero_Bob:	ds.l	1
Enemy_Bob:	ds.l	1

Speed:		ds.w	1

EndSkate:	ds.b	1
JoyInfo:	ds.b	2
HeroDirX:	ds.b	1
HeroLastDirX:	ds.b	1
HeroCnt:	ds.b	1
HeroChangeCnt:	ds.b	1
HeroZiel:	ds.b	1
EnemyZiel:	ds.b	1
HeroEnd:	ds.b	1
EnemyEnd:	ds.b	1
