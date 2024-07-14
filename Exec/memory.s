**************************************************************************
**                                                                      **
**   MEMORY - Die schnellste, beste, kürzeste Speicherverwaltung  :-)   **
**                                                                      **
**              by Christian A. Weber, Zurich/Switzwerland              **
**                                                                      **
**************************************************************************
**                                                                      **
**   Modification History                                               **
**   --------------------                                               **
**                                                                      **
**   15-May-89  CHW  Created this file!                                 **
**   27-Nov-89  CHW  Fast-Memory added                                  **
**   30-Jul-90  CHW  Chip allocation for AllocFastMem() works now       **
**   18-Sep-90  CHW  Chip allocation for AllocFastMem() really works    **
**   20-Nov-90  CHH  NoMemHandler eingebaut				**                                                                      **
**   10-Jan-93  CHH  CheckMem BUG behoben				**                                                                      **
**                                                                      **
**************************************************************************

		OPT	OW6+

		IDNT	Memory
		SECTION	text,CODE

		INCLUDE	"MyExec.i"

		XREF	MyNoMemHandler

		XDEF	InitChipMemFunc,InitFastMemFunc
		XDEF	AllocMemFunc,AllocClearMemFunc
		XDEF	AllocFastMemFunc,AllocFastClearMemFunc
		XDEF	FreeMemFunc,CopyMemQuickFunc,CopyMemFunc,ClearMemFunc
		XDEF	AvailMemFunc,AvailFastMemFunc,CheckMemFunc

***************************************************************************

	*** ChipMemHeader init, A0=Adresse, D0=Size des freien Blocks

InitChipMemFunc:
		movem.l	d0/a0-a1,-(SP)
		lea	meb_ChipMRHeader(a6),a1
		bra.s	DoInitMem

	*** FastMemHeader init, A0=Adresse, D0=Size des freien Blocks

InitFastMemFunc:
		movem.l	d0/a0-a1,-(SP)
		lea	meb_FastMRHeader(a6),a1
	;;	bra.s	DoInitMem

DoInitMem:	move.l	a0,mh_Lower(a1)
		move.l	a0,mh_First(a1)
		move.l	d0,mh_Free(a1)
		move.l	d0,mc_Bytes(a0)
		clr.l	mc_Next(a0)
		adda.l	d0,a0
		move.l	a0,mh_Upper(a1)

		movem.l	(SP)+,d0/a0-a1
		rts

***************************************************************************

	*** D0: Amount, gibt D0: Adresse oder ruft AllocChipMem() auf

AllocFastMemFunc:
		movem.l	d1-d2/a0-a3,-(SP)
		move.l	d0,d1			; Amount retten

		tst.l	meb_FastMRHeader+mh_Free(a6)	; Fast RAM vorhanden ?
		beq.s	ChipEntry		; nein --->

		lea	meb_FastMRHeader(a6),a0	; The MemoryRegionHeader
		bsr	DoAlloc			; Speicher holen
		bne.s	1$			; OK --->
		move.l	d1,d0			; Amount
		bra.s	ChipEntry		; ---> CHIP RAM holen
1$:
		movem.l	(SP)+,d1-d2/a0-a3
		rts

***************************************************************************

	*** D0: Amount, gibt D0: Adresse oder Guru
	*** Wenn nicht genuegen Speicher vorhanden ist, wird ein evt.
	*** vorhandener Handler angesprungen 

AllocMemFunc:	movem.l	d1-d2/a0-a3,-(SP)
		move.l	d0,d1			; Amount retten
ChipEntry:	move.l	d0,ActAmount
		lea	meb_ChipMRHeader(a6),a0	; The MemoryRegionHeader
		bsr	DoAlloc			; --->
		movem.l	(SP)+,d1-d2/a0-a3
	;;	tst.l	d0
		beq.s	.NotEnough		; nicht genug --->
		rts
		
.NotEnough:	movem.l	d1-d7/a0-a6,-(SP)
		move.l	ActAmount,d1
		bsr	MyNoMemHandler
		tst.w	d0
		beq	.MemAlert
		movem.l	(SP)+,d1-d7/a0-a6
		move.l	ActAmount,d0
		bra	AllocMemFunc


.MemAlert:	movem.l	(SP)+,d1-d7/a0-a6	
		move.l	d1,d0			; Amount für MSG
		lea	meb_ChipMRHeader(a6),a0	; MemoryRegionHeader für MSG
		move.l	meb_ChipMRHeader+mh_Free(a6),d7	; Free für MSG
		movea.l	(SP)+,a5		; PC für MSG
		lea	AvailMemFunc,a1
		MSG	<'AllocMem: No mem, D0=amount, D7=free, A0=MRH, A1=AvailFunc A5=PC'>
		jmp	meb_ColdReboot(a6)

***************************************************************************

	*** D0: Amount, A0: MRH gibt D0: Adresse oder 0, rettet keine Regs!

DoAlloc:	tst.l	d0			; 0 Bytes reservieren ?
		beq	.AllocError		; ja ---> Guru
		addq.l	#4,d0			; Remember-Size
		addq.l	#7,d0
		andi.b	#$f8,d0			; Bytezahl modulo 8 aufrunden
		jsr	meb_Disable(a6)
	;;	cmp.l	mh_Free(a0),d0		; Amount > freier Speicher ?
	;;	bhi	.NotEnoughMemory	; ja ---> Guru
		lea	mh_First(a0),a2		; Zeiger auf 1. freien Chunk

.AllocLoop:	move.l	(a2),d2			; Link zum nächsten Chunk
		beq.s	.NotEnoughMemory	; Liste zu Ende ---> Guru
		movea.l	d2,a1			; Nächster Blockanfang
		cmp.l	mc_Bytes(a1),d0		; Chunklänge > Amount ?
		bls.s	1$			; ja ---> Chunk gefunden!
		movea.l	a1,a2			; Nächster Blockanfang
		bra.s	.AllocLoop		; ---> Loop
1$:
		beq.s	2$			; Chunklänge == Amount --->
		lea	0(a1,d0.l),a3		; Anfang des Restchunks
		move.l	(a1),(a3)		; Link eintragen
		move.l	mc_Bytes(a1),d2		; Länge des freien Blocks
		sub.l	d0,d2			; minus amount
		move.l	d2,mc_Bytes(a3)		; gibt Länge des Restchunks
		move.l	a3,(a2)			; Vorherigen Link korrigieren
		bra.s	3$			; --->

2$:		move.l	(a1),(a2)		; Link zurückkopieren
3$:
		sub.l	d0,mh_Free(a0)		; Frei-Zähler anpassen
		move.l	d0,(a1)+		; Grösse für FreeMem eintragen
		move.l	a1,d0			; Allozierter Bereich
.AllocEnd:
		jsr	meb_Enable(a6)				; versabbert CCR!
		tst.l	d0
		rts

.NotEnoughMemory:
		moveq.l	#0,d0
		bra.s	.AllocEnd

.AllocError:	movem.l	(SP)+,d1-d2/a0-a3
		movea.l	(SP)+,a5
		MSG	<'AllocMem: Got request for 0 bytes, A0=MRH, A5=PC'>
		jmp	meb_ColdReboot(a6)

**************************************************************************

	*** FAST-Speicher reservieren und löschen

AllocFastClearMemFunc:
		movem.l	d1/a0,-(SP)
		move.l	d0,d1			; Amount retten
		bsr	AllocFastMemFunc
		bra.s	DoAllocClear		; --->

**************************************************************************

	*** CHIP-Speicher reservieren und löschen

AllocClearMemFunc:
		movem.l	d1/a0,-(SP)
		move.l	d0,d1			; Amount retten
		bsr	AllocMemFunc
DoAllocClear:	movea.l	d0,a0			; Adresse
		move.l	d1,d0			; Länge
		bsr	ClearMemFunc
		move.l	a0,d0			; Adresse
		movem.l	(SP)+,d1/a0
		rts

***************************************************************************

	*** Speicherbereich (A1) freigeben

FreeMemFunc:	movem.l	d0-d2/a0-a2,-(SP)
		jsr	meb_Disable(a6)
		move.l	a1,d0			; Null ?
		beq	.FreeEnd		; ja --->

		cmp.l	meb_ChipMRHeader+mh_Upper(a6),d0 ; Ist's CHIP-RAM ?
		bhs.s	1$			 ; nein --->
		lea	meb_ChipMRHeader(a6),a0	; The MemoryRegionHeader
		bra.s	2$
1$:
		lea	meb_FastMRHeader(a6),a0
2$:
		move.l	-(a1),d0		; Länge des Blocks
		beq	.FreeError		; ja ---> Guru
		move.l	a1,d1			; Freizugebender Block

		lea	mh_First(a0),a2		; Zeiger auf 1. freien Chunk
		move.l	(a2),d2			; Link zum nächsten Chunk
		beq.s	5$			; Ende der Liste --->

3$:		cmpa.l	d2,a1			; Start des freizugebenden Chunks
		bcs.s	4$			; < Anfang des Blocks --->
		beq	.FreeError		; == Anfang ---> Guru
		movea.l	d2,a2			; Link zum nächsten Chunk
		move.l	(a2),d2			; Neuer Link
		bne.s	3$			; Liste geht weiter ---> Loop
4$:
		moveq	#mh_First,d1		; war 16 (?)
		add.l	a0,d1			; + MemoryRegionHeader
		cmp.l	a2,d1			; zeigt A2 auf mh_First ?
		beq.s	5$			; ja ---> Spezialfall

		move.l	mc_Bytes(a2),d2		; Länge des freien Chunks
		add.l	a2,d2			; + Anfang = Chunk-Ende
		cmp.l	a1,d2			; Anfang des freizugebenden Chunks
		beq.s	6$			; == Ende des freien Chunks --->
		bhi.s	.FreeError		; im freien Bereich ---> Guru

5$:		move.l	(a2),(a1)		; Neuen Blockheader erzeugen
		move.l	a1,(a2)
		move.l	d0,mc_Bytes(a1)
		bra.s	7$			; --->
6$:
		add.l	d0,mc_Bytes(a2)		; Blocklänge += Freibytes
		move.l	a2,a1			; Blockanfang
7$:
		tst.l	(a1)			; Link eingetragen ?
		beq.s	8$			; nein --->
		move.l	mc_Bytes(a1),d2		; Blocklänge
		add.l	a1,d2			; + Anfang = Ende+1
		cmp.l	(a1),d2			; mit Linkadresse vergleichen
		bhi.s	.FreeError		; Linkadr. kleiner ---> Guru
		bne.s	8$			; Linkadresse grösser --->
		move.l	(a1),a2			; Nächsten Chunk einlinken
		move.l	(a2),(a1)
		move.l	mc_Bytes(a2),d2
		add.l	d2,mc_Bytes(a1)
8$:
		add.l	d0,mh_Free(a0)		; Frei-Zähler anpassen

.FreeEnd:	jsr	meb_Enable(a6)
		movem.l	(SP)+,d0-d2/a0-a2
		rts	

.FreeError:	movem.l	(SP)+,d0-d2/a0-a2
		movea.l	(SP)+,a5
		MSG	<'FreeMem: MemList corrupt, A0=MRH, A5=PC'>
		jmp	meb_ColdReboot(a6)

***************************************************************************

CheckMemFunc:	movem.l	d0-d1/a0-a1,-(SP)
		jsr	meb_Disable(a6)

		lea	meb_ChipMRHeader(a6),a0	; The MemoryRegionHeader
		bsr.s	CheckMemList

		tst.l	meb_FastMRHeader+mh_First(a6)	; FAST RAM vorhanden ?
		beq.s	1$
		lea	meb_FastMRHeader(a6),a0
		bsr.s	CheckMemList
1$:
		jsr	meb_Enable(a6)
		movem.l	(SP)+,d0-d1/a0-a1
		rts

	*** Speicherliste (A0) testen, Message falls korrupt

CheckMemList:	moveq.l	#0,d1			; Free-Count löschen
		lea	mh_First(a0),a1		; Zeiger auf 1. freien Chunk

.CheckLoop:	move.l	mc_Next(a1),d0		; Link zum nächsten Chunk
		beq.s	1$			; Ende der Liste --->
	;;	cmp.l	a1,d0			; Next < actual ?
	;;	bls.s	.CheckError		; ja ---> Error
		movea.l	d0,a1
		add.l	mc_Bytes(a1),d1		; FreeCount += bytes
		bra.s	.CheckLoop
1$:
		cmp.l	mh_Free(a0),d1		; FreeCount richtig ?
		bne.s	.CheckError
		rts

.CheckError:	move.l	mh_Free(a0),d0		; Soll-Wert
		MSG	<'CheckMem: List corrupt, D0=soll, D1=ist, A0=MRH, A1=Chunk'>
		jmp	meb_ColdReboot(a6)

**************************************************************************

	*** Speicher schnell kopieren, WORD-aligned, Länge % 4 = 0

CopyMemQuickFunc:
		movem.l	d0-d1/a0-a1,-(SP)
		moveq	#0,d1			; Kein Byte-Rest
		bra.s	l272			; --->

	*** Speicher normal kopieren

CopyMemFunc:	movem.l	d0-d1/a0-a1,-(SP)
		moveq	#12,d1
		cmp.l	d1,d0			; Länge < 12 ?
		bcs.s	l277			; ja ---> byteweise kopieren
		move.l	a0,d1			; Source
		btst	#0,d1			; Gerade ?
		beq.s	l271			; ja --->
		move.b	(a0)+,(a1)+		; Sonst 1 Byte kopieren
		subq.l	#1,d0
l271:		move.l	a1,d1			; Destination
		btst	#0,d1			; Gerade ?
		bne.s	l277			; nein ---> byteweise kopieren
		move.l	d0,d1			; Länge
		andi.w	#3,d1			; Byte-Rest von LONGs

l272:		move.w	d1,-(SP)		; Rest retten für später
		moveq	#96,d1			; 2* Länge von 12 Registern
		cmp.l	d1,d0
		bcs.s	l274			; movem lohnt sich nicht --->

		movem.l	d1-d7/a2-a6,-(SP)	; Alles retten
l273:		movem.l	(a0)+,d1-d7/a2-a6
		movem.l	d1-d7/a2-a6,(a1)
		moveq	#48,d1			; 12 LONG-Register
		adda.l	d1,a1			; INC dest
		sub.l	d1,d0			; DEC len
		cmp.l	d1,d0			; nochmal ?
		bcc.s	l273			; ja --->
		movem.l	(SP)+,d1-d7/a2-a6

l274:		lsr.l	#2,d0			; restliche Longwords
		beq.s	l276			; keine --->
		subq.l	#1,d0			; für dbf
		move.l	d0,d1
		swap	d0
l275:		move.l	(a0)+,(a1)+
		dbf	d1,l275
		dbf	d0,l275

l276:		move.w	(SP)+,d1		; Geretteter Byte-Rest
		beq.s	l27a			; 0 --->
		moveq	#0,d0
		bra.s	l279			; byteweise kopieren

l277:		move.w	d0,d1
		swap	d0
		bra.s	l279
l278:		move.b	(a0)+,(a1)+
l279:		dbf	d1,l278
		dbf	d0,l278
l27a:
		movem.l	(SP)+,d0-d1/a0-a1
		rts	

**************************************************************************

	*** Speicher löschen, A0 :  Adresse, D0 :  Länge in Bytes ( <=1MB! )

ClearMemFunc:	movem.l	d0-d2/a0,-(SP)
		moveq.l	#0,d2			; Lösch-Register
		move.l	a0,d1
		btst	#0,d1			; Adresse gerade ?
		beq.s	1$			; ja --->
		subq.l	#1,d0			; DEC len
		bmi.s	99$			; Länge war 0 --->
		move.b	d2,(a0)+		; 1 Byte löschen
1$:
		move.l	d0,d1			; Länge
		lsr.l	#4,d1			; /16 weil 4 LONGs aufs mal
		bra.s	3$			; Für dbf
2$:		move.l	d2,(a0)+
		move.l	d2,(a0)+
		move.l	d2,(a0)+
		move.l	d2,(a0)+
3$:		dbf	d1,2$

		andi.w	#15,d0			; restliche Bytes
		bra.s	5$			; Für dbf
4$:		move.b	d2,(a0)+
5$:		dbf	d0,4$
99$:
		movem.l	(SP)+,d0-d2/a0
		rts

***************************************************************************

	*** Anzahl freie Bytes CHIP-RAM nach D0

AvailMemFunc:	move.l	meb_ChipMRHeader+mh_Free(a6),d0
		rts

***************************************************************************

	*** Anzahl freie Bytes FAST-RAM nach D0

AvailFastMemFunc:
		move.l	meb_FastMRHeader+mh_Free(a6),d0
		rts


ActAmount:	ds.l	1

		END
