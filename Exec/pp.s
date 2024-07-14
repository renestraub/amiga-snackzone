ARP
		;opt	O+
		;opt	O5-

		OPT	O+
		OPT	O5-
		OPT	OW-


		SECTION	text,CODE

		XDEF	Main



		INCLUDE "exec.i"
		INCLUDE "structures.i"
		INCLUDE "structoffsets.i"
		INCLUDE	"dos.i"
		INCLUDE	"arp.i"

		INCLUDE "constants.i"



PathLen:	EQU	255

   BITDEF  SIGBREAK,CTRL_C,12
   BITDEF   FIB,SCRIPT,6	; program is an execute script
   BITDEF   FIB,PURE,5		; program is reentrant and reexecutable
   BITDEF   FIB,ARCHIVE,4	; cleared whenever file is changed
   BITDEF   FIB,READ,3		; ignored by the system
   BITDEF   FIB,WRITE,2		; ignored by the system
   BITDEF   FIB,EXECUTE,1	; ignored by the system
   BITDEF   FIB,DELETE,0	; prevent file from being deleted



	STRUCTURE MyAnchor,ap_SIZEOF
		STRUCT	PathBuffer,PathLen
		LABEL	ma_SIZEOF	


	STRUCTURE  MyData,0
		LABEL	ArgArray
		APTR	DirPointer
		LONG	AllFlag
		STRUCT	Para,3*4
		STRUCT	NameBuffer,100
		LONG	ReadBuffer
		BPTR	FileHandle
		LABEL	md_SIZEOF


		OPENARP

Main:	
		movem.l	a0/d0,-(SP)
		move.l	#md_SIZEOF,d0
		Last	ArpAlloc
		move.l	d0,a5
		movem.l	(SP)+,d0/a0
		lea	HelpString(pc),a1
		lea	ArgArray(a5),a2
		lea	Template(pc),a3
		Last	GADS
		tst.l	d0
		bpl	1$
		lea	BadArgText(pc),a0
		jmp	Printf(a6)

1$:		move.l	DirPointer(a5),a0
		tst.w	d0
		bne	.PathOk
		lea	PathError(pc),a0
		sub.l	a1,a1
		jmp	Printf(a6)

.PathOk:	;bsr	ListDir
		;rts

ListDir:	movem.l	d1-d7/a0-a6,-(SP)
		lea	NameBuffer(a5),a1
		tst.b	(A0)
		bne	4$
		move.b	#'*',(A1)
		clr.b	1(a1)
		bra	6$
4$:		move.b	(A0)+,(a1)+		
		bne	4$
		subq.w	#2,a1
		move.b	(a1),d0
		cmp.b	#'*',d0
		beq	6$
		cmp.b	#':',d0
		bne	7$
		move.b	#'*',1(a1)
		clr.b	2(a1)
		bra	6$
7$:			
		move.b	#'/',1(A1)
		move.b	#'*',2(a1)
		clr.b	3(A1)

6$:		move.l	#ERROR_BREAK,d6
		lea	NameBuffer(a5),a4
		move.l	#ma_SIZEOF,d0
		Last	ArpAlloc
		move.l	d0,a3
		move.l	#PathLen,ap_Length(A3)
		move.l	#SIGBREAKF_CTRL_C,ap_BreakBits(A3)
		move.l	a3,a0
		move.l	a4,d0
		Last	FindFirst
		tst.l	d0
		bne	EndListDir
2$:		lea	PathBuffer(A3),a0
		move.l	a0,Para(A5)
		lea	ap_Info(a3),a0
		tst.l	fib_DirEntryType(a0)
		bmi	1$
10$:		;lea	DirText(pc),a0
		;lea	Para(a5),a1
		;Last	Printf	
9$:		tst.l	AllFlag(a5)
		beq	3$
		move.l	Para(a5),a0
		bsr	ListDir
		cmp.l	d6,d0
		beq	Break
		bra	3$

1$:		move.l	fib_Size(a0),d0		; D0 : FileLänge
		move.l	Para(a5),a0		; A0 : FileName mit Pfad
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2
		Last	Open
		move.l	d0,FileHandle(a5)
		beq	.NotFound
		move.l	d0,d1

		lea	ReadBuffer(a5),a0
		move.l	a0,d2
		moveq.l	#4,d3
		Last	Read
		cmp.l	#'PP20',ReadBuffer(a5)
		bne	.NoPP

		lea	NameText(pc),a0
		lea	Para(A5),a1
		Last	Printf
	
	
		move.l	FileHandle(a5),d1
		moveq.l	#-4,d2
		move.l	#OFFSET_END,d3
		Last	Seek

		move.l	FileHandle(a5),d1
		lea	ReadBuffer(a5),a0
		move.l	a0,d2
		moveq.l	#4,d3
		Last	Read

		move.l	ReadBuffer(a5),d0
		lsr.l	#8,d0
		move.l	d0,ReadBuffer(a5)

		move.l	FileHandle(a5),d1
		moveq.l	#0,d2
		move.l	#OFFSET_BEGINNING,d3
		Last	Seek

		move.l	FileHandle(a5),d1
		lea	ReadBuffer(a5),a0
		move.l	a0,d2
		moveq.l	#4,d3
		Last	Write

		move.l	Para(A5),d1
		moveq.l	#0,d2
		or.l	#FIBF_DELETE|FIBF_EXECUTE|FIBF_WRITE|FIBF_READ|FIBF_PURE,d2
		eor.b	#%1111,d2
		Last	SetProtection	


.NoPP:		move.l	FileHandle(a5),d1
		Last	Close			



.NotFound:	



3$:		move.l	a3,a0
		Last	FindNext
		tst.l	d0
		beq	2$
		cmp.l	d6,d0
		bne	EndListDir
Break:		lea	BreakText(pc),a0
		sub.l	a1,a1
		Last	Printf

EndListDir:
		movem.l	(SP)+,d1-d7/a0-a6
		rts

HelpString:	dc.b	'PP BrauchbarMacher V1.2 © 11-May-1991 by Chris Haller',10 
		dc.b	'Usage: PP [Dir] [ALL]',10,0
Template:	dc.b	'Dir/a,All/s',0
BadArgText:	dc.b	'Bad Args',10,0
NameText:	dc.b	'%s',10,0
;DirText:	dc.b	'%-68s    (dir)',10,0
BreakText:	dc.b	'*** BREAK',10,0
PathError:	dc.b	'Bitte Pfad angeben',10,0
																		dc.b	"CHW was here!"

