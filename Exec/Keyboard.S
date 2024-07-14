**************************************************************************
**                                                                      **
**    Keyboard.S  -  Routinen zum Keyboard-Handling ohne System         **
**                                                                      **
**************************************************************************
**                                                                      **
**   Modification History                                               **
**   --------------------                                               **
**                                                                      **
**   13-Jun-88   Created this file!                                     **
**   29-May-89   SetMap function added                                  **
**   06-Jun-89   SetResetHandler function added                         **
**   10-Nov-89   Numeric pad keys ()/*+- implemented                    **
**   30-Mar-90   HELP key no longer used to exit/reset                  **
**   30-Sep-90   Shift-Sternchen (Numeric Pad) ist ROMCrack-Einsprung   **
**   27-Feb-91   System-taugliche Version falls SYSTEM definiert        **
**                                                                      **
**************************************************************************

		IDNT	Keyboard
		SECTION	text,CODE

		INCLUDE	"MyExec.i"
		INCLUDE	"hardware/custom.i"

	IFD SYSTEM
		INCLUDE	"exec/macros.i"
		INCLUDE	"exec/io.i"
		INCLUDE "devices/input.i"
		INCLUDE "devices/inputevent.i"
	ENDC

		XREF	_custom,__MyExecBase

	IFD SYSTEM
		XREF	_idstring,@CreateIO,@DeleteIO
		XDEF	ExitKeyFunc
	ENDC
		XDEF	InitKeyFunc
		XDEF	GetKeyFunc,WaitKeyFunc,FlushKeyBufFunc
		XDEF	SetMapFunc,SetResetHandlerFunc,SetCheatTextFunc

KEYBUFSIZE:	EQU	40	; Grösse des Tastaturpuffers in Bytes

**************************************************************************
* Keyboard-Interrupt bzw. Input-Handler initialisieren

InitKeyFunc:
	IFD SYSTEM
		movem.l	d1/a0-a2/a6,-(SP)
		moveq.l	#IOSTD_SIZE,d0
		bsr	@CreateIO
		move.l	d0,InputIOReq
		beq.s	1$
		movea.l	d0,a2

		moveq	#0,d0			; Unit
		moveq	#0,d1			; Flags
		lea	InputName(PC),a0
		movea.l	a2,a1
		movea.l	4,a6
		JSRLIB	OpenDevice

		movea.l	a2,a1
		move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
		move.l	#MyInterrupt,IO_DATA(a1)
		JSRLIB	DoIO
1$:
		movem.l	(SP)+,d1/a0-a2/a6
	ELSEIF
		move.l	a0,-(SP)
		lea	KeyboardServer(PC),a0
		move.l	a0,meb_CiaASerialVector(a6)
		move.w	#$8008,_custom+intena	; Interrupt zulassen
		move.b	#$88,$bfed01		; Im CIA ICR auch
		move.l	(SP)+,a0
	ENDC
		rts

**************************************************************************
* Keyboard-Inputhandler wieder rausschmeissen

	IFD SYSTEM
ExitKeyFunc:	movem.l	d1-d2/a0-a1/a6,-(SP)
		move.l	InputIOReq,d2
		beq.s	1$
		movea.l	d2,a1
		move.w	#IND_REMHANDLER,IO_COMMAND(a1)
		move.l	#MyInterrupt,IO_DATA(a1)
		movea.l	4,a6
		JSRLIB	DoIO

		movea.l	d2,a1
		JSRLIB	CloseDevice

		movea.l	d2,a1			; IO-Request
	;;	MSG	<"Trying to DeleteIO (a1)">
	;;	bsr	@DeleteIO		; freigeben
		clr.l	InputIOReq
1$:
		movem.l	(SP)+,d1-d2/a0-a1/a6
		rts
	ENDC

**************************************************************************

	*** ASCII-Zeichen aus Tastaturpuffer lesen, Null falls nix gedrückt

GetKeyFunc:	movem.l	d1/a0,-(SP)
	IFD SYSTEM
		btst.b	#EXECB_RESETREQUEST,meb_ExecFlags(a6)
		beq.s	1$
		jmp	meb_ColdReboot(a6)
1$:
	ENDC
		moveq.l	#0,d0			; Default: Null
		move.w	KeyBufPtr,d1
		beq.s	.NoKey
		subq.w	#1,d1
		jsr	meb_Disable(a6)
		move.w	d1,KeyBufPtr
		lea	KeyBuf,a0
		move.b	(a0),d0			; nächstes Zeichen
2$:		move.b	1(a0),(a0)+		; Puffer verschieben
		dbf	d1,2$
		jsr	meb_Enable(a6)
.NoKey:		tst.b	d0			; key ok ? Z=0 : Z=1
		movem.l	(SP)+,d1/a0
		rts

**************************************************************************

	*** ASCII-Zeichen aus Tastaturpuffer lesen, warten falls nix parat

WaitKeyFunc:	bsr	GetKeyFunc
		bne.s	1$
		move.b	$bfe001,d0
		not.b	d0
		andi.b	#3,d0		; Knopf Port 0 oder 1 gedrückt ?
		beq.s	WaitKeyFunc	; Nein ---> loop
		moveq	#0,d0		; Gedrücktes Zeichen: 0
1$:		rts

**************************************************************************

	*** Tastaturpuffer leeren

FlushKeyBufFunc:
		clr.w	KeyBufPtr
		clr.b	meb_ActualQualifiers(a6) ; ** DEBUG **  billiges trick!
		rts

**************************************************************************

	*** Keymap (A0) setzen, Default falls A0 == 0

SetMapFunc:	movem.l	d0/a0,-(SP)
		move.l	a0,d0			; A0 == 0 ?
		bne.s	1$			; nein --->
		lea	DefaultKeyMap(PC),a0
1$:		move.l	a0,KeyMapPtr
		movem.l	(SP)+,d0/a0
		rts

**************************************************************************

	*** ResetHandler (A0) setzen, Default falls A0 == 0

SetResetHandlerFunc:
		movem.l	d0/a0,-(SP)
		move.l	a0,d0			; A0 == 0 ?
		bne.s	1$			; nein --->
		lea	meb_ColdReboot(a6),a0
1$:		move.l	a0,ResetHandler
		movem.l	(SP)+,d0/a0
		rts

**************************************************************************

	*** Cheat-Text (A0) setzen, Default falls A0 == 0

SetCheatTextFunc:
		movem.l	d0/a0,-(SP)
		move.l	a0,d0			; A0 == 0 ?
		bne.s	1$			; nein --->
		lea	DefaultCheatText,a0
1$:		move.l	a0,CheatTextPtr
		move.l	a0,CheatPtr
		movem.l	(SP)+,d0/a0
		rts

**************************************************************************

	*** IRQ-Routine der Tastatur, wird bei IRQ 2 (PORTS) angesprungen

KeyboardServer:
	IFD SYSTEM
		btst	#8,$dff016		; Mittlere Maustaste ?
		bne.s	0$			; nee
		move.l	a0,d0			; Sonst Handler beenden
		rts

0$:		movem.l	d1/a0-a3/a5-a6,-(SP)
		lea	_custom,a5
		movea.l	a1,a6			; A6: MyExecBase
		movea.l	a0,a1			; A1: EventChain
		suba.l	a2,a2			; A2: Vorheriges event
		movea.l	a0,a3			; A3: Neue chain

1$:		cmpi.b	#IECLASS_RAWKEY,ie_Class(a1)
		bne.s	2$
		move.w	ie_Code(a1),d0
		bsr	RawKeyConvert
		bsr	CheatTest
		bra.s	.delink
2$:
		cmpi.b	#IECLASS_RAWMOUSE,ie_Class(a1)
		bne.s	4$

.delink:	move.l	a2,d0			; 1. Event ?
		beq.s	3$			; ja --->
		move.l	ie_NextEvent(a1),ie_NextEvent(a2)
		bra.s	4$
3$:		movea.l	ie_NextEvent(a1),a3	
4$:
		movea.l	ie_NextEvent(a1),a1	; Nächstes Event
		move.l	a1,d0			; Liste fertig ?
		bne.s	1$			; nein ---> Loop

		bsr	ResetTest		; Reset-Handler nötig ?

		move.l	a3,d0
		movem.l	(SP)+,d1/a0-a3/a5-a6
		rts
	ELSEIF
		movem.l	d0-d7/a0-a5,-(SP)
		lea	_custom,a5

		moveq 	#0,d0
		move.b	$bfec01,d0		; read SDR
		bset.b	#6,$bfee01		; Quittierung starten
		not.b	d0
		ror.b	#1,d0			; up/down code ins Bit 7
		bsr	RawKeyConvert
		bsr	CheatTest

;;	IFD RAMVERSION
		cmpi.b	#$5D,d0			; Sternchen aufm Zahlenblock ?
		bne.s	.NoRC			; nein --->
		move.b	meb_ActualQualifiers(a6),d1
		andi.b	#3,d1			; left or right shift ?
		beq.s	.NoRC			; nein --->
		movem.l	(SP)+,d0-d7/a0-a5
		move.l	((6+1)*4)+2(SP),a0	; Rücksprungadresse vom Interrupt
		jsr	meb_Debug(a6)		; ROMCrack aufrufen
		movem.l	d0-d7/a0-a5,-(SP)
.NoRC:
;;	ENDC
		moveq	#15,d0			; 16 * 64 Mikrosec. warten
bratfett:	move.b	vhposr(a5),d1
1$:		cmp.b	vhposr(a5),d1
		beq.s	1$
		dbf	d0,bratfett

		bclr.b	#6,$bfee01		; Quittierung beenden
		bsr	ResetTest		; Reset-Handler nötig ?

		movem.l	(SP)+,d0-d7/a0-a5
		rts
	ENDC

**************************************************************************

	*** Raw-Code (D0.B) nach ActualKey und auch nach ASCII wandeln

RawKeyConvert:	ext.w	d0		; auf WORD erweitern für Index
		bmi	keyup		; Key Up --->

keydown:	cmpi.b	#$60,d0		; shift, alt, ctrl amiga etc. ?
		blt.s	1$		; nein --->
		cmpi.b	#$68,d0		; > $68 (Error, etc.) ?
		bge	keyerror	; ja --->
		bset.b	d0,meb_ActualQualifiers(a6) ; entspr. Bit setzen (0-7)
		bra	keyend
1$:
		move.b	d0,meb_ActualKey(a6)	; Raw-Code eintragen
		move.b	meb_ActualQualifiers(a6),d1
		andi.b	#7,d1		; left, right shift  or  caps lock?
		beq.s	2$		; nein --->
		addi.w	#$60,d0		; shift: Daten aus Tabelle 2
2$:		movea.l	KeyMapPtr,a0	; Zeiger auf aktuelle Keymap
		move.b	0(a0,d0.w),d0
		move.b	d0,meb_ActualASCIIKey(a6)
		beq.s	keyend		; wenn 0: ignorieren
		move.w	KeyBufPtr,d1	; D0 in den Tastaturpuffer
		cmpi.w	#KEYBUFSIZE,d1	; Tastaturpuffer voll?
		bge.s	3$		; ja --> Key ignorieren
		lea	KeyBuf,a0
		move.b	d0,0(a0,d1.w)
		addq.w	#1,KeyBufPtr	; Anzahl erhöhen
3$:		bra.s	keyend		; --->

keyup:		bclr	#7,d0		; Up/Down-Bit löschen
		cmpi.b	#$60,d0		; shift, alt, ctrl amiga etc. ?
		blt.s	dokeyup		; nein --->
		cmpi.b	#$68,d0		; > $68 (Error, etc.) ?
		bge.s	keyerror	; ja --->
		bclr.b	d0,meb_ActualQualifiers(a6) ; entspr. Bit löschen (0-7)
		bra.s	keyend

keyerror:	clr.b	meb_ActualQualifiers(a6)
dokeyup:	clr.b	meb_ActualKey(a6)
		clr.b	meb_ActualASCIIKey(a6)
keyend:		rts

**************************************************************************
* Testet Tastatur, ob CHEAT Mode angeschaltet werden soll 

CheatTest:	move.l	CheatPtr,a0		; nächstes Zeichen, das kommt
		move.b	meb_ActualKey(a6),d0	; Tastaturcode holen
		beq.s	3$			; nichts gedrückt --->
		cmp.b	(a0)+,d0		; richtiges Zeichen?
		bne.s	2$			; nein --->
		move.l	a0,CheatPtr		; dort gehts weiter
		tst.b	(a0)			; alle Zeichen eingegeben?
		bne.s	3$			; nein --->
		not.b	meb_CheatFlag(a6)	; Flag umdrehen
		move.w	#10000,d0
1$:		move.w	#$eef,color(a5)		; kurzes Flackern
		tst.w	vhposr(a5)		; Processor independant
		dbf	d0,1$
		move.w	#$000,color(a5)
2$:		move.l	CheatTextPtr,CheatPtr	; wieder vorne anfangen
3$:	 	rts

**************************************************************************

	*** Testet ob 2 der 3 Reset-Tasten gedrückt sind

ResetTest:	move.b	meb_ActualQualifiers(a6),d0
		andi.b	#%11001000,d0	; Nur Ctrl, LeftAmiga, RightAmiga
		cmpi.b	#%11000000,d0
		beq.s	1$
		cmpi.b	#%10001000,d0
		beq.s	1$
		cmpi.b	#%01001000,d0
		bne.s	2$
1$:
	IFD SYSTEM
		bset.b	#EXECB_RESETREQUEST,meb_ExecFlags(a6)
	ELSEIF
		movea.l	ResetHandler,a0
		jsr	(a0)
	ENDC
2$:
		rts

**************************************************************************

	*** KeyMap Ohne Shift (auch im CODE-Segment!)

DefaultKeyMap:
	dc.b	 96,049,050,051,052,053,054,055  ; 00-07 `1234567
	dc.b	 56,057,048,045,061,092,000,048  ; 08-0F 890-=\ 0
	dc.b	113,119,101,114,116,121,117,105	 ; 10-17 qwertyui
	dc.b	111,112,091,093,000,049,050,051  ; 18-1F op[] 123
	dc.b	 97,115,100,102,103,104,106,107	 ; 20-27 asdfghjk
	dc.b	108,059,039,036,000,052,053,054  ; 28-2F l;'$ 456 ($ on VSM)
	dc.b	 60,122,120,099,118,098,110,109	 ; 30-37 <zxcvbnm (< on VSM)
	dc.b	 44,046,047,000,046,055,056,057  ; 38-3F ,./ .789
	dc.b	 32,008,009,010,010,027,127,000  ; 40-47 SPCBSTABCR CRESCDELnix
	dc.b	 00,000,045,000,016,017,019,018  ; 48-4F nixnix-nix UPDWNFWBW
	dc.b	241,242,243,244,245,246,247,248  ; 50-57 f1-f8
	dc.b	249,250,040,041,047,042,043,021  ; 58-5F f9f10() /*+HELP (numpad)

	*** Mit Shift

	dc.b	126,033,064,035,036,037,094,038  ; 00-07 ~!@#$%^&
	dc.b	 42,040,041,000,043,124,000,048  ; 08-0F *()_+| 0
	dc.b	 81,087,069,082,084,089,085,073  ; 10-17 QWERTYUI
	dc.b	 79,080,123,125,000,049,050,051  ; 18-1F OP{} 123
	dc.b	 65,083,068,070,071,072,074,075  ; 20-27 ASDFGHJK
	dc.b	 76,058,034,092,000,052,053,054  ; 28-2F L:"Pfund 456 (Pfund on VSM)
	dc.b	 62,090,088,067,086,066,078,077  ; 30-37 >ZXCVBNM (> on VSM)
	dc.b	 60,062,063,000,000,055,056,057  ; 38-3F <>?  789
	dc.b	 32,008,009,000,000,000,127,000  ; 40-47 SPCBSTABCR CRESCDELnix
	dc.b	 00,000,000,000,016,017,019,018  ; 48-4F nixnixPADnix UPDWNFWBW
	dc.b	 00,000,000,000,000,000,000,000  ; 50-57 f1-f8
	dc.b	 00,000,000,000,000,000,000,021  ; 58-5F f9f10 5*nix HELP

**************************************************************************

	IFD SYSTEM
InputName:	dc.b	"input.device",0
		EVEN
	ENDC

		SECTION	Keyboard,DATA

CheatTextPtr:	dc.l	DefaultCheatText	; Zeiger auf Anfang
CheatPtr:	dc.l	DefaultCheatText	; Zeiger auf akt. Zeichen

DefaultCheatText:
		dc.b	$21,$33,$20,$37,$20,$24,$17,$33,0	; scamagic
		EVEN

ResetHandler:	dc.l	__MyExecBase+meb_ColdReboot
KeyMapPtr:	dc.l	DefaultKeyMap		; Zeiger auf aktuelle KeyMap
KeyBufPtr:	dc.w	0
KeyBuf:		dcb.b	KEYBUFSIZE+2,0
		EVEN

	IFD SYSTEM
MyInterrupt:	dc.l	0,0
		dc.b	0,120
		dc.l	_idstring	; LN_NAME
		dc.l	__MyExecBase	; IS_DATA
		dc.l	KeyboardServer	; IS_CODE

InputIOReq:	dc.l	0
	ENDC

		END
