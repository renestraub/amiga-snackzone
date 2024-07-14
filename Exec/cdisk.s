*****************************************************************************
**                                                                         **
**       C - D I S K  -  The ultimate Amiga Disk Control Software          **
**                                                                         **
**               (Lese- und Schreibroutinen ohne Blitter)                  **
**                                                                         **
**              by Christian A. Weber, Zürich/Switzwerland                 **
**                                                                         **
*****************************************************************************
**                                                                         **
**   Modification History                                                  **
**   --------------------                                                  **
**                                                                         **
**   13-Jan-88  V0.01  Project BDisk started                               **
**   05-Feb-88  V0.04  BDisk Last updated                                  **
**   27-May-88  V0.10  CDisk created from BDisk                            **
**   17-Aug-88  V1.01  First working version                               **
**   25-Aug-88  V1.02  Roottrack-bug fixed                                 **
**   04-Sep-88  V1.03  Disk length set from 6500 to 6650                   **
**   06-Sep-88  V2.01  Write-Routinen implementiert                        **
**   30-Oct-88  V2.02  Derselbe Track wird nicht mehr mehrmals gelesen     **
**   22-Nov-88  V2.03  Write-Bug korrigiert                                **
**   29-Jan-89  V2.04  Timeouts vergrössert für 68020                      **
**   10-Apr-89  V2.05  Labels angepasst, cleanup etc.                      **
**   26-Apr-89  V2.06  Kein 'MotorOff' wenn Unit nicht gefunden            **
**   29-Jun-89  V2.07  Angepasst an Genim2-Assembler                       **
**   01-Aug-89  V3.01  Völlig umgekrempelt, läuft jetzt im Interrupt       **
**   27-Aug-89  V3.10  Läuft nun endlich (fast) fehlerfrei im Interrupt    **
**   30-Aug-89  V3.15  RAMDisk-Routinen auch hier eingebaut                **
**   01-Sep-89  V3.20  Unterstützt FFS-RAMDrive                            **
**   02-Sep-89  V3.21  ReadyTimeOut implementiert                          **
**   27-Nov-89  V3.22  LoadFastFile() implementiert                        **
**   21-Mar-90  V3.23  Code aufgeräumt, alte RAM-Disk rausgeworfen         **
**   29-Dec-90  V3.24  Gecrunchte Files werden automatisch entcruncht      **
**   06-May-91  V4.00  Tada! Schreibroutine eingebaut                      **
**   16-Apr-92  V4.01  PP_SAVEMARGIN added, PowerPacker jetzt 100%         **
**                                                                         **
*****************************************************************************

		IDNT	CDisk
		SECTION	text,CODE

CRUNCH

;;DEBUG
;;LIGHTSHOW

	IFD DEBUG
DERR_DRIVENOTREADY:	EQU	$21
DERR_DMATIMEOUT:	EQU	$22
DERR_NOSYNC:		EQU	$23
DERR_BADCHECKSUM:	EQU	$24
DERR_BADTRACK:		EQU	$25
DERR_WRONGDISK:		EQU	$26
DERR_WRONGPRODUCT:	EQU	$27
	ENDC

CUSTOMOFFSET:	EQU	$19BE

		INCLUDE	"MyExec.i"

	;;	INCLUDE	"relcustom.i"
		INCLUDE	"protcustom.i"

		INCLUDE	"hardware/intbits.i"
		INCLUDE	"hardware/cia.i"

	IFD RAMVERSION
		XREF	ProcessFFSPacket	; Für ramdrive.device
	ENDC

	IFD CRUNCH
		XREF	PPDecrunch
	ENDC

		XDEF	InitDiskFunc	; Disk-System initialisieren
		XDEF	SetNoDiskHandlerFunc
		XDEF	ReadFileFunc	; 'Datei' lesen
		XDEF	LoadFileFunc	; Speicher reservieren & File lesen
		XDEF	LoadFastFileFunc	; FAST alloc   & File lesen
		XDEF	WriteFileFunc	; 'Datei' schreiben
		XDEF	SendPacketFunc	; Asynchronen Lese-Request schicken

***************************************************************************

ciabase:	EQU	$bfd000-$16ff	; scramble disassemblies
a_pra:		EQU	$bfe001-ciabase
a_talo:		EQU	$bfe401-ciabase
a_tahi:		EQU	$bfe501-ciabase
a_icr:		EQU	$bfed01-ciabase
a_cra:		EQU	$bfee01-ciabase
b_prb:		EQU	$bfd100-ciabase
b_icr:		EQU	$bfdd00-ciabase

***************************************************************************

TIMERRATE:	EQU	2836		; Taktrate der Diskroutine
DMATIME:	EQU	25000		; Max. # Ticks zum Read/Write von 1 Spur
READYTIME:	EQU	2800		; Max. # Ticks bis DriveReady kommt
READBYTES:	EQU	6800		; Anzahl zu lesende MFM-Words
WRITEBYTES:	EQU	6300		; Anzahl zu schreibende MFM-Words ohne Gap
TRACKBUFSIZE:	EQU	16300		; Größe des gesamten Buffers
GAPBYTES:	EQU	1664		; Größe der Track-Gap in Bytes
TRIALS:		EQU	5		; Anzahl Versuche bei r/w error
MAXUNITS:	EQU	4		; Maximale Anzahl Drives

DISKMAGIC:	EQU	$43485700	; Currently 'CHW',0
FFSMAGIC:	EQU	$444f5301	; 'DOS',1
FN_HEADER:	EQU	$7f030000	; Disk <??> Track <2> Offset <0>

***************************************************************************

	*** Die Disk-Header-Struktur, wird von Disk eingelesen

   STRUCTURE DiskHeader,0

	LONG	dh_DiskMagic		; Disk-Magic, muss DISKMAGIC sein
	WORD	dh_ProductKey		; Identifikation des Produkts
	WORD	dh_DiskNumber		; Nummer der Disk oder 0 = no disk
	STRUCT	dh_Reserved,8		; 8 Bytes Future Expansion

   LABEL dh_SIZEOF

***************************************************************************

	*** Die Disk-Unit-Struktur, existiert für jedes Laufwerk

   STRUCTURE DiskUnit,0

	APTR	du_MFMBuffer		; Zeiger auf 16K CHIP-RAM
	WORD	du_DiskNumber		; Disk-Nummer oder 0 wenn ungültig
	WORD	du_CurrentTrack		; Aktueller TRACK (0..159)
	WORD	du_DestTrack		; Ziel-Spur
	WORD	du_TrackSize		; Anzahl Bytes der gelesenen Spur
	WORD	du_Sync			; Sync-Wert für dieses Drive
	LONG	du_FileName		; DiskMaker-Filename
	APTR	du_DestAddr		; Aktuelle Ladeadresse
	LONG	du_FileSize		; Größe des aktuellen Files
	APTR	du_ActPacket		; Zeiger auf aktuelles Packet
	WORD	du_TimeOutCntr		; TimeOut-Zähler für Read
	BYTE	du_Status		; Siehe DS_ - Definitionen
	BYTE	du_OnMask		; Motor On,  z.B. $01101111 für df1
	BYTE	du_OffMask		; Motor Off, z.B. $11101111 für df1
	BYTE	du_RetryCntr		; Zähler für Retry

   LABEL du_SIZEOF			; Größe dieser Struktur


	*** Werte für DiskUnit.du_Status (IN 2ERSCHRITTEN ALS INDEX!!)

DS_IDLE:	EQU	0	; Unit hat nichts zu tun
DS_RECALIBRATE:	EQU	2	; Unit ist am auf Track 0 zurücksteppen
DS_STEP:	EQU	4	; Laufwerk ist am steppen
DS_SETTLE:	EQU	6	; Laufwerk hat fertiggesteppt, DMA starten
DS_WAITDMA:	EQU	8	; Wir warten auf's Read/Write-DMA-Ende

DSF_WRITING:	EQU	$80	; Schreib-Flag (MUSS $80 sein für tst.b!)


***************************************************************************
**                                                                       **
**   I N I T D I S K  -  Disk-System init, Recalibrate, Timer alloc ...  **
**                                                                       **
**   Parameter :  nix                                                    **
**                                                                       **
***************************************************************************

InitDiskFunc:	movem.l	d0-d7/a0-a5,-(SP)

		bsr	GetD7A4A5		; Get BitMask,CiaBase,Custom
		clr.l	InsertDiskRoutine	; InsertDisker retten

	*** UnitPointer-Tabelle löschen

		lea	UnitTab(PC),a0
		moveq	#16,d0			; 4 Pointers
		jsr	meb_ClearMem(a6)	; löschen

	*** MFM-Buffer holen, Track-Gap und ½ Sync erzeugen für Write

		move.l	#TRACKBUFSIZE,d0	; Amount
		jsr	meb_AllocMem(a6)	; CHIP-RAM reservieren
		movea.l	d0,a0			; A0 :  MFM-Buffer
		lea	GAPBYTES(a0),a1		; Buffer-Start für Read
		move.l	a1,MFMBuffer

		move.l	d7,d0			; $55555555
		add.l	d0,d0			; $aaaaaaaa
		move.w	#TRACKBUFSIZE/4-1,d2
2$:		move.l	d0,(a0)+
		dbf	d2,2$
		move.w	#$4489*2,-(a1)		; ½ SYNC
		lsr.w	(a1)			; gegen die Cracker

	*** Unit-Strukturen für angeschlossene Laufwerke erstellen

checkdrives:	lea	UnitTab(PC),a2		; Zeiger auf Units
		moveq	#MAXUNITS-1,d3		; Anzahl Laufwerke zu suchen
		move.b	#%11110111,d2		; D2 := Select-Maske DF0
		bra.s	2$			; DF0 ist immer da

1$:		bsr	CheckUnit		; Testen ob Unit angeschlossen
		tst.b	d0			; 3.5"-Drive vorhanden ?
		bne.s	3$			; nein --->

2$:		moveq.l	#du_SIZEOF,d0		; Größe einer Unit
		jsr	meb_AllocFastClearMem(a6) ; Unit allozieren
		movea.l	d0,a3			; Unit merken
		move.l	a3,(a2)+		; und in Tabelle eintragen

		move.l	#$4489*6337,d0		; Gegen Cracker
		move.l	MFMBuffer,du_MFMBuffer(a3)
	;;	clr.w	du_DiskNumber(a3)	; Keine Disk in diesem Drive
	;;	clr.w	du_CurrentTrack(a3)
	;;	clr.w	du_DestTrack(a3)
	;;	clr.w	du_TrackSize(a3)	; 0 = ungültig
		divs.w	#6337,d0		; Gibt $4489
		move.w	d0,du_Sync(a3)
	;;	move.b	#DS_IDLE,du_Status(a3)	; Drive schläft
		move.b	d2,du_OffMask(a3)
		move.b	d2,du_OnMask(a3)
		bclr.b	#CIAB_DSKMOTOR,du_OnMask(a3)

3$:		rol.b	#1,d2			; SEL für nächstes Drive
		dbf	d3,1$			; ---> Für alle Drives

	*** Alle Motoren abschalten

		st.b	b_prb(a4)		; Deselect all
		bsr	ShortDelay
		move.b	#%10000111,b_prb(a4)	; Select all
		bsr	ShortDelay
		st.b	b_prb(a4)		; Deselect all

	*** DiskRequest-Liste initialisieren

		lea	meb_DiskList(a6),a0
		jsr	meb_NewList(a6)

	*** Timer initialisieren, TimerInterrupt-Handler installieren

		lea	MyTimerHandler(PC),a0
		move.l	a0,meb_CiaATimerAVector(a6)
		andi.b	#%11100110,a_cra(a4)	; Timer A Continuous
		move.b	#TIMERRATE&$ff,a_talo(a4)
		move.b	#TIMERRATE>>8,a_tahi(a4)
		ori.b	#%00010001,a_cra(a4)	; Timer A ForceLoad|Start

		move.w	#$8008,intena(a5)	; PORTS-Interrupt on
		move.b	#$81,$bfed01		; Im CIA ICR auch
		move.w	#$8010,dmacon(a5)	; Disk DMA enable

		movem.l	(SP)+,d0-d7/a0-a5
		rts

***************************************************************************

	*** Testen ob Laufwerk mit Select-Maske in D2 vorhanden ist

CheckUnit:	lea	b_prb(a4),a0
		moveq	#$7f,d0			; Alle Drives deselektieren
		move.b	d0,(a0)
		bsr	ShortDelay
		and.b	d2,d0			; Select-Bit löschen
		move.b	d0,(a0)			; Select Drive, Motor on
		bsr	ShortDelay
		st.b	(a0)			; Laufwerk deselektieren
		bsr	ShortDelay
		move.b	d2,(a0)			; Select Drive, Motor off
		bsr	ShortDelay
		st.b	(a0)			; Laufwerk deselektieren

		moveq	#31,d1			; 32 Bits
		moveq.l	#0,d0			; Ergebnis löschen
1$:		add.l	d0,d0			; Ergebnis 1 nach links
		move.b	d2,(a0)			; Laufwerk selektieren
		bsr	ShortDelay
		btst.b	#5,a_pra(a4)		; Disk Ready ?
		beq.s	2$			; RDY==0 ---> Drive vorhanden
		bset	#0,d0			; Sonst Bit 0 in D0 setzen
2$:		st.b	(a0)			; Motor ausschalten
		bsr	ShortDelay
		dbf	d1,1$			; loop --->
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


***************************************************************************
**                                                                       **
**   R E A D F I L E  -  Datei von Disk an angegebene Adresse laden      **
**                                                                       **
**   Parameter :  D0.L :  DiskAdresse (Disk/Track/Offset) der Datei      **
**                A0.L :  Ladeadresse                                    **
**                                                                       **
**   Resultat  :  nix                                                    **
**                                                                       **
***************************************************************************

ReadFileFunc:	movem.l	d1/a0-a1,-(SP)
		moveq	#0|DPF_REPLYBYTE,d1		; LESEN
		bra.s	APost				; Paket aufgeben


***************************************************************************
**                                                                       **
**   W R I T E F I L E  -  Existierende 'Datei' auf Disk überschreiben   **
**                                                                       **
**   Parameter :  D0.L :  DiskAdresse (Disk/Track/Offset) der Datei      **
**                A0.L :  Adresse der Daten für das File                 **
**                                                                       **
**   Resultat  :  nix                                                    **
**                                                                       **
***************************************************************************

WriteFileFunc:	movem.l	d1/a0-a1,-(SP)
		move.b	#DPF_WRITE|DPF_REPLYBYTE,d1	; SCHREIBEN
		bra.s	APost				; Paket aufgeben


***************************************************************************
**                                                                       **
**   L O A D F I L E  -  Speicher reservieren, Datei von Disk lesen      **
**                                                                       **
**   Parameter :  D0.L :  DiskAdresse (Disk/Track/Offset) der Datei      **
**                                                                       **
**   Resultat  :  D0.L :  Adresse des Files, 0 if error                  **
**                Z-Bit:  gelöscht wenn OK, gesetzt wenn Error           **
**                                                                       **
***************************************************************************

LoadFileFunc:	movem.l	d1/a0-a1,-(SP)
		moveq	#DPF_REPLYBYTE|DPF_ALLOCMEM,d1	; Packet Flags
		bra.s	APost				; Paket aufgeben

LoadFastFileFunc:
		movem.l	d1/a0-a1,-(SP)
		moveq	#DPF_REPLYBYTE|DPF_ALLOCFASTMEM,d1 ; Packet Flags
	;;	bra.s	APost				; Paket aufgeben


APost:		lea	-dp_SIZEOF-2(SP),SP	; DiskPacket erstellen
		move.l	a0,dp_Address(SP)	; Ladeadresse eintragen
		movea.l	SP,a0			; A0 :  Packet
		move.l	d0,dp_FileName(a0)	; Dateinamen eintragen
		lea	dp_SIZEOF(SP),a1	; A1 :  End-Flag
		clr.b	(a1)			; löschen
		move.l	a1,dp_Reply(a0)
		move.b	d1,dp_Flags(a0)		; DPF_REPLYBYTE [|DPF_WRITE] usw.
		bsr.s	SendPacketFunc
1$:		tst.b	(a1)			; Warten bis File geladen/geschrieben
		beq.s	1$
		move.l	dp_Address(SP),d0	; Resultat: Adresse
		lea	dp_SIZEOF+2(SP),SP	; DiskPacket freigeben
		movem.l	(SP)+,d1/a0-a1
		rts


***************************************************************************
**                                                                       **
**   S E N D P A C K E T  -  Asynchronen Read-Request aufgeben           **
**                                                                       **
**   Parameter :  A0.L :  Zeiger auf struct DiskPacket                   **
**                                                                       **
**   Resultat  :  nix                                                    **
**                                                                       **
***************************************************************************

SendPacketFunc:	movem.l	d7/a0-a1/a4-a5,-(SP)
		bsr	GetD7A4A5		; Für ProcessNextRequest()
		movea.l	a0,a1			; Packet
		lea	meb_DiskList(a6),a0
		jsr	meb_AddTail(a6)		; Packet anhängen
		bsr.s	ProcessNextRequest	; System ankicken
		movem.l	(SP)+,d7/a0-a1/a4-a5
		rts


***************************************************************************

	*** Nächsten Request aus Diskliste verarbeiten

ProcessNextRequest:
		movem.l	d0-d2/a0-a2/a3,-(SP)
		move.l	ActUnit(PC),d0		; Working? (tst.l ActUnit(PC))
		bne	.EndProcReq		; ja --->
		lea	meb_DiskList(a6),a0
		jsr	meb_RemHead(a6)		; setzt CCR
		beq	.EndProcReq		; Kein Request pending --->
		movea.l	d0,a2			; A2 :  Aktuelles Packet

	*** Falls RAM-Disk erlaubt: RAMDisk-Request bearbeiten

		moveq.l	#0,d2
		move.b	dp_FileName(a2),d2	; D2 :  DiskNumber

   IFD RAMVERSION
		movea.l	a2,a0			; A0: Packet
		movea.l	meb_RAMDiskBase(a6),a1	; Filename=RAM-Basis
		cmpi.l	#FFSMAGIC,(a1)		; RAM-Disk in Ordnung ?
		beq.s	1$			; ja --->
		MSG	<"RAMDISK CORRUPT, A0=PACKET, A1=BASE">
1$:		bsr	ProcessFFSPacket	; Packet (A0) bearbeiten (FFS)
		bsr	ReplyPacket		; Packet (A0) beantworten
		bra	.EndProcReq		; --->
   ENDC

	*** Drives nach gewünschter Disk absuchen

.SearchDisk:	moveq.l	#MAXUNITS-1,d0		; 4 Units maximal
		lea	UnitTab(PC),a1		; Start des Pointer-Arrays
4$:		move.l	(a1)+,d1		; Get next unit
		beq.s	5$			; 0 ---> Unit überhüpfen
		movea.l	d1,a3
		cmp.w	du_DiskNumber(a3),d2	; Disk in diesem Drive ?
		beq.s	.DiskFound		; ja --->
5$:		dbf	d0,4$			; sonst nächstes Drive testen

	*** Disk nicht gefunden: Header aller Drives einlesen

		moveq.l	#MAXUNITS-1,d0		; 4 Units maximal
		lea	UnitTab(PC),a1		; Start des Pointer-Arrays
6$:		move.l	(a1)+,d1		; Get next unit
		beq.s	7$			; 0 ---> Unit überhüpfen
		movea.l	d1,a3
		bsr	GetHeader		; DiskHeader einlesen
		cmp.w	du_DiskNumber(a3),d2	; Disk in diesem Drive ?
		beq.s	.DiskFound		; ja --->
7$:		dbf	d0,6$			; sonst nächstes Drive testen

	*** Disk nicht gefunden: User-Routine aufrufen oder weiter probieren

		move.l	InsertDiskRoutine(PC),d1 ; von InitDisk()
		beq.s	8$
		movea.l	d1,a1
		move.l	d2,d0			; Disk-Nummer für User
		move.l	dp_FileName(a2),d1	; Filename für User
		jsr	(a1)			; User-Routine aufrufen
8$:
		bra.s	.SearchDisk		; ---> Loop

	*** Disk gefunden: Packet an Unit (a3) schicken

.DiskFound:	move.l	a2,du_ActPacket(a3)	; Dieses Packet war's!
		move.l	dp_FileName(a2),du_FileName(a3)
		move.l	dp_Address(a2),du_DestAddr(a3)
		bsr.s	StartUnit

.EndProcReq:	movem.l	(SP)+,d0-d2/a0-a2/a3
		rts

***************************************************************************

	*** Header einer Disk (a3) lesen und eintragen

GetHeader:	movem.l	d0-d2/a0-a1,-(SP)
		lea	-dh_SIZEOF-16(SP),SP	; Platz für Header

		clr.w	du_DiskNumber(a3)	; Markierung für RawRead()
		move.l	#FN_HEADER,du_FileName(a3) ; Header-'Name'
		bsr.s	StartUnit

		move	sr,d0			; ** DEBUG **
		move	#$2000,sr		; ** DEBUG **
1$:		stop	#$2000			; Auf Interrupt warten
		cmpi.b	#DS_IDLE,du_Status(a3)	; Fertig ?
		bne.s	1$			; nein --->
		move	d0,sr			; ** DEBUG **

		movea.l	du_MFMBuffer(a3),a0
		lea	2+16(a0),a0		; Start des DiskHeaders
		movea.l	SP,a1			; Destination
		moveq	#dh_SIZEOF,d0		; Anzahl Bytes
		bsr	MFMDecode

		cmpi.l	#DISKMAGIC,dh_DiskMagic(SP)
		bne.s	99$			  ; Keine CDisk-Disk --->
		move.w	meb_ProductCode(a6),d0
		beq.s	2$			; Produkt-Egal-Magic --->
		cmp.w	dh_ProductKey(SP),d0
		bne.s	99$
2$:		move.w	dh_DiskNumber(SP),du_DiskNumber(a3)	; Tada!

99$:		lea	dh_SIZEOF+16(SP),SP	; Header freigeben
		movem.l	(SP)+,d0-d2/a0-a1
		rts


***************************************************************************

	*** Unit (a3) starten

StartUnit:	move.l	d0,-(SP)
		clr.l	du_FileSize(a3)			; Länge := 0
		move.b	#TRIALS,du_RetryCntr(a3)	; # Versuche setzen
		move.w	du_FileName(a3),d0		; Disk# & Track (.W)
		andi.w	#$ff,d0
		move.w	d0,du_DestTrack(a3)
		move.b	#$7f,b_prb(a4)			; Motor on
		bsr	ShortDelay
		move.b	du_OnMask(a3),b_prb(a4)		; Motor on & Select
		move.b	#DS_STEP,du_Status(a3)		; Schreiten!
		tst.w	du_CurrentTrack(a3)
		bgt.s	1$				; Spur > 0 --->
		move.b	#DS_RECALIBRATE,du_Status(a3)	; 1. Mal: recalibrate
1$:		move.l	a3,ActUnit			; Tada!
		move.l	(SP)+,d0
		rts

***************************************************************************

	*** Packet (A0) beantworten

ReplyPacket:	movem.l	a0-a2,-(SP)
		movea.l	a0,a2			; A2 :  Packet

	IFD CRUNCH
		bclr.b	#DPB_CRUNCHED,dp_Flags(a2)
		beq.s	1$
		movea.l	dp_Address(a2),a0	; A0 :  Start der gecrunchten Daten
		move.l	dp_FileSize(a2),d0	; D0 :  File-Länge gecruncht
		move.l	(a0),dp_FileSize(a2)	; Echte Länge für User
		bsr	PPDecrunch		; File decrunchen
1$:
	ENDC
		movea.l	dp_Reply(a2),a1		; A1 :  User's Reply-Adresse
		btst.b	#DPB_REPLYHANDLER,dp_Flags(a2)
		beq.s	2$
		movea.l	a2,a0			; A0 :  Packet für User
		jsr	(a1)			; ReplyHandler aufrufen
		bra.s	99$			; --->
2$:
		btst.b	#DPB_REPLYBYTE,dp_Flags(a2)
		beq.s	3$
		st.b	(a1)			; ReplyByte setzen
	;;	bra.s	99$			; --->
3$:
99$:		movem.l	(SP)+,a0-a2
		rts


***************************************************************************
**                                                                       **
**   TimerInterrupt-Handler: Kommandos auswerten und ausführen           **
**                                                                       **
***************************************************************************

MyTimerHandler:	movem.l	d0-d7/a0-a5,-(SP)
		move.l	ActUnit(PC),d0		; Gibt's Arbeit ?
		beq.s	99$			; nein --->
		bsr	GetD7A4A5		; Get BitMask,Custom,CiaBase
		movea.l	d0,a3			; a3 :  Unit
		move.b	du_Status(a3),d0	; Action to take
		andi.w	#$000f,d0		; Flag-Bits interessieren nicht
		lea	.ComTable(PC),a0	; Command offset table
		adda.w	0(a0,d0.w),a0		; plus actual command offset
	IFD LIGHTSHOW
		move.w	#$ff0,$dff180
	ENDC
		jsr	(a0)			; Go do the code
	IFD LIGHTSHOW
		move.w	#$000,$dff180
	ENDC
99$:		movem.l	(SP)+,d0-d7/a0-a5
		rts

.ComTable:	dc.w	DoIdle-.ComTable	; DS_IDLE
		dc.w	DoReCalibrate-.ComTable	; DS_RECALIBRATE
		dc.w	DoStep-.ComTable	; DS_STEP
		dc.w	DoSettle-.ComTable	; DS_SETTLE
		dc.w	DoWaitDMA-.ComTable	; DS_WAITDMA

***************************************************************************

	*** Kommando DS_IDLE: nix machen

DoIdle:
	IFD LIGHTSHOW
		move.w	#$f00,color(a5)		; rot
	ENDC
		rts

***************************************************************************

	*** Kommando DS_RECALIBRATE: Auf Track 0 zurückfahren

DoReCalibrate:
	IFD LIGHTSHOW
		move.w	#$0f0,color(a5)			; grün
	ENDC
		clr.w	du_TrackSize(a3)		; Track ist ungültig
		btst.b	#CIAB_DSKTRACK0,a_pra(a4)	; Track 0 ?
		beq.s	.ReCalFin			; ja --->
		bset.b	#CIAB_DSKDIREC,b_prb(a4)	; Nach Aussen
		bclr.b	#CIAB_DSKSTEP,b_prb(a4)		; Steppen
		bsr	ShortDelay
		bset.b	#CIAB_DSKSTEP,b_prb(a4)
		bra	ShortDelay			; --->

.ReCalFin:	clr.w	du_CurrentTrack(a3)		; Hier sind wir jetzt
		move.b	#DS_STEP,du_Status(a3)		; Und wieder steppen
		rts

***************************************************************************

	*** Kommando DS_STEP: Ziel-Track ansteuern

DoStep:
	IFD LIGHTSHOW
		move.w	#$ff0,color(a5)		; gelb
	ENDC
		move.w	du_DestTrack(a3),d1	; Destination Track
		cmpi.w	#80,d1			; == Root-Track ?
		bne.s	1$			; nein --->
		addq.w	#2,du_DestTrack(a3)	; sonst überhüpfen
		bra.s	DoStep			; und nochmal das ganze
1$:
		move.w	du_CurrentTrack(a3),d0	; Hier sind wir
	;;	cmp.w	d1,d0			; Sind wir schon richtig ?
	;;	bne.s	2$			; nein --->
	;;	tst.w	du_TrackSize(a3)	; Spur schon gelesen ?
	;;	beq.s	2$			; nein --->
	;;	move.b	#DS_WAITDMA,du_Status(a3) ; Sonst sofort Statuswechsel
	;;	move.w	#INTF_SETCLR|INTF_DSKBLK,intreq(a5) ; Interrupt auslösen
	;;	bra.s	99$			; --->
	;; 2$:
		lsr.w	#1,d0			; Nur Cylindernr interessiert
		lsr.w	#1,d1			; Nur Cylindernr interessiert
		cmp.w	d1,d0
		beq.s	.TrackFound
		blt.s	.StepIn

.StepOut:	subq.w	#2,du_CurrentTrack(a3)
		btst.b	#CIAB_DSKTRACK0,a_pra(a4)	; Track 0 ?
		beq.s	99$				; ja ---> fertig
		bset.b	#CIAB_DSKDIREC,b_prb(a4)
		bra.s	.Step

.StepIn:	addq.w	#2,du_CurrentTrack(a3)
		bclr.b	#CIAB_DSKDIREC,b_prb(a4)
	;;	bra.s	.Step

.Step:		clr.w	du_TrackSize(a3)	; Track ist nicht gelesen
		bclr.b	#CIAB_DSKSTEP,b_prb(a4)
		bsr	ShortDelay
		bset.b	#CIAB_DSKSTEP,b_prb(a4)
		bsr	ShortDelay
		bra.s	99$			; ---> fertig

.TrackFound:	move.w	du_DestTrack(a3),d0	; Wir sind am Ziel
		move.w	d0,du_CurrentTrack(a3)
		btst	#0,d0			; Seite ermitteln
		bne.s	3$
		bset.b	#CIAB_DSKSIDE,b_prb(a4)	; Seite 0
		bra.s	4$
3$:		bclr.b	#CIAB_DSKSIDE,b_prb(a4)	; Seite 1
4$:		move.b	#DS_SETTLE,du_Status(a3)
99$:
		rts

***************************************************************************

	*** Kommando DS_SETTLE: DMA für nächste Spur starten

DoSettle:
	IFD LIGHTSHOW
		move.w	#$00f,color(a5)		; blau
	ENDC
		movea.l	du_MFMBuffer(a3),a0	; A0: The Buffer
		clr.l	(a0)			; Falls gar nix gelesen wird
		move.w	du_Sync(a3),dsksync(a5)	; SYNC-Wort
		move.w	#$0c00,d0
		move.w	#INTF_DSKBLK,intreq(a5)	; DSKBLK-Intreq löschen
		move.w	d0,adkcon(a5)		; Precomp 0
		lea	dsklen-14(a5),a1
		tst.b	du_Status(a3)		; Schreiben ?
		bpl.s	1$			; Noe --->

		add.w	#$9100-$0c00,d0		; $9100 (MFMPRECOMP|FAST)
		lea	-GAPBYTES(a0),a0	; Gap-Bytes auch schreiben
		move.w	#(WRITEBYTES+GAPBYTES/2)|$C000,d1	; Words to write
		move.b	#DS_WAITDMA|DSF_WRITING,du_Status(a3)	; Statusübergang

	;;	btst.b	#CIAB_DSKPROT,a_pra(a4)	; Disk schreibgeschützt ?
	;;	bne.s	2$			; nein --->
	;;	moveq	#ER_WRITEPROT,d0
	;;	bra.s

		bra.s	2$
1$:
		add.w	#$9500-$0c00,d0		; $9500 (MFMPRECOMP|WORDSYNC|FAST)
		move.w	#READBYTES|$8000,d1	; Words to read
		move.b	#DS_WAITDMA,du_Status(a3)	; Statusübergang
2$:
		move.l	a0,dskpt(a5)		; Lese- bzw. Schreib-Adresse
		move.w	d0,adkcon(a5)
		bsr	ShortDelay		; Das brauchts glaub
		move.w	d1,dsklen(a5)		; Anzahl Words zu lesen/schreiben
		move.w	d1,14(a1)		; =DskLen, DMA starten

		move.w	#DMATIME,du_TimeOutCntr(a3)	; Lesezeit setzen

99$:		rts

***************************************************************************

	*** Kommando DS_WAITDMA: Warten bis Disk-DMA fertig, dann processing

DoWaitDMA:
	IFD LIGHTSHOW
		move.w	#$f0f,color(a5)		; pink
	ENDC
		BTSTW	INTB_DSKBLK,intreqr(a5)	; Spur fertig gelesen?
		bne.s	.ProcTrack		; ja --->
		cmpi.w	#DMATIME-READYTIME,du_TimeOutCntr(a3)
		bgt.s	0$			; Noch kein Ready-TimeOut --->
	IFD DEBUG
		moveq	#DERR_DRIVENOTREADY,d0
	ENDC
		btst.b	#CIAB_DSKRDY,a_pra(a4)	; Drive ready ?
		bne.s	1$			; nein ---> Error
0$:
	IFD DEBUG
		moveq	#DERR_DMATIMEOUT,d0
	ENDC
		subq.w	#1,du_TimeOutCntr(a3)	; Schon TimeOut ?
		bpl	.DoWaitDMAEnd		; Noch nicht ---> fertig
1$:
		move.w	#0,dsklen(a5)		; DMA OFF (NICHT clr!)
		bra	.ReadRetry		; Retry oder Error

	*** Gelesene Spur verarbeiten: Test ob 1. Sync OK

.ProcTrack:	move.w	#INTF_DSKBLK,intreq(a5)	; DSKBLK-Intreq löschen
		move.w	#0,dsklen(a5)		; DMA OFF (NICHT clr!)

		movea.l	du_MFMBuffer(a3),a2	; A2 :  MFM-Buffer
	IFD DEBUG
		moveq	#DERR_NOSYNC,d0
	ENDC
		move.w	du_Sync(a3),d1
		cmp.w	(a2),d1			; 2. Sync-Wort OK ?
		bne	.ReadRetry		; Retry oder Error

	*** Anzahl codierte LONGS des Tracks berechnen und eintragen & D2

.GetSize:	lea	2(a2),a0		; Start der Daten nach Sync
		movem.l	(a0),d1/d2		; 1. Headerlangwort
		and.l	d7,d1
		and.l	d7,d2
		add.l	d2,d2
		or.l	d1,d2			; D2: Anzahl Datenbytes
		move.w	d2,du_TrackSize(a3)	; in Unit-Struktur eintragen

	*** Checksumme des Tracks errechnen & prüfen

		bsr	CalcCheckSum		; D0:=Checksumme, A0 := Adr
		move.l	d0,d1			; D1: Ist-Checksumme

		movem.l	(a0),d0/d2		; Soll-Checksumme
		and.l	d7,d0
		and.l	d7,d2
		add.l	d2,d2
		or.l	d0,d2			; D2: Soll-Checksumme

	IFD DEBUG
		moveq	#DERR_BADCHECKSUM,d0
	ENDC
		cmp.l	d2,d1			; Checksumme richtig ?
		bne	.ReadRetry		; nein ---> Retry oder Error
2$:
	*** Testen ob es der richtige Track ist

.CheckTrackNo:	movem.l	2+8(a2),d1/d2		; 2. Headerlangwort
		and.l	d7,d1
		and.l	d7,d2
		add.l	d2,d2
		or.l	d2,d1			; D1 :  2. HeaderLong

	IFD DEBUG
		moveq	#DERR_BADTRACK,d0
	ENDC
		cmp.b	du_CurrentTrack+1(a3),d1	; Richtige Spur ?
		bne	.ReCalibrate			; nein --->

	*** Testen ob's die richtige Disknummer ist

		lsr.w	#8,d1
		move.w	du_DiskNumber(a3),d0
		beq	.ReadFinished		; Bei GetHeader(): fertig!
		cmp.b	d0,d1			; Richtige Disk ?
		beq.s	3$			; ja --->
	IFD DEBUG
		moveq	#DERR_WRONGDISK,d0
	ENDC
		move.w	d1,du_DiskNumber(a3)	; Neue Disknummer eintragen
		bra	.ReadError		; ---> Request zurückpushen
3$:
		swap	d1			; DiskKey
		move.w	meb_ProductCode(a6),d0
		beq.s	4$			; Product-Egal-Magic
		cmp.w	d0,d1			; richtige Disk ?
		beq.s	4$			; ja --->
		clr.w	du_DiskNumber(a3)
	IFD DEBUG
		moveq	#DERR_WRONGPRODUCT,d0
	ENDC
		bra	.ReadError		; ---> Request zurückpushen
4$:
	*** Testen ob's die 1. Spur des Files ist, ggf. File-Länge nach D5

		tst.l	du_FileSize(a3)		; Länge schon eingetragen ?
		bne.s	.ProcDataTrack		; ja --->

		move.w	du_FileName+2(a3),d2	; File-Byte-Offset
		add.w	d2,d2			; D2 :  MFM-Offset
		movem.l	2+16(a2,d2.w),d0/d5	; kodierte File-Länge
		and.l	d7,d0			; MFM-decodieren
		and.l	d7,d5
		add.l	d5,d5
		or.l	d0,d5			; D5 :  Länge des Files

	*** Testen ob File gecruncht ist, ggf. Flag setzen und rumwursteln

		movea.l	du_ActPacket(a3),a0	; A0 :  Packet
	IFD CRUNCH
		bclr.l	#31,d5			; File gecruncht ?
		beq.s	41$			; nein --->
		bset.b	#DPB_CRUNCHED,dp_Flags(a0) ; Crunch-Flag setzen

		movem.l	2+16+8(a2,d2.w),d0/d6	; 1. Langwort im File
		and.l	d7,d0			; MFM-decodieren
		and.l	d7,d6
		add.l	d6,d6
		or.l	d0,d6			; D6 :  Ungecrunchte Länge
		moveq.l	#PP_SAVEMARGIN,d0	; Für auf-sich-selber-decrunchen
		add.l	d0,d6			; Alloc-Länge += Sicherheitsbereich
		bra.s	42$
41$:		move.l	d5,d6			; Nicht gecruncht
42$:
	ELSEIF
		move.l	d5,d6			; D6 :  Amount für AllocMem()
	ENDC
		move.l	d5,du_FileSize(a3)	; Lade-Länge eintragen
		move.l	d5,dp_FileSize(a0)	; Lade-Länge für Decruncher

	*** Testen ob Speicher reserviert werden muss, ggf. reservieren

		bclr.b	#DPB_ALLOCMEM,dp_Flags(a0) ; CHIP-Alloc gewünscht ?
		beq.s	5$			; nein --->
		move.l	d6,d0			; Amount
		jsr	meb_AllocMem(a6)
		bra.s	6$			; --->
5$:
		bclr.b	#DPB_ALLOCFASTMEM,dp_Flags(a0) ; FAST-Alloc gewünscht?
		beq.s	61$			; nein --->
		move.l	d6,d0			; Amount
		jsr	meb_AllocFastMem(a6)
6$:		move.l	d0,dp_Address(a0)	; Adresse ins Packet
		move.l	d0,du_DestAddr(a3)	; Adresse in DiskUnit
61$:
	*** 1. Spur (ab File-Start+4) kodieren / dekodieren

		lea	18+8(a2,d2.w),a0	; File-Data-Start im Puffer
		moveq.l	#0,d0
		move.w	du_TrackSize(a3),d0	; Länge dieses Tracks
		sub.w	du_FileName+2(a3),d0	; minus Start-Offset
		subq.l	#4,d0			; minus Längen-Langwort
		bra.s	7$			; --->

	*** Daten-Spur ab Track-Start kodieren / dekodieren

.ProcDataTrack:
		lea	18(a2),a0		; Track-Data-Start im Puffer
		moveq.l	#0,d0
		move.w	du_TrackSize(a3),d0	; Länge dieses Tracks
7$:		cmp.l	du_FileSize(a3),d0	; weniger als 1 Track ?
		blt.s	8$			; nein --->
		move.l	du_FileSize(a3),d0	; Sonst begrenzen
8$:
		tst.b	du_Status(a3)		; Haben wir soeben geschrieben ?
		bmi.s	10$			; ja --->

		movea.l	du_ActPacket(a3),a1
		tst.b	dp_Flags(a1)		; Kodieren oder dekodieren?
		movea.l	du_DestAddr(a3),a1	; Destination (doesn't change ccr)
		bpl.s	9$
		bsr	MFMEncode		; D0 Bytes A1 nach A0 kodieren
		move.b	#DS_SETTLE|DSF_WRITING,du_Status(a3)	; Schreiben!!
		bra	.DoWaitDMAEnd		; --->

9$:		bsr	MFMDecode		; D0 Bytes A0 nach A1 dekodieren

	*** Nächsten Track zum Lesen vorbereiten

10$:		add.l	d0,du_DestAddr(a3)	; INC address
		sub.l	d0,du_FileSize(a3)	; DEC verbleibende Länge
		ble	.ReadFinished		; Fertig ---> (Tada!)
		addq.w	#1,du_DestTrack(a3)	; Nächste Spur
		move.b	#DS_STEP,du_Status(a3)	; Schreiten
		bra	.DoWaitDMAEnd		; --->

	*** ReadError: RetryCounter runterzählen und ggf. retry

.ReadRetry:	clr.w	du_TrackSize(a3)	; Spur ungültig
		move.b	#DS_STEP,du_Status(a3)	; Retry without bumping
		bra.s	11$			; --->

.ReCalibrate:	move.b	#DS_RECALIBRATE,du_Status(a3)	; Bump

11$:		subq.b	#1,du_RetryCntr(a3)	; Namal probiere ?
		bgt	.DoWaitDMAEnd		; ja --->

.ReadError:
	IFD DEBUG
		movea.l	du_ActPacket(a3),a0	; Für MSG
		MSG	<"Read Error D0=Error A0=Packet A2=MFM A3=Unit">
	ELSEIF
		move.w	#$fff,$dff180		; Weiss=Failure
	ENDC
		clr.w	du_DiskNumber(a3)	; Ungültige Diskette
		lea	meb_DiskList(a6),a0
		move.l	du_ActPacket(a3),d0	; Packet ?
		beq.s	12$			; nein --->
		movea.l	d0,a1
		jsr	meb_AddHead(a6)		; Request nochmals bearbeiten
12$:
	*** Lese-Abschluss bei Error/Success, quittieren falls Success

.ReadFinished:	move.b	#DS_IDLE,du_Status(a3)	; Nix mehr tun
		clr.l	ActUnit			; Drive freigeben
		st.b	b_prb(a4)		; Motor off
		bsr	ShortDelay
		move.b	du_OffMask(a3),b_prb(a4); Motor off & Select
		bsr	ShortDelay
		st.b	b_prb(a4)		; Drive deselektieren
		bsr	ShortDelay

		tst.w	du_DiskNumber(a3)	; War alles OK ?
		beq.s	.Kick			; nein --->
		move.l	du_ActPacket(a3),d0
		beq.s	.Kick			; kein Packet --->
		movea.l	d0,a0
		bsr	ReplyPacket		; Packet (A0) beantworten

.Kick:		bsr	ProcessNextRequest	; Nächsten Request ankicken

.DoWaitDMAEnd:	rts



*****************************************************************************
* Checksumme des Tracks berechnen
* IN:  A2=MFM-Buffer-Start (2. SYNC), A3=Unit
* OUT: D0=Checksumme, A0=Adresse der Checksumme im MFM-Buffer

CalcCheckSum:	movem.l	d1-d2,-(SP)		; A0 NICHT retten!
		lea	2(a2),a0		; Start der Daten nach Sync
		move.w	du_TrackSize(a3),d2	; Tracklänge in Bytes
		lsr.w	#1,d2			; /2 gibt # MFM-Longs
		addq.w	#3,d2			; 2 Headerlongs - 1 für dbf
		moveq	#0,d0			; D0: Checksumme
.SumLoop:	move.l	(a0)+,d1
		eor.l	d1,d0
		dbf	d2,.SumLoop
		and.l	d7,d0			; Taktbits ausblenden
		movem.l	(SP)+,d1-d2
		rts

*****************************************************************************
* MFM-Dekodierung (CDisk-Format)
* D0 = # Bytes, D7=$55555555, A0=Source (MFM), A1=Destination

MFMDecode:	movem.l	d0-d5/a0-a1,-(SP)
		move.w	d0,d5			; Anzahl Bytes
		andi.w	#7,d5			; D5 := Anzahl Rest-Bytes
		lsr.w	#3,d0			; D0 := Anzahl LONGS/2
		bra.s	2$			; für dbf

1$:		movem.l	(a0)+,d1/d2/d3/d4	; 4 MFM-Longs gibt 8 Bytes
		and.l	d7,d1
		and.l	d7,d2
		and.l	d7,d3
		and.l	d7,d4
		add.l	d2,d2
		add.l	d4,d4
		or.l	d2,d1
		or.l	d4,d3
		move.l	d1,(a1)+
		move.l	d3,(a1)+
2$:		dbf	d0,1$

		bclr	#2,d5			; mehr als 1 LONG noch ?
		beq.s	3$			; nein --->
		movem.l	(a0)+,d1/d2		; 1 Langwort mehr für Rest
		and.l	d7,d1
		and.l	d7,d2
		add.l	d2,d2
		or.l	d2,d1
		move.l	d1,(a1)+
3$:
		movem.l	(a0)+,d1/d2		; 1 Langwort mehr für Rest
		and.l	d7,d1
		and.l	d7,d2
		add.l	d2,d2
		or.l	d2,d1

4$:		subq.w	#1,d5
		bmi.s	5$
		rol.l	#8,d1			; Nächstes Byte
		move.b	d1,(a1)+
		bra.s	4$
5$:
		movem.l	(SP)+,d0-d5/a0-a1
		rts

*****************************************************************************
* MFM-Kodierung (CDisk-Format)
* D0 = # Bytes, D7=$55555555, A0=Destination, A1=Source (MFM), A2=MFM-BufferStart

MFMEncode:	movem.l	d0-d1/a0-a1,-(SP)
		move.l	d0,d1			; Anzahl Bytes
		lsr.w	#2,d1			; Anzahl Longs
		bra.s	2$			; für dbf
1$:		move.l	(a1)+,d0		; 1 Source-Longwort
		bsr.s	PutD0			; codieren und nach (A0)++
2$:		dbf	d1,1$

		bsr	CalcCheckSum		; Prüfsumme der Spur berechnen
		bsr	PutD0			; und eintragen
		moveq	#0,d0			; Abschluß-AAAAAAAA
		bsr	PutD0			; eintragen (wozu? hmmmm..)

		movem.l	(SP)+,d0-d1/a0-a1
	;;	bra	SetClockBits

	*** Im ganzen Track Taktbits setzen/löschen, D7=BitMask

SetClockBits:	movem.l	d0-d3/a0,-(SP)
		lea	2(a2),a0		; A0 :  MFM-Buffer (OHNE SYNC!!)
		move.w	#WRITEBYTES/2,d3	; 1 LONG mehr anpassen
1$:		move.l	(a0),d0
		and.l	d7,d0			; Alle Taktbits löschen
		move.l	d0,d2
		eor.l	d7,d2			; Datenbits invertieren
		move.l	d2,d1
		lsr.l	#1,d1			; D1: invert. Daten nach rechts
		bset.l	#31,d1
		lsl.l	#1,d2			; D2: invert. Daten nach links
		addq.w	#1,d2			; = bset #0,d2
		and.l	d2,d1
		or.l	d1,d0			; nur 1 falls zwischen 2 Nullen
		btst.b	#0,-1(a0)		; Grenztest nach unten
		beq.s	2$
		bclr.l	#31,d0
2$:		move.l	d0,(a0)+
		dbf	d3,1$
		movem.l	(SP)+,d0-d3/a0
		rts

	*** D0.L MFM codieren und in (A0)++ eintragen

PutD0:		move.l	d0,(a0)+
		lsr.l	#1,d0
		move.l	d0,(a0)+
		rts

**************************************************************************

	*** Wichtige Register initialisieren

GetD7A4A5:	movem.l	InitVals(PC),d7/a4/a5
		rts

InitVals:	dc.l	$55555555	; D7
		dc.l	ciabase		; A4
		dc.l	custom		; A5

**************************************************************************

	*** Kurz verzögern, nach Schreiben in Hardware-Register

ShortDelay:	move.l	d0,-(SP)
		moveq	#2,d0			; 3 Rasterzeilen
		bsr.s	WaitLines
		move.l	(SP)+,d0
		rts

**************************************************************************

	*** Genau D0.L * 64 Mikrosekunden warten (+- 64 µs)

WaitLines:	movem.l	d0/d1,-(SP)
1$:		move.b	vhposr(a5),d1
2$:		cmp.b	vhposr(a5),d1
		beq.s	2$
		dbf	d0,1$
		movem.l	(SP)+,d0/d1
		rts


***************************************************************************
*             D A T E N  (auch im CODE-Segment wegen PC-relativ)          *
***************************************************************************

MFMBuffer:		ds.l	1		; MFM-Buffer + GAPBYTES
UnitTab:		ds.l	MAXUNITS	; Unit-Zeiger-Array
ActUnit:		ds.l	1		; Zeiger auf aktive Unit
InsertDiskRoutine:	ds.l	1		; User's InsertDisk handler


		END
