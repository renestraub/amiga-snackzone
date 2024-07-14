***************************************************************************
**                                                                       **
**   FFS.S  -  FastFileSystem-Laderoutine               (2. Generation)  **
**                                                                       **
***************************************************************************
**                                                                       **
**   Modification History                                                **
**   --------------------                                                **
**                                                                       **
**   Steinzeit  RS    Created this file!                                 **
**   01-Sep-89  CHW   Adaptiert für Exec (Packet-Interface)              **
**   ??-Nov-89  CHW   File-Size/512-Bytes-Guru-Bug fixed (GRRRR!)        **
**   18-Sep-90  CHW   74-Block-Bug gefunden, (2 Tage futsch! #@$*&!)     **
**                                                                       **
**   19-Sep-90  CHW   Neu programmiert, ist 200 Bytes kürzer worden :-)  **
**   29-Dec-90  CHW   Pure-Flag bedeutet File ist gecruncht              **
**                                                                       **
***************************************************************************

		OPT	OW6+

		IDNT	FastFileSystem
		SECTION	text,CODE

		INCLUDE	"MyExec.i"

CRUNCH
	IFD RAMVERSION


		XDEF	ProcessFFSPacket

***************************************************************************

BLOCKSIZE:	EQU	512		; Grösse eines Disk-Blocks in Bytes
ST.FILE:	EQU	-3		; SubTyp eines Files

   STRUCTURE FileHeaderBlock,0

	ULONG	fh_Type			;   0 T.SHORT
	ULONG	fh_OwnKey		;   1 Zeiger auf sich selbst
	ULONG	fh_HighSeq		;   2 Anzahl hier vermerkter Datenblöcke
	ULONG	fh_DataSize		;   3 Anzahl der benutzten Datenblöcke
	ULONG	fh_FirstData		;   4 Erster Datenblock
	ULONG	fh_CheckSum		;   5 Checksumme
	STRUCT	fh_BlockPtrs,4*72	;   6 Zeiger auf Datenblöcke (rückwärts!)
	LABEL	fh_BlockPtrEnd		;  78
	ULONG	fh_unused78		;  78
	ULONG	fh_unused79		;  79
	ULONG	fh_Protect		;  80 Protection-Bits
	ULONG	fh_FileSize		;  81 Grösse der Datei in Bytes
	STRUCT	fh_Comment,4*23		;  82 Kommentar als BCPL-String
	ULONG	fh_Days			; 105 Datum und Zeit der Erstellung
	ULONG	fh_Mins			; 106
	ULONG	fh_Ticks		; 107
	STRUCT	fh_Name,4*16		; 108 Dateiname als BCPL-String
	ULONG	fh_HashChain		; 124
	ULONG	fh_Parent		; 125 Zeiger auf Ursprungs-Directory
	ULONG	fh_Extension		; 126 Null oder Zeiger auf Extension
	ULONG	fh_SecondaryType	; 127 Sekundärtyp (ST.FILE)

	LABEL	fh_SIZEOF

	IFNE	fh_SIZEOF-BLOCKSIZE
	  FAIL	"Bad FileHeaderBlock structure!"
	ENDC

***************************************************************************
* CDisk-Packet (A0) abarbeiten (File aus der RAMDisk laden)

ProcessFFSPacket:
		movem.l	d0-d2/d7/a0-a3/a5,-(SP)
		movea.l	a0,a2			; A2 :  Packet
		move.l	#BLOCKSIZE,d7		; D7 :  BlockSize (immer)

		move.l	d7,d0			; 1 Block
		jsr	meb_AllocFastMem(a6)	; reservieren
		movea.l	d0,a5			; a5 :  Block-Buffer

		movea.l	dp_FileName(a2),a0
		bsr	FindFile		; Fileheader suchen
		bne.s	1$			; OK --->
		MSG	<"FFS: File not found, A0=name A2=packet">
		jmp	meb_ColdReboot(a6)
1$:
		bsr	GetBlock		; Fileheader laden
		moveq.l	#ST.FILE,d0
		cmp.l	fh_SecondaryType(a5),d0	; Ist's ein File ?
		beq.s	2$			; ja --->
		MSG	<"FFS: Not a file, A0=name A2=packet">
		jmp	meb_ColdReboot(a6)
2$:
		move.l	fh_FileSize(a5),d2	; D2 :  Datei-Größe in Bytes
		move.l	d2,dp_FileSize(a2)	; ins Packet eintragen

	IFD CRUNCH
		btst.b	#5,fh_Protect+3(a5)	; Pure-Bit gesetzt ?
		beq.s	.NotCrunched
		bset.b	#DPB_CRUNCHED,dp_Flags(a2)
		move.l	fh_FirstData(a5),d0	; 1. Datenblock
		bsr	GetBlock
		moveq.l	#PP_SAVEMARGIN,d2	; Sicherheitsabstand
		add.l	(a5),d2			; Plus ungecrunchte Länge
		movea.l	dp_FileName(a2),a0
		bsr	FindFile		; Fileheader suchen
		bsr	GetBlock		; Fileheader laden
.NotCrunched:
	ENDC
		btst.b	#DPB_ALLOCMEM,dp_Flags(a2) ; CHIP-Alloc gewünscht ?
		beq.s	.NoChipAlloc		; nein --->
		move.l	d2,d0			; File-Länge
		jsr	meb_AllocMem(a6)
		bra.s	.AllocCont		; --->
.NoChipAlloc:
		btst.b	#DPB_ALLOCFASTMEM,dp_Flags(a2) ; FAST-Alloc gewünscht?
		beq.s	.NoFastAlloc		; nein --->
		move.l	d2,d0			; File-Länge
		jsr	meb_AllocFastMem(a6)
.AllocCont:	move.l	d0,dp_Address(a2)	; Adresse ins Packet
.NoFastAlloc:
	IFD CRUNCH
		move.l	fh_FileSize(a5),d2	; D2 :  Datei-Größe in Bytes
	ENDC
		movea.l	dp_Address(a2),a1	; A1 :  Ziel-Adresse
.ExtLoop:	move.l	fh_HighSeq(a5),d1	; D1 :  Datablock-Zähler
		lea	fh_BlockPtrEnd(a5),a3	; A3 :  Datenblockpointer-Zeiger
		bra.s	.BlockDBF		; Für DBF
.BlockLoop:	move.l	-(a3),d0
		cmp.l	d7,d2			; Weniger als ein Block übrig ?
		blo.s	.LastBlock		; ja ---> Spezialfall
		movea.l	a1,a0			; Destination
		bsr	ReadBlock		; Datenblock nach (A0) lesen
		adda.l	d7,a1			; destination += BLOCKSIZE
		sub.l	d7,d2			; file size   -= BLOCKSIZE
.BlockDBF	dbf	d1,.BlockLoop

		move.l	fh_Extension(a5),d0	; File-Extension vorhanden ?
		beq.s	.End			; nein ---> fertig
		bsr	GetBlock		; Extension-Block nach (a5)
		bra.s	.ExtLoop		; ---> Loop

.LastBlock	bsr	GetBlock		; letzten Block nach (a5)
		movea.l	a5,a0			; Source
		move.l	d2,d0			; Size
		jsr	meb_CopyMem(a6)		; Daten kopieren
.End:
		movea.l	a5,a1			; Hilfs-Block
		jsr	meb_FreeMem(a6)		; freigeben

		movem.l	(SP)+,d0-d2/d7/a0-a3/a5
		rts

***************************************************************************
* File mit Namen (A0) finden und Header-Blocknummer nach D0 / CCR

FindFile:	movem.l	d1-d3/a0-a2,-(SP)

		move.l	meb_RAMDiskSize(a6),d0	; Grösse der Disk
		lsr.l	#5,d0			; /BLOCKSIZE/2 gibt Mitte
		lsr.l	#5,d0
		bsr	GetBlock		; Rootblock einlesen

		bsr	CalcHash		; Hashwert von (A0) berechnen
		beq.s	.FileNotFound		; ungültig --->
		move.l	0(a5,d0.w),d0		; D0 :  FileHeader-Blocknummer

.BlockLoop:	beq.s	.FileNotFound		; Nummer ungültig --->
		bsr	GetBlock		; Fileheaderblock einlesen

		movea.l	a0,a1			; Filename
		lea	fh_Name(a5),a2		; Name im Fileheader
		moveq.l	#0,d3
		move.b	(a2)+,d3		; Stringlänge
		bra.s	.Dbf
.CmpLoop:	move.b	(a1)+,d1
		move.b	(a2)+,d2
		andi.b	#$df,d1			; ToUpper
		andi.b	#$df,d2			; ToUpper
		cmp.b	d2,d1
		bne.s	.NextHash		; Nicht gleich ---> weitersuchen
.Dbf:		dbf	d3,.CmpLoop

.FileNotFound:	tst.l	d0			; CCR richtig setzen
		movem.l	(SP)+,d1-d3/a0-a2
		rts

.NextHash:	move.l	fh_HashChain(a5),d0	; Liste durchackern
		bra.s	.BlockLoop		; ---> Loop

***************************************************************************
* Hashwert des C-Strings (A0) berechnen

CalcHash:	movem.l	d1/a0-a1,-(SP)
		moveq.l	#0,d0			; Hashwert resetten
		tst.b	(a0)
		beq	.End

                movea.l	a0,a1			; Hash := strlen(name)
1$:		tst.b	(a1)+
		beq.s	2$
		addq.l	#1,d0
		bra.s	1$
2$:
.Loop:		moveq.l	#0,d1
		move.b	(a0)+,d1		; Nächstes Zeichen
		beq.s	4$			; Null ---> fertig
		cmpi.w	#'a',d1
		blo.s	3$
		cmpi.w	#'z',d1
		bhi.s	3$
		andi.b	#$df,d1			; char = ToUpper(char)
3$:
		mulu.w	#13,d0                  ; Hash *= 13
		add.l	d1,d0                   ; Hash += char
		andi.l	#$7ff,d0		; Hash &= $7FF
		bra.s	.Loop
4$:
                divu.w	#72,d0			; Hash %= 72
		swap	d0
                ext.l	d0
		addq.l	#6,d0			; Hash += 6 (Tabellenanfang)

.End:		lsl.l	#2,d0			; Hash *= 4, affect Z bit
		movem.l	(SP)+,d1/a0-a1
		rts

***************************************************************************
* Einen Block (D0=Blocknummer) in Buffer (A5) einlesen

GetBlock:	move.l	a0,-(SP)
		movea.l	a5,a0
		bsr.s	ReadBlock
		movea.l	(SP)+,a0
		rts

***************************************************************************
* Einen Block (D0=Blocknummer) an Adresse (A0) einlesen

ReadBlock:	movem.l	d0/a0-a1,-(SP)
		lsl.l	#5,d0			; Blocknr *BLOCKSIZE = Offset
		lsl.l	#4,d0
		move.l	a0,a1			; Destination
		movea.l	d0,a0			; Offset
		add.l	meb_RAMDiskBase(a6),a0	; Plus Basis-Adresse
		move.l	d7,d0			; Länge: 1 Block
		jsr	meb_CopyMem(a6)
		movem.l	(SP)+,d0/a0-a1
		rts

	ENDC

***************************************************************************

		END
