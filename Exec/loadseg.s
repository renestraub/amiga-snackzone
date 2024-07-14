**************************************************************************
**                                                                      **
**   Modification History                                               **
**   --------------------                                               **
**                                                                      **
**   15-May-89  CHW  Created this file!                                 **
**   24-Oct-90  CHW  Schrottet die Memoryliste nicht mehr               **
**                                                                      **
**************************************************************************

		IDNT	LoadSeg
		SECTION	text,CODE

		INCLUDE	"MyExec.i"

		XREF	AllocMemFunc,FreeMemFunc
		XREF	LoadFileFunc,LoadFastFileFunc

		XDEF	LoadSegFunc,UnLoadSegFunc

SEGMAGIC:	EQU	'SEG2'	; Neues Format
RELOCMAGIC:	EQU	'RLOC'

LIB_VERSION:	EQU	$14

***************************************************************************

	IFD sakdksdhgksdjhg

'struct' SpecialFile
{
	ULONG	ID;			/* Segment-Start-Magic SPECIAL_SEGID */
	ULONG	CodeSize;		/* CODE-Size (FAST-RAM) in Bytes */
	ULONG	DataSize;		/* DATA-Size (CHIP-RAM) in Bytes */
	ULONG	BSSSize;		/* BSS-Size, mindestens 4 Bytes FAST RAM */

	BYTE	Code[0];		/* CodeSize Bytes, geht ins FAST RAM */

	ULONG	rloc1;			/* muss SPECIAL_RELOC sein */
	ULONG	Numccrelocs;		/* Anzahl folgende Relocs */
	BYTE	CCRelocs[0];		/* Im Code nach Code relocs */

	ULONG	rloc2;			/* muss SPECIAL_RELOC sein */
	ULONG	Numcdrelocs;		/* Anzahl folgende Relocs */
	BYTE	CDRelocs[0];		/* Im Code nach Data relocs */

	ULONG	rloc3;			/* muss SPECIAL_RELOC sein */
	ULONG	Numcbrelocs;		/* Anzahl folgende Relocs */
	BYTE	CBRelocs[0];		/* Im Code nach BSS relocs */


	BYTE	Data[0];		/* DataSize Bytes, geht ins CHIP RAM */

	ULONG	rloc4;			/* muss SPECIAL_RELOC sein */
	ULONG	Numdcrelocs;		/* Anzahl folgende Relocs */
	BYTE	DCRelocs[0];		/* Im Data nach Code relocs */

	ULONG	rloc5;			/* muss SPECIAL_RELOC sein */
	ULONG	Numddrelocs;		/* Anzahl folgende Relocs */
	BYTE	DDRelocs[0];		/* Im Data nach Data relocs */

	ULONG	rloc6;			/* muss SPECIAL_RELOC sein */
	ULONG	Numdbrelocs;		/* Anzahl folgende Relocs */
	BYTE	DBRelocs[0];		/* Im Data nach BSS relocs */
};

	ENDC

***************************************************************************

	*** D0 :  Filename

LoadSegFunc:	movem.l	d1-d6/a0-a5,-(SP)

		move.l	#-RELOCMAGIC,d5
		bsr	LoadFastFileFunc	; File ins FAST RAM einladen
		movea.l	d0,a2			; A2 :  File-Base
		move.l	a2,d6			; D6 :  File-Base für später
		neg.l	d5			; Gegen Cracker

	*** Parameter aus FileHeader holen

		move.l	#~SEGMAGIC,d0
		not.l	d0			; Gegen Cracker
		cmp.l	(a2)+,d0		; Kennung OK ?
		beq.s	1$			; ja --->
		MSG	<"Not an object module, D6=File">
		jmp	meb_ColdReboot(a6)
1$:
		movem.l	(a2)+,d2-d4		; D2 : CODESIZE, D3: DATASIZE
						; D4 : BSSSIZE

	*** Speicher für Code, Data und BSS allozieren

		move.l	d2,d0			; CODE-Size
		addq.l	#8,d0			; Platz für DATA- und BSS-Zeiger
		jsr	meb_AllocFastMem(a6)	; FAST RAM reservieren
		movea.l	d0,a3			; A3 :  CODE-Segment

		move.l	d3,d0			; DATA-Size
		jsr	meb_AllocMem(a6)	; CHIP RAM reservieren
		movea.l	d0,a4			; A4 :  DATA-Segment
		move.l	a4,(a3)+		; in Code-Segment merken

		move.l	d4,d0			; BSS-Size
		jsr	meb_AllocClearMem(a6)	; BSS wird gelöscht
		movea.l	d0,a5			; A5 :  BSS-Segment
		move.l	a5,(a3)+		; in Code-Segment merken

	*** Code ins Code-Segment rüberkopieren, FilePtr auf Relocs

		movea.l	a2,a0			; Source: File
		movea.l	a3,a1			; Destination: Code-Segment
		move.l	d2,d0			; Code-Size
		jsr	meb_CopyMem(a6)		; Segment kopieren
		adda.l	d2,a2			; File-Zeiger vorrücken

	*** Code to Code/Data/BSS Relocs ausführen
	*** Relocs sind 16bit signed deltas oder 0 und dann 32bit signed

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Code-Code-Relocs
		move.l	a3,d1			; Zu addierender Wert
		movea.l	a3,a0			; Zu relozierender Code
		bsr	DoReloc

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Code-Data-Relocs
		move.l	a4,d1			; Zu addierender Wert
		movea.l	a3,a0			; Zu relozierender Code
		bsr	DoReloc

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Code-BSS-Relocs
		move.l	a5,d1			; Zu addierender Wert
		movea.l	a3,a0			; Zu relozierender Code
		bsr	DoReloc

	*** Data ins Data-Segment rüberkopieren, FilePtr auf Relocs

		movea.l	a2,a0			; Source: File
		movea.l	a4,a1			; Destination: Data-Segment
		move.l	d3,d0			; Data-Size
		jsr	meb_CopyMem(a6)		; Segment kopieren
		adda.l	d3,a2			; File-Zeiger vorrücken

	*** Data to Code/Data/BSS Relocs ausführen

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Data-Code-Relocs
		move.l	a3,d1			; Zu addierender Wert
		movea.l	a4,a0			; Zu relozierender Code
		bsr	DoReloc

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Data-Data-Relocs
		move.l	a4,d1			; Zu addierender Wert
		movea.l	a4,a0			; Zu relozierender Code
		bsr	DoReloc

		cmp.l	(a2)+,d5		; Magic vorhanden ?
		bne	BadReloc		; nein ---> Error
		move.l	(a2)+,d0		; Anzahl Data-BSS-Relocs
		move.l	a5,d1			; Zu addierender Wert
		movea.l	a4,a0			; Zu relozierender Code
		bsr	DoReloc

	*** Ur-File freigeben

		movea.l	d6,a1			; File
		jsr	meb_FreeMem(a6)
LoadSegEnd:
		move.l	a3,d0			; The File
		movem.l	(SP)+,d1-d6/a0-a5


		movem.l	d0-d7/a0-a6,-(SP)
		;move.l	4,a6
		;cmp.w	#36,LIB_VERSION(a6)
		;blt.s	.NoC
		;jsr	-636(a6)		; CacheClearU
.NoC		

		movem.l	(SP)+,d0-d7/a0-a6
		rts


BadReloc:	MSG	<"Bad reloc, D6=File">
		jmp	meb_ColdReboot(a6)


	*** D0=Anzahl, D1=Offset, A0=Segment, A2=File, wird vorgerückt

DoReloc:	movem.l	d1-d3,-(SP)
		moveq.l	#0,d2			; Reloc-Pointer resetten
		bra.s	3$			; Für dbf
1$:		move.w	(a2)+,d3		; Nächste Adresse
		ext.l	d3			; auf Langwort erweitern
		bne.s	2$			; nicht 0 ---> 16bit-delta
		move.l	(a2)+,d3		; sonst 32bit-delta
2$:		add.l	d3,d2			; Delta-Wert addieren
		add.l	d1,0(a0,d2.l)		; Tada!
3$:		dbf	d0,1$
		movem.l	(SP)+,d1-d3
		rts

***************************************************************************

	*** A1 :  Segmentliste von LoadSeg()

UnLoadSegFunc:	movem.l	a0-a1,-(SP)
		movea.l	a1,a0
		movea.l	-(a0),a1		; A1 :  BSS-Segment
		jsr	meb_FreeMem(a6)		; Segment freigeben
		movea.l	-(a0),a1		; A1 :  Data-Segment
		jsr	meb_FreeMem(a6)		; Segment freigeben
		movea.l	a0,a1			; A1 :  CodeSegment
		jsr	meb_FreeMem(a6)		; Segment freigeben
		movem.l	(SP)+,a0-a1
		rts
