**************************************************************************
**                                                                      **
**   MYEXEC  -  Verschiedene Routinen die so manches Programm braucht   **
**                                                                      **
**              by Christian A. Weber, Zurich/Switzwerland              **
**                                                                      **
**************************************************************************
**                                                                      **
**   Modification History                                               **
**   --------------------                                               **
**                                                                      **
**   18-May-89  CHW   Recreated this file!                              **
**   20-Jun-89  CHW   Supports 1MB CHIP RAM                             **
**   29-Jun-89  CHW   Auf Genim2 umgeschrieben                          **
**   22-Aug-89  CHW   AddHead() added                                   **
**   27-Aug-89  CHW   AddHead() rettet nun die Register (!^%#$@)        **
**   13-Sep-89  CHW   CopyMem() rettet nun D0 (grmbl!)                  **
**   06-Nov-89  CHW   SetCache() added                                  **
**   27-Nov-89  CHW   FastMem support routines added                    **
**   04-Feb-90  CHW   Zero-Handler & other Guru handlers added          **
**   11-Feb-90  CHW   Supervisor-Stack ist jetzt im FAST-RAM            **
**   28-Mar-90  CHW   ColdReboot() implementiert, ABORT springt dahin   **
**   18-Sep-90  CHW   CheckMem() implementiert und so                   **
**   20-Oct-90  CHW   Config-File entfernt, MainPrg muss am Anfang sein **
**   30-Dec-90  CHW   Gecrunchte Files werden automatisch entcruncht    **
**   06-Jan-91  CHH   BufLoadFile testet ob genug RAM vorhanden ist     **
**   11-Feb-91  CHH   BufReadFile eingebaut                             **
**   18-Feb-91  CHW   Multitasking-fähige Version                       **
**   06-May-91  CHW   Diskroutine kann jetzt schreiben                  **
**                                                                      **
**************************************************************************

		IDNT	Exec
		SECTION	text,CODE

		INCLUDE	"MyExec.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"zeropage.i"
		INCLUDE	"hardware/custom.i"
		INCLUDE	"hardware/dmabits.i"
		INCLUDE	"hardware/intbits.i"


;STACKSIZE:	EQU	5432			; Grösse des Super-Stacks
STACKSIZE:	EQU	20000			; Grösse des Super-Stacks -C5- 

ROMCRACKEXCEPT:	EQU	$fc2ff4+(2*6)		; ROMCrack Exception-Einspr.
ROMCRACKSPEC:	EQU	$fc2ff4+(4*6)		; ROMCrack Special-Einsprung

INITMAGIC:	EQU	'INIT'			; steht vor InitExecFunc()
FFSMAGIC:	EQU	$444f5301

FN_MAINPRG:	EQU	$01030010		; Disk 1, Track 3, 1. File

**************************************************************************

		XREF	_custom,__H2_end

		XREF	InitChipMemFunc,InitFastMemFunc
		XREF	AllocMemFunc,AllocClearMemFunc
		XREF	AllocFastMemFunc,AllocFastClearMemFunc
		XREF	AvailMemFunc,AvailFastMemFunc,CheckMemFunc
		XREF	FreeMemFunc,ClearMemFunc,CopyMemQuickFunc,CopyMemFunc
		XREF	InitKeyFunc,GetKeyFunc,WaitKeyFunc,FlushKeyBufFunc
		XREF	SetMapFunc,SetResetHandlerFunc,SetCheatTextFunc
		XREF	RawDoFmtFunc,RawPrintfFunc
		XREF	RandomizeFunc,RandomFunc

		XREF	InitDiskFunc,SetNoDiskHandlerFunc,ReadFileFunc
		XREF	WriteFileFunc,LoadFileFunc,LoadFastFileFunc
		XREF	LoadSegFunc,UnLoadSegFunc,SendPacketFunc
		XREF	InitRAMLib,BufReadFileFunc,BufLoadFileFunc
		XREF	DeleteFileNodeFunc,DeleteFileListFunc

		XREF	WaitBlit,InitDrawBob,AddBob,RemBob,RemAllBobs
		XREF	RestoreBobList,DrawBobList
		XREF	RestoreOneBob,DrawOneBob
		XREF	AnimateOneBob,MoveOneBob,TestPoint
		XREF	SetMovePrg,SetAnimPrg,SetGlobalClip
		XREF	HandleCollision,CollOneBob,FlashBob,GetBobData
	IFD SYSTEM
		XREF	ExitKeyFunc
		XREF	InitCDFunc,ExitCDFunc,PlayCDTrackFunc,WaitCDTrackFunc

		XREF	_DebugText

	ENDC

		XDEF	__MyExecBase,_InitExec,_idstring

		XDEF	InitExecFunc,ColdRebootFunc,SetCacheFunc,DebugFunc
		XDEF	NewListFunc,EnqueueFunc,RemoveFunc
		XDEF	AddHeadFunc,AddTailFunc,RemHeadFunc
		XDEF	DisableFunc,EnableFunc

**************************************************************************

	*** Die Zero-Page mit den vielen Vektoren

__MyExecBase:
Null:		DC.L	0		; $00 := 0 für Sprites usw.
		BRA.W	JumpZero	; $04 Falls jemand nach 0 springt ...
		DC.L	Guru2Handler	; $08
		DC.L	Guru3Handler	; $0C
		DC.L	Guru4Handler	; $10
		DC.L	Guru5Handler	; $14
		DC.L	Guru6Handler	; $18
		DC.L	Guru7Handler	; $1C
		DC.L	Guru8Handler	; $20
		DC.L	Guru9Handler	; $24
		DC.L	GuruAHandler	; $28
		DC.L	GuruBHandler	; $2C
		DC.L	GuruCHandler	; $30
		DC.L	GuruDHandler	; $34
		DC.L	GuruEHandler	; $38
		DC.L	GuruFHandler	; $3C
		DCB.L	9,0		; $40-$60	; Reserved exceptions
		DC.L	DebugFunc	; $64		; Interrupt Level 1
		DC.L	CiaAServer	; $68		; Interrupt Level 2
		DC.L	VBLServer	; $6C		; Interrupt Level 3
		DC.L	DebugFunc	; $70		; Interrupt Level 4
		DC.L	DebugFunc	; $74		; Interrupt Level 5
		DC.L	CiaBServer	; $78		; Interrupt Level 6
		DC.L	ColdRebootFunc	; $7C		; Interrupt Level 7
		DCB.L	16,0		; $80-$BC	; Trap-Vectors 0-15
		DC.B	"CHW!"		; $C0		; Kennung für Booter!
		DCB.L	15,0		; $C4-$FC	; Reserviert

	*** Tada! Die ExecBase-Struktur

		DC.L	0		; Nicht debuggen!
		DC.L	'ICH!'		; ROMCrackMagic für Mem
		DC.L	$1d0000		; ROMCrackBSS
		DC.L	$1e0000		; ROMCrackChipMem
		DC.L	ROMCrackText	; ROMCrack's Debug-Text

	*** Private Einträge

		DCB.B	mh_SIZEOF,0	; MemoryRegionHeader
		DCB.B	mh_SIZEOF,0	; FastMemoryRegionHeader
		DC.L	0		; RAMDiskBase
		DC.L	0		; RAMDiskSize
		DC.L	FN_MAINPRG	; MainPrgName
		DC.L	$affebad,356789	; LastRnd1,LastRnd2
		DCB.B	lh_SIZEOF,0	; DiskList
		DCB.B	lh_SIZEOF,0	; FileList (für RAMLib)
		DC.W	0		; Product-Code
		DC.B	-1		; IDNestCnt
		DC.B	0		; ExecFlags

	*** Erlaubte Einträge

		DC.L	0		; SuperStackUpper
		DC.W	0		; AttnFlags
		DC.W	0		; SystemBplcon0
		DC.B	0		; VBlankFrequency
		DC.B	0		; expad2

		DC.B	0		; ActualKey
		DC.B	0		; ActualQualifiers
		DC.B	0		; ActualASCIIKey
		DC.B	0		; CheatFlag

		DCB.B	lh_SIZEOF,0	; BobList
		DC.L	0		; TripleScreen: Zeiger auf 3. BitMap
		DC.W	0		; SignalSet (für Bobroutine)

		DC.L	0		; UserData1
		DC.L	0		; UserData2

		DCB.B	6,0		; exreserved, pad auf LONG

		DC.W	0		; LONG-Align
		DC.W	$4EF9		; VBL-Jmp
		DC.L	0		; VBL-Vektor

		DC.W	0		; LONG-Align
		DC.W	$4EF9		; Copper-Jmp
		DC.L	0		; Copper-Vektor

		DCB.L	2*5,0		; Cia-Interruptvektoren

		DC.L	INITMAGIC	; Steht vor InitExecFunc()
_InitExec:
		BRA.W	InitExecFunc	; MUSS 1. Funktion sein: FinalBooter.S
		BRA.W	ColdRebootFunc	; MUSS 2. Funktion sein: FinalBooter.S
		BRA.W	InitChipMemFunc
		BRA.W	InitFastMemFunc
		BRA.W	InitDiskFunc
		BRA.W	InitKeyFunc
		BRA.W	SetCacheFunc

		BRA.W	DebugFunc

		BRA.W	AllocMemFunc
		BRA.W	AllocClearMemFunc
		BRA.W	AllocFastMemFunc
		BRA.W	AllocFastClearMemFunc
		BRA.W	FreeMemFunc
		BRA.W	AvailMemFunc
		BRA.W	AvailFastMemFunc
		BRA.W	CheckMemFunc
		BRA.W	CopyMemFunc
		BRA.W	CopyMemQuickFunc
		BRA.W	ClearMemFunc

		BRA.W	DisableFunc
		BRA.W	EnableFunc
		BRA.W	OwnBlitterFunc
		BRA.W	DisownBlitterFunc

		BRA.W	NewListFunc
		BRA.W	EnqueueFunc
		BRA.W	RemoveFunc
		BRA.W	AddHeadFunc
		BRA.W	AddTailFunc
		BRA.W	RemHeadFunc

		BRA.W	GetKeyFunc
		BRA.W	WaitKeyFunc
		BRA.W	FlushKeyBufFunc
		BRA.W	SetMapFunc
		BRA.W	SetResetHandlerFunc
		BRA.W	SetCheatTextFunc

		BRA.W	RawDoFmtFunc
		BRA.W	RawPrintfFunc
		BRA.W	PlayCDTrackFunc
		BRA.W	WaitCDTrackFunc

		BRA.W	RandomizeFunc
		BRA.W	RandomFunc

		BRA.W	SetNoDiskHandlerFunc
		BRA.W	ReadFileFunc
		BRA.W	WriteFileFunc
		BRA.W	LoadFileFunc
		BRA.W	LoadFastFileFunc
		BRA.W	LoadSegFunc
		BRA.W	UnLoadSegFunc
		BRA.W	BufReadFileFunc
		BRA.W	BufLoadFileFunc
		BRA.W	DeleteFileNodeFunc
		BRA.W	DeleteFileListFunc
		BRA.W	SendPacketFunc

		BRA.W	WaitBlit
		BRA.W	InitDrawBob
		BRA.W	AddBob
		BRA.W	RemBob
		BRA.W	RemAllBobs
		BRA.W	RestoreBobList
		BRA.W	DrawBobList
		BRA.W	RestoreOneBob
		BRA.W	DrawOneBob
		BRA.W	AnimateOneBob
		BRA.W	MoveOneBob
		BRA.W	TestPoint
		BRA.W	SetMovePrg
		BRA.W	SetAnimPrg
		BRA.W	SetGlobalClip
		BRA.W	HandleCollision
		BRA.W	CollOneBob
		BRA.W	FlashBob
		BRA.W	GetBobData


 IFNE (*-Null)-__EXECBASESIZE
	Fail	"ExecBase structure size mismatch!"
 ENDC


		BRA.W	UndefdFunc
		BRA.W	UndefdFunc
		BRA.W	UndefdFunc
		BRA.W	UndefdFunc


		DCB.B	7,0
VersTag:	DC.B	0,"$VER: "

_idstring:
ROMCrackText:	DC.B	"GAME EXEC Operating System V4.4 (16-Apr-92)",0
		DC.B	"Copyright (c) 1989 - 1992 by Christian A. Weber,"
		DC.B	"Bruggerweg 2, CH-8037 Zuerich, Switzerland.",10,0
		DC.B	"All Rights Reserved.",10,0
		DC.B	"Greetings to Chris Haller, René Straub, Roman Werner",10,0
		DCB.B	27,0

ExceptText:	DC.B	"Exception "
exno:		DC.B	"xx",0

JumpZeroText:	DC.B	"Caught jump to 0",0
UndefdText:	DC.B	"Undef'd routine",0
		EVEN


**************************************************************************
**		E X E C  -  I N I T I A L I S I E R U N G
**************************************************************************

	*** SYSTEM:
	*** D0=AttnFlags,    D1=SystemBplcon0, D2=VBlankFrequency,
	*** D3=Product Code, A0=CHIPRAM-Base,  A1=CHIPRAM-Ende,
	*** A2=FASTRAM-Base, A3=FASTRAM-Ende   D4=MainPrg-Name

	*** SONST:
	*** D0=AttnFlags,    D1=SystemBplcon0, D2=VBlankFrequency,
	*** D3=Product Code, A0=RAMDiskBase,   A1=RAMDiskSize,
	*** A2=FASTRAM-Base, A3=FASTRAM-Ende   A7=CHIPRAM-Ende-8

InitExecFunc:
	IFND SYSTEM
		move	#$2700,sr
	ENDC
		lea	_custom,a5
		lea	__MyExecBase(PC),a6

	*** System-Status initialisieren (NUR 1x , NICHT BEI RESTART!)

		tst.b	meb_VBlankFrequency(a6)	; ExecBase schon installiert?
		bne.s	.NotFirst		; ja --->

		move.w	d0,meb_AttnFlags(a6)
		move.w	d1,meb_SystemBplcon0(a6)
		move.b	d2,meb_VBlankFrequency(a6)
		move.w	d3,meb_ProductCode(a6)
	IFND DISKVERSION
		move.l	d4,meb_MainPrgName(a6)
	ENDC

	IFD SYSTEM
		move.l	(SP)+,ColdRebootJmp+2	; Return-Adresse
		move.l	a0,meb_ChipMRHeader+mh_Lower(a6)
		move.l	a1,meb_ChipMRHeader+mh_Upper(a6)
	ELSEIF
		move.l	a0,meb_RAMDiskBase(a6)	; Muss 0 sein falls kein RAM!
		move.l	a1,meb_RAMDiskSize(a6)	; Muss 0 sein falls kein RAM!

		move.l	#__H2_end,d0		; Ende von Exec's BSS
		addq.l	#7,d0
		andi.b	#$f8,d0			; Modulo-8 aufrunden
		move.l	d0,meb_ChipMRHeader+mh_Lower(a6)
		move.l	SP,meb_ChipMRHeader+mh_Upper(a6)
	ENDC
		move.l	a2,meb_FastMRHeader+mh_Lower(a6)
		move.l	a3,meb_FastMRHeader+mh_Upper(a6)

	*** StackPointer initialisieren (ins FAST-RAM falls vorhanden)

		lea	meb_FastMRHeader+mh_Upper(a6),a0
		tst.l	(a0)
		bne.s	1$				; FAST-RAM vorhanden --->
		lea	meb_ChipMRHeader+mh_Upper(a6),a0
1$:
		move.l	(a0),d0				; Alte Obergrenze
		move.l	d0,meb_SuperStackUpper(a6)	; nach StackPointer
		sub.l	#STACKSIZE,d0			; Stack-Grösse wegzählen
		move.l	d0,(a0)				; Neue Obergrenze setzen

	*** VBL und Copper-Interrupt-Server installieren falls SYSTEM

	IFD SYSTEM
		move.l	a6,-(SP)
		movea.l	4,a6

		moveq	#INTB_VERTB,d0
		lea	MyVertInt(PC),a1
		JSRLIB	AddIntServer

		moveq	#INTB_COPER,d0
		lea	MyCopInt(PC),a1
		JSRLIB	AddIntServer

		movea.l	(SP)+,a6

		bsr	InitCDFunc
	ENDC

.NotFirst:

	*** Speicherverwaltung initialisieren

		movea.l	meb_SuperStackUpper(a6),SP	; StackPointer holen

		movea.l	meb_ChipMRHeader+mh_Lower(a6),a0
		move.l	meb_ChipMRHeader+mh_Upper(a6),d0
		sub.l	a0,d0			; D0 := Länge
		jsr	meb_ClearMem(a6)	; ** DEBUG ** Cracker-Schutz: Speicher mit Muster füllen
		jsr	meb_InitChipMem(a6)

		movea.l	meb_FastMRHeader+mh_Lower(a6),a0
		move.l	meb_FastMRHeader+mh_Upper(a6),d0
		sub.l	a0,d0			; D0 := Länge
		beq.s	2$			; Kein FAST-RAM --->
		jsr	meb_ClearMem(a6)	; ** DEBUG ** Cracker-Schutz: Speicher mit Muster füllen
		jsr	meb_InitFastMem(a6)
2$:
	*** Jenes Zeugs initialisieren

	IFND SYSTEM
		move.w	#$7fff,intena(a5)	; Alle Interrupts off
		move.w	#$7fff,intreq(a5)	; Interrupt-Requests löschen
		move	#$2000,sr		; Interrupt Level 0
		move.w	#INTF_SETCLR|INTF_INTEN|INTF_VERTB|INTF_COPER,intena(a5)
		move.w	#$7fff,dmacon(a5)	; Alle DMAs off
		move.w	#DMAF_SETCLR|DMAF_MASTER,dmacon(a5)
	ENDC
		jsr	meb_InitKey(a6)		; Tastatur on
		jsr	meb_InitDisk(a6)	; Diskroutine on
		bsr	InitRAMLib		; RAMLib initialisieren

	*** 1. File einladen & starten

		move.l	meb_MainPrgName(a6),d0	; 1. Modul
		jsr	meb_LoadSeg(a6)		; meinprg laden
		movea.l	d0,a0			; Muss A0 sein, User weiss es!
		jmp	(a0)			; A6 muss MyExecBase sein!

**************************************************************************

	*** System resetten (wir sind im Supervisor)

ColdRebootFunc:
	IFD SYSTEM
		bsr	ExitCDFunc
		bsr	ExitKeyFunc

		move.l	a6,-(SP)
		movea.l	4,a6

		moveq	#INTB_VERTB,d0
		lea	MyVertInt(PC),a1
		JSRLIB	RemIntServer

		moveq	#INTB_COPER,d0
		lea	MyCopInt(PC),a1
		JSRLIB	RemIntServer

		movea.l	(SP)+,a6

ColdRebootJmp:	jmp	(1$).L				; Zum Patchen
1$:
	ENDC

	IFD DISKVERSION
		btst	#AFB_68020,meb_AttnFlags+1(a6)	; MMU ?
		beq.s	2$				; nein --->
		clr.l	-(SP)				; Code für MMU off
		move.l	SP,a0
		dc.w	$f010,$4000			; pmove (a0),tc
2$:		nop
		nop
		lea	2,a0
		RESET
		jmp	(a0)
	ENDC

	IFD RAMVERSION
		jmp	$1FFFFA				; ABORT
	ENDC


**************************************************************************
* Level 3 Interrupt Server

	IFD SYSTEM

VBLServer:	EQU	0

MyVertInt:	dc.l	0,0
		dc.b	0,60
		dc.l	_idstring
		dc.l	__MyExecBase
		dc.l	1$

	* D1/A0-A1/A5-A6 = Scratch

1$:		lea	_custom,a5
		movea.l	a1,a6			; _MyExecBase
		tst.l	meb_VBLIntVector(a6)
		beq.s	2$
		jsr	meb_VBLIntJump(a6)
2$:		movea.l	a5,a0			; Custom für Gfx-IntServer
		moveq.l	#0,d0			; Set Z bit
		rts

MyCopInt:	dc.l	0,0
		dc.b	0,60
		dc.l	_idstring
		dc.l	__MyExecBase
		dc.l	1$

1$:		lea	_custom,a5
		movea.l	a1,a6			; _MyExecBase
		tst.l	meb_CopperIntVector(a6)
		beq.s	2$
		jsr	meb_CopperIntJump(a6)
2$:		moveq.l	#0,d0			; Set Z bit
		rts

	ELSEIF

VBLServer:	movem.l	a5/a6,-(SP)
		lea	_custom,a5			; User weiss das!
		lea	__MyExecBase(PC),a6		; User weiss das!
		btst.b	#INTB_VERTB,intreqr+1(a5)
		beq.s	2$
		tst.l	meb_VBLIntVector(a6)
		beq.s	1$
		jsr	meb_VBLIntJump(a6)
1$:		move.w	#INTF_VERTB,intreq(a5)
2$:
		btst.b	#INTB_COPER,intreqr+1(a5)
		beq.s	4$
		tst.l	meb_CopperIntVector(a6)
		beq.s	3$
		jsr	meb_CopperIntJump(a6)
3$:		move.w	#INTF_COPER,intreq(a5)
4$:
		movem.l	(SP)+,a5/a6
		rte
	ENDC

**************************************************************************
* CIA Interrupt Server

	IFD SYSTEM

CiaAServer:	EQU	0
CiaBServer:	EQU	0

	ELSEIF

CiaAServer:	movem.l	d0/d2/a0/a2/a5/a6,-(SP)		; ACHTUNG: unten gleich!
		lea	_custom,a5			; User weiss das!
		lea	__MyExecBase(PC),a6		; User weiss das!
		move.w	#$0008,intreq(a5)		; Interruptrequest löschen
		move.b	$bfed01,d2			; ICAA ICR auslesen
		lea	meb_CiaATimerAVector(a6),a2	; Vektor-Basis
		bra.s	CiaCommon

CiaBServer:	movem.l	d0/d2/a0/a2/a5/a6,-(SP)		; ACHTUNG: oben gleich!
		lea	_custom,a5			; User weiss das!
		lea	__MyExecBase(PC),a6		; User weiss das!
		move.w	#$2000,intreq(a5)		; Interruptrequest löschen
		move.b	$bfdd00,d2			; ICAB ICR auslesen
		lea	meb_CiaBTimerAVector(a6),a2	; Vektor-Basis
	;;	bra.s	CiaCommon

CiaCommon:	lsr.b	#1,d2			; Timer A Interrupt ?
		bcc.s	1$			; Nein --->
		move.l	(a2),d0			; Vektor gültig ?
		beq.s	1$			; nein --->
		movea.l	d0,a0
		jsr	(a0)
1$:
		lsr.b	#1,d2			; Timer B Interrupt ?
		bcc.s	2$			; Nein --->
		move.l	4(a2),d0		; Vektor gültig ?
		beq.s	2$			; nein --->
		movea.l	d0,a0
		jsr	(a0)
2$:
		lsr.b	#1,d2			; Alarm Interrupt ?
		bcc.s	3$			; Nein --->
		move.l	8(a2),d0		; Vektor gültig ?
		beq.s	3$			; nein --->
		movea.l	d0,a0
		jsr	(a0)
3$:
		lsr.b	#1,d2			; Serial Interrupt ?
		bcc.s	4$			; Nein --->
		move.l	12(a2),d0		; Vektor gültig ?
		beq.s	4$			; nein --->
		movea.l	d0,a0
		jsr	(a0)
4$:
		lsr.b	#1,d2			; Flag Interrupt ?
		bcc.s	5$			; Nein --->
		move.l	16(a2),d0		; Vektor gültig ?
		beq.s	5$			; nein --->
		movea.l	d0,a0
		jsr	(a0)
5$:
		movem.l	(SP)+,d0/d2/a0/a2/a5/a6
		rte

	ENDC

**************************************************************************
**		E X C E P T I O N - H A N D L E R
**************************************************************************

	*** Die Einsprünge von den ZeroPage-Vektoren:

GuruHandler:	bsr.s	CalcGuru
;;Guru1Handler:	bsr.s	CalcGuru
Guru2Handler:	bsr.s	CalcGuru
Guru3Handler:	bsr.s	CalcGuru
Guru4Handler:	bsr.s	CalcGuru
Guru5Handler:	bsr.s	CalcGuru
Guru6Handler:	bsr.s	CalcGuru
Guru7Handler:	bsr.s	CalcGuru
Guru8Handler:	bsr.s	CalcGuru
Guru9Handler:	bsr.s	CalcGuru
GuruAHandler:	bsr.s	CalcGuru
GuruBHandler:	bsr.s	CalcGuru
GuruCHandler:	bsr.s	CalcGuru
GuruDHandler:	bsr.s	CalcGuru
GuruEHandler:	bsr.s	CalcGuru
GuruFHandler:	bsr.s	CalcGuru
		nop				; Damit letzter Offset != 0

CalcGuru:	subi.l	#GuruHandler,(SP)	; Vektornummer erzeugen
		lsr.w	2(SP)
		cmpi.w	#$4ef9,ROMCRACKSPEC	; Ist's unsere Kickstart?
		bne.s	1$			; Nein --->
		jmp	ROMCRACKEXCEPT
1$:		move.l	#ExceptText,meb_ROMCrackDebugText+__MyExecBase
		move.w	2(SP),d0
		lsr.w	#4,d0
		add.b	#'0',d0
		move.b	d0,exno
		move.w	2(SP),d0
		and.w	#15,d0
		add.b	#'0',d0
		move.b	d0,exno+1
		bra	ColdRebootFunc


**************************************************************************
* Handler für JMP 0

JumpZero:	move.l	#JumpZeroText,meb_ROMCrackDebugText+__MyExecBase
		bra.s	DebugFunc

	*** ROMCrack aufrufen

UndefdFunc:	move.l	#UndefdText,$110

DebugFunc:	cmpi.w	#$4ef9,ROMCRACKSPEC	; Ist's unsere Kickstart?
		bne.s	1$			; Nein --->
		jmp 	ROMCRACKSPEC


1$:	
	IFD SYSTEM
		move.l	meb_ROMCrackDebugText,a0
		lea	_DebugText,a1		; FehlerText kopieren
2$:		move.b	(a0)+,(A1)+
		bne.s	2$
	ENDC
		bra	ColdRebootFunc


**************************************************************************
**		E X E C - R O U T I N E N
**************************************************************************

**************************************************************************
* Cache D0 setzen

SetCacheFunc:
	IFD SYSTEM
		XREF	@SetCACR
		bra	@SetCACR
	ELSEIF
		btst.b	#AFB_68020,meb_AttnFlags+1(a6)	; Cache vorhanden ?
		beq.s	1$				; nein --->
		dc.w	$4E7B,$0002			; movec d0,cacr
1$:		rts
	ENDC

**************************************************************************
* Blitter reservieren

OwnBlitterFunc:
	IFD SYSTEM
		XREF	_GfxBase
		move.l	a6,-(SP)
		movea.l	_GfxBase,a6
		JSRLIB	OwnBlitter
		JSRLIB	WaitBlit
		movea.l	(SP)+,a6
	ELSEIF
PlayCDTrackFunc:
WaitCDTrackFunc:
	ENDC
		rts

**************************************************************************
* Blitter freigeben

DisownBlitterFunc:
	IFD SYSTEM
		move.l	a6,-(SP)
		movea.l	_GfxBase,a6
		JSRLIB	WaitBlit
		JSRLIB	DisownBlitter
		movea.l	(SP)+,a6
	ENDC
		rts

**************************************************************************
* Neue Liste initialisieren, A0: Liste

NewListFunc:	move.l	a0,lh_Head(a0)
		addq.l	#lh_Tail,(a0)		; Head zeigt auf Tail
		clr.l	lh_Tail(a0)		; Tail ist immer 0
		move.l	a0,lh_TailPred(a0)	; TailPred zeigt auf Head
		rts

**************************************************************************
* Node in Liste einfügen (nach Priorität), A0: Liste, A1: Node

EnqueueFunc:	movem.l	d0-d1/a0,-(SP)
		bsr.s	DisableFunc
		move.b	ln_Pri(a1),d1
		move.l	lh_Head(a0),d0
1$:		movea.l	d0,a0
		move.l	ln_Succ(a0),d0
		beq.s	2$		; Ende der Liste --->
		cmp.b	ln_Pri(a0),d1	; Priorität kleiner  oder gleich ?
		ble.s	1$		; ja ---> weitersuchen
2$:		move.l	ln_Pred(a0),d0
		move.l	a1,ln_Pred(a0)
		move.l	a0,ln_Succ(a1)
		move.l	d0,ln_Pred(a1)
		movea.l	d0,a0
		move.l	a1,ln_Succ(a0)
		bsr.s	EnableFunc
		movem.l	(SP)+,d0-d1/a0
		rts

**************************************************************************
* Node aus Liste entfernen, A1: Node

RemoveFunc:	movem.l	a0/a1,-(SP)
		bsr.s	DisableFunc
		movea.l	ln_Succ(a1),a0
		movea.l	ln_Pred(a1),a1
		move.l	a0,ln_Succ(a1)
		move.l	a1,ln_Pred(a0)
		bsr.s	EnableFunc
		movem.l	(SP)+,a0/a1
		rts

**************************************************************************
* Node an den Anfang der Liste anhängen, A0: Liste, A1: Node

AddHeadFunc:	movem.l	d0/a0/a1,-(SP)
		bsr.s	DisableFunc
		move.l	lh_Head(a0),d0
		move.l	a1,lh_Head(a0)
		movem.l	d0/a0,ln_Succ(a1)
		movea.l	d0,a0
		move.l	a1,ln_Pred(a0)
		bsr.s	EnableFunc
		movem.l	(SP)+,d0/a0/a1
		rts	

**************************************************************************
* Interrupts sperren mit IDNestCnt und so

DisableFunc:
	IFD SYSTEM
		move.l	a6,-(SP)
		movea.l	4,a6
		JSRLIB	Disable
		movea.l	(SP)+,a6
	ELSEIF
		move.w	#$4000,$dff09a		; Master interrupt off
		addq.b	#1,meb_IDNestCnt(a6)	; INC counter
	ENDC
		rts

**************************************************************************
* Interrupts zulassen mit IDNestCnt und so

EnableFunc:
	IFD SYSTEM
		move.l	a6,-(SP)
		movea.l	4,a6
		JSRLIB	Enable
		movea.l	(SP)+,a6
	ELSEIF
		subq.b	#1,meb_IDNestCnt(a6)
		bge.s	1$
		move.w	#$c000,$dff09a
1$:
	ENDC
		rts

**************************************************************************
* Node ans Ende der Liste anhängen, A0: Liste, A1: Node

AddTailFunc:	movem.l	d0/a0/a1,-(SP)
		bsr.s	DisableFunc
		lea	lh_Tail(a0),a0
		move.l	ln_Pred(a0),d0
		move.l	a1,ln_Pred(a0)
		move.l	a0,ln_Succ(a1)
		move.l	d0,ln_Pred(a1)
		move.l	d0,a0
		move.l	a1,ln_Succ(a0)
		bsr.s	EnableFunc
		movem.l	(SP)+,d0/a0/a1
		rts

**************************************************************************
* Ersten Node aus Liste entfernen, A0: Liste gibt D0: Node, CCR

RemHeadFunc:	movem.l	a0/a1,-(SP)
		bsr.s	DisableFunc
		move.l	lh_Head(a0),a1
		move.l	ln_Succ(a1),d0
		beq.s	1$
		move.l	d0,lh_Head(a0)
		exg	d0,a1
		move.l	a0,ln_Pred(a1)
1$:		bsr.s	EnableFunc
		movem.l	(SP)+,a0/a1
		tst.l	d0
		rts	

**************************************************************************

		END
