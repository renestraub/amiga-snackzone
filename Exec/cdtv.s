
		IDNT	CDTV
		SECTION	text,CODE

		INCLUDE	"MyExec.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"exec/io.i"

		XREF	@CreateIO,@DeleteIO,RawPrintfFunc
		XDEF	InitCDFunc,ExitCDFunc,PlayCDTrackFunc
		XDEF	WaitCDTrackFunc

CD_PLAYTRACK:	EQU	43
CD_MUTE:	EQU	56

*****************************************************************************
* CDTV-IORequest erstellen und Device öffnen

InitCDFunc:	movem.l	d1/a0-a2/a6,-(SP)
		
		moveq.l	#IOSTD_SIZE,d0
		bsr	@CreateIO
		move.l	d0,CDIOReq
		beq.s	1$			; No mem --->
		movea.l	d0,a2

		moveq	#0,d0			; Unit
		moveq	#0,d1			; Flags
		lea	CDTVName(PC),a0
		movea.l	a2,a1
		movea.l	4,a6
		JSRLIB	OpenDevice
		tst.l	d0			; Device OK ?
		beq.s	1$			; yep --->
		bsr.s	ExitCDFunc		; Sonst Request freigeben
		bra.s	2$
1$:
		movea.l	CDIOReq,a1
		move.w	#CD_MUTE,IO_COMMAND(a1)
		move.l	#$7fff,IO_OFFSET(a1)
		move.l	#1,IO_LENGTH(a1)
		move.l	#0,IO_DATA(a1)
		JSRLIB	DoIO

		pea	CDDevOKText(PC)
		bsr	RawPrintfFunc
		addq	#4,SP
2$:
		movem.l	(SP)+,d1/a0-a2/a6
		rts

*****************************************************************************
* CDTV-Resourcen wieder freigeben

ExitCDFunc:	movem.l	d1-d2/a0-a1/a6,-(SP)

		move.l	CDIOReq,d2
		beq.s	2$
		movea.l	d2,a1
		tst.l	IO_DEVICE(a1)
		ble.s	1$
		movea.l	4,a6
		JSRLIB	CloseDevice
1$:
		movea.l	d2,a1			; IO-Request
		bsr	@DeleteIO		; freigeben
		clr.l	CDIOReq			; Wichtig!
2$:
		movem.l	(SP)+,d1-d2/a0-a1/a6
		rts

*****************************************************************************
* CDTV-Track abspielen

PlayCDTrackFunc:
		movem.l	d1-d3/a0-a1/a6,-(SP)

		move.l	CDIOReq,-(SP)
		move.l	d0,-(SP)
		pea	PlayText(PC)
		bsr	RawPrintfFunc
		lea	12(SP),SP

		movea.l	4,a6
		move.l	CDIOReq,d3
		beq.s	2$

	;;	movea.l	d3,a1
	;;	cmpi.w	#CD_PLAYTRACK,IO_COMMAND(a1)	; Schon initialisiert ?
	;;	bne.s	1$				; nein ---> Nicht warten
	;;	JSRLIB	AbortIO
		bsr.s	WaitCDTrackFunc
1$:
		movea.l	d3,a1
		move.w	#CD_PLAYTRACK,IO_COMMAND(a1)
		move.l	d0,IO_OFFSET(a1)		; Gewünschter Track
		clr.l	IO_LENGTH(a1)
		clr.l	IO_DATA(a1)
		JSRLIB	SendIO
2$:
		movem.l	(SP)+,d1-d3/a0-a1/a6
		rts

*****************************************************************************
* Auf CD warten

WaitCDTrackFunc:
		movem.l	d0-d3/a0-a1/a6,-(SP)

		movea.l	4,a6
		move.l	CDIOReq,d3
		beq.s	2$

		pea	WaitText(PC)
		bsr	RawPrintfFunc
		addq	#4,SP

		movea.l	d3,a1
		cmpi.w	#CD_PLAYTRACK,IO_COMMAND(a1)	; Schon initialisiert ?
		bne.s	1$				; nein ---> Nicht warten
		JSRLIB	WaitIO
1$:
		pea	WaitFinText(PC)
		bsr	RawPrintfFunc
		addq	#4,SP
2$:
		movem.l	(SP)+,d0-d3/a0-a1/a6
		rts

*****************************************************************************

CDTVName:	dc.b	"cdtv.device",0

CDDevOKText:	dc.b	"CDTV device OK",13,10,0
PlayText:	dc.b	"PlayCDTrack(%ld), req=$%08lx",13,10,0
WaitText:	dc.b	"Waiting for audio to finish ... ",0
WaitFinText:	dc.b	"Done.",13,10,0

		EVEN

		SECTION	bss,BSS
CDIOReq:	ds.l	1

		END

