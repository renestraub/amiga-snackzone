***************************************************************************
**                                                                       **
**   RawDoFmt  -  Die geniale Ausgabe-Routine, beherrscht neuerdings     **
**                auch Bin�r-Zahlen (%b, %lb, %04b etc.)                 **
**                                                                       **
***************************************************************************
**                                                                       **
**   Modification History                                                **
**   --------------------                                                **
**                                                                       **
**   01-May-89  CHW  Created this file from CHH's HdExec.S               **
**   01-May-89  CHW  Binary String Conversion added, code cleaned up     **
**   25-Nov-89  CHW  Linksize changed from 34 to 64 (Paranoia?)          **
**                                                                       **
***************************************************************************

		OPT	O+,OW-,O5-,OW6+

		SECTION	text,CODE

		XDEF	RawDoFmtFunc,RawPrintfFunc

RB_LEFTALIGNED:	EQU	0		; Flag-Definitionen
RB_ZEROFILL:	EQU	1
RB_LONGARG:	EQU	2

LINKSIZE:	EQU	64		; Jaja, bin�r wird lang...


***************************************************************************

	*** A0=Formatstring A1=Args A2=Routine A3=Ptr f�r Routine

RawDoFmtFunc:	movem.l	d0-d6/a0-a5,-(a7)
		link	a6,#-LINKSIZE		; Puffer f�r Umwandlungen
		move.l	a1,-(SP)		; Argumente
		move.l	a0,a4			; Formatstring

MainLoop:	move.b	(a4)+,d0		; N�chstes Zeichen
		beq.s	Ende			; fertig --->
		cmpi.b	#'%',d0
		beq.s	DoFormat
DirectOut:	jsr	(a2)			; Zeichen direkt ausgeben
		bra.s	MainLoop		; --->

Ende:		jsr	(a2)			; Endzeichen ausgeben
		unlk	a6
		movem.l	(SP)+,d0-d6/a0-a5
		rts

	*** Format-Anweisung bearbeiten

DoFormat:	lea	-LINKSIZE(a6),a5	; Start des Puffers
		clr.w	d3			; Flags l�schen
		cmpi.b	#'-',(a4)		; Erstes Zeichen == '-' ?
		bne.s	1$			; nein --->
		bset	#RB_LEFTALIGNED,d3	; Linksb�ndig-Flag setzen
		addq.l	#1,a4			; Formatzeiger vorr�cken
1$:
		cmpi.b	#'0',(a4)		; N�chstes Zeichen == '0' ?
		bne.s	2$			; nein --->
		bset	#RB_ZEROFILL,d3		; Flag f�r mit Nullen f�llen
2$:
		bsr	DecimalConvert
		move.w	d0,d6			; D6 := minimale Feldbreite
		clr.l	d5
		cmpi.b	#'.',(a4)		; N�chstes Zeichen == '.' ?
		bne.s	3$			; nein --->
		addq.w	#1,a4			; Formatzeiger vorr�cken
		bsr	DecimalConvert
		move.w	d0,d5			; D5 := maximale Feldbreite
3$:
		cmpi.b	#'l',(a4)		; N�chstes Zeichen == 'l' ?
		bne.s	4$			; nein --->
		bset	#RB_LONGARG,d3		; Flag f�r LONG-Argument
		addq.w	#1,a4			; Formatzeiger vorr�cken
4$:
		move.b	(a4)+,d0		; N�chstes Zeichen
		cmpi.b	#'d',d0			; 'd': Dezimaldarstellung ?
		bne.s	5$			; nein --->
		bsr.s	GetData			; Daten nach D4
		bsr	D4ToDez			; und in String verwandeln
		bra.s	AusgAbschl
5$:
		cmpi.b	#'x',d0			; 'x': Hex-Darstellung ?
		bne.s	6$			; nein --->
		bsr.s	GetData			; Daten nach D4
		bsr	D4ToHex			; und in String verwandeln
		bra.s	AusgAbschl
6$:
		cmpi.b	#'b',d0			; 'b': Bin�r-Darstellung ?
		bne.s	7$			; nein --->
		bsr.s	GetData			; Daten nach D4
		bsr	D4ToBin			; und in String verwandeln
		bra.s	AusgAbschl
7$:
		cmpi.b	#'s',d0			; 's': String ?
		bne.s	8$			; nein --->
		move.l	(a7),a1			; A1: Ausgabedaten
		move.l	(a1)+,a5		; A5: Zeiger auf String
		move.l	a1,(a7)			; Neues A1 zur�ckschreiben
		bra.s	AusgAbschl2
8$:
		cmpi.b	#'c',d0			; 'c': Einzelnes Zeichen ?
		bne	DirectOut		; nein --->
		bsr.s	GetData			; Zeichencode nach D4
		move.b	d4,(a5)+		; und in Puffer schreiben


AusgAbschl:	clr.b	(a5)			; Puffer mit 0 abschliessen
		lea	-LINKSIZE(a6),a5	; A5: Pufferanfang

AusgAbschl2:	move.l	a5,a0
		bsr.s	StrLenD2
		tst.w	d5			; Maximale Feldl�nge ?
		beq.s	1$			; nein --->
		cmp.w	d5,d2			; String l�nger als max. ?
		bhi.s	2$			; ja --->
1$:
		move.w	d2,d5			; Feldl�nge := Stringl�nge
2$:
		sub.w	d5,d6			; D6 := Feldl�nge-Stringl�nge
		bpl.s	3$			; Feldl�nge gr�sser --->
		clr.w	d6
3$:
		btst	#RB_LEFTALIGNED,d3	; Linksb�ndige Ausgabe ?
		bne.s	5$			; ja --->
		bsr	Filler			; Mit 0 oder Space f�llen

		bra.s	5$			; f�r dbf
4$:		move.b	(a5)+,d0		; N�chstes Zeichen
		jsr	(a2)			; ausgeben
5$:		dbf	d5,4$

		btst	#RB_LEFTALIGNED,d3	; Linksb�ndig ?
		beq	MainLoop		; nein --->
		bsr	Filler			; sonst auff�llen
		bra	MainLoop		; --->

**************************************************************************

	*** Ausgabedaten nach D4 holen

GetData:	move.l	4(a7),a1		; Argument-Array
		btst	#RB_LONGARG,d3		; LONG-Argument ?
		bne.s	1$			; ja --->
		move.w	(a1)+,d4		; Datenwort holen
		move.l	a1,4(a7)		; Neues A1 zur�ckschreiben
		ext.l	d4			; Wort auf LONG erweitern
		rts
1$:
		move.l	(a1)+,d4		; Datenlangwort holen
		move.l	a1,4(a7)		; Neues A1 zur�ckschreiben
		rts

***************************************************************************

	*** Stringl�nge von (a0) nach D2

StrLenD2:	moveq	#-1,d2
1$:		tst.b	(a0)+
		dbeq	d2,1$
		neg.l	d2
		subq.w	#1,d2
		rts

***************************************************************************

	*** Dezimal-String (A4) in Zahl D0 umwandeln

DecimalConvert:	clr.l	d0
		clr.l	d2
1$:		move.b	(a4)+,d2		; N�chstes Zeichen
		cmpi.b	#'0',d2
		bcs.s	2$
		cmpi.b	#'9',d2
		bhi.s	2$
		move.l	d0,d1
		lsl.l	#2,d0			; Zahl *= 4
		add.l	d1,d0			; gibt * 5
		add.l	d0,d0			; gibt * 10
		subi.b	#'0',d2
		add.l	d2,d0			; Zahl += n�chste Ziffer
		bra.s	1$			; ---> Loop
2$:		subq.l	#1,a4
		rts

***************************************************************************

	*** Zahl D4 in Dezimal-String (A5)+ umwandeln

D4ToDez:	tst.l	d4			; Zahl testen
		beq.s	D4To_End		; == 0 --->
		bmi.s	1$			;  < 0 --->
		neg.l	d4			; Zahl negieren
		bra.s	2$			; --->
1$:		move.b	#'-',(a5)+		; Minuszeichen
2$:
		lea	ZehnerPotenzen(PC),a0
		st	d1			; Anfangsnullenflag setzen
3$:
		move.l	(a0)+,d2		; D2 := n�chster Tabellenwert
		beq.s	D4To_End		; Tabelle fertig --->

		moveq	#-1,d0			; Z�hler := 0
4$:		add.l	d2,d4			; So oft D2 zur Zahl addieren
		dbgt	d0,4$			; bis sie positiv ist
		sub.l	d2,d4			; dann einmal subtrahieren
		addq.w	#1,d0			; Wurde nur 1* addiert ?
		bne.s	5$			; nein --->
		tst.b	d1			; Ist es eine f�hrende 0 ?
		bne.s	3$			; ja ---> nicht ausgeben
5$:
		sf	d1			; Anfangsnullenflag l�schen
		neg.b	d0			; Zahl der Additionen -1
		addi.b	#'0',d0			; ergibt Zifferncode
		move.b	d0,(a5)+		; Ziffer in Puffer
		bra.s	3$			; ---> Loop
D4To_End:
		neg.b	d4			; D4 := Letzte Ziffer
		addi.b	#'0',d4			; ergibt Zifferncode
		move.b	d4,(a5)+		; Ziffer in Puffer
		rts

ZehnerPotenzen:	dc.l	1000000000
		dc.l	 100000000
		dc.l	  10000000
		dc.l	   1000000
		dc.l	    100000
		dc.l	     10000
		dc.l	      1000
		dc.l	       100
		dc.l	        10
		dc.l	         0		; Endmarke
												dc.l	$43485721

***************************************************************************

	*** Zahl D4 in Hex-String (A5)+ umwandeln

D4ToHex:	tst.l	d4			; Zahl testen
		beq	D4To_End		; == 0 --->
		st	d1			; Anfangsnullenflag setzen
		btst	#RB_LONGARG,d3		; LONG-Argument ?
		bne.s	1$			; ja --->
		moveq	#3,d2			; sonst 4 Stellen
		swap	d4			; Zahlwert in oberes Wort
		bra.s	2$
1$:		moveq	#7,d2			; 8 Stellen
2$:
		rol.l	#4,d4			; Bits 0-3 := n�chste Stelle
		move.b	d4,d0
		andi.b	#15,d0
		bne.s	3$			; Nicht 0 --->
		tst.b	d1			; Anfangsnull ?
		bne.s	6$			; ja ---> nicht ausgeben
3$:
		sf	d1			; Anfangsnullenflag l�schen
		cmpi.b	#9,d0			; Ziffer > 9 ?
		bhi.s	4$			; ja --->
		addi.b	#'0',d0
		bra.s	5$
4$:		addi.b	#'A'-10,d0
5$:		move.b	d0,(a5)+		; Ziffer in Puffer
6$:		dbf	d2,2$			; Loop --->
		rts

***************************************************************************

	*** Zahl D4 in Bin�r-String (A5)+ umwandeln

D4ToBin:	tst.l	d4			; Zahl testen
		beq	D4To_End		; == 0 --->
		st	d1			; Anfangsnullenflag setzen
		btst	#RB_LONGARG,d3		; LONG-Argument ?
		bne.s	1$			; ja --->
		moveq	#15,d2			; sonst 16 Stellen
		swap	d4			; Zahlwert in oberes Wort
		bra.s	2$
1$:		moveq	#31,d2			; 32 Stellen
2$:		roxl.l	#1,d4			; N�chste Stelle in Carry
		bcs.s	3$			; 1 --->
		tst.b	d1			; Anfangsnull ?
		bne.s	5$			; ja ---> nicht ausgeben
		moveq	#'0',d0
		bra.s	4$			; --->
3$:		sf	d1			; Anfangsnullenflag l�schen
		moveq	#'1',d0
4$:		move.b	d0,(a5)+		; Ziffer in Puffer
5$:		dbf	d2,2$			; Loop --->
		rts

***************************************************************************

	*** Nullen oder Leerstellen ausgeben

Filler:		move.b	#' ',d2			; F�llcode: Space
		btst	#RB_ZEROFILL,d3		; F�llen mit Nullen ?
		beq.s	2$			; nein --->
		move.b	#'0',d2			; Sonst F�llcode '0'
		bra.s	2$			; F�r dbf
1$:		move.b	d2,d0			; F�llcode
		jsr	(a2)			; ausgeben
2$:		dbf	d6,1$
		rts

*************************************************************************
*
* _RawPrintf.asm  - Self-contained printf clone.  Formatted strings
*		    are sent directly out the serial port.  Xon/Xoff
*		    handshake is supported.
*		    This function may be called at any time, including
*		    interrupts.
*
*	Bryce Nesbitt, 02-24-89
*
*************************************************************************

		XDEF	RawPrintfFunc

RawPrintfFunc:	movem.l a0/a1,-(sp)
		move.l	4*3(SP),A0      ;grab format string
		lea.l	4*4(SP),A1      ;grab stack address of parameters
		movem.l A2/A3/D0/D1,-(SP)
		lea.l	PSCODE(pc),a2
		suba.l	a3,a3
		bsr	RawDoFmtFunc
		movem.l (SP)+,D0/D1/A2/A3
		movem.l (sp)+,a0/a1
		rts


PSCODE: 	tst.b	d0
		beq.s	ignore
1$		move.w	$DFF018,d1	;_serdatr
		btst	#13,d1		;TBE bit
		beq.s	1$
		and.b	#$7f,d1
		cmp.b	#$18,d1 	;Check for CAN (^X)
		beq.s	ignore
		cmp.b	#$13,d1 	;Check for Xoff
		beq.s	1$
		and.w	#$ff,d0
		or.w	#$100,d0
		move.w	d0,$DFF030	;_serdat
ignore: 	rts

*****************************************************************************

		END
