SCROLL_S:
		INCLUDE "MyExec.i"
		INCLUDE	"Copper.i"
		INCLUDE	"Scroll.i"

		INCLUDE	"Definitions.i"

		SECTION Program,CODE

**************************************************************************

_FlipScreen:	movem.l	d0-d1/a0-a1,-(sp)

		not.b	_FlipFlag			* Flip it

		moveq	#ScrDepth,d0			* Depth
		move.l	#Plane_SIZEOF,d1		* PlaneSize

		lea	_ViewBitmStr,a0			* BitmapStructure
		move.l	_PictureBase,a1			* BaseAdress

		tst.b	_FlipFlag
		beq.s	1$
		add.l	_ScrSize,a1			* Second Plane

1$:		bsr	@SetBitmapPtrs

		lea	_DrawBitmStr,a0			* BitmapStructure
		move.l	_PictureBase,a1			* BaseAdress
		tst.b	_FlipFlag
		bne.s	2$

		add.l	_ScrSize,a1			* Second Plane

2$:		bsr	@SetBitmapPtrs
		movem.l	(sp)+,d0-d1/a0-a1
		rts

**************************************************************************

@SoftScroll:	movem.l	d0-d2/a0-a1,-(SP)

	*** Richtigen Bildausschnitt in Copperliste eintragen

		bsr	@SoftScroll2

	*** Char-Reihe bei X-Scroll refreshen

		moveq	#0,d3				* Set to left Border

		move.w	_LevelX,d2
		move.w	d2,d1				* D1=LevelX
		move.w	_LastLevelX,d0
		move.w	d2,_LastLevelX			* D2=LastLevelX
		sub.w	d0,d2				* D2=ScrollValue
;		beq.s	.NoXScroll			* NoScroll

.XScroll:	tst.w	d2
		bmi.s	.LeftScroll			* LeftScroll
		moveq	#23,d3				* Set to right Border

.LeftScroll:	move.w	d1,d0
		asr.w	#4,d0				* XKoordinate
		add.w	d3,d0				* Border (Left/Right)

		moveq	#0,d1
		asr.w	#4,d1				* in Chars
		moveq	#12-1,d2

		lea	_ViewBitmStr,a4
		not.b	_DrawFlipFlag
	;;;	tst.b	_FlipFlag
		bne.s	2$

		lea	_DrawBitmStr,a4

2$:		bsr	_DrawChar			* Draw It
		addq.w	#1,d1				* Next Y-Pos
		dbf	d2,2$				* -->

.NoXScroll:	movem.l	(SP)+,d0-d2/a0-a1
		rts

**************************************************************************

@SoftScroll2:	movem.l	d0-d2/a0-a1,-(sp)

		move.w	_LevelX,d0			* X0 des Ausschnitts
		move.w	d0,d2
		asr.w	#4,d2				* /16
		addq.w	#2,d2
		add.w	d2,d2				* D2 := Byte-Offset (gerade)
		ext.l	d2

		not.w	d0				* Bits umkehren
		andi.w	#15,d0				* Pixelscroll-Wert
		move.w	d0,d1
		lsl.w	#4,d1
		or.w	d1,d0				* Bits 0-3 in Bits 4-7
		move.w	d0,c_bplcon1+2			* in Copperliste eintragen

		lea	_ViewBitmStr+bm_Planes,a1	* Anzuzeigendes Bild
		lea	BitMapPtrs+2,a0			* Start in Copperliste
		moveq	#ScrDepth-1,d1

1$:		move.l	(a1)+,d0			* Nächste Plane

		add.l	d2,d0				* Plus Scroll-Offset
		move.w	d0,4(a0)			* Lo-Word
		swap	d0
		move.w	d0,(a0)				* Hi-Word
		lea	8(A0),a0
		dbf	d1,1$

		movem.l	(sp)+,d0-d2/a0-a1
		rts

**************************************************************************

	*** DrawChar: Char mit Char-Koordinaten D0/D1 refreshen

_DrawChar:	movem.l	d0-d3/a0-a4,-(SP)

	*** Source-Offset (Level-Data) berechnen

		move.w	d1,d3				* D3 :  Y
		mulu.w	_SizeX,d1			* Chars per Row
		move.l	_LevelBase,a0			* A0 :  Die Level-Daten
		adda.w	d0,a0
		adda.l	d1,a0

		move.l	bm_Planes(a4),a2		* A2 :  Planes-Base
5$:
		adda.w	d0,a2
		adda.w	d0,a2				* Chars sind ja WORDs
		mulu.w	#ScrWidth*16,d3			* 16 Linien pro Char
		adda.l	d3,a2

		moveq	#0,d0
		move.b	18(a0),d0			* Char-Nr nach d0

		lsl.w	#5,d0				* Mal sizeof(charplane)
		mulu.w	#NumCharPlanes,d0		* Mal Anzahl Char-Planes

		move.l	_CharBase,a1			* A1 :  Zeichensatz ..
		add.l	#70,a1
		adda.l	d0,a1				* .. plus Offset gibt Src
		moveq	#ScrWidth,d1			* Zwecks Speed

	*** Char-Daten in die ersten Planes reinkopieren

		moveq	#NumCharPlanes,d2		* Plane-Counter
		bra.s	2$				* Für dbf
1$:		move.w	(a1)+,(a2)			* 1. Zeile kopieren
		adda.w	d1,a2				* auf nächste Zeile springen
		move.w	(a1)+,(a2)			* 2. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 3. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 4. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 5. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 6. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 7. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 8. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 9. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 10. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 11. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 12. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 13. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 14. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 15. Zeile kopieren
		adda.w	d1,a2
		move.w	(a1)+,(a2)			* 16. Zeile kopieren
		adda.w	d1,a2

		lea	Plane_SIZEOF-16*ScrWidth(a2),a2	* next Plane
2$:		dbf	d2,1$				* ---> PlaneLoop

	*** Restliche Planes löschen

		moveq	#0,d0				* Clear-Register
		moveq	#ScrDepth,d2
		subq.w	#NumCharPlanes,d2		* Plane-Counter
		bra.s	4$				* Für dbf
3$:		move.w	d0,(a2)				* 1. Zeile löschen
		adda.w	d1,a2				* auf nächste Zeile springen
		move.w	d0,(a2)				* 2. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 3. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 4. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 5. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 6. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 7. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 8. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 9. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 10. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 11. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 12. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 13. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 14. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 15. Zeile löschen
		adda.w	d1,a2
		move.w	d0,(a2)				* 16. Zeile löschen
		adda.w	d1,a2

		lea	Plane_SIZEOF-16*ScrWidth(a2),a2	* next Plane
4$:		dbf	d2,3$				* ---> PlaneLoop
		movem.l	(SP)+,d0-d3/a0-a4
		rts

**************************************************************************

GetElem:	movem.l	d1/a0,-(sp)
		asr.w	#4,d0				* CharX
		asr.w	#4,d1				* CharY

		muls	_SizeX,d1
		add.w	d0,d1				* Offset

		move.l	_LevelBase,a0
		moveq	#0,d0
		move.b	18(A0,d1.w),d0			* Elem
		movem.l	(sp)+,d1/a0
		rts

**************************************************************************

GetInfo:	move.l	a0,-(sp)
		lsl.w	#1,d0				* Elem
		move.l	_LevelFlags,a0			* Liste
		move.w	(a0,d0.w),d0			* Wert
		move.l	(sp)+,a0
		rts

****************************************************************************
* A0 = BitmStr A1 = Bitmap
* D0 = Depth   D1 = PlaneSize

@SetBitmapPtrs:	movem.l	d0/a0/a1,-(sp)
		lea	bm_Planes(a0),a0		* Pointers to 1.BitPlane
		bra.s	2$

1$:		move.l	a1,(A0)+	
		add.l	d1,a1				* Set All BitPlanes
2$:		dbf	d0,1$					

		movem.l	(sp)+,d0/a0/a1
		rts

**************************************************************************

		SECTION	MyBss,BSS

_FlipFlag:	ds.b	1
_DrawFlipFlag:	ds.b	1
