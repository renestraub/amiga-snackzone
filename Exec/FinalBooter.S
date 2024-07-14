**************************************************************************
**                                                                      **
**  FinalBooter  -  Lädt und startet Exec.                              **
**                                                                      **
**************************************************************************
**                                                                      **
**   Modification History                                               **
**   --------------------                                               **
**                                                                      **
**   19-May-89  CHW  Created this file from Auto/Start.S                **
**   04-Jun-89  CHW  Testet jetzt ob RAMDisk vorhanden ist              **
**   20-Jun-89  CHW  Unterstützt jetzt 1MB CHIP-RAM wenn man's hat      **
**   21-Jun-89  CHW  ENV-Variable 'RAMDISKBASE' implementiert           **
**   27-Jun-89  CHW  Converted to genim2                                **
**   24-Aug-89  CHW  Disk-Version implemented                           **
**   30-Aug-89  CHW  Adapted from Start to FinalBooter                  **
**   27-Nov-89  CHW  Fast-RAM implemented                               **
**   15-Dec-89  CHW  Code cleaned up, setzt jetzt VBR auf 0 if 68010+   **
**   28-Mar-90  CHW  Abort springt nach ColdReset() statt $fc0002       **
**   01-Mar-91  CHW  Benutzt jetzt die System-Includefiles              **
**                                                                      **
**************************************************************************

		OPT	O+,OW-,O5-

		IDNT	FinalBooter
		SECTION	text,CODE

		INCLUDE	"exec/types.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"exec/memory.i"
		INCLUDE	"exec/nodes.i"
		INCLUDE	"exec/ports.i"
		INCLUDE	"exec/io.i"
		INCLUDE	"exec/execbase.i"
		INCLUDE	"devices/trackdisk.i"
		INCLUDE	"graphics/rastport.i"
		INCLUDE	"hardware/custom.i"

SUPERSTACK:	EQU	$80000-8		; LONGWORD-aligned
INITMAGIC:	EQU	'INIT'
EXECTRACKS:	EQU	3			; Anzahl Tracks für Exec
EXECSIZE:	EQU	(EXECTRACKS*11-2)*512
ABORT:		EQU	$1FFFFA

TRIALS:		EQU	3			; 3x versuchen pro Drive

		XREF	@Exit,_custom
		XDEF	@Main

**************************************************************************

		DCB.B	16,0
		DC.B	"Copyright (c) 1988-1991 by "
		DC.B	"Christian A. Weber, Zurich, Switzerland. "
		DC.B	"All rights reserved.",0
		DCB.B	6+16,0
		EVEN
@Main:
	*** Evtl. Warn-Requester ausgeben

		subq.l	#2,d0			; CLI mit Args ?
		bpl.s	1$			; ja ---> no warning
		bsr	ShowWarning
		beq.s	.Exit			; Cancel --->
1$:
	*** Globale Register initialisieren

		movem.l	InitRegs(PC),d5/d6/d7/a4/a5
		movea.l	4,a6

	*** Exec einladen

		moveq	#4*TRIALS-1,d4		; Anzahl Versuche * Units -1
		moveq	#0,d3			; Aktuelle Unit
.ReadIt:	bsr	ReadExec		; Exec laden
		bne.s	.Okay			; OK --->
		addq.w	#1,d3			; INC unit
		andi.w	#3,d3			; immer rund herum
		dbf	d4,.ReadIt		; ---> Loop
.Exit:		moveq	#20,d0			; Error-Code
		bra	@Exit			; ---> Raus
.Okay:
	*** System-Status für MyExec merken etc.

		move.w	AttnFlags(a6),d3	; FÜR MYEXEC!
		move.b	VBlankFrequency(a6),d2	; FÜR MYEXEC!

		lea	GfxName(PC),a1
		JSRLIB	OldOpenLibrary
		movea.l	d0,a0
		move.w	164(a0),d4		; FÜR MYEXEC!

	*** Chip-RAM-Obergrenze ermitteln und nach A4

MegaTest:	lea	$1000(a4),a1		; SuperStack+$1000
		JSRLIB	TypeOfMem
		andi.w	#MEMF_CHIP,d0		; auch Chip ?
		beq.s	1$			; Nein, nur 512K --->
		adda.l	#$10000,a4		; 64K mehr
		bra.s	MegaTest		; Weiter probieren
1$:
	*** Grössten Fast-RAM-Block reservieren und nach A2, Ende nach A3

		JSRLIB	Disable			; INTERRUPTS FUER IMMER WEG!

_getfast:	suba.l	a2,a2			; Default: No FAST RAM
		suba.l	a3,a3			; Grösse 0
		move.l	#MEMF_FAST|MEMF_LARGEST,d1
		JSRLIB	AvailMem		; FAST-RAM-Grösse bestimmen
		cmpi.l	#300000,d0		; genug damit sich's lohnt ?
		blo.s	1$			; nein --->
		movea.l	d0,a3			; Size
		moveq.l	#MEMF_FAST,d1
		JSRLIB	AllocMem
		movea.l	d0,a2			; A2: FastRAM-Base
		adda.l	d0,a3			; A3: FastRAM-End
1$:
	*** Supervisor-Mode, Interrupts sperren

_supie:		move.w	d7,dmacon(a5)
		move.w	d7,intena(a5)
		lea	1$(PC),a5
		JSRLIB	Supervisor
1$:		lea	_custom,a5
		move	#$2700,sr
		movea.l	a4,SP			; SupieStack init
		btst	#AFF_68010,d3		; 68010+ ?
		beq.s	2$			; nein --->
		suba.l	a0,a0
		DC.L	$4E7B8801		; movec.l a0,vbr
2$:
	*** MyExec installieren und starten

_installexec:	movea.l	d5,a0			; Source: Exec-Ladeadresse
		suba.l	a1,a1			; Destination: 0
		move.l	d6,d0			; ExecSize
	;;	bra.s	2$			; Für dbf, macht aber nix aus
1$:		move.b	(a0)+,(a1)+
2$:		dbf	d0,1$

		move.l	d3,d0			; AttnFlags
		move.l	d4,d1			; Bplcon0
		move.l	MyProduct(PC),d3	; Von DiskMaker eingetragen
		suba.l	a0,a0			; WICHTIG FüR CDISK !!
		suba.l	a1,a1			; WICHTIG FüR CDISK !!

		suba.l	a4,a4
3$:		cmpi.l	#INITMAGIC,(a4)
		beq.s	4$
		addq.l	#2,a4			; WORD-weise schreiten
		bra.s	3$
4$:
		move.l	a4,d6			; Adresse der Vektoren-4
		add.l	#$4ef80008,d6		; JMP<<16+4+4 (=2. Einspr.)
		move.l	d6,ABORT		; JMP ColdReset().W
		move.w	#$000,color(a5)
		jmp	4(a4)			; Tada! (=1. Einspr.)

**************************************************************************

ReadExec:

	*** IO-Request und Port initialisieren

_initio:	lea	MyPort,a0		; A0 :  The Port
		move.l	ThisTask(a6),MP_SIGTASK(a0)
		move.b	#NT_MSGPORT,LN_TYPE(a0)
	;;	move.b	#PA_SIGNAL,MP_FLAGS(a0)
		move.b	#17,MP_SIGBIT(a0)

		lea	MyIO,a2			; A2 :  The IO-Request
		move.b	#NT_MESSAGE,LN_TYPE(a2)
		move.w	#IOSTD_SIZE,MN_LENGTH(a2)
		move.l	a0,MN_REPLYPORT(a2)

		lea	MP_MSGLIST(a0),a0	; Die Message-Liste
		move.l	a0,LH_HEAD(a0)		; Macro NewList
		addq.l	#LH_TAIL,(a0)
	;;	clr.l	LH_TAIL(a0)
		move.l	a0,LH_TAILPRED(a0)

	*** Trackdisk.device öffnen

		move.l	d3,d0			; Unit number
		moveq	#0,d1			; Flags
		lea	TrackDiskName(PC),a0
		movea.l	a2,a1			; IOStdRequest Struktur
		JSRLIB	OpenDevice
		tst.l	d0			; OK ?
		bne.s	.ReadError		; nein --->

	*** Exec von Track 0 einlesen

		move.w	#CMD_READ,IO_COMMAND(a2)
		move.l	d6,IO_LENGTH(a2)	; ExecSize
		move.l	d5,IO_DATA(a2)		; ExecAdr
		moveq.l	#64,d0
		lsl.l	#4,d0			; Gibt 1024
		move.l	d0,IO_OFFSET(a2)
		movea.l	a2,a1			; IO-Request
		JSRLIB	DoIO
		tst.b	d0			; Error ?
		bne.s	.ReadError		; ja --->

	*** Motor abschalten

		move.w	#TD_MOTOR,IO_COMMAND(a2)
		clr.l	IO_LENGTH(a2)		; Motor off
		movea.l	a2,a1			; IO-Request
		JSRLIB	DoIO

	*** Test ob's unser Exec ist

		movea.l	d5,a0
		tst.l	(a0)			; Ist's unser Exec ?
		bne.s	.ReadError		; nein --->
		cmpi.l	#'CHW!',$c0(a0)		; Sicher ?
		beq.s	.ExecOK			; ja ---> Success

.ReadError:	moveq	#0,d2			; Error-Code: FAIL
		bra.s	1$			; --->

.ExecOK:	moveq	#1,d2			; Error-Code: SUCCESS

1$:		movea.l	a2,a1
		tst.l	IO_DEVICE(a1)
		bmi.s	2$
		JSRLIB	CloseDevice
2$:		move.l	d2,d0			; Set/Reset Z bit
		rts

**************************************************************************

ShowWarning:	lea	IntuiName(PC),a1
		movea.l	4,a6
		JSRLIB	OldOpenLibrary
		movea.l	d0,a6

		suba.l	a0,a0			; Window
		lea	body(PC),a1
		lea	ptext(PC),a2
		lea	ntext(PC),a3
		moveq.l	#0,d0			; pflag
		moveq.l	#0,d1			; nflag
		move.w	#530,d2			; width
		moveq.l	#78,d3			; height
		JSRLIB	AutoRequest
		tst.l	d0			; Z == CANCEL ? 1:0
		rts

**************************************************************************

GfxName:	dc.b	"graphics.library",0
IntuiName:	dc.b	"intuition.library",0
TrackDiskName:	dc.b	"trackdisk.device",0

		EVEN

InitRegs:	dc.l	ExecBSS			; D5 :  Exec-Ladeadresse
		dc.l	EXECSIZE		; D6 :  Exec-LadeGröße
		dc.l	$7fff			; D7 :  Int/DMADisable-Maske
		dc.l	SUPERSTACK		; A4 :  SuperStack
		dc.l	_custom			; A5 :  Custom


ProdMagic:	dc.l	'PROD'		; Muss vor MyProduct stehen
MyProduct:	dc.l	0		; Wird von DiskMaker eingesetzt

		EVEN
body:		dc.b	2,1,RP_JAM1,0
		dc.w	14,8
		dc.l	0,bodytext,body2

body2:		dc.b	2,1,RP_JAM1,0
		dc.w	14,18
		dc.l	0,body2text,body3

body3:		dc.b	2,1,RP_JAM1,0
		dc.w	14,28
		dc.l	0,body3text,0

ptext:		dc.b	2,1,RP_JAM2,0
		dc.w	6,3
		dc.l	0,ptexttext,0

ntext:		dc.b	2,1,RP_JAM2,0
		dc.w	6,3
		dc.l	0,ntexttext,0

bodytext:	dc.b	"WARNING: This program will shut down the Amiga's",0
body2text:	dc.b	"-------  multi-tasking system. Finish all running",0
body3text:	dc.b	"         programs before selecting 'START GAME' !",0
ptexttext:	dc.b	"START GAME",0
ntexttext:	dc.b	"CANCEL",0


		SECTION	bss,BSS

MyIO:		ds.b	IOSTD_SIZE+32

MyAttnFlags:	ds.w	1
MySysBplcon0:	ds.w	1
MyVBlankFreq:	ds.w	1

MyPort:		ds.b	MP_SIZE+32

		EVEN
ExecBSS:	ds.b	EXECSIZE+32	; Hierhin wird's geladen


		END
