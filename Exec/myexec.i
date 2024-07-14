**************************************************************************
**                                                                      **
**   MYEXEC  -  Verschiedene Routinen die so manches Programm braucht   **
**                                                                      **
**              by Christian A. Weber, Zurich/Switzwerland              **
**                                                                      **
**************************************************************************
**                                                                      **
**   Version 4.4, 16-Apr-92                                             **
**                                                                      **
**************************************************************************

		OPT	O+,OW-,O5-

		INCDIR	INCLUDE:
		INCDIR	H:
		INCLUDE	"exec/types.i"

STRUCTURES_I	SET	1		; Damit's kein Chaos gibt ;-)

PP_SAVEMARGIN:	EQU	32		; Anzahl PowerPacker-Sicherheitsbytes

**************************************************************************
* Beispiel: SYSCALL AllocMem

SYSCALL:	MACRO
		  XREF    _MyExecBase
		  MOVE.L  A6,-(SP)
		  MOVEA.L _MyExecBase,A6
		  JSR     meb_\1(A6)
		  MOVEA.L (SP)+,A6
		ENDM

**************************************************************************
* Beispiel: SYSJSR AllocMem (A6 muss auf _MyExecBase zeigen!)

SYSJSR:		MACRO
		  JSR     meb_\1(A6)
		ENDM

**************************************************************************
* Beispiel: SYSGET.b CheatFlag,D0

SYSGET:		MACRO
		  XREF    _MyExecBase
		  MOVE.L  A6,-(SP)
		  MOVEA.L _MyExecBase,A6
		  MOVE.\0 meb_\1(A6),\2
		  MOVEA.L (SP)+,A6
		ENDM

**************************************************************************
* Beispiel: SYSPUT.l D0,UserData1

SYSPUT:		MACRO
		  XREF    _MyExecBase
		  MOVE.L  A6,-(SP)
		  MOVEA.L _MyExecBase,A6
		  MOVE.\0 \1,meb_\2(A6)
		  MOVEA.L (SP)+,A6
		ENDM

**************************************************************************
* Beispiel: SYSLEA UserData1,A0

SYSLEA:		MACRO
		  XREF    _MyExecBase
		  MOVE.L  A6,-(SP)
		  MOVEA.L _MyExecBase,A6
		  LEA.L   meb_\1(A6),\2
		  MOVEA.L (SP)+,A6
		ENDM

**************************************************************************
* Beispiel: SYSTST.l TripleScreen

SYSTST:		MACRO
		  XREF     _MyExecBase
		  MOVE.L   A6,-(SP)
		  MOVEA.L  _MyExecBase,A6
		  TST.\0   meb_\1(A6)
		  MOVEA.L  (SP)+,A6
		ENDM

**************************************************************************

DISABLE		MACRO
		FAIL	Use SYSCALL Disable
		ENDM

ENABLE		MACRO
		FAIL	Use SYSCALL Enable
		ENDM


clra		MACRO
		  suba.l \1,\1
		ENDM

**************************************************************************

FUNCTION	MACRO
		 IFNE	SOFFSET&1
		  FAIL	 FUNCTION at odd address
		 ENDC
meb_\1		 EQU	SOFFSET
SOFFSET		 SET	SOFFSET+4
		ENDM

**************************************************************************
* MSG "Text" ruft ROMCrack mit "Text" auf

MSG		MACRO
		XREF	_MyExecBase
		bra.s	.msg1\@
.msg2\@:	dc.b	\1,0
		EVEN
.msg1\@:	move.l	a6,-(SP)
		movea.l	_MyExecBase,a6
		move.l	#.msg2\@,meb_ROMCrackDebugText	; NICHT (a6)!
		jsr	meb_Debug(a6)
		move.l	(SP)+,a6
		ENDM

**************************************************************************
* SMSG "Text" gibt "Text" auf serial port aus

SMSG		MACRO
		XREF	_MyExecBase
		bra.s	.smsg1\@
.smsg2\@:	dc.b	\1,0
		EVEN
.smsg1\@:	move.l	a6,-(SP)
		movea.l	_MyExecBase,a6
		pea	.smsg2\@(PC)
		jsr	meb_RawPrintf(a6)
		addq.w	#4,SP
		move.l	(SP)+,a6
		ENDM

**************************************************************************
* BTSTW: Testet ein Bit in einem WORD

BTSTW		MACRO

		IFNE	NARG-2
		FAIL	BTSW: Format= BTSTW bitno,<ea>
		ENDC

		IFGT	\1-8
		btst.b	#\1,\2
		ENDC

		IFLE	\1-8
		btst.b	#\1,1+\2
		ENDC

		ENDM

**************************************************************************

   STRUCTURE  Node,0

	APTR	ln_Succ
	APTR	ln_Pred
	UBYTE	ln_Type
	BYTE	ln_Pri
	APTR	ln_Name
	LABEL	ln_SIZEOF

**************************************************************************

   STRUCTURE MinNode,0

	APTR	mln_Succ
	APTR	mln_Pred
	LABEL	mln_SIZEOF

**************************************************************************

   STRUCTURE List,0

	APTR	lh_Head
	APTR	lh_Tail
	APTR	lh_TailPred
	UBYTE	lh_Type
	UBYTE	lh_pad
	LABEL	lh_SIZEOF

**************************************************************************

   STRUCTURE BitMap,0

	WORD	bm_BytesPerRow
	WORD	bm_Rows
	BYTE	bm_Flags
	BYTE	bm_Depth
	WORD	bm_Pad
	STRUCT	bm_Planes,8*4
	LABEL	bm_SIZEOF

**************************************************************************

   STRUCTURE DiskPacket,mln_SIZEOF	; Struktur für SendPacket()

	LONG	dp_FileName		; Filename von DiskMaker
	APTR	dp_Address		; Ladeadresse wenn nicht DPF_ALLOCMEM
	LONG	dp_FileSize		; Wird ausgefüllt von der Diskroutine
	APTR	dp_Reply		; Routine oder Flag-Adresse oder nix
	LONG	dp_UserData		; Frei benutzbar für den User
	BYTE	dp_Flags		; see DP-definitions below
	BYTE	dp_pad1			; Strukturlänge auf WORD aufrunden
	WORD	dp_pad2			; Strukturlänge auf LONG aufrunden :-)
	LABEL	dp_SIZEOF

	BITDEF	DP,REPLYHANDLER,0	; Reply ist Routine (jsr)
	BITDEF	DP,REPLYBYTE,1		; Reply ist Byte-Flag, wird $ff
	BITDEF	DP,ALLOCMEM,4		; CHIP wird automatisch reserviert
	BITDEF	DP,ALLOCFASTMEM,5	; FAST wird automatisch reserviert
	BITDEF	DP,CRUNCHED,6		; INTERNAL USE ONLY !!!
	BITDEF	DP,WRITE,7		; Auf Disk schreiben statt lesen

**************************************************************************

   STRUCTURE MemoryRegionHeader,0	; EXEC-PRIVATE STRUKTUR !

	APTR	mh_Lower		; Zeiger auf Anfang der Region
	APTR	mh_Upper		; Zeiger auf Ende der Region
	APTR	mh_First		; Zeiger auf 1. freien Chunk
	LONG	mh_Free			; Anzahl freie Bytes der Region
	LABEL	mh_SIZEOF

**************************************************************************

   STRUCTURE MemoryChunk,0		; EXEC-PRIVATE STRUKTUR !

	APTR	mc_Next			; Zeiger auf nächsten freien Chunk
	LONG	mc_Bytes		; Anzahl Bytes dieses Chunks
	LABEL	mc_SIZEOF

**************************************************************************

	*** AttentionFlag - Bits

	BITDEF	AF,68010,0	; also set for 68020+
	BITDEF	AF,68020,1	; also set for 68030+
	BITDEF	AF,68030,2	; also set for 68040+
	BITDEF	AF,68040,3
	BITDEF	AF,68881,4	; also set for 68882
	BITDEF	AF,68882,5

	*** Flag - Bits, only for internal use :-)

	BITDEF	EXEC,BUFENABLE,0
	BITDEF	EXEC,RESETREQUEST,4

**************************************************************************

   STRUCTURE MyExecBaseStruct,$100

	LONG	meb_ROMCRACKMagic	; 'NCLR' oder 'DBUG' oder 0
	LONG	meb_ROMCrackConfigMagic	; 'ICH!'
	APTR	meb_ROMCrackBSS
	APTR	meb_ROMCrackChipMem
	APTR	meb_ROMCrackDebugText	; ROMCrack's Debug-Text

   *** Private Einträge, SUBJECT TO CHANGE, NICHT BENUTZEN!

	STRUCT	meb_ChipMRHeader,mh_SIZEOF
	STRUCT	meb_FastMRHeader,mh_SIZEOF
	APTR	meb_RAMDiskBase
	LONG	meb_RAMDiskSize
	LONG	meb_MainPrgName
	LONG	meb_LastRnd1		; Beide müssen nacheinander stehen
	LONG	meb_LastRnd2
	STRUCT	meb_DiskList,lh_SIZEOF	; Die Packet-Liste
	STRUCT	meb_FileList,lh_SIZEOF	; Die File-Cache-Liste
	WORD	meb_ProductCode
	BYTE	meb_IDNestCnt
	BYTE	meb_ExecFlags		; siehe EXECF_...

   *** Erlaubte Einträge

	APTR	meb_SuperStackUpper	; SuperStack am Anfang (READ ONLY!)
	WORD	meb_AttnFlags		; Kopie von ExecBase->AttnFlags
	WORD	meb_SystemBplcon0	; Kopie von gfxbase->system_bplcon0
	BYTE	meb_VBlankFrequency	; Kopie von ExecBase->VBlankFrequency
	BYTE	meb_expad2

	BYTE	meb_ActualKey		; RawKeyCode
	BYTE	meb_ActualQualifiers	; Qualifier-Bits, (BitNr=KeyCode-$60)
	BYTE	meb_ActualASCIIKey	; ASCII-Code
	BYTE	meb_CheatFlag		; >0 falls Cheat mode on

	STRUCT	meb_BobList,lh_SIZEOF	; für die Bobroutine
	APTR	meb_TripleScreen	; für die Bobroutine
	WORD	meb_SignalSet		; für die Bobroutine

	LONG	meb_UserData1		; Frei für den User, am Anfang 0
	LONG	meb_UserData2		; Frei für den User, am Anfang 0

	STRUCT	meb_exreserved,6	; + pad auf LONG, NICHT benutzen!

   *** Level 3 Interrupt-Vektoren, zum Patchen oder 0 reinschreiben

	UWORD	meb_VBLIntPad
	UWORD	meb_VBLIntJump
	APTR	meb_VBLIntVector

	UWORD	meb_CopperIntPad
	UWORD	meb_CopperIntJump
	APTR	meb_CopperIntVector

   *** Cia-Interrupt-Vektoren, zum Patchen oder 0 reinschreiben

	APTR	meb_CiaATimerAVector
	APTR	meb_CiaATimerBVector
	APTR	meb_CiaAAlarmVector
	APTR	meb_CiaASerialVector
	APTR	meb_CiaAFlagVector

	APTR	meb_CiaBTimerAVector
	APTR	meb_CiaBTimerBVector
	APTR	meb_CiaBAlarmVector
	APTR	meb_CiaBSerialVector
	APTR	meb_CiaBFlagVector


   *** System-Funktionen (use at your own risk!)

	ULONG		meb_SecretMagic	; PRIVAT
	FUNCTION	InitExec	; (ExecEvent)		(CRP)
	FUNCTION	ColdReboot	; ()			()
	FUNCTION	InitChipMem	; (Address,Size)	(A0/D0)
	FUNCTION	InitFastMem	; (Address,Size)	(A0/D0)
	FUNCTION	InitDisk	; (Product)		(D0)
	FUNCTION	InitKey		; ()			()
	FUNCTION	SetCache	; (NewCacheBits)	(D0)

   *** Debug-Funktionen

	FUNCTION	Debug		; ()			()

   *** Speicherverwaltung

	FUNCTION	AllocMem	; (Amount)		(D0)
	FUNCTION	AllocClearMem	; (Amount)		(D0)
	FUNCTION	AllocFastMem	; (Amount)		(D0)
	FUNCTION	AllocFastClearMem ;(Amount)		(D0)
	FUNCTION	FreeMem		; (Address)		(A1)
	FUNCTION	AvailMem	; ()			()
	FUNCTION	AvailFastMem	; ()			()
	FUNCTION	CheckMem	; ()			()
	FUNCTION	CopyMem		; (Src,Dest,Len)	(A0/A1/D0)
	FUNCTION	CopyMemQuick	; (Src,Dest,Len)	(A0/A1/D0)
	FUNCTION	ClearMem	; (Address,Len)		(A0/D0)

   *** Semaphoren

	FUNCTION	Disable		; ()			()
	FUNCTION	Enable		; ()			()
	FUNCTION	OwnBlitter	; ()			()
	FUNCTION	DisownBlitter	; ()			()

   *** Listenverwaltung

	FUNCTION	NewList		; (List)		(A0)
	FUNCTION	Enqueue		; (List,Node)		(A0/A1)
	FUNCTION	Remove		; (Node)		(A1)
	FUNCTION	AddHead		; (List,Node)		(A0/A1)
	FUNCTION	AddTail		; (List,Node)		(A0/A1)
	FUNCTION	RemHead		; (List)		(A0)

   *** Tastatur

	FUNCTION	GetKey		; ()			()
	FUNCTION	WaitKey		; ()			()
	FUNCTION	FlushKeyBuf	; ()			()
	FUNCTION	SetMap		; (KeyMap oder 0)	(A0)
	FUNCTION	SetResetHandler	; (Handler)		(A0)
	FUNCTION	SetCheatText	; (RawKeyCodes)		(A0)

   *** Ausgabe

	FUNCTION	RawDoFmt	; (wie normal :-))	(...)
	FUNCTION	RawPrintf	; (Stack)		(...)
	FUNCTION	PlayCDTrack	; (TrackNumber)		(D0)
	FUNCTION	WaitCDTrack	; (nüt)			()

   *** Zufall

	FUNCTION	Randomize	; (Value1,Value2)	(D0/D1)
	FUNCTION	Random		; (Limit)		(D0)

   *** Disk-Routinen

	FUNCTION	SetNoDiskHandler ;(Routine)		(A0)
	FUNCTION	ReadFile	; (Name,Address)	(D0/A0)
	FUNCTION	WriteFile	; (Name,Address)	(D0/A0)
	FUNCTION	LoadFile	; (Name)		(D0)
	FUNCTION	LoadFastFile	; (Name)		(D0)
	FUNCTION	LoadSeg		; (Name)		(D0)
	FUNCTION	UnLoadSeg	; (Segment)		(A1)
	FUNCTION	BufReadFile	; (Name,Address		(D0/A0)
	FUNCTION	BufLoadFile	; (Name)		(D0)
	FUNCTION	DeleteFileNode	; (Name)		(D0)
	FUNCTION	DeleteFileList	; ()			()
	FUNCTION	SendPacket	; (Packet)		(A0)

   *** Bob-Routinen

	FUNCTION	WaitBlit	; (Custom)		(A5)
	FUNCTION	InitDrawBob	; (BitMap)		(A0)
	FUNCTION	AddBob		; (NewBob)		(A1)
	FUNCTION	RemBob		; (Bob)			(A0)
	FUNCTION	RemAllBobs	; ()			()
	FUNCTION	RestoreBobList	; (BitMap)		(A1)
	FUNCTION	DrawBobList	; (BitMap)		(A1)
	FUNCTION	RestoreOneBob	; (Bob,BitMap)		(A0/A1)
	FUNCTION	DrawOneBob	; (Bob,BitMap)		(A0/A1)
	FUNCTION	AnimateOneBob	; (Bob)			(A0)
	FUNCTION	MoveOneBob	; (Bob)			(A0)
	FUNCTION	TestPoint	; (X,Y)			(D0/D1)
	FUNCTION	SetMovePrg	; (Bob,MPrg,Speed,Step) (A0/A1/D0/D1)
	FUNCTION	SetAnimPrg	; (Bob,APrg,Speed)      (A0/A1/D0)
	FUNCTION	SetGlobalClip	; (X,Y)			(D0/D1)
	FUNCTION	HandleCollision	; ()			()
	FUNCTION	CollOneBob	; (Bob)			(A0)
	FUNCTION	FlashBob	; (Bob,Time,Color)	(A0/D0/D1)
	FUNCTION	GetBobData	; (Bob)			(A0)->A2

	LABEL	__EXECBASESIZE
