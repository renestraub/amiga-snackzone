
		IDNT	SysCDisk
		SECTION	text,CODE

		INCLUDE	"MyExec.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"dos/dos.i"

		XREF	_DOSBase,@CheckFile

CRUNCH
;;PRINT

		XREF	RawPrintfFunc

	IFD CRUNCH
		XREF	PPDecrunch2
	ENDC

		XDEF	InitDiskFunc		; Disk-System initialisieren
		XDEF	SetNoDiskHandlerFunc
		XDEF	ReadFileFunc		; 'Datei' lesen
		XDEF	WriteFileFunc		; 'Datei' schreiben
		XDEF	LoadFileFunc		; Speicher reservieren & File lesen
		XDEF	LoadFastFileFunc	; FAST alloc   & File lesen
		XDEF	SendPacketFunc		; Asynchronen Lese-Request schicken


***************************************************************************
**                                                                       **
**   I N I T D I S K  -  Disk-System init, Recalibrate, Timer alloc ...  **
**                                                                       **
**   Parameter :  nix                                                    **
**                                                                       **
***************************************************************************

InitDiskFunc:	movem.l	d0/a0,-(SP)

		clr.l	InsertDiskRoutine

	*** DiskRequest-Liste initialisieren

		lea	meb_DiskList(a6),a0
		jsr	meb_NewList(a6)

		movem.l	(SP)+,d0/a0
		rts


***************************************************************************
**                                                                       **
**   S E T N O D I S K H A N D L E R  -  NoDisk-Handler setzen           **
**                                                                       **
**   Parameter :  A0.L:  InsertDisk-Handler oder 0                       **
**                                                                       **
***************************************************************************

SetNoDiskHandlerFunc:
		move.l	a0,InsertDiskRoutine
		rts


**************************************************************************
**                                                                      **
**   R E A D F I L E  -  'Datei' von Disk lesen & MFM-dekodieren        **
**                                                                      **
**   Parameter :  D0.L :  DiskAdresse (Disk/Track/Offset) der Datei     **
**                A0.L :  Ladeadresse                                   **
**                                                                      **
**   Resultat  :  D0.L :  Fehlernummer, 0 if successful                 **
**                Z-Bit:  gesetzt if OK, gelöscht wenn Fehler           **
**                                                                      **
**************************************************************************

ReadFileFunc:	movem.l	a0-a1,-(SP)
		lea	-dp_SIZEOF-2(SP),SP	; DiskPacket erstellen
		move.l	d0,dp_FileName(SP)
		move.l	a0,dp_Address(SP)
		movea.l	SP,a0			; A0 :  Packet
		lea	dp_SIZEOF(SP),a1	; A1 :  End-Flag
		clr.b	(a1)			; löschen
		move.l	a1,dp_Reply(a0)
		move.b	#DPF_REPLYBYTE,dp_Flags(a0)
		bsr.s	SendPacketFunc
1$:		tst.b	(a1)			; Warten bis File geladen!
		beq.s	1$
		lea	dp_SIZEOF+2(SP),SP	; DiskPacket freigeben
		moveq	#0,d0			; Success ** DEBUG **
		movem.l	(SP)+,a0-a1
		rts


**************************************************************************
**                                                                      **
**   L O A D F I L E  -  Speicher reservieren, Datei von Disk lesen     **
**                                                                      **
**   Parameter :  D0.L :  DiskAdresse (Disk/Track/Offset) der Datei     **
**                                                                      **
**   Resultat  :  D0.L :  Adresse des Files, 0 if error                 **
**                Z-Bit:  gelöscht wenn OK, gesetzt wenn Error          **
**                                                                      **
**************************************************************************

LoadFileFunc:	movem.l	d1/a0-a1,-(SP)
		moveq	#DPF_REPLYBYTE|DPF_ALLOCMEM,d1	; Packet Flags
		bra.s	DoLoadFile			   ; --->

LoadFastFileFunc:
		movem.l	d1/a0-a1,-(SP)
		moveq	#DPF_REPLYBYTE|DPF_ALLOCFASTMEM,d1 ; Packet Flags
	;;	bra.s	DoLoadFile			; --->

DoLoadFile:	lea	-dp_SIZEOF-2(SP),SP	; DiskPacket erstellen
		movea.l	SP,a0			; A0 :  Packet
		lea	dp_SIZEOF(SP),a1	; A1 :  End-Flag
		move.l	d0,dp_FileName(a0)
		clr.b	(a1)			; End-Flag löschen
		move.l	a1,dp_Reply(a0)
		move.b	d1,dp_Flags(a0)		; ReplyType & MemoryType
		bsr.s	SendPacketFunc
1$:		tst.b	(a1)			; Warten bis File geladen!
		beq.s	1$
		move.l	dp_Address(SP),d0	; Resultat: Adresse
		lea	dp_SIZEOF+2(SP),SP	; Doesn't change CCR
		movem.l	(SP)+,d1/a0-a1
		rts


**************************************************************************
**                                                                      **
**   S E N D P A C K E T  -  Asynchronen Read-Request aufgeben          **
**                                                                      **
**   Parameter :  A0.L :  Zeiger auf struct DiskPacket                  **
**                                                                      **
**   Resultat  :  nix                                                   **
**                                                                      **
**************************************************************************

SendPacketFunc:	movem.l	d7/a0-a1/a4-a5,-(SP)
		movea.l	a0,a1			; Packet
		lea	meb_DiskList(a6),a0
		jsr	meb_AddTail(a6)		; Packet anhängen
		bsr.s	ProcessNextRequest	; System ankicken
		movem.l	(SP)+,d7/a0-a1/a4-a5
		rts


**************************************************************************

	*** Nächsten Request aus Diskliste verarbeiten

ProcessNextRequest:
		movem.l	d0-d7/a0-a5,-(SP)

		lea	meb_DiskList(a6),a0
		jsr	meb_RemHead(a6)		; setzt CCR
		beq	.EndProcReq		; Kein Request pending --->
		movea.l	d0,a2			; A2 :  Aktuelles Packet

	*** Text ausgeben

	IFD PRINT
		moveq	#0,d0
		move.b	dp_Flags(a2),d0
		move.w	d0,-(SP)
		move.l	dp_FileName(a2),-(SP)
		pea	LoadingFmt(PC)
		bsr	RawPrintfFunc
		lea	10(SP),SP
	ENDC

	*** Packet bearbeiten

		movea.l	a6,a5			; A5 :  MyExecBase

		movea.l	dp_FileName(a2),a0
		bsr	@CheckFile
		move.l	d0,d6			; D2 :  File-Länge
		beq	.Error

		move.l	d6,dp_FileSize(a2)

	IFD	CRUNCH
		move.l	dp_FileName(a2),d1
		move.l	#MODE_OLDFILE,d2
		movea.l	_DOSBase,a6
		JSRLIB	Open
		move.l	d0,d7
		beq	.Error

		move.l	d7,d1
		move.l	#FileHeader,d2
		moveq.l	#4,d3
		JSRLIB	Read

		move.l	FileHeader,d0
		cmp.l	#$50503230,d0		* 'PP20'
		bne.s	2$

		bset.b	#DPB_CRUNCHED,dp_Flags(a2)

		move.l	d7,d1
		moveq.l	#-4,d2
		moveq.l	#OFFSET_END,d3
		JSRLIB	Seek

		move.l	d7,d1
		move.l	#FileHeader,d2
		moveq.l	#4,d3
		JSRLIB	Read

		move.l	FileHeader,d6
		lsr.l	#8,d6
		add.l	#PP_SAVEMARGIN,d6

2$:		move.l	d7,d1
		JSRLIB	Close

	ENDC
		btst.b	#DPB_ALLOCMEM,dp_Flags(a2) ; CHIP-Alloc gewünscht ?
		beq.s	.NoChipAlloc		; nein --->

		move.l	d6,d0			; File-Länge
		movea.l	a5,a6			; MyExecBase
		jsr	meb_AllocClearMem(a6)
		bra.s	.AllocCont		; --->

.NoChipAlloc:	btst.b	#DPB_ALLOCFASTMEM,dp_Flags(a2) ; FAST-Alloc gewünscht?
		beq.s	.NoFastAlloc		; nein --->

		move.l	d6,d0			; File-Länge
		movea.l	a5,a6			; MyExecBase
		jsr	meb_AllocFastClearMem(a6)

.AllocCont:	move.l	d0,dp_Address(a2)	; Adresse ins Packet

.NoFastAlloc:	move.l	dp_FileName(a2),d1
		move.l	#MODE_OLDFILE,d2
		movea.l	_DOSBase,a6
		JSRLIB	Open
		move.l	d0,d7
		beq.s	.Error

;		bne.s	1$
;		movea.l	dp_FileName(a2),a0
;		lea	df0buf,a1
;.copy:		move.b	(a0)+,(a1)+
;		bne.s	.copy

;		move.l	#buf,d1
;		JSRLIB	Open
;		move.l	d0,d7
;		beq.s	.Error


1$		move.l	d7,d1
		move.l	dp_Address(a2),d2
		move.l	#10000000,d3
		JSRLIB	Read

.EndLoad:	move.l	d7,d1
		JSRLIB	Close

		movea.l	a2,a0
		movea.l	a5,a6			; MyExecBase
		bsr.s	ReplyPacket		; Packet (A0) beantworten

.EndProcReq:	movem.l	(SP)+,d0-d7/a0-a5
		rts

.Error:		movea.l	a5,a6			; MyExecBase
		jmp	meb_ColdReboot(a6)	; Raus hier!

***************************************************************************

	*** Packet (A0) beantworten

ReplyPacket:	movem.l	d1/a0-a2,-(SP)
		movea.l	a0,a2			; A2 :  Packet

	*** Text ausgeben

	IFD PRINT
		move.l	dp_Address(a2),-(SP)
		pea	LoadedFmt(PC)
		bsr	RawPrintfFunc
		lea	8(SP),SP
	ENDC

	IFD CRUNCH
		btst.b	#DPB_CRUNCHED,dp_Flags(a2)
		beq.s	1$

		movea.l	dp_Address(a2),a0	; A0 :  Decrunch-Start
		move.l	dp_FileSize(a2),d0	; D0 :  File-Länge gecruncht
	;;	move.l	-4(a0,d0),d1
	;;	lsr.l	#8,d1
	;;	move.l	d1,dp_FileSize(A2)	; Echte Länge für User

		bsr	PPDecrunch2
1$:
	ENDC
		movea.l	dp_Reply(a2),a1		; A1 :  User's Reply-Adresse
		btst.b	#DPB_REPLYHANDLER,dp_Flags(a2)
		beq.s	2$

		movea.l	a2,a0			; A0 :  Packet für User
		jsr	(a1)			; ReplyHandler aufrufen
		bra.s	99$			; --->

2$:		btst.b	#DPB_REPLYBYTE,dp_Flags(a2)
		beq.s	3$

		st.b	(a1)			; ReplyByte setzen
	;;	bra.s	99$			; --->
3$:
99$:		movem.l	(SP)+,d1/a0-a2
		rts

**************************************************************************
**                                                                      **
**   W R I T E F I L E  -  Existierende 'Datei' auf Disk überschreiben  **
**                                                                      **
**   Parameter :  D0.L :  FN_-Konstante (von DiskMaker erzeugt)         **
**                A0.L :  Adresse der Daten für das File                **
**                                                                      **
**************************************************************************

WriteFileFunc:	rts


**************************************************************************
*             D A T E N  (auch im CODE-Segment wegen PC-relativ)         *
**************************************************************************

InsertDiskRoutine:	ds.l	1		; User's InsertDisk handler
FileHeader:		ds.l	1

LoadingFmt:	dc.b	"Loading '%s' (flags=$%02x) ... ",0
LoadedFmt:	dc.b	"0x%08lx",10,13,0

buf:		dc.b	"DF0:"
df0buf:		ds.b	64

		END
