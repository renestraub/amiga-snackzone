****************************************************************************
**                                                                        **
**       R A M L I B  -  Automatisches FileBuffern                        **
**                                                                        **
****************************************************************************
**                                                                        **
**   Modification History                                                 **
**   --------------------                                                 **
**                                                                        **
**   20-Nov-90  CHH  Created this file                                    **
**   21-Nov-90  CHH  NoMemHandler eingebaut. Löscht erstes File in der    **
**                   Liste                                                **
**   11-Feb-91  CHH  BufReadFile eingebaut                                **
**                                                                        **
****************************************************************************

		IDNT	RAMLib
		SECTION	text,CODE


		XDEF	InitRAMLib
		XDEF	BufLoadFileFunc,DeleteFileNodeFunc
		XDEF	DeleteFileListFunc,MyNoMemHandler
		XDEF	BufReadFileFunc

		INCLUDE "myexec.i"

	     STRUCTURE  LoadEntry,0
		STRUCT	le_Node,ln_SIZEOF
		APTR	le_FileBuffer
		LONG	le_Len
		LABEL	le_SIZEOF


NT_DISKNODE:	EQU	$80
NT_RAMNODE:	EQU	$81

******************************************************************************

InitRAMLib:	lea	meb_FileList(a6),a0
		jsr	meb_NewList(a6)

		bset.b	#EXECB_BUFENABLE,meb_ExecFlags(a6)
		tst.l	meb_FastMRHeader+mh_Free(a6)
		bne.s	.EnoughRam
		cmp.l	#$80000,meb_ChipMRHeader+mh_Free(a6)
		bhi.s	.EnoughRam
		bclr.b	#EXECB_BUFENABLE,meb_ExecFlags(a6)
.EnoughRam:
		rts

******************************************************************************

	***  Ein File laden und im FastRam buffern

BufLoadFileFunc:
		btst.b	#EXECB_BUFENABLE,meb_ExecFlags(a6)
		bne.s	0$
		jmp	meb_LoadFile(a6)
0$:
		move.l	d0,ActName

	** Zuerst schauen ob File bereits in der Liste ist

		movem.l	d1-d7/a0-a4,-(SP)
		lea	meb_FileList(a6),a0
		move.l	lh_Head(a0),a0		; Ersten Eintrag holen
.SearchLoop:	tst.l	ln_Succ(a0)		; Listen-Ende ?
		beq	.NormLoad		; wenn ja -> File normal laden
		cmp.l	ln_Name(a0),d0		; gesuchter FileNode ?
		beq.s	.FileFound
		move.l	ln_Succ(a0),a0
		bra	.SearchLoop


.FileFound:	movea.l	a0,a3			; A3 : FileNode

		move.l	le_Len(a3),d0
		jsr	meb_AllocMem(a6)
		move.l	d0,a2


	** jetzt testen ob wir immer noch in der Liste sind 
	** (jaja, letztes AllocMem könnte uns rausgeschmissen haben)

		lea	meb_FileList(a6),a4
		move.l	lh_Head(a4),a4		; erster Node
.NochDrinLoop:	tst.l	ln_Succ(a4)		; kein Eintrag mehr ?
		beq	.NormLoad2		; wenn ja -> tja, wir wurden soeben entfernt und muessen das file nochmal laden
		cmp.l	a3,a4			; sind wir das ?
		beq.s	.NochDrin		; ja -> File aus Ram laden
		move.l	ln_Succ(A4),a4
		bra	.NochDrinLoop


.NochDrin:	move.l	le_FileBuffer(a3),a0	; A0 : RamAdresse
		move.l	a2,a1			; A1 : LadeAdresse
		move.l	le_Len(a3),d0		; D0 : FileLänge
		jsr	meb_CopyMem(a6)		; File aus Ram laden

		move.l	a2,d0			; D0 : Ergebnis

		movem.l	(SP)+,d1-d7/a0-a4
		rts


	** Den vergebens reservierten Speicher wieder freigeben

.NormLoad2:	movea.l	a2,a1
		jsr	meb_FreeMem(a6)


	** File normal laden

.NormLoad:	movem.l	(SP)+,d1-d7/a0-a4
		move.l	ActName,d0		; D0 : FileName
		jsr	meb_LoadFile(a6)	; File von Disk einladen

	** File in Liste einbinden

		movem.l	d0-d7/a0-a4,-(SP)
		move.l	d0,a2			; A2 : Zeiger auf geladenes File

		move.l	#le_SIZEOF,d0			; Platz für
		jsr	meb_AllocFastClearMem(a6)	; Node reservieren

		move.l	d0,a4			; a4 = Node

	** NodeType entspechend dem FileNamen festlegen (nur zum debugen)

		moveq.l	#NT_DISKNODE,d0
		tst.b	ActName			; Igitt! So nicht!
		bne.s	1$
		moveq.l	#NT_RAMNODE,d0
1$:		move.b	d0,ln_Type(a4)		; NodeType eintragen
		move.l	ActName,ln_Name(a4)	; FileName eintragen

		move.l	-4(a2),d0		; D0 : Länge des zu buffernden Files
		subq.l	#4,d0
		move.l	d0,le_Len(a4)

		jsr	meb_AllocFastMem(a6)	; Speicher dafür reservieren
		move.l	d0,le_FileBuffer(a4)
		move.l	d0,a3

		move.l	a2,a0			; File
		move.l	a3,a1			; in Buffer
		move.l	le_Len(a4),d0
		jsr	meb_CopyMem(a6)		; kopieren

		lea	meb_FileList(a6),a0	; FileNode
		move.l	a4,a1			; in Liste
		jsr	meb_Enqueue(a6)		; einbinden

		movem.l	(SP)+,d0-d7/a0-a4
		rts

******************************************************************************


	** D0 : FileName / A0 : Address

BufReadFileFunc:
		btst.b	#EXECB_BUFENABLE,meb_ExecFlags(a6)
		bne.s	0$
		jmp	meb_ReadFile(a6)
0$:
		move.l	d0,ActName

	** Zuerst schauen ob File bereits in der Liste ist

		movem.l	d1-d7/a0-a4,-(SP)
		move.l	a0,a1
		lea	meb_FileList(a6),a0
		move.l	lh_Head(a0),a0		; Ersten Eintrag holen
.SearchLoop:	tst.l	ln_Succ(a0)		; Listen-Ende ?
		beq	.NormLoad		; wenn ja -> File normal laden
		cmp.l	ln_Name(a0),d0		; gesuchter FileNode ?
		beq.s	.FileFound
		move.l	ln_Succ(a0),a0
		bra	.SearchLoop


.FileFound:	movea.l	a0,a3			; A3 : FileNode
		move.l	le_Len(a3),d0
		move.l	le_FileBuffer(A3),a0
		jsr	meb_CopyMem(a6)
		movem.l	(SP)+,d1-d7/a0-a4
		rts


	** File normal laden

.NormLoad:	movem.l	(SP)+,d1-d7/a0-a4
		move.l	ActName,d0		; D0 : FileName
		move.l	a0,a1
		jsr	meb_LoadFastFile(a6)	; File von Disk einladen

	** File in Liste einbinden

		movem.l	d0-d7/a0-a4,-(SP)
		move.l	d0,a2			; A2 : Zeiger auf geladenes File

		move.l	#le_SIZEOF,d0			; Platz für
		jsr	meb_AllocFastClearMem(a6)	; Node reservieren

		move.l	d0,a4			; a4 = Node

		moveq.l	#NT_DISKNODE,d0
		tst.b	ActName			; Igitt! So nicht!
		bne.s	1$
		moveq.l	#NT_RAMNODE,d0
1$:		move.b	d0,ln_Type(a4)		; NodeType eintragen
		move.l	ActName,ln_Name(a4)	; FileName eintragen

		move.l	-4(a2),d0		; D0 : Länge des zu buffernden Files
		subq.l	#4,d0
		move.l	d0,le_Len(a4)

		move.l	a2,le_FileBuffer(a4)

		move.l	a2,a0			; File
		move.l	le_Len(a4),d0
		jsr	meb_CopyMem(a6)		; kopieren

		lea	meb_FileList(a6),a0	; FileNode
		move.l	a4,a1			; in Liste
		jsr	meb_Enqueue(a6)		; einbinden

		movem.l	(SP)+,d0-d7/a0-a4
		rts

******************************************************************************



	** Ein FileNode löschen / D0 = FileName

DeleteFileNodeFunc:
		move.l	a0,-(SP)
		lea	meb_FileList(a6),a0
		move.l	lh_Head(A0),a0		; A0 : erster Eintrag
.SearchLoop:	tst.l	ln_Succ(a0)		; ListenEnde ?
		beq	.EndDel
		cmp.l	ln_Name(A0),d0		; File gefunden ?
		beq	.FileFound		; ja ->
		move.l	ln_Succ(a0),a0		; sonst nächsten
		bra	.SearchLoop		; Eintrag holen

.FileFound:	bsr.s	DeleteNode		; Node und File freigeben 

.EndDel:	movea.l	(SP)+,a0
		rts



	** Node (A0) und File freigeben

DeleteNode:	movem.l	d0/a0-a2,-(SP)
		move.l	a0,a2			; File
		move.l	le_FileBuffer(a0),a1
		jsr	meb_FreeMem(a6)		; freigeben

		move.l	a2,a1			; Node aus Liste
		jsr	meb_Remove(a6)		; entfernen

		move.l	a2,a1			; Node Speicher
		jsr	meb_FreeMem(a6)		; freigeben

		movem.l	(SP)+,d0/a0-a2
		rts



	** Ganze FileListe freigeben


DeleteFileListFunc:
		move.l	a0,-(SP)
.DelLoop:	lea	meb_FileList(a6),a0
		move.l	lh_Head(a0),a0
		tst.l	ln_Succ(a0)
		beq	.EndDel
		bsr.s	DeleteNode
		bra.s	.DelLoop
.EndDel:	movea.l	(SP)+,a0
		rts

******************************************************************************

	** Wenn kein Speicher mehr vorhanden ist, erstes File in Buffer-
	** Liste freigeben und nochmal AllocMem() probieren
	** (Wird von AllocMem aufgerufen)

MyNoMemHandler:	movem.l	a0-a1,-(SP)
		lea	meb_FileList(a6),a0
		move.l	lh_Head(a0),a1		; A1 : Zeiger auf ersten Node 
		tst.l	ln_Succ(a1)		; Listen Ende ? 
		beq.s	.ListEmpty		; ja -> Guru
		movea.l	a1,a0			; sonst ersten
		bsr.s	DeleteNode		; Node freigeben
		movem.l	(SP)+,a0-a1
		moveq.l	#-1,d0			; Noch einmal probieren
		rts

.ListEmpty:	movem.l	(SP)+,a0-a1
		moveq.l	#0,d0			; Kein Speicher mehr
		rts


******************************************************************************

		SECTION	BSS,BSS

ActName:	ds.l	1

