****************************************************************************
**                                                                        **
**       B O B O L  -  The Amiga High Speed Bob Animation System          **
**                                                                        **
****************************************************************************
**                                                                        **
**   Modification History                                                 **
**   --------------------                                                 **
**                                                                        **
**   04-Apr-89  CHH  Created this file from CHW's DrawBob.s               **
**   07-Apr-89  CHH  NORESTORE NODRAW + BACKCLEAR Flags                   **
**   07-Apr-89  CHH  NOLIST                                               **
**   08-Apr-89  CHH  Added BobControlSystem  "BOBOL"                      **
**   08-Apr-89  CHH  RemBob Bug fixed                                     **
**   14-Apr-89  CHH  RemBob Bug 2 fixed                                   **
**   21-Apr-89  CHH  BOBPOKEL Bug fixed                                   **
**   22-May-89  CHW  Bit definitions cleaned up                           **
**   04-Jun-89  CHH  DownClipping                                         **
**   06-Jun-89  CHH  UpClipping LeftClipping RightClipping                **
**   06-Jun-89  CHW  Converted to conform the Exec rules                  **
**   07-Jun-89  CHH  RemAllBobs added                                     **
**   15-Jun-89  CHH  SETCLIPFLAGS+SETORGTAB added                         **
**   19-Jun-89  CHH  CMP/BNE-BOBOL-Wüste durch Tabelle ersetzt.           **
**                     SetMovePrg,SetAnimPrg extern gemacht.              **
**   20-Jun-89  CHH  NewBobStructure durch NewBobPrg ersetzt              **
**   26-Jun-89  CHH  FOR/NEXT added                                       **
**   27-Jun-89  CHH  GlobalClipping added                                 **
**   19-Jul-89  CHH  Local Signals added                                  **
**   27-Jul-89  CHH  KollisionsRectangle added                            **
**   13-Sep-89  CHH  GetBobData extern definiert                          **
**   29-Oct-89  CHH  ADDBOB added                                         **
**   22-Nov-89  CHH  NEWIMAGE added                                       **
**   27-Nov-89  CHH  TestPoint() Collision-Rectangle added                **
**   15-Dec-89  CHH  RNDANIM added                                        **
**   27-Jan-90  CHH  GlobalX added                                        **
**   25-Mar-90  CHH  SETHANDLER added                                     **
**   02-Apr-90  CHH  rechtes Clipping korrigiert                          **
**   02-Apr-90  CHH  Straubs Kollisions-Routine eingebaut                 **
**   02-Apr-90  CHH  WaitBlit() will nun Custom im A5                     **
**   02-Apr-90  CHW  Code gekürzt, verschnellert und aufgeräumt           **
**   29-May-90  CHH  MOVETO eingebaut, MOVESPEED und MOVESTEP sind auf    **
**                   1 initialisiert, Reihenfolge-Bug von SETMOVE und     **
**                     SETMOVESTEP entfernt -> ist jetzt egal             **
**                   FLASH eingebaut                                      **
**   16-Jun-90  CHH  X0 und Y0 in BobStruktur eingebaut, damit alles      **
**                   pure ist                                             **
**   20-Jun-90  RS   TestBehind durch TestBobOverlay ersetzt ->           **
**                     SPECIALDRAW läuft wieder                           **
**   25-Jul-90        CHH  ANIMSPEED werden auf 1 initialisiert           **
**   31-Jul-90  CHH  TripleScreen halb eingebaut                          **
**    2-Aug-90  CHH  SETCONVERT eingebaut                                 **
**    6-Aug-90  CHH  NOANIM eingebaut                                     **
**    8-Aug-90  CHH  ANIMTO    ""                                         **
**   13-Aug-90  CHH  GOTO fuer AddBobPrg eingebaut                        **
**   14-Aug-90  CHH  MAXANIM entfernt -> beliebige Anzahl Bobs            **
**   15-Aug-90  RS   RTS in Function's optimiert                          **
**   18-Aug-90  RS   MAXANIM bug fixed -> clr.l (A3)                      **
**   09-Sep-90  RS   ADDRELBOB added                                      **
**   15-Sep-90  RS   ADDDAUGHTERBOB added                                 **
**   15-Sep-90  CHH  SETIMAGE added                                       **
**   16-Sep-90  CHW  Code cleaned up and optimized, Kollision repariert   **
**   19-Sep-90  RS   Kollision fuer DaughterBobs angepasst                **
**   19-Oct-90  CHH  Joystick-Kommandos eingebaut			  **
**   23-Oct-90  CHH  StatusRegister added                                 **
**   25-Oct-90  CHH  BITTEST/JEQ/JNE/FOREVER eingebaut                    **
**   28-Oct-90  C+R  SETWORD/SETLONG eingebaut. Makros geändert ->        **
**                   alles kürzer,besser,schneller,genialer.              **
**    1-Nov-90  CHH  Joystick-Routine geändert auf JoyBuf                 **
**    2-Nov-90  CHH  SETHANDLER-Funktion durch doppeltes SETLONG-MACRO    **
**                   ersetzt,UserFlags added,ONLYANIM-Flag added          **                                              **
**   21-Nov-90  CHH  RemBob/SpecialDraw-Bug behoben                       **
**   24-Feb-91  CHW  An neues Library-Konzept angepasst                   **
**   28-Feb-91  CHW  Blitter-Arbitration eingebaut                        **
**   10-Apr-91  CHH  SaveMask eingebaut                                   **
**   10-Apr-91  CHH  SaveMask wird jetzt im BitmStr übergeben / JNE und   **
**                   JEQ Sprünge relativ gemacht                          **
**   23-Aug-91  CHH  FlipFlag für AskJoy added                            **
**                                                                        **
**   Benutzung: Einmal 'InitDrawBob' aufrufen  | Parameter: A0=BitMap     **
**                                               Resultat : Nix           **
**                                                                        **
**               'AddBob' ein Bob addieren     | Parameter: A1=InitPrg    **
**                                               Resultat : D0=Bob        **
**                                                                        **
**               'RemBob' ein Bob entfernen    | Parameter: A0=Bob        **
**                                               Resultat : Nix           **
**                                                                        **
**   MainLoop:   'RestoreBobList'              | Parameter: A1=BitMap     **
**                                               Resultat : Nix           **
**                                                                        **
**               'DrawBobList'                 | Parameter: A1=BitMap     **
**                                               Resultat : Nix           **
**                                                                        **
****************************************************************************


BOBVERSION:	EQU	3
BOBREVISION:	EQU	16

		OPT	O+,OW-,O5-,OW6+

		IDNT	Bobol
		SECTION	text,CODE

		INCLUDE	"MyExec.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"hardware/custom.i"
		INCLUDE	"DrawBob.i"

		XREF	_custom,__MyExecBase

		XDEF	InitDrawBob,AddBob,RemBob,RestoreBobList
		XDEF	DrawBobList,RestoreOneBob,DrawOneBob
		XDEF	AnimateOneBob,MoveOneBob,TestPoint
		XDEF	WaitBlit,RemAllBobs,SetAnimPrg,SetMovePrg
		XDEF	SetGlobalClip,GetBobData,GlobalX
		XDEF	HandleCollision,CollOneBob,FlashBob


   STRUCTURE DrawOneBobStackFrame,0

	WORD	sf_Temp1
	WORD	sf_Temp2
	WORD	sf_TempX	; X und Y müssen hintereinander sein!
	WORD	sf_TempY
	WORD	sf_BobOffset
	WORD	sf_BobModulo
	UWORD	sf_FirstMask
	UWORD	sf_LastMask

	LABEL	sf_SIZEOF

;-----------------------------------------------------------------------
; Achtung: Die Befehlstabelle ist rückwärts organisiert, also neue
;          Kommandos hier am Anfang anfügen und nicht beim Label, gell!
;          Die Kommando-Konstanten (BOBLOOP, ...) müssen GERADE sein!
		
		dc.w	JneFunc-BobolTab

		dc.w	JeqFunc-BobolTab
		dc.w	BitTestFunc-BobolTab
		dc.w	TestJoyFunc-BobolTab
		dc.w	AddDaughterFunc-BobolTab
		dc.w	SetRelDataFunc-BobolTab
		
		dc.w	AddRelBobFunc-BobolTab
		dc.w	GotoFunc-BobolTab
		dc.w	AnimToFunc-BobolTab
		dc.w	SetConvertFunc-BobolTab
		dc.w	FlashFunc-BobolTab
		
		dc.w	MoveToFunc-BobolTab
		dc.w	RndAnimFunc-BobolTab
		
		dc.w	AddBobFunc-BobolTab
		dc.w	RndDelayFunc-BobolTab
		dc.w	DelayFunc-BobolTab
		dc.w	LWaitFunc-BobolTab
		dc.w	LSignalFunc-BobolTab

		dc.w	NextFunc-BobolTab
		dc.w	ForFunc-BobolTab
		dc.w	SetIdFunc-BobolTab
		dc.w	SetAnimSpeedFunc-BobolTab
		
		dc.w	SetMoveSpeedFunc-BobolTab
		dc.w	SetDataFunc-BobolTab
		dc.w	SetClipFunc-BobolTab
		dc.w	SetMoveFunc-BobolTab
		
		dc.w	SetAnimFunc-BobolTab
		dc.w	RelMoveFunc-BobolTab
		dc.w	PokeLFunc-BobolTab
		dc.w	PokeWFunc-BobolTab
		dc.w	PokeBFunc-BobolTab

		dc.w	WhileFunc-BobolTab
		dc.w	UntilFunc-BobolTab
		dc.w	CpuJumpFunc-BobolTab
		dc.w	WaitFunc-BobolTab
		dc.w	SignalFunc-BobolTab

		dc.w	SetPriFunc-BobolTab
		dc.w	RemoveFunc-BobolTab
		dc.w	EndeFunc-BobolTab
		dc.w	LoopFunc-BobolTab
		dc.w	SetLongFunc-BobolTab
		dc.w	SetWordFunc-BobolTab

BobolTab:	dc.w	0

;-----------------------------------------------------------------------

	*** A0 : BitMap 

InitDrawBob:	movem.l	d0/a0,-(SP)
		move.w	bm_Pad(a0),d0
		not.w	d0
		move.b	d0,SaveMask
		moveq	#0,d0
		move.b	bm_Depth(a0),d0
		move.w	d0,NumPlanes
		lea	meb_BobList(a6),a0
		jsr	meb_NewList(a6)
		movem.l	(SP)+,d0/a0
		rts

;-----------------------------------------------------------------------

	*** D0: GlobalXClip / D1: GlobalYClip

SetGlobalClip:	movem.w	d0/d1,GlobalXClip
		rts


;-----------------------------------------------------------------------


	*** D0: Länge des Flashes / D1: Farbe des Flashes

FlashBob:	move.b	d0,bob_FlashTime(a0)
		move.b	d1,bob_FlashColor(a0)
		rts

;-----------------------------------------------------------------------

	*** A0: Bob / A1: AnimPrg / D0: Speed

SetAnimPrg:	move.l	a1,bob_AnimPrg(a0)
		clr.w	bob_AnimOffset(a0)
		move.b	d0,bob_AnimSpeed(a0)
		move.b	d0,bob_AnimSpeedCounter(a0)
		subq.b	#1,bob_AnimSpeedCounter(a0)
		clr.w	bob_AnimDelayCounter(a0)
		rts

;-----------------------------------------------------------------------

	*** A0: Bob / A1: MovePrg / D0: Speed / D1: MoveStep

SetMovePrg:	move.l	a1,bob_MovePrg(a0)
		move.b	d0,bob_MoveSpeed(a0)
		move.w	d1,bob_MoveStep(a0)
		clr.w	bob_MoveOffset(a0)
		clr.b	bob_MoveSpeedCounter(a0)
		clr.w	bob_MoveCounter(a0)
		clr.w	bob_MoveCommand(a0)
		clr.w	bob_RelMoveCounter(a0)
		clr.w	bob_MoveDelayCounter(a0)
		rts

;-----------------------------------------------------------------------

	*** A1: NewBob-Programm

AddBob:		movem.l	d1-d7/a0-a6,-(SP)

		cmp.w	#BOBSETDATA,(a1)	; SetData am Anfang ?
		beq.s	1$			; ja --->
		cmp.w	#BOBSETRELDATA,(a1)	; SetRelocData
		beq.s	1$			; ja --->

.Endlos:	move.w	#$f00,$dff180		; ROT
		move.w	#$ff0,$dff180		; GELB
		MSG	<"BadBob (A1)">
		bra.s	.Endlos			; Flacker

1$:		suba.l	a0,a0			; Reloc = 0;

		cmp.w	#BOBSETDATA,(a1)	; Reloc
		beq.s	.NormalAdd		; no -->

		move.l	6(a1),a0		; GetRelocBase
		move.l	(a0),a0			; GetReloc

.NormalAdd:	add.l	2(a1),a0

		move.l	#bob_SIZEOF+8,d0	; jaja
11$:		addq.l	#4,d0
		add.w	bod_TotalSize(a0),a0
		tst.w	bod_Width(A0)
		bmi.s	12$
		btst	#BODB_ANIMKEY,bod_Flags(a0)
		beq.s	11$

12$:		SYSCALL	AllocFastClearMem	; BobStruktur reservieren
		move.l	d0,a0
		moveq.l	#1,d0
		move.b	d0,bob_AnimSpeed(a0)
		move.b	d0,bob_MoveSpeed(a0)
		move.w	d0,bob_MoveStep(a0)
		move.w	#-1,bob_AnimTo(A0)

		move.l	a1,a2			; Zeiger auf NewBobPrg
		moveq.l	#0,d1			; Bobol-PC

2$:		lea	BobolTab(PC),a3		; NewBob-Programm ausführen
		move.w	0(a2,d1.w),d0		; Nächstes Kommando
		or.w	#$ff00,d0
		cmp.w	#BOBENDE,d0		; Ende ?
		beq.s	3$			; ja --->
		adda.w	0(a3,d0.w),a3		; Routinen-Offset dazu

		jsr	(a3)
		bra.s	2$
3$:

gugugu		move.b	bob_NewPri(a0),bob_Priority(a0)
		move.b	#$80,bob_NewPri(a0)

		move.w	bob_Flags(a0),d4

		moveq.l	#-1,d0
		move.l	d0,bob_LastLastOffset(a0)
		move.l	d0,bob_LastOffset(a0)

		move.l	d0,bob_LastImage(a0)

		lea	bob_AnimPtrs(a0),a3	; Animations Array
		move.l	bob_BobData(a0),a2	; Größtes Bob suchen
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
.Loop:		addq.w	#1,d2
		move.l	a2,(a3)+		; Bob ins AnimArray eintragen
		move.w	bod_Width(a2),d0	; Breite des Bobs in Pixel
		bmi.s	.EndLoop		; End-Markierung --->
		addi.w	#15,d0			; aufrunden auf WORD
		lsr.w	#3,d0			; Breite in Bytes
		addq.w	#2,d0			; Breite + 2
		mulu.w	bod_Height(a2),d0	; mal Höhe
		cmp.l	d1,d0			; Ist Bob das grösste ?
		blo.s	6$			; nein --->
		move.l	d0,d1			; sonst übernehmen
6$:		add.w	bod_TotalSize(a2),a2
		btst.b	#BODB_ANIMKEY,bod_Flags(a2)	; Anim fertig ?
		beq.s	.Loop			; nein ---> Loop
.EndLoop:
		clr.l	(a3)			; Endmarkierung im AnimArray

		btst	#BOBB_NORESTORE,d4	; Speicher reservieren ?
		bne.s	2$			; nein --->

		SYSTST.l TripleScreen
		bne.s	2$


		move.w	NumPlanes,d2
		move.w	d2,d3


		subq.w	#1,d3
		move.b	SaveMask,d0
.CLoop:		ror.b	#1,d0
		bcs	.PlaneExists
		subq.w	#1,d2
.PlaneExists:	dbf	d3,.CLoop



		mulu.w	d2,d1			; Länge einer BobPlane*Anzahl Bitmaps des Bildes
		move.l	d1,d0
		add.l	d0,d0			; 2* wegen Double-Buffer
		SYSCALL	AllocMem		; reservieren

		move.l	d0,bob_LastSaveBuffer(a0)
		add.l	d1,d0
		move.l	d0,bob_LastLastSaveBuffer(a0)
2$:
		btst	#BOBB_NOLIST,d4		; Bob in Liste eintragen ?
		bne.s	3$			; nein --->
		movea.l	a0,a1			; Bob
		move.l	a6,-(SP)
		lea	__MyExecBase(PC),a6
		lea	meb_BobList(a6),a0
		jsr	meb_Enqueue(a6)
		movea.l	(SP)+,a6
		movea.l	a1,a0
3$:
		move.l	a0,d0
		movem.l	(SP)+,d1-d7/a0-a6
		rts

;-----------------------------------------------------------------------

	*** A0: Bob to remove

RemBob:		movem.l	d0/a0-a1,-(SP)
		move.l	a0,d0			; Bob gültig ?
		beq.s	4$			; nein --->

		tst.b	bob_RemFlag(a0)
		bne.s	4$

		move.b	#1,bob_RemFlag(a0)
		clr.l	bob_MovePrg(a0)
		clr.l	bob_AnimPrg(a0)
		clr.l	bob_CollHandler(a0)
		clr.w	bob_HitMask(a0)

		move.l	a0,a1			; A1=Bob
1$:		lea	__MyExecBase(PC),a0	; SHIIIT!! 3 TAGE DEBUG...
		lea	meb_BobList(a0),a0
3$:		move.l	bob_NextBob(a0),a0
		tst.l	bob_NextBob(a0)
		beq.s	4$
						; Ist Bob ParentBob des eben
		cmp.l	bob_ParentBob(A0),a1	; gelöschten ? nein -->
		bne.s	3$

		bsr.s	RemBob
		bra.s	3$

4$:		movem.l	(SP)+,d0/a0-a1
		rts

;-----------------------------------------------------------------------

	*** void

RemAllBobs:	move.l	a0,-(SP)
		lea	meb_BobList(a6),a0
1$:		move.l	bob_NextBob(a0),a0
		tst.l	bob_NextBob(a0)
		beq.s	2$
		tst.l	bob_ParentBob(A0)
		bne	1$
		bsr	RemBob
		bra.s	1$
2$:		movea.l	(SP)+,a0
		rts

;-----------------------------------------------------------------------

	*** A1: BitMap, Zeichnet alle Bobs der Liste (rückwärts)

DrawBobList:	movem.l	d0-d7/a0-a6,-(SP)
		lea	_custom,a5
		bsr	AskJoy
		move.w	d0,JoyBuf

.Loop:		lea	__MyExecBase(PC),a0
		lea	meb_BobList(a0),a0		; Zeiger auf erstes Bob

3$:		movea.l	bob_NextBob(a0),a0		; nächstes Bob
		tst.l	bob_NextBob(a0)			; kein Bob mehr ?
		beq.s	TestNewPri
		cmp.b	#3,bob_RemFlag(a0)		; muss Bob enfernt werden
		blt.s	3$				; nein --->
		move.l	a1,-(SP)			; jaja :-( !!
		movea.l	a0,a1				; BobNode
		SYSCALL	Remove				; entfernen
		move.l	bob_LastSaveBuffer(a0),d0
		move.l	bob_LastLastSaveBuffer(a0),d1
		cmp.l	d0,d1
		bhi.s	6$
		move.l	d1,d0
6$:
		move.l	d0,a1				; Save-Buffer
		SYSCALL	FreeMem				; freigeben
		move.l	a0,a1				; Bob
		SYSCALL	FreeMem				; freigeben
		movea.l	(SP)+,a1
		bra.s	.Loop				; Nochmal von vorn


TestNewPri:	tst.b	NewPri
		beq.s	.End
		lea	__MyExecBase(PC),a0
		lea	meb_BobList(a0),a0		; erstes Bob in der Liste
		moveq.l	#0,d7
1$:		movea.l	bob_NextBob(a0),a0		; Zeiger auf nächstes Bob
		tst.l	bob_NextBob(a0)			; Noch ein Bob ?
		beq.s	.End				; nein ---> Ende
		move.b	bob_NewPri(a0),d0
		cmpi.b	#$80,d0				; neue Priorität ?
		beq.s	1$				; nein --->
		move.b	#$80,bob_NewPri(a0)
		move.b	d0,bob_Priority(a0)
		movem.l	a1/a6,-(SP)
		movea.l	a0,a1				; Bob
		lea	__MyExecBase(PC),a6
		jsr	meb_Remove(a6)			; entfernen
		lea	meb_BobList(a6),a0
		jsr	meb_Enqueue(a6)			; und wieder rein
		movem.l	(SP)+,a1/a6
		bra.s	TestNewPri			; ---> Loop
.End:
		clr.b	NewPri

DrawBobs:	lea	__MyExecBase(PC),a0
		lea	meb_BobList+lh_Tail(a0),a0	; letztes Bob der Liste

1$:		movea.l	bob_LastBob(a0),a0		; Zeiger auf nächstes Bob
		tst.l	bob_LastBob(a0)			; kein Bob mehr ?
		beq.s	EndDrawBobList			; wenn ja ---> Ende
		move.w	bob_Flags(A0),d0
		btst	#BOBB_NOANIM,d0
		bne.s	2$
		bsr	AnimateOneBob			; sonst Bob animieren
2$:		move.w	bob_Flags(A0),d0
		btst	#BOBB_NOMOVE,d0
		bne.s	3$
		bsr	MoveOneBob			; bewegen
3$:		bsr	DrawOneBob			; und zeichnen
		bra.s	1$				; ---> Loop
EndDrawBobList:
		movem.l	(SP)+,d0-d7/a0-a6
		rts

;-----------------------------------------------------------------------

	*** A1: BitMap, restauriert alle BobHintergründe

RestoreBobList:	movem.l	a0/a5,-(SP)
		lea	_custom,a5
		lea	__MyExecBase(PC),a0
		lea	meb_BobList(a0),a0	; erstes Bob in der Liste
1$:		movea.l	bob_NextBob(a0),a0	; Zeiger auf nächstes Bob
		tst.l	bob_NextBob(a0)		; kein Bob mehr ?
		beq.s	.End			; wenn ja ---> Ende
		bsr.s	RestoreOneBob		; sonst Hintergrund zeichnen
		bra	1$			; ---> Loop
.End:		movem.l	(SP)+,a0/a5
		rts

;-----------------------------------------------------------------------

	*** A0: Bob, A5: custom

RestoreOneBob:	movem.l	d0-d7/a0-a6,-(SP)

		move.w	bob_Flags(a0),d4
		btst	#BOBB_BACKCLEAR,d4	; BOBF_BACKCLEAR ?
		bne.s	5$			; ja --->
		btst	#BOBB_NORESTORE,d4	; BOBF_NORESTORE ?
		bne	3$			; ja ---> kein Hintergrund restoren
5$:
		btst	#BOBB_NODOUBLE,d4	; BOBF_NODOUBLE ?
		beq.s	6$			; nein --->

		move.w	bob_LastBltSize(a0),bob_LastLastBltSize(a0)      ; nicht double-buffern
		move.l	bob_LastOffset(a0),bob_LastLastOffset(a0)
		move.l	bob_LastSaveBuffer(a0),bob_LastLastSaveBuffer(a0)

6$:		move.l	bob_LastLastSaveBuffer(a0),a3	; A3 : HintergrundBuffer
		move.w	bob_LastLastBltSize(a0),d0	; D0 : BltSize
		beq.s	2$
		move.w	d0,d1
		and.w	#%111111,d1			; Breite des Blits in Words
		add.w	d1,d1				; D1 : jetzt in Bytes
		move.w	bm_BytesPerRow(a1),d2		; Breite des Bildes
		sub.w	d1,d2				; D2 : BildBreite - BlitBreite = Modulo

		moveq	#0,d3
		move.w	d0,d3				; BltSize
		lsr.w	#6,d3				; Höhe des Blits
		mulu	d1,d3				; D3 : PlaneLänge

		move.b	SaveMask,d7
		moveq	#0,d4
		move.b	bm_Depth(a1),d4			; D4 : Anzahl Planes
		subq	#1,d4				; für dbf

		move.l	bob_LastLastOffset(a0),d5 	; D5 :  XY Offset
		cmp.l	#-1,d5
		beq.s	2$				; negativ? -> nicht restoren

		lea	bm_Planes(a1),a6		; A6 : Zeiger auf Planes


		SYSGET.l TripleScreen,d1
		beq.s	.Normal
		move.l	d1,a3
		add.w	#bm_Planes,a3

		bsr	TripleRestore
		bra	2$


.Normal:	bsr	RestoreItNormal

2$:		move.w	bob_LastBltSize(a0),bob_LastLastBltSize(a0)
		move.l	bob_LastOffset(a0),bob_LastLastOffset(a0)
		move.l	bob_LastLastSaveBuffer(a0),d0
		move.l	bob_LastSaveBuffer(a0),bob_LastLastSaveBuffer(a0)
		move.l	d0,bob_LastSaveBuffer(a0)

3$:		movem.l	(SP)+,d0-d7/a0-a6
		rts



RestoreItNormal:
		SYSCALL	OwnBlitter
1$:		bsr	WaitBlit
		move.l	a3,bltapt(a5)			; Source A
		move.l	(a6)+,d6			; Ziel
		ror.b	d7
		bcc.s	.NextPlane		

		add.l	d5,d6				; + Offset
		move.l	d6,bltdpt(a5)			; Dest D
		move.l	#-1,bltafwm(a5)			; First+LastWordMask
		moveq	#0,d6
		move.w	d6,bltcon1(a5)			; BltCon1
		move.w	d6,bltamod(a5)			; QuellModulo
		move.w	#$09f0,bltcon0(a5)		; D = A

		move.w	bob_Flags(a0),d6
		btst	#BOBB_BACKCLEAR,d6		; BOBF_BACKCLEAR ?
		beq.s	4$				; nein ->
		move.w	#$0100,bltcon0(a5)		; sonst Hintergrund nur löschen
4$:		move.w	d2,bltdmod(a5)			; ZielModulo

		move.w	d0,bltsize(a5)			; Blit starten!
		add.w	d3,a3				; PlaneLänge zum Source addieren
.NextPlane:	dbf	d4,1$
		SYSCALL	DisownBlitter
		rts




TripleRestore:
		SYSCALL	OwnBlitter
1$:		bsr	WaitBlit
		move.l	(A3)+,d6			; Hintergrund
		add.l	d5,d6				; + Offset =
		move.l	d6,bltapt(a5)			; Source A
		move.l	(a6)+,d6			; Ziel
		add.l	d5,d6				; + Offset
		move.l	d6,bltdpt(a5)			; Dest D
		move.l	#-1,bltafwm(a5)			; First+LastWordMask
		moveq	#0,d6
		move.w	d6,bltcon1(a5)			; BltCon1
		move.w	#$09f0,bltcon0(a5)		; D = A

		move.w	bob_Flags(a0),d7
		btst	#BOBB_BACKCLEAR,d7		; BOBF_BACKCLEAR ?
		beq.s	4$				; nein ->
		move.w	#$0100,bltcon0(a5)		; sonst Hintergrund nur löschen
4$:		move.w	d2,bltdmod(a5)			; ZielModulo
		move.w	d2,bltamod(A5)

		move.w	d0,bltsize(a5)			; Blit starten!
		dbf	d4,1$
		SYSCALL	DisownBlitter
		rts



;-----------------------------------------------------------------------

	*** A0: Bob

AnimateOneBob:	bsr	GetBobData
		move.l	bod_CollX0(a2),bob_CollX0(a0)	; X0.W und Y0.W
		move.l	bod_CollX1(a2),bob_CollX1(a0)	; X1.W und Y1.W

		movea.l	bob_AnimPrg(a0),a2		; Animationsprogram
		move.l	a2,d0				; vorhanden ?
		beq	.End				; nein ---> Exit
		addq.b	#1,bob_AnimSpeedCounter(a0)	; Zähler erhöhen
		move.b	bob_AnimSpeedCounter(a0),d0	; Limit
		cmp.b	bob_AnimSpeed(a0),d0		; erreicht ?
		bne	.End				; nein ---> exit

;		tst.b	bob_TraceMode(A0)
;		beq.s	.AnimRepeat

;		clr.b	bob_AnimSpeedCounter(a0)	; Zähler löschen

;		tst.b	bob_TraceLock(A0)
;		bne.s	.End
;		st.b	bob_TraceLock(A0)

.AnimRepeat:	clr.b	bob_AnimSpeedCounter(a0)	; Zähler löschen
		tst.w	bob_AnimDelayCounter(a0)
		beq.s	1$
		subq.w	#1,bob_AnimDelayCounter(a0)
		bra	.End

1$:		move.w	bob_AnimTo(a0),d1
		bmi.s	11$

		move.w	bob_Image(a0),d2
		cmp.w	d1,d2
		beq.s	12$				; ende ? -> nein

		blt.s	13$


		subq.w	#1,bob_Image(a0)
		bra.s	.End


13$:		addq.w	#1,bob_Image(a0)
		bra.s	.End


12$:		move.w	#-1,bob_AnimTo(a0)


11$:		move.w	bob_AnimOffset(a0),d1		; Offset ins Prg
		move.l	bob_AnimPrg(a0),a2
		move.w	0(a2,d1.w),d0			; Kommando holen
		bmi.s	.AnimCommand			; wenn negativ -> Kommando
		cmp.b	#BOBSETWORD,d0
		beq.s	.AnimCommand
		cmp.b	#BOBSETLONG,d0
		beq.s	.AnimCommand
		

		move.l	bob_ConvertTab(a0),d4
		beq.s	2$
		move.l	d4,a3
		mulu	bob_ConvertSize(a0),d0
		add.w	bob_ConvertOffset(a0),d0
		move.w	(a3,d0.w),d0


2$:		move.w	d0,bob_Image(a0)		; sonst als BobNummer eintragen
		addq.w	#2,bob_AnimOffset(a0)		; Offset erhöhen
		bra.s	.End

.AnimCommand:
		or.w	#$ff00,d0
		lea	BobolTab(PC),a3
		adda.w	0(a3,d0.w),a3
		lea	bob_AnimForCounter(a0),a4
		lea	bob_AnimDelayCounter(a0),a6

		jsr	(a3)				; Ausführen MARSCH!

		move.w	d1,bob_AnimOffset(a0)		; Neuer 'PC'
		tst.b	d0				; Weitermachen ?
		beq	.AnimRepeat			; ja ---> Loop
.End:		rts

;-----------------------------------------------------------------------

	*** A0: Bob

MoveOneBob:	move.l	bob_MovePrg(a0),a2		; MovePrg
		move.l	a2,d0				; vorhanden ?
		beq	EndMoveOneBob			; nein ->

		move.w	bob_Flags(a0),d0
		addq.b	#1,bob_MoveSpeedCounter(a0)	; SpeedZähler erhöhen
		move.b	bob_MoveSpeedCounter(a0),d0	; auslesen
		cmp.b	bob_MoveSpeed(a0),d0		; Limit erreicht
		bne	EndMoveOneBob			; nein ->
MoveRepeat:	clr.b	bob_MoveSpeedCounter(a0)	; Counter löschen
		tst.w	bob_MoveDelayCounter(a0)
		beq.s	0$
		subq.w	#1,bob_MoveDelayCounter(a0)
		bra	EndMoveOneBob

0$:		move.w	bob_MoveStep(a0),d2
		bra.s	2$
1$:		tst.w	bob_RelMoveCounter(a0)
		beq.s	NoRelMove

		move.w	bob_MoveOffset(a0),d1
		movem.w	0(a2,d1.w),d0/d1		; X/Y-Move-Deltas
		move.w	bob_Flags(a0),d3
		btst	#BOBB_FLIPXMOVE,d3		; BOBF_FLIPXMOVE
		beq.s	11$
		neg.w	d0
11$:		btst	#BOBB_FLIPYMOVE,d3		; BOBF_FLIPYMOVE
		beq.s	22$
		neg.w	d1
22$:
		add.w	d0,bob_X(a0)
		add.w	d1,bob_Y(a0)

		addq.w	#4,bob_MoveOffset(a0)
		subq.w	#4,bob_RelMoveCounter(a0)
2$:		dbf	d2,1$
		bra	EndMoveOneBob


NoRelMove:	tst.w	bob_MoveToSteps(A0)
		beq.s	.NoMoveToMoves

		subq.w	#1,bob_MoveToSteps(a0)
		move.w	bob_MoveToX(A0),d0
		add.w	bob_MoveToXStep(a0),d0
		move.w	d0,bob_MoveToX(a0)
		asr.w	#4,d0
		move.w	d0,bob_X(a0)

		move.w	bob_MoveToY(A0),d0
		add.w	bob_MoveToYStep(a0),d0
		move.w	d0,bob_MoveToY(a0)
		asr.w	#4,d0
		move.w	d0,bob_Y(a0)
		bra	EndMoveOneBob

.NoMoveToMoves:
		tst.w	bob_MoveCounter(a0)		; neues Kommando holen
		beq.s	GetNewMoveCommand		; ja ->
		subq.w	#1,bob_MoveCounter(a0)		; KommandoZähler subtrahieren
		move.w	bob_MoveCommand(a0),d1		; aktuelles Kommando holen
		move.w	bob_MoveStep(a0),d2		; Geschwindigkeit
		move.w	bob_Flags(a0),d3
		btst	#BOBB_FLIPXMOVE,d3		; BOBF_FLIPXMOVE
		beq.s	5$
		neg.w	d2
5$:		btst	#BOBB_FLIPYMOVE,d3		; BOBF_FLIPYMOVE
		beq.s	6$
		neg.w	d2
6$:
		btst	#0,d1				; BOBLEFT ?
		beq.s	1$
		sub.w	d2,bob_X(a0)
1$:
		btst	#1,d1				; BOBRIGHT ?
		beq.s	2$
		add.w	d2,bob_X(a0)
2$:
		btst	#2,d1				; BOBUP ?
		beq.s	3$
		sub.w	d2,bob_Y(a0)
3$:
		btst	#3,d1				; BOBDOWN ?
		beq.s	4$
		add.w	d2,bob_Y(a0)
4$:
		bra.s	EndMoveOneBob

GetNewMoveCommand:
		move.w	bob_MoveOffset(a0),d1
		move.w	0(a2,d1.w),d0
		bmi.s	1$
		cmp.b	#BOBSETWORD,d0
		beq.s	1$
		cmp.b	#BOBSETLONG,d0
		beq.s	1$

		addq.w	#4,bob_MoveOffset(a0)
		move.w	d0,bob_MoveCommand(a0)		; aktuelles Kommando setzen
		move.w	2(a2,d1.w),bob_MoveCounter(a0)	; WiederholungsZähler setzen
		bra	MoveRepeat

1$:
		or.w	#$ff00,d0
		lea	BobolTab(PC),a3
		adda.w	0(a3,d0.w),a3
		lea	bob_MoveForCounter(a0),a4
		lea	bob_MoveDelayCounter(a0),a6

		jsr	(a3)				; Bobol-Kommando aufrufen

		move.w	d1,bob_MoveOffset(a0)
		tst.w	d0
		beq	MoveRepeat
EndMoveOneBob:
		rts

;-----------------------------------------------------------------------

	*** D0: X, D1: Y	-> D0: Bob das hier liegt oder 0

TestPoint:	movem.l	d1-d7/a0-a6,-(SP)
		lea	__MyExecBase(PC),a0
		lea	meb_BobList(a0),a0		; erstes Bob in der Liste
		moveq	#0,d7
1$:		move.l	bob_NextBob(a0),a0		; Zeiger auf nächstes Bob
		tst.l	bob_NextBob(a0)			; kein Bob mehr ?
		beq.s	EndTestPoint			; wenn ja -> Ende
		move.w	bob_Flags(a0),d6
		tst.b	bob_RemFlag(a0)
		bne.s	1$

		btst	#BOBB_NOCOLLISION,d6		; BOBF_NOCOLLISION ?
		bne.s	1$				; nein ->

		bsr.s	TestOneBobPoint			; sonst Bob testen
		beq.s	1$				; Loop ->
EndTestPoint:
		move.l	d7,d0
		movem.l	(SP)+,d1-d7/a0-a6
		rts

TestOneBobPoint:
		movem.l	d0-d6/a0-a6,-(SP)
		moveq.l	#0,d7
		bsr.s	GetBobData

		move.w	bob_AbsX(a0),d2
		move.w	d2,d3
		add.w	bod_CollX0(a2),d2
		add.w	bod_CollX1(a2),d3
		cmp.w	d0,d2			; ist Test X kleiner Bob X1 ?
		bgt.s	9$			; nein -> Ende
		cmp.w	d0,d3			; ist Test X grösser Bob X2 ?
		blt.s	9$			; nein -> Ende

78$:		move.w	bob_AbsY(a0),d2
		move.w	d2,d3
		add.w	bod_CollY0(a2),d2
		add.w	bod_CollY1(a2),d3
		cmp.w	d1,d2			; ist Test Y kleines Bob Y1 ?
		bgt.s	9$			; Nein -> Ende
		cmp.w	d1,d3			; ist Test Y grösser Bob Y2
		blt.s	9$			; nein -> Ende
		move.l	a0,d7
9$:
		movem.l	(SP)+,d0-d6/a0-a6
		tst.l	d7
		rts

;-----------------------------------------------------------------------

	*** A0: Bob -> A2: BobData

GetBobData:	movem.l	d0/d1/a1,-(SP)
		move.w	bob_Image(a0),d0
		lsl.w	#2,d0
		lea	bob_AnimPtrs(a0),a2
		movea.l	0(a2,d0.w),a2
		move.l	bod_X0(a2),bob_X0(a0)		; X0.W und Y0.W
		movea.l	bob_OrgTab(a0),a1
		move.l	a1,d1				; Keine OrgTab --->
		beq.s	1$
		move.l	0(a1,d0.w),bob_X0(a0)		; X0.W und Y0.W
1$:
		movem.l	(SP)+,d0/d1/a1
		rts

;-----------------------------------------------------------------------

	*** A0: Bob -> bob_AbsX & bob_AbsY berechnen aus ParentBobs

GetAbsKoords:	movem.l	d2/a1-a2,-(SP)
		movem.w	bob_X(a0),d0/d1			; X und Y holen
		movea.l	a0,a1				; a1=Bob

.NextParentBob:	move.l	bob_ParentBob(a1),d2		; Existiert ein ParentBob ?
		beq.s	1$				; nein ---> Fertig
		movea.l	d2,a1				; a2=ParentBob
		add.w	bob_X(a1),d0			; add XPos
		add.w	bob_Y(a1),d1			; add YPos
		bra.s	.NextParentBob			; ---> Loop
1$:
		movem.w	d0/d1,bob_AbsX(a0)		; AbsX und AbsY
		movem.l	(SP)+,d2/a1-a2
		rts

;-----------------------------------------------------------------------

	*** A0: Bob, Hintergrund retten und Bob in die BitMap zeichnen

DrawOneBob:	movem.l	d0-d7/a0-a6,-(SP)
		SYSCALL	OwnBlitter

		lea	-sf_SIZEOF(SP),SP	; StackFrame erstellen
		lea	_custom,a5

		clr.w	sf_LastMask(SP)
		bsr	GetAbsKoords		; Koordinaten umrechnen
		bsr	GetBobData		; BobDaten ins A2 holen

		move.w	bob_Flags(a0),d7

		move.l	bob_Handler(a0),d0
		beq.s	.NoHandler
		movea.l	d0,a3
		move.l	bob_HandlerD0(a0),d0
		movem.l	d0-d7/a0-a6,-(SP)
		jsr	(a3)			; Handler aufrufen
		movem.l	(SP)+,d0-d7/a0-a6
.NoHandler:
		move.w	bob_Flags(a0),d7


		tst.b	bob_RemFlag(a0)		; muss Bob entfernt werden
		beq.s	5$			; nein ->
		addq.b	#1,bob_RemFlag(a0)	; Zähler addieren
5$:		btst	#BOBB_SPECIALDRAW,d7	; BOBF_SPECIALDRAW ?
		beq.s	1$			; nein --->
		bsr	TestBobOverlay		; liegt ein Bob hinter akt Bob ?
		or.w	#BOBF_HIDDEN,bob_Flags(a0)
		tst.l	d7
		beq	EndDrawOneBob		; nein -> akt Bob nicht zeichnen
1$:
		and.w	#~BOBF_HIDDEN,bob_Flags(a0)
		move.w	bob_Flags(a0),d7
		btst	#BOBB_NEWIMAGE,d7
		beq.s	0$
		move.w	bob_LastLastImage(a0),d7
		cmp.w	bob_Image(a0),d7
		beq	EndDrawOneBob
		move.w	bob_LastImage(a0),bob_LastLastImage(a0)
		move.w	bob_Image(a0),bob_LastImage(a0)
0$:
		movem.w	bob_AbsX(a0),d0/d1	; AbsX und AbsY holen
		add.w	GlobalX,d0

		sub.w	bob_X0(a0),d0		; X -= Nullpunkt
		sub.w	bob_Y0(a0),d1		; Y -= Nullpunkt

		movem.w	d0/d1,sf_TempX(SP)	; TempX & TempY

		move.w	d0,d4			; XPos nach D4 für Feinbest.
		ror.w	#4,d4			; in Bits 12-15 schieben
		andi.w	#$f000,d4		; D4 :  Shift-Value
		asr.w	#4,d0			; XPos / 8  -> Bytes
		add.w	d0,d0			; Nur gerade Adressen
		ext.l	d0

		muls.w	bm_BytesPerRow(a1),d1	; aus YPos wird Y-Offset
		add.l	d0,d1			; Plus XPos = Dest.-Offset

		move.w	bod_WordSize(a2),d3	; Bob-Breite+1 in Words
		move.w	bod_Height(a2),d2	; Bob-Höhe in Lines
		lsl.w	#6,d2			; Höhe nach Bits 15-6
		or.w	d3,d2			; D2 : BltSize

		move.w	d2,sf_Temp1(SP)
		move.w	d3,sf_Temp2(SP)

		clr.w	sf_BobOffset(SP)
		clr.w	sf_BobModulo(SP)
		move.w	#-1,sf_FirstMask(SP)

		move.w	bob_ClipFlags(a0),d7
		btst	#CLIPB_DOWN,d7
		beq.s	11$

		move.w	sf_TempY(SP),d6
		move.w	bob_ClipY2(a0),d3	; untere Grenze
		btst	#CLIPB_GLOBAL,d7
		beq.s	55$
		add.w	GlobalYClip(PC),d3
55$:
		lsr.w	#6,d2			; Höhe des Bobs
		add.w	d2,d6			; untere Grenze des Bobs
		sub.w	d3,d6			; BobUnten - UnterGrenze
		bmi.s	11$			; wenn minus -> nicht clippen
		clr.w	sf_Temp1(SP)
		move.w	bod_Height(a2),d2
		sub.w	d6,d2
		beq.s	11$
		bmi.s	11$
		lsl.w	#6,d2
		move.w	bod_WordSize(a2),d3
		or.w	d3,d2
		move.w	d2,sf_Temp1(SP)
11$:
		btst	#CLIPB_UP,d7
		beq.s	2$

		move.w	sf_Temp1(SP),d2		; BltSize
		beq.s	2$			; wenn NULL ->
		move.w	sf_TempY(SP),d6		; Bob Y
		move.w	bob_ClipY(a0),d3	; Obere ClipGrenze
		btst	#CLIPB_GLOBAL,d7
		beq.s	66$
		add.w	GlobalYClip(PC),d3
66$:
		sub.w	d6,d3			; um wieviel muss geklipt werden
		bmi.s	2$			; um nichts ->
		clr.w	sf_Temp1(SP)		; altes bltsize loeschen
		move.w	d2,d6
		lsr.w	#6,d6			; D6 : alte Hoehe
		sub.w	d3,d6			; Anzahl Linien die nicht gezeichnet werden
		bmi.s	2$
		beq.s	2$
		lsl.w	#6,d6
		move.w	bod_WordSize(a2),d2
		or.w	d6,d2			; D2 : neues BltSize
		move.w	d2,sf_Temp1(SP)
		move.w	d3,d5			; ClipLinien
		muls.w	bm_BytesPerRow(a1),d5	; * Breite
		add.l	d5,d1			; D1 : neuer ZielOffset

		move.w	bod_WordSize(a2),d5
		subq.w	#1,d5
		add.w	d5,d5			; D5 : breite des Bobs in Bytes
		mulu	d3,d5
		add.w	d5,sf_BobOffset(SP)
2$:
		btst	#CLIPB_LEFT,d7
		beq.s	3$

		move.w	sf_Temp1(SP),d2		; D2 : BltSize
		beq.s	3$

		move.w	sf_TempX(SP),d5
		asr.w	#3,d5
		and.w	#~1,d5			; D5 : X Position in geraden bytes

		move.w	bob_ClipX(a0),d6
		btst	#CLIPB_GLOBAL,d7
		beq.s	33$
		add.w	GlobalXClip(PC),d6
33$:
		asr.w	#3,d6
		and.w	#~1,d6			; D6 : ClipX Position in geraden bytes

		sub.w	d5,d6			; D6 : Anzahl der zu clipenden Bytes
		bmi.s	3$			; wenn kein ->
		clr.w	sf_Temp1(SP)		; altes BltSize loeschen

		move.w	d2,d3
		and.w	#%111111,d3
		add.w	d3,d3			; D3 : Breite des Blits in Bytes
		sub.w	d6,d3			; Breite - ClipSize
		ble.s	3$			; bob ganz weg

		ext.l	d6
		add.w	d6,sf_BobModulo(SP)
		add.l	d6,d1
		add.w	d6,sf_BobOffset(SP)

		lsr.w	#1,d3
		move.w	d3,sf_Temp2(SP)

		and.w	#~%111111,d2
		or.w	d3,d2
		move.w	d2,sf_Temp1(SP)

		move.w	sf_TempX(SP),d3
		and.w	#$f,d3
		eor.w	#$f,d3
		add.w	d3,d3
		lea	ClipMasks(PC),a3
		move.w	0(a3,d3.w),sf_FirstMask(SP)


3$:		btst	#CLIPB_RIGHT,d7
		beq	4$

		move.w	bob_ClipX2(a0),d5
		btst	#CLIPB_GLOBAL,d7
		beq.s	44$
		add.w	GlobalXClip(PC),d5
44$:
		asr.w	#3,d5
		and.w	#~1,d5			; D5 : ClipX2 in bytes

		move.w	sf_TempX(SP),d6
		and.w	#~15,d6

		move.w	bod_Width(a2),d0
		add.w	#15,d0
		and.w	#~15,d0
		add.w	d0,d6
		asr.w	#3,d0
		move.w	d0,Width

		asr.w	#3,d6			; D6 : BobX2 in Bytes

		sub.w	d5,d6			; D6 : Anzahl zu clippende Bytes
		bmi.s	4$

		move.w	sf_Temp1(SP),d2		; D2 : letztes BltSize
		clr.w	sf_Temp1(SP)
		move.w	d2,d3
		and.w	#%111111,d3
		add.w	d3,d3
		sub.w	d6,d3
		ble.s	4$


		lsr.w	#1,d3			; D3 : zu clippende Words
		move.w	d3,sf_Temp2(SP)		; retten
		and.w	#~%111111,d2		; D2 : BltSize-Höhe
		or.w	d3,d2			; D2 : neues BltSize
		move.w	d2,sf_Temp1(SP)		; retten
		add.w	sf_BobModulo(SP),d6
		addq.w	#2,d6
		move.w	d6,sf_BobModulo(SP)
		subq.w	#1,d3
		move.w	d3,sf_Temp2(SP)

		move.w	d2,d6
		and.w	#%111111,d6
		subq.w	#1,d6
		bne.s	100$
101$:		clr.w	d2
		bra.s	102$
100$:		bmi	101$

		and.w	#~%111111,d2
		or.w	d6,d2

102$:		move.w	d2,sf_Temp1(SP)


		move.w	sf_TempX(SP),d3
		and.w	#$f,d3
		eor.w	#$f,d3
		add.w	d3,d3
		lea	ClipMasks(PC),a3
		move.w	0(a3,d3.w),d3
		not.w	d3
		move.w	d3,sf_LastMask(SP)


4$:		movem.w	sf_Temp1(SP),d2/d3	; Temp1 und Temp2
		move.w	bob_Flags(a0),d0
		btst	#BOBB_VHALF,d0
		beq.s	.NoVHalf
		move.w	d2,d0
		and.w	#%1111111111000000,d0
		lsr.w	#1,d0
		and.w	#%1111111111000000,d0
		btst	#6,$bfe001
		bne	.NoMo
		jsr	$fc2ffa
.NoMo
		and.w	#%0000000000111111,d2
		or.w	d0,d2

.NoVHalf:	move.w	d2,bob_LastBltSize(a0)	; BltSize für Restore retten
		move.l	d1,bob_LastOffset(a0)	; ZielOffset für Restore retten


		move.w	bm_BytesPerRow(a1),d0	; Bildbreite in Bytes, even!
		add.w	d3,d3			; Bob-Breite+1 (Bytes, even)
		sub.w	d3,d0			; Bildbreite - Bobbreite = Modulo




DrawIt:		move.w	bob_Flags(a0),d7
		btst	#BOBB_NORESTORE,d7	; BOBF_NORESTORE ?
		bne.s	9$			; wenn ja -> kein Hintergrund speichern

		SYSTST.l TripleScreen		; Wenn TrippleScreen gestetzt
		bne.s	9$			; kein Hintergrund rettten


	*******   Jetzt Hintergrund retten   ******

		tst.w	d2			; BltSize = NULL ?
		beq.s	11$			; wenn ja -> nichts retten

		move.b	SaveMask,d3
		moveq	#0,d5
		move.b	bm_Depth(a1),d5		; Anzahl Planes
		subq	#1,d5			; für dbf
		move.l	bob_LastSaveBuffer(a0),a3  ; SaveBuffer

		bsr	WaitBlit
		move.l	a3,bltdpt(a5)		; Ziel setzen
		lea	bm_Planes(a1),a3

0$:		move.l	(a3)+,a6		; Zeiger auf BildBitMaps
		ror.b	d3
		bcc.s	.NextPlane
		add.l	d1,a6			; + Offset
		move.l	a6,bltapt(a5)		; Quelle A setzen
		clr.w	bltcon1(a5)		; BltCon1
		move.w	#$09f0,bltcon0(a5)	; BltCon0 D = A
		move.l	#-1,bltafwm(a5)		; First+LastWordMask
		move.w	d0,bltamod(a5)		; Modulo A
		clr.w	bltdmod(a5)		; Modulo D
		move.w	d2,bltsize(a5)		; Blit starten
		bsr	WaitBlit		; auf Blitter warten
.NextPlane:	dbf	d5,0$			; nächste Plane


9$:
		bsr	WaitBlit		; Jetzt Bob ins Bild zeichnen

11$:		tst.b	bob_RemFlag(a0)
		bne	EndDrawOneBob

		btst	#BOBB_NODRAW,d7		; BOBF_NODRAW ?
		bne	EndDrawOneBob		; ja ->



		tst.w	d2
		beq	EndDrawOneBob
		move.w	bob_Flags(a0),d7

		move.w	d0,bltcmod(a5)		; Source C (=Bild) Modulo
		move.w	d0,bltdmod(a5)		; Destination Modulo
		move.w	sf_BobModulo(SP),d0
		subq.w	#2,d0

		btst	#BOBB_VHALF,d7
		beq.s	.NoVHalf		
		add.w	Width,d0
.NoVHalf:	move.w	d0,bltamod(a5)		; Masken-Modulo   := -2
		move.w	d0,bltbmod(a5)		; Bob-Data-Modulo := -2
		move.w	sf_FirstMask(SP),bltafwm(a5)
		move.w	sf_LastMask(SP),bltalwm(a5)

		moveq	#0,d5
		moveq	#0,d6
		move.b	bod_PlanePick(a2),d5	; D5 :  PlanePick
		move.b	bod_PlaneOnOff(a2),d6	; D6 :  PlaneOnOff

		tst.b	bob_FlashTime(a0)
		beq.s	.NoFlash
		subq.b	#1,bob_FlashTime(a0)
		moveq.l	#0,d5
		move.b	bob_FlashColor(a0),d6
.NoFlash:


		move.w	bod_PlaneSize(a2),d0	; D0 :  Bob-PlaneSize
		lea	bod_Images(a2),a0	; A0 :  Maske
		lea	0(a0,d0.w),a6		; A6 :  1. Bob-Plane
		move.w	d0,sf_Temp1(SP)
		add.w	sf_BobOffset(SP),a6
		add.w	sf_BobOffset(SP),a0
		lea	bm_Planes(a1),a2	; A2 : Dest. Planes-Base

	*** Vorhandene Bob-Planes ins Bild hineinkopieren

		move.w	d4,bltcon1(a5)		; Source B Shift value


		moveq	#0,d0			; Plane-Counter
1$:		movea.l	(a2)+,a3		; nächste Destination-Plane
		adda.l	d1,a3			; += Bob-Position
		move.w	d4,d3			; Shift-value für bltcon0
		btst	d0,d5			; Gibt's Daten für diese Plane?
		bne.s	3$			; ja --->
		btst	d0,d6			; Plane setzen oder löschen?
		bne.s	2$			; setzen --->    _
		ori.w	#$b0a,d3		; Minterm:  D := AC
		bra.s	4$			; --->
2$:		ori.w	#$bfa,d3		; Minterm:  D := A+C
		bra.s	4$			; --->
3$:		ori.w	#$fca,d3		; Minterm:  cookie-cut
4$:		bsr.s	WaitBlit
		move.l	a6,bltbpt(a5)		; Source B: Bob-Planes
		btst	#4,d7			; BOBF_NOCUT in bob_Flags ?
		beq.s	6$
		move.w	#-1,bltadat(a5)		; Maske setzen
		and.w	#~$800,d3		; Source A auschalten
6$:
		move.l	a0,bltapt(a5)		; Blitter Source A : Maske
		move.l	a3,bltcpt(a5)		; = Source C (Hintergrund)
		move.l	a3,bltdpt(a5)		; = Destination
		move.w	d3,bltcon0(a5)
		move.w	d2,bltsize(a5)		; Blit starten !!!

		btst	d0,d5
		beq.s	7$
		adda.w	sf_Temp1(SP),a6
7$:		addq.w	#1,d0
		cmp.b	bm_Depth(a1),d0
		blt	1$

EndDrawOneBob:	lea	sf_SIZEOF(SP),SP	; StackFrame aufräumen

		SYSCALL	DisownBlitter

		movem.l	(SP)+,d0-d7/a0-a6
		rts

;-----------------------------------------------------------------------

	*** A5: custom

WaitBlit:	btst	#6,dmaconr(a5)
1$:		btst	#6,dmaconr(a5)
		bne.s	1$
		rts

;-----------------------------------------------------------------------

	*** void

HandleCollision:
		movem.l	d0-d7/a0-a6,-(SP)
		lea	meb_BobList(a6),a0
.MainBobLoop:	move.l	bob_NextBob(a0),a0
		tst.l	bob_NextBob(a0)			; A0=Kollision
		beq.s	.EndMainLoop			; auslösendes Bob

		bsr	GetAbsKoords
		bsr.s	CollOneBob
		bra.s	.MainBobLoop

.EndMainLoop:	movem.l	(SP)+,d0-d7/a0-a6
		rts

;-----------------------------------------------------------------------

	*** A0: Bob

CollOneBob:	movem.l	d0-d7/a0-a6,-(SP)
		move.w	bob_HitMask(a0),d0		; Bob löst keine
		beq.s	.EndMainLoop			; Kollision aus

		movem.w	bob_CollX0(a0),d0-d3		; Koordinaten
		add.w	bob_AbsX(a0),d0
		add.w	bob_AbsY(a0),d1
		add.w	bob_AbsX(a0),d2
		add.w	bob_AbsY(a0),d3			; SourceBob

		lea	__MyExecBase(PC),a1
		lea	meb_BobList(a1),a1

.BobLoop:	move.l	bob_NextBob(a1),a1
		tst.l	bob_NextBob(a1)			; A1=Kollision
		beq.s	.EndMainLoop			; einfangendes Bob

		cmp.l	a0,a1				; Keine Kollision
		beq.s	.BobLoop			; mit sich selber

		move.w	bob_HitMask(a0),d4		; HitMask
		move.w	bob_MeMask(a1),d5		; MeMask
		and.w	d4,d5				; nicht über-
		beq.s	.BobLoop			; einstimmend -->

		movem.w	bob_CollX0(a1),d4-d7
		add.w	bob_AbsX(a1),d4
		add.w	bob_AbsY(a1),d5
		add.w	bob_AbsX(a1),d6			; Koordinaten
		add.w	bob_AbsY(a1),d7			; ZielBob

		cmp.w	d2,d4
		bgt.s	.BobLoop
		cmp.w	d0,d6
		blt.s	.BobLoop
		cmp.w	d3,d5
		bgt.s	.BobLoop
		cmp.w	d1,d7
		blt.s	.BobLoop

.Coll:		move.l	bob_CollHandler(a1),d4		; KollisionsHandler
		beq.s	.BobLoop			; nicht vorhanden -->

		movem.l	d0-d7/a0-a6,-(SP)		; Zur Sicherheit
		move.l	d4,a2
		jsr	(a2)				; Handler Starten
		movem.l	(SP)+,d0-d7/a0-a6		; Zur Sicherheit
		bra.s	.BobLoop

.EndMainLoop:	movem.l	(SP)+,d0-d7/a0-a6
		rts

;-----------------------------------------------------------------------

	*** Kollisionstest ohne CollisionRectangle

TestBobOverlay:	movem.l	d0-d6/a0-a2,-(SP)

		bsr	GetBobData
		movem.w	bob_AbsX(a0),d0/d1		; AbsX und AbsY
		sub.w	bob_X0(a0),d0
		sub.w	bob_Y0(a0),d1
		move.w	d0,d2
		move.w	d1,d3
		add.w	bod_Width(a2),d2
		add.w	bod_Height(a2),d3

		lea	__MyExecBase(PC),a1
		lea	meb_BobList(a1),a1

.BobLoop:	move.l	bob_NextBob(a1),a1
		tst.l	bob_NextBob(a1)			; A1=Kollision
		beq.s	.EndMainLoop			; einfangendes Bob

		cmp.l	a0,a1				; Keine Kollision
		beq.s	.BobLoop			; mit sich selber

		move.l	a0,-(SP)
		move.l	a1,a0
		bsr	GetBobData
		movem.w	bob_AbsX(a0),d4/d5		; AbsX und AbsY
		sub.w	bob_X0(a0),d4
		sub.w	bob_Y0(a0),d5
		move.w	d4,d6
		move.w	d5,d7
		add.w	bod_Width(a2),d6
		add.w	bod_Height(a2),d7
		move.l	(SP)+,a0

		cmp.w	d2,d4
		bhi.s	.BobLoop
		cmp.w	d0,d6
		blt.s	.BobLoop
		cmp.w	d3,d5
		bhi.s	.BobLoop
		cmp.w	d1,d7
		blt.s	.BobLoop

		move.l	a1,d7
		bra.s	.End

.EndMainLoop:	moveq	#0,d7
.End:
		movem.l	(SP)+,d0-d6/a0-a2
		rts




******************************************************************************

AskJoy:		;	1=down		transform
		;	2=right		joycode
		;	4=up		into
		;	8=left		c-64 joycode
		;     128=Fire (1 aktiv)
		

		movem.l	d1,-(SP)

		move.w	joy1dat(a5),d0	
		
		move.w	d0,d1
		and.w	#$101,d1	;seperate bits
		and.w	#$202,d0

		lsr.w	#1,d0		;shift one group
		eor.w	d0,d1		;eor
		lsl.w	#1,d0		;shift back

		or.w	d1,d0		;or together

		move.w	d0,d1
		lsr.w	#6,d1		;crunch bits
		and.w	#$ff,d0
		or.w	d1,d0

		move.b	$bfe001,d1	;get both firebuttons
		not.w	d1
		
		and.w	#$80,d1		;isolate fire
		or.w	d1,d0		;Joy-Code finished
		movem.l	(SP)+,d1
		rts


******************************************************************************

;-----------------------------------------------------------------------
;	BOBOL-KOMMANDOS, Offset D1 wird upgedatet
;-----------------------------------------------------------------------


SetWordFunc:	moveq.l	#0,d0
		move.b	0(a2,d1.w),d0		; Offset in BobStrukt
		move.w	2(A2,d1.w),d2		; zu setzender Wert
		move.w	d2,0(a0,d0.w)		; in BobStrukt eintragen
		moveq.l	#0,d0
		addq.l	#4,d1
		rts


SetLongFunc:	moveq.l	#0,d0
		move.b	0(a2,d1.w),d0		; Offset in BobStrukt
		move.l	2(A2,d1.w),d2		; zu setzender Wert
		move.l	d2,0(a0,d0.w)		; in BobStrukt eintragen
		moveq.l	#0,d0
		addq.l	#6,d1
		rts




LoopFunc:	moveq	#0,d1			; 'PC' zurücksetzen
		bra.s	ReturnNull

RemoveFunc:	bsr	RemBob
EndeFunc:	st.b	d0			; Nicht weitermachen
		rts


SignalFunc:	move.w	2(a2,d1.w),d2		; zu setzende Signals holen
		move.l	a6,-(SP)
		lea	__MyExecBase(PC),a6
		or.w	d2,meb_SignalSet(a6)	; und setzen
		movea.l	(SP)+,a6
		addq.w	#4,d1			; Offset erhöhen
		bra.s	ReturnNull

WaitFunc:	move.w	2(a2,d1.w),d2		; WaitMaske holen
		move.l	a6,-(SP)
		lea	__MyExecBase(PC),a6
		move.w	meb_SignalSet(a6),d3	; getzte Signals holen
		and.w	d2,d3			; ist ein Signal gesetzt ?
		beq.s	1$			; nein --->
		not.w	d2
		and.w	d2,meb_SignalSet(a6)	; Signals löschen
		movea.l	(SP)+,a6
		addq.w	#4,d1			; Offset erhöhen
		bra.s	ReturnNull
1$:		movea.l	(SP)+,a6
		st.b	d0			; Nicht weitermachen
		rts


SetPriFunc:	move.w	2(a2,d1.w),d2		; neue Priorität holen
		move.b	d2,bob_NewPri(a0)	; und setzen
		addq.w	#4,d1			; Offset erhöhen
		st.b	NewPri
		bra.s	ReturnNull

CpuJumpFunc:	move.l	2(a2,d1.w),a3		; SprungAdresse
		move.l	6(a2,d1.w),d0		; Parameter ins D0
		movem.l	d0-d7/a0-a6,-(SP)
		move.w	bob_Flags(A0),d1
		lea	__MyExecBase(PC),a6	; Für User
		jsr	(a3)			; Routine anspringen
		movem.l	(SP)+,d0-d7/a0-a6
		add.w	#10,d1			; nächstes Kommando
ReturnNull:	moveq	#0,d0
		rts

UntilFunc:	move.w	2(a2,d1.w),d2		; Signals die abgfragt werden sollen
		move.w	4(a2,d1.w),d4		; Offset
		move.l	a6,-(SP)
		lea	__MyExecBase(PC),a6
		move.w	meb_SignalSet(a6),d3	; gesetzte Signals
		and.w	d2,d3
		bne.s	1$			; Signal gesetzt -> Loop beenden
		sub.w	d4,d1			; SchleifenAnfang PC setzen
		not.w	d2
		and.w	d2,meb_SignalSet(a6)	; Signal löschen
		bra.s	2$
1$:		addq.w	#6,d1			; Signal gesetzt
2$:		movea.l	(SP)+,a6
		bra.s	ReturnNull

WhileFunc:	move.w	2(a2,d1.w),d2		; Signal
		move.w	4(a2,d1.w),d4		; Offset
		SYSGET.W SignalSet,d3		; gesetzte
		and.w	d2,d3
		beq.s	1$			; Signal nicht gesetzt -> Loop beenden
		sub.w	d4,d1			; SchleifenAnfang PC setzen
		bra.s	2$
1$:		addq.w	#6,d1			; Signal gesetzt
2$:		bra.s	ReturnNull

PokeBFunc:	move.l	2(a2,d1.w),a3		; Adresse
		move.w	6(a2,d1.w),d2		; Wert
		move.b	d2,(a3)
		addq.w	#8,d1
		bra.s	ReturnNull

PokeWFunc:	move.l	2(a2,d1.w),a3
		move.w	6(a2,d1.w),d2
		move.w	d2,(a3)
		addq.w	#8,d1
		bra.s	ReturnNull

PokeLFunc:	move.l	2(a2,d1.w),a3
		move.l	6(a2,d1.w),d2
		move.l	d2,(a3)
		add.w	#10,d1			; nächstes Kommando
		bra.s	ReturnNull

SetClipFunc:	move.w	2(a2,d1.w),bob_ClipX(a0)
		move.w	4(a2,d1.w),bob_ClipY(a0)
		move.w	6(a2,d1.w),bob_ClipX2(a0)
		move.w	8(a2,d1.w),bob_ClipY2(a0)
		move.w	10(a2,d1.w),bob_ClipFlags(a0)
		add.w	#12,d1			; nächstes Kommando
		bra.s	ReturnNull1

RelMoveFunc:	move.w	2(a2,d1.w),d2
		move.w	d2,bob_RelMoveCounter(a0)
		addq.w	#4,d1
		bra.s	ReturnNull1

SetAnimFunc:	move.l	a1,-(SP)
		move.l	2(a2,d1.w),a1
		moveq	#0,d0
		move.b	bob_AnimSpeed(a0),d0
		bsr	SetAnimPrg
		move.l	(SP)+,a1
		addq.w	#6,d1
		bra.s	ReturnNull1

SetMoveFunc:	movem.l	d1/a1,-(SP)
		move.l	2(a2,d1.w),a1
		moveq	#0,d0
		move.b	bob_MoveSpeed(a0),d0
		moveq	#0,d1
		move.w	bob_MoveStep(a0),d1
		bsr	SetMovePrg
		movem.l	(SP)+,d1/a1
		addq.w	#6,d1
		bra.s	ReturnNull1


SetDataFunc:	move.l	2(a2,d1.w),bob_BobData(a0)
		addq.w	#6,d1
ReturnNull1:	moveq	#0,d0
		rts

SetMoveSpeedFunc:
		move.w	2(a2,d1.w),d0
		move.b	d0,bob_MoveSpeed(a0)
		clr.b	bob_MoveSpeedCounter(a0)
		addq.w	#4,d1
		bra.s	ReturnNull1

SetAnimSpeedFunc:
		move.w	2(a2,d1.w),d0
		move.b	d0,bob_AnimSpeed(a0)
		clr.b	bob_AnimSpeedCounter(a0)
		addq.w	#4,d1
		bra.s	ReturnNull1

SetIdFunc:	move.w	2(a2,d1.w),d0
		move.b	d0,bob_Id(a0)
		addq.w	#4,d1
		bra.s	ReturnNull1


ForFunc:	move.w	2(a2,d1.w),(a4)		; Zähler setzen
		addq.w	#4,d1
		bra.s	ReturnNull1

NextFunc:	moveq	#0,d0
		move.w	2(a2,d1.w),d2
		cmp.w	#FOREVERMAGIC,(A4)
		beq.s	1$
		subq.w	#1,(a4)			; Zähler erniedrigen
		bne.s	1$
		addq	#4,d1
		rts
1$:		sub.w	d2,d1
		rts


LSignalFunc:	move.w	2(a2,d1.w),d2		; zu setzende Signals holen
		or.w	d2,bob_LSignalSet(a0)	; und setzen
		addq.w	#4,d1			; Offset erhöhen
		bra.s	ReturnNull1

LWaitFunc:	move.w	2(a2,d1.w),d2		; WaitMaske holen
		move.w	bob_LSignalSet(a0),d3	; getzte Signals holen
		and.w	d2,d3			; ist ein Signal gesetzt ?
		beq.s	1$			; nein ->
		not.w	d2
		and.w	d2,bob_LSignalSet(a0)	; Signals löschen
		addq.w	#4,d1			; Offset erhöhen
		moveq	#0,d0
		rts
1$:		st.b	d0
		rts


DelayFunc:	move.w	2(A2,d1.w),(a6)		; DelayZeit eintragen
		addq.w	#4,d1
		bra	ReturnNull2

RndDelayFunc:	bsr.s	GetLimitRandom
		move.w	d0,(A6)
		addq.w	#6,d1
		bra	ReturnNull2

RndAnimFunc:	bsr.s	GetLimitRandom
		move.w	d0,bob_Image(a0)
		addq.w	#6,d1
		st.b	d0
		rts

GetLimitRandom:	move.w	4(A2,d1.w),d0		; oberes Limit
		sub.w	2(a2,d1.w),d0		; - unteres Limit
		ext.l	d0
		SYSCALL	Random
		add.w	2(a2,d1.w),d0		; + unteres Limit
		rts

AddBobFunc:	move.l	a1,-(SP)
		move.w	bob_Flags(A0),d0
		btst	#BOBB_ONLYANIM,d0
		bne.s	1$
		move.l	2(a2,d1.w),a1
		bsr	AddBob
1$:		addq.w	#6,d1
		moveq.l	#0,d0
		move.l	(SP)+,a1
		rts

AddRelBobFunc:	move.l	a1,-(SP)
		move.l	2(a2,d1.w),a1		; Bob
		bsr	AddBob			; adden
		move.l	d0,a1			; NewBob

		move.w	bob_X(A0),d0		; BobX
		add.w	6(A2,d1.w),d0		; X-Versatz
		add.w	d0,bob_X(A1)
		move.w	bob_Y(A0),d0		; BobY
		add.w	8(A2,d1.w),d0		; Y-Versatz
		add.w	d0,bob_Y(A1)		; relativ zu Bob

		add.w	#10,d1
		moveq.l	#0,d0
		move.l	(SP)+,a1
		rts


ReturnNull2:	moveq	#0,d0
		rts


MoveToFunc:	movem.l	d0-d7,-(SP)
		move.l	d1,d7			; D7 : PrgOffset
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		movem.w	bob_X(a0),d0/d1		; X & Y
		movem.w	2(a2,d7.w),d2-d3
		asl.l	#4,d0			; X1 Koordinate * 16
		asl.l	#4,d1			; Y1 Koordinate * 16
		asl.l	#4,d2			; X2 Koordinate * 16
		asl.l	#4,d3			; Y2 Koordinate * 16

		move.w	6(a2,d7.w),d4		; Anzahl der Steps
		move.l	d2,d5
		sub.l	d0,d5
		divs.w	d4,d5
		move.w	d5,bob_MoveToXStep(A0)

		move.l	d3,d5
		sub.l	d1,d5
		divs.w	d4,d5
		move.w	d5,bob_MoveToYStep(a0)

		move.w	d0,bob_MoveToX(a0)
		move.w	d1,bob_MoveToY(a0)
		move.w	d4,bob_MoveToSteps(a0)

		movem.l	(SP)+,d0-d7
		addq.w	#8,d1			; Nächstes Kommando
ReturnNull3:	moveq	#0,d0
		rts

FlashFunc:	movem.l	d0-d1,-(SP)
		move.w	2(a2,d1.w),d0
		move.w	4(a2,d1.w),d1
		bsr	FlashBob
		movem.l	(SP)+,d0-d1
		addq.l	#6,d1
		bra.s	ReturnNull3

SetConvertFunc:	move.l	2(a2,d1.w),bob_ConvertTab(a0)
		move.w	6(a2,d1.w),bob_ConvertSize(a0)
		move.w	8(a2,d1.w),bob_ConvertOffset(a0)
		add.w	#10,d1
		bra.s	ReturnNull3

AnimToFunc:	move.w	2(a2,d1.w),bob_Image(a0)
		move.w	4(a2,d1.w),bob_AnimTo(a0)
		addq.w	#6,d1
		bra.s	ReturnNull3

GotoFunc:	move.l	2(a2,d1.w),a2
		moveq.l	#0,d1
		bra.s	ReturnNull3

SetRelDataFunc:	move.l	6(a2,d1.w),a1			; BobBase
		move.l	(a1),d0				; Address
		add.l	2(a2,d1.w),d0			; + Offset
		move.l	d0,bob_BobData(a0)
		add.w	#10,d1
		bra.s	ReturnNull3

AddDaughterFunc:
		movem.l	a0-a3,-(SP)
		move.l	a0,a3				; aktives Bob
		move.l	2(a2,d1.w),a1			; NewBob
		bsr	AddBob				; adden
		move.l	d0,a1				; a0=NewBob

		move.w	6(a2,d1.w),d0			; X-Offset
		add.w	d0,bob_X(a1)			; addieren
		move.w	8(a2,d1.w),d0			; Y-Offset
		add.w	d0,bob_Y(a1)			; addieren

		move.l	a3,bob_ParentBob(a1)		; Aktuelles Bob = ParentBob

		add.w	#10,d1
		movem.l	(SP)+,a0-a3

ReturnNull4:	moveq.l	#0,d0
		rts



TestJoyFunc:	movem.l	d2/a3,-(SP)
		bclr	#SRB_ZEROFLAG,bob_sr(A0)	; ZeroFlag löschen	
		move.w	JoyBuf,d0			; Joystick abfragen
		move.l	4(a2,d1.w),d2
		beq.s	.NoFlip
		move.l	d2,a3
		btst	#0,(a3)
		beq.s	.NoFlip
		move.w	d0,d2
		bclr	#JOYB_LEFT,d2
		bclr	#JOYB_RIGHT,d2
		btst	#JOYB_LEFT,d0
		beq.s	2$
		bset	#JOYB_RIGHT,d2
2$:		btst	#JOYB_RIGHT,d0
		beq.s	3$
		bset	#JOYB_LEFT,d2
3$:		move.w	d2,d0
.NoFlip:	cmp.w	2(a2,d1.w),d0			; Ergebnis mit Maske vergleichen
		bne.s	1$				; wenn nicht gleich -> Ende
		bset	#SRB_ZEROFLAG,bob_sr(A0)	; ZeroFlag setzen
1$:		addq.w	#8,d1
		movem.l	(SP)+,d2/a3
		bra	ReturnNull4



BitTestFunc:	bclr	#SRB_ZEROFLAG,bob_sr(A0)	; ZeroFlag löschen	
		move.w	2(A2,d1.w),d0			; zu testendes bit
		move.l	4(a2,d1.w),a3			; zu testende Adr
		btst	d0,(A3)				; bit testen
		bne.s	1$				; wenn bit 0 ist
		bset	#SRB_ZEROFLAG,bob_sr(A0)	; ZeroFlag setzen
1$:		addq.w	#8,d1
		bra	ReturnNull4


		
JeqFunc:	btst	#SRB_ZEROFLAG,bob_sr(A0)
		beq.s	1$
		;sub.l	a2,a3
		;move.w	a3,d1
		add.w	2(a2,d1.w),d1
		bra	ReturnNull4

1$:		addq.w	#4,d1
		bra	ReturnNull4

JneFunc:	btst	#SRB_ZEROFLAG,bob_sr(A0)
		bne.s	1$
		;sub.l	a2,a3
		;move.w	a3,d1
		add.w	2(a2,d1.w),d1
		bra	ReturnNull4

1$:		addq.w	#4,d1
		bra	ReturnNull4




;-----------------------------------------------------------------------
;	Daten
;-----------------------------------------------------------------------

ClipMasks:	dc.w	%1111111111111111
		dc.w	%0111111111111111
		dc.w	%0011111111111111
		dc.w	%0001111111111111
		dc.w	%0000111111111111
		dc.w	%0000011111111111
		dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
		dc.w	%0000000001111111
		dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
		dc.w	%0000000000000011
		dc.w	%0000000000000001


Width:		ds.w	1
NumPlanes:	ds.w	1
GlobalXClip:	ds.w	1	; GlobalXClip und GlobalYClip müssen
GlobalYClip:	ds.w	1	; hintereinander stehen!
NewPri:		ds.w	1
GlobalX:	ds.w	1
JoyBuf:		ds.w	1
SaveMask:	ds.b	1
		ds.b	1

		END
