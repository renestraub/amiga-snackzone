*
* DrawBob.i  (zu BOBOL V3.16  23-Aug-91)
*

         ***********  BOBOL  Kommandos  *************


DO		MACRO				; LoopBeginn setzen
dovar		set	*			
		ENDM

REPEAT		MACRO				; LoopBeginn setzen
repeatvar	set	*
		ENDM

FOR		MACRO
forvar		set	*
		dc.w	BOBFOR
		dc.w	\1			; Anzahl Durchläufe
		ENDM

LOOP		MACRO				; Prg von vorne starten
		dc.w	BOBLOOP
		ENDM

ENDE		MACRO				; Prg beenden
		dc.w	BOBENDE
		ENDM
		
REMOVE		MACRO				; Bob entfernen
		dc.w	BOBREMOVE
		ENDM

SETPRI		MACRO				; Bob-Priorität ändern
		dc.w	BOBSETPRI
		dc.w	\1
		ENDM

SIGNAL		MACRO				; SignalMaske senden
		dc.w	BOBSIGNAL
		dc.w	\1
		ENDM

WAIT		MACRO				; auf SignalMaske warten
		dc.w	BOBWAIT
		dc.w	\1
		ENDM
		
BBEQ		MACRO				; Springen wenn Maske falsch
scavar		set	*
		dc.w	BOBUNTIL
		dc.w	\1			; Maske
		dc.w	scavar-\2		; Zieladresse
		ENDM
	
BBNE		MACRO				; Springen wenn Maske richtig
scavar		set	*
		dc.w	BOBWHILE
		dc.w	\1			; Maske
		dc.w	scavar-\2		; Zieladresse
		ENDM

UNTIL		MACRO				; zum REPEAT springen bis Bedingung stimmt
scavar		set	*
		dc.w	BOBUNTIL
		dc.w	\1
		dc.w	scavar-repeatvar
		ENDM
	
WHILE		MACRO				; zum DO springen bis Bedingung nicht mehr stimmt
scavar		set	*
		dc.w	BOBWHILE
		dc.w	\1
		dc.w	scavar-dovar
		ENDM

NEXT		MACRO
forvar2		set	*
		dc.w	BOBNEXT
		dc.w	forvar2-forvar-4
		ENDM

CPUJUMP		MACRO
		dc.w	BOBCPUJUMP
		dc.l	\1
		dc.l	\2
		ENDM

LEFT		MACRO
		dc.w	BOBLEFT
		dc.w	\1
		ENDM

RIGHT		MACRO
		dc.w	BOBRIGHT
		dc.w	\1
		ENDM

UP		MACRO
		dc.w	BOBUP
		dc.w	\1
		ENDM

DOWN		MACRO
		dc.w	BOBDOWN
		dc.w	\1
		ENDM

LEFTUP:		MACRO
		dc.w	BOBLEFT+BOBUP
		dc.w	\1
		ENDM

RIGHTUP:	MACRO
		dc.w	BOBRIGHT+BOBUP
		dc.w	\1
		ENDM

LEFTDOWN:	MACRO
		dc.w	BOBLEFT+BOBDOWN
		dc.w	\1
		ENDM

RIGHTDOWN:	MACRO
		dc.w	BOBRIGHT+BOBDOWN
		dc.w	\1
		ENDM

DELAY		MACRO
		dc.w	BOBDELAY
		dc.w	\1
		ENDM

RNDDELAY	MACRO
		dc.w	BOBRNDDELAY
		dc.w	\1
		dc.w	\2
		ENDM

POKEB:		MACRO
		dc.w	BOBPOKEB
		dc.l	\1
		dc.w	\2
		ENDM
		
POKEW		MACRO
		dc.w	BOBPOKEW
		dc.l	\1
		dc.w	\2
		ENDM

POKEL		MACRO
		dc.w	BOBPOKEL
		dc.l	\1
		dc.l	\2
		ENDM

RELMOVE:	MACRO
		dc.w	BOBRELMOVE
		dc.w	\1
		ENDM

SETANIM:	MACRO
		dc.w	BOBSETANIM
		dc.l	\1
		ENDM

SETMOVE:	MACRO
		dc.w	BOBSETMOVE
		dc.l	\1
		ENDM

SETCLIP:	MACRO
		dc.w	BOBSETCLIP
		dc.w	\1
		dc.w	\2
		dc.w	\3
		dc.w	\4
		dc.w	\5
		ENDM

SETORGTAB:	MACRO
		dc.b	bob_OrgTab
		dc.b	BOBSETLONG
		dc.l	\1
		ENDM


SETX:		MACRO
		dc.b	bob_X
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM



SETY:		MACRO
		dc.b	bob_Y
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM


SETDATA:	MACRO
		 IFEQ	NARG-1			; 1 Argument
		  DC.W	BOBSETDATA		; Normales AddBob
		  DC.L	\1
		 ENDC
		 IFEQ	NARG-2			; 2 Argumente
		  DC.W	BOBSETRELDATA		; Relatives AddBob
		  DC.L	\1			; Offset im Bobifile
		  DC.L	\2			; Zeiger auf Zeiger auf File
		 ENDC
		ENDM

SETMOVESPEED:	MACRO
		DC.W	BOBSETMOVESPEED
		DC.W	\1
		ENDM

SETMOVESTEP:	MACRO
		dc.b	bob_MoveStep
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM

SETANIMSPEED:	MACRO
		DC.W	BOBSETANIMSPEED
		DC.W	\1
		ENDM
 
SETID:		MACRO
		DC.W	BOBSETID
		DC.W	\1
		ENDM

SETUSERDATA:	MACRO
		dc.b	bob_UserData
		dc.b	BOBSETLONG
		DC.L	\1
		ENDM

SETUSERDATAPTR:	MACRO
		dc.b	bob_UserDataPtr
		dc.b	BOBSETLONG
		DC.L	\1
		ENDM



SETFLAGS:	MACRO
		dc.b	bob_Flags
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM


SETUSERFLAGS:	MACRO
		dc.b	bob_UserFlags
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM



LSIGNAL:	MACRO
		dc.w	BOBLSIGNAL
		dc.w	\1
		ENDM

LWAIT:		MACRO
		dc.w	BOBLWAIT
		dc.w	\1
		ENDM

ADDBOB:		MACRO
		dc.w	BOBADDBOB
		dc.l	\1
		ENDM

ADDRELBOB:	MACRO
		dc.w	BOBADDRELBOB
		dc.l	\1			; Bob
		dc.w	\2,\3			; X/Y-Offsets
		ENDM

SETCOLLHANDLER: MACRO
		dc.b	bob_CollHandler
		dc.b	BOBSETLONG
		dc.l	\1
		ENDM

SETMEMASK:	MACRO
		dc.b	bob_MeMask
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM


SETHITMASK:	MACRO
		dc.b	bob_HitMask
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM


RNDANIM:	MACRO
		dc.w	BOBRNDANIM
		dc.w	\1			; 1. Bildchen (-1 ?)
		dc.w	\2			; Letztes Bildchen
		ENDM

SETHANDLER: 	MACRO
		dc.b	bob_Handler
		dc.b	BOBSETLONG
		dc.l	\1
		IFEQ	NARG-2	
		 dc.b	bob_HandlerD0
		 dc.b	BOBSETLONG
		 dc.l	\2
		ENDC
		ENDM


REMHANDLER:	MACRO
		SETHANDLER	0
		ENDM


MOVETO:		MACRO
		dc.w	BOBMOVETO
		dc.w	\1,\2			; X/Y
		dc.w	\3			; Anzahl Schritte bis dahin
		ENDM

FLASH:		MACRO
		dc.w	BOBFLASH
		dc.w	\1			; Zeit in DrawBob()s oder so
		dc.w	\2			; Farbnummer
		ENDM

SETCONVERT:	MACRO
		dc.w	BOBSETCONVERT
		dc.l	\1			; Tabelle
		dc.w	\2			; EintragsGrösse
		dc.w	\3			; EintragsOffset
		ENDM

ANIMTO:		MACRO
		dc.w	BOBANIMTO
		dc.w	\1			; 1. Bobnummer
		dc.w	\2			; Letzte Bobnummer
		ENDM

GOTO:		MACRO
		dc.w	BOBGOTO
		dc.l	\1			; Label
		ENDM

ADDDAUGHTER:	MACRO
		dc.w	BOBADDDAUGHTERBOB
		dc.l	\1			; Daughter-Bob
		dc.w	\2,\3			; X-Versatz,Y-Versatz
		ENDM

SETIMAGE:	MACRO
		dc.b	bob_Image
		dc.b	BOBSETWORD
		dc.w	\1
		ENDM


TESTJOY:	MACRO
		dc.w	BOBTESTJOY
		dc.w	\1			; Joystick-Maske
		IFEQ	NARG-1
		dc.l	0
		ELSE
		dc.l	\2			; Zeiger auf FlipFlag
		ENDC
		ENDM


BITTEST:	MACRO				; BitTest BitNr,Adr
		dc.w	BOBBITTEST
		dc.w	\1
		dc.l	\2
		ENDM

JEQ:		MACRO
mvar:		SET	*
		dc.w	BOBJEQ
		dc.w	\1-mvar
		ENDM

JNE:		MACRO
mvar:		SET	*
		dc.w	BOBJNE
		dc.w	\1-mvar
		ENDM


FOREVERMAGIC:	EQU	-1

FOREVER:	MACRO
		FOR	FOREVERMAGIC
		ENDM

	



         ***********  BOBKOMMANDOS  *************


COMVAL:		SET	-2

SETCOM:		MACRO
BOB\1:		EQU	COMVAL
COMVAL:		SET	COMVAL-2
		ENDM
			

	SETCOM	SETWORD
	SETCOM	SETLONG
	SETCOM	LOOP		
	SETCOM	ENDE		
	SETCOM	REMOVE		
	SETCOM	SETPRI		

	SETCOM	SIGNAL		
	SETCOM	WAIT		
	SETCOM	CPUJUMP	
	SETCOM	UNTIL		
	SETCOM	WHILE		

	SETCOM	POKEB		
	SETCOM	POKEW		
	SETCOM	POKEL		
	SETCOM	RELMOVE	
	SETCOM	SETANIM	

	SETCOM	SETMOVE	
	SETCOM	SETCLIP 	
	SETCOM	SETDATA	
	SETCOM	SETMOVESPEED	

	SETCOM	SETANIMSPEED	
	SETCOM	SETID		
	SETCOM	FOR		
	SETCOM	NEXT		

	SETCOM	LSIGNAL	
	SETCOM	LWAIT		
	SETCOM	DELAY		
	SETCOM	RNDDELAY	
	SETCOM	ADDBOB		

	SETCOM	RNDANIM	
	SETCOM	MOVETO		

	SETCOM	FLASH		
	SETCOM	SETCONVERT	
	SETCOM	ANIMTO		
	SETCOM	GOTO		
	SETCOM	ADDRELBOB	

	SETCOM	SETRELDATA	
	SETCOM	ADDDAUGHTERBOB	
	SETCOM	TESTJOY	
	SETCOM	BITTEST	
	SETCOM	JEQ		

	SETCOM	JNE		


BOBLEFT:		EQU	1
BOBRIGHT:		EQU	2
BOBUP:			EQU	4
BOBDOWN:		EQU	8

;-----------------------------------------------------------------------
	
         ***********  BOBSTRUKTUREN  *************
	
  STRUCTURE BobData,0
	WORD	bod_Width		; Breite des Bobs in Pixel
	WORD	bod_Height		; Höhe des Bobs in Zeilen
	WORD	bod_X0			; X-Offset des Bob-Nullpunkts
	WORD	bod_Y0			; Y-Offset des Bob-Nullpunkts
	WORD	bod_CollX0
	WORD	bod_CollY0
	WORD	bod_CollX1
	WORD	bod_CollY1
	BYTE	bod_PlanePick		; Für welche Planes sind Daten vorhanden
	BYTE	bod_PlaneOnOff		; Was tun mit den restlichen Planes
	WORD	bod_Flags		; Siehe BODF_ Definitionen
	WORD	bod_WordSize		; Bob-Breite in WORDs +1
	WORD	bod_PlaneSize		; Anzahl Bytes einer Plane
	WORD	bod_TotalSize		; Länge des Bobs+Header
	LABEL	bod_SIZEOF		; Grösse dieses Bob-Headers
	LABEL	bod_Images		; Bob Images

	BITDEF	BOD,ANIMKEY,8		; Bit 8 / erstes Bob einer Anim	

;-----------------------------------------------------------------------

	*** Flags für bob_Flags

	BITDEF	BOB,NORESTORE,0		; Bit 0 / Bob nicht restoren
	BITDEF	BOB,NODRAW,1		; Bit 1 / Bob nicht zeichnen
	BITDEF	BOB,BACKCLEAR,2		; Bit 2 / Hintergrund löschen
	BITDEF	BOB,NOLIST,3		; Bit 3 / Bob nicht in Liste einfügen
	BITDEF	BOB,NOCUT,4		; Bit 4 / nicht Cookie Cut
	BITDEF	BOB,NODOUBLE,5		; Bit 5 / nicht double buffern
	BITDEF	BOB,SPECIALDRAW,6	; Bit 6 / nur zeichnen wenn ein anderes bob dahinter liegt
	BITDEF	BOB,NOCOLLISION,7	; Bit 7 / keine Kollision ausloesen
	BITDEF	BOB,FLIPXMOVE,8		; Bit 8 / X-Move-Koordinaten spiegeln
	BITDEF	BOB,FLIPYMOVE,9		; Bit 9 / Y-Move-Koordinaten spiegeln
	BITDEF	BOB,NEWIMAGE,10		; Bit 10 / Bob nur zeichnen wenn sich Image geändert hat
	BITDEF	BOB,NOMOVE,11		; Bit 11 / MovePrg anhalten
	BITDEF	BOB,NOANIM,12		; Bit 12 / Bob in Liste eintragen aber nicht handeln
	BITDEF	BOB,ONLYANIM,13		; Bit 13 / nur Anims ausführen
	BITDEF	BOB,HIDDEN,14		; Bit 14 / wird gesetzt wenn bob nicht gezeichnet wird (SPECIAL-DRAW)
	BITDEF	BOB,VHALF,15		; Bit 15 / Bob nur jede zeite Zeile zeichnen

	****  Flags für bob_ClipFlags

	BITDEF	CLIP,DOWN,0	; Bit 0 / gegen unten clippen
	BITDEF	CLIP,UP,1	; Bit 1 / gegen oben clippen
	BITDEF	CLIP,LEFT,2	; Bit 2 / gegen links clippen
	BITDEF	CLIP,RIGHT,3	; Bit 3 / gegen rechts clippen
	BITDEF	CLIP,GLOBAL,4	; Bit 4 / Globale Klipkoordinate mitrechnen

CLIPF_X:	EQU	CLIPF_RIGHT|CLIPF_LEFT
CLIPF_Y:	EQU	CLIPF_UP|CLIPF_DOWN
CLIPF_ALL:	EQU	CLIPF_X|CLIPF_Y
CLIPF_GLOBALL:	EQU	CLIPF_ALL|CLIPF_GLOBAL


	****  Bits für Status-Register

	BITDEF	SR,ZEROFLAG,0	; Bit 0 / ZeroBit (Anwendung wie CPU-SR)


;-------------------------------------------------------------------------

   STRUCTURE Bob,0

	APTR	bob_NextBob		; nachfolgendes Bob in der Liste
	APTR	bob_LastBob		; vorhergehendes Bob in der Liste
	BYTE	bob_Id			; BobKennung
	BYTE	bob_Priority		; Priorität

	APTR	bob_BobData		; Zeiger auf BobData Struktur
	WORD	bob_X			; aktuelle X Koordinate (ohne Offset)
	WORD	bob_Y			; aktuelle Y Koordinate (ohne Offset)

	WORD	bob_AbsX		; korrigierte X Koordinate (ohne Offset)
	WORD	bob_AbsY		; korrigierte Y Koordinate (ohne Offset)
	
	WORD	bob_X0			; Kopie aus bod_X0
	WORD	bob_Y0			; Kopie aus bod_Y0

	LONG	bob_LastLastOffset	; vorletzte X+Y Koordinate (mit Offset)
	WORD	bob_LastLastBltSize	; vorletzte Breite+Höhe

	LONG	bob_LastOffset		; letzte X+Y Koordinate (mit Offset)
	WORD	bob_LastBltSize		; letzte Breite+Höhe

	WORD	bob_Image		; aktuelles Bob
	WORD	bob_LastImage		; letztes Bob
	WORD	bob_LastLastImage	; vorletztes Bob

	APTR	bob_AnimPrg		; Zeiger auf aktuelles AnimKommando
	WORD	bob_AnimOffset		; Offset ins AnimPrg
	BYTE	bob_AnimSpeed		; AnimationsGeschwindigkeit
	BYTE	bob_AnimSpeedCounter	; Speed-Zähler
	WORD	bob_AnimTo		; Ziel von ANIMTO

	APTR	bob_MovePrg		; Zeiger auf aktuelles MoveProgram
	WORD	bob_MoveOffset		; Offsets ins MovePrg
	BYTE	bob_MoveSpeed		; Bewegungsgeschwindigkeit
	BYTE	bob_MoveSpeedCounter	; Speed-Zähler
	WORD	bob_MoveCounter		; Kommando Zähler
	WORD	bob_MoveCommand		; aktuelles Kommando
	WORD	bob_MoveStep		; Geschwindigkeit
	WORD	bob_RelMoveCounter	; Anzahl RelMoves (in Bytes)	

	WORD	bob_AnimDelayCounter
	WORD	bob_MoveDelayCounter

	WORD	bob_LSignalSet		; gesetzte lokale symbols
	WORD	bob_Flags		; diverse Flags (siehe NewBob Struktur)
	BYTE	bob_RemFlag		; Wenn dieses Flag nicht 0 ist, wird Bob entfernt sobald es wieder 0 ist
	BYTE	bob_NewPri

	APTR	bob_LastLastSaveBuffer	; HintergrundBuffer für vorletztes Bob
	APTR	bob_LastSaveBuffer	; HintergrundBuffer für letztes Bob

	WORD	bob_ClipX		; linke obere X Clip-Koordinate
	WORD	bob_ClipY		; linke obere Y Clip-Koordinate
	WORD	bob_ClipX2		; rechte untere X Clip-Koordinate
	WORD	bob_ClipY2		; rechte untere Y Clip-Koordinate
	WORD	bob_ClipFlags		; diverse Flags fürs Cliing

	WORD	bob_CollX0
	WORD	bob_CollY0
	WORD	bob_CollX1
	WORD	bob_CollY1

	WORD	bob_AnimForCounter	; für AnimPrg-For-Next 
	WORD	bob_MoveForCounter	; für MovePrg-For-Next 

	APTR	bob_OrgTab		; Zeiger auf ersetzende OriginTabelle

	APTR	bob_CollHandler		; Wird angesprungen bei MeMask-Koll.
	WORD	bob_MeMask		; which types can collide with this bob
	WORD	bob_HitMask		; which types this bob can collide with

	LONG	bob_Handler		; CPU-Prg welches vor dem Zeichnen aufgerufen wird
	LONG	bob_HandlerD0		; Diesen Wert bekommt man im D0

	WORD	bob_MoveToSteps		; Anzahl der noch zu machenden Steps	
	WORD	bob_MoveToX		; X Koordinate mit 16 multipliziert 
	WORD	bob_MoveToY		; Y Koordinate mit 16 multipliziert
	WORD	bob_MoveToXStep		; X Verschiebung
	WORD	bob_MoveToYStep		; Y Verschiebung
	
	APTR	bob_ConvertTab
	WORD	bob_ConvertSize
	WORD	bob_ConvertOffset

	BYTE	bob_TraceMode
	BYTE	bob_TraceLock

	BYTE	bob_FlashTime
	BYTE	bob_FlashColor
	
	LONG	bob_UserData		; Frei benutzbar vom User
	APTR	bob_UserDataPtr		; noch mal was für Straub's Ronny
	WORD	bob_UserFlags

	APTR	bob_ParentBob

	BYTE	bob_sr			; Status-register
	BYTE	bob_Pad1

	LABEL	bob_SIZEOF		; Länge der Bob Struktur

	LABEL	bob_AnimPtrs		; Array auf die einzelnen Bobs der Animation

bob_Test:	EQU	18504


	BITDEF	JOY,DOWN,0
	BITDEF	JOY,RIGHT,1
	BITDEF	JOY,UP,2
	BITDEF	JOY,LEFT,3
	BITDEF	JOY,FIRE,7
