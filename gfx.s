GFX_S
MYEXEC
NTSC

		IFND	MYEXEC
		 XREF	AllocMem,AllocClearMem,FreeMem,AvailMem,InitAlloc			; Sys
		 XREF	Disable,Enable,Randomize,Random
		 XREF	AddBob,RemBob,DrawBobList,RestoreBobList		; DrawBob
	 	 XREF	InitDrawBob,DrawOneBob,RestoreOneBob,AnimateOneBob
		 XREF	MoveOneBob,SignalSet,TestPoint,RemAllBobs,WaitBlit
		 XREF	Enqueue,Remove,NewList
		 XREF	RawDoFmt
		ENDC

		XREF	_MyExecBase

		INCDIR	"h:"

		IFD	MYEXEC
		 INCLUDE "MyExec.i"
		ENDC

		IFND	MYEXEC
		 INCLUDE "structures.i"
		 INCLUDE "equates.i"
		ENDC

		INCLUDE "gfx.i"
		INCLUDE "drawbob.i"
		INCLUDE "relcustom.i"
		INCLUDE	"constants.i"

		SECTION	Program,CODE

MoveMcr:	MACRO
		move.w	\1,wn_CursorX(A0)
		move.w	\2,wn_CursorY(A0)
		ENDM

DrawMcr:	MACRO
		move.w	\1,d0
		move.w	\2,d1
		bsr	Draw
		ENDM

*****************************************************************************
* Function	: InitGfx						
* Parameters	: none
* Result	: none
*****************************************************************************

_InitGfx:
InitGfx:	movem.l	a0-a1,-(sp)
		lea	GfxBase,a1			* GFX-Base
		move.l	#Copper1,gfx_ViewCpr(A1)
		move.l	#Copper2,gfx_DrawCpr(A1)
		lea	ScrList,a0
		move.l	a0,gfx_ScrList(a1)		* ScreenListe
		SYSCALL	NewList
		movem.l	(sp)+,a0-a1
		rts

*****************************************************************************
* Function	: InitBitmap						
* Parameters	: A0 = Bitmap  A1 = PlaneBase
*		  D0 = Width  D1 = Height  D2 = Depth
* Result	: D0 = BitMap
*****************************************************************************

_InitBitmap:
InitBitmap:	movem.l	d0-d7/a0-a6,-(sp)
		move.w	d0,d3

		add.w	#15,d3			* +15
		lsr.w	#4,d3
		lsl.w	#1,d3			* auf ganze Words runden
		move.w	d3,bm_BytesPerRow(a0)
		move.w	d1,bm_Rows(a0)
		clr.b	bm_Flags(a0)
		move.b	d2,bm_Depth(a0)
		mulu	d3,d1			* D1 = PlaneSize

		lea	bm_Planes(a0),a2
	
		ext.w	d2
		subq.w	#1,d2			* D2 = Planes - 1
		
1$:		move.l	a1,(a2)+
		add.l	d1,a1
		dbf	d2,1$

		movem.l	(sp)+,d0-d7/a0-a6
		rts

*****************************************************************************
* Function	: CreateBitmap						
* Parameters	: D0 = Width  D1 = Height  D2 = Depth
* Result	: D0 = BitMap
*****************************************************************************

_CreateBitmap
CreateBitmap:	movem.l	d1-d7/a0-a6,-(sp)
		move.w	d0,d3

		moveq	#bm_SIZEOF,d0
		SYSCALL	AllocFastClearMem
		move.l	d0,a0			* Allocate BitmStr
		beq.s	.NoBitmap

		add.w	#15,d3			* +15
		lsr.w	#4,d3
		lsl.w	#1,d3			* auf ganze Words runden
		move.w	d3,bm_BytesPerRow(a0)
		move.w	d1,bm_Rows(a0)
		clr.b	bm_Flags(a0)
		move.b	d2,bm_Depth(a0)

		lea	bm_Planes(a0),a1

		mulu	d3,d1			* D1 = PlaneSize
		
		ext.w	d2
		subq.w	#1,d2			* D2 = Planes - 1
		
1$:		move.l	d1,d0
		SYSCALL	AllocClearMem		* Allocate Buffer
		move.l	d0,(a1)+
		dbf	d2,1$

.NoBitmap:	move.l	a0,d0			* Bitmap
		movem.l	(sp)+,d1-d7/a0-a6
		rts


*****************************************************************************
* Function	: DeleteBitmap						
* Parameters	: D0 = Width  D1 = Height  D2 = Depth
* Result	: D0 = BitMap
*****************************************************************************

_DeleteBitmap
DeleteBitmap:	movem.l	d0-d7/a0-a6,-(sp)

		move.b	bm_Depth(a0),d2
		ext.w	d2
		subq.w	#1,d2

		lea	bm_Planes(a0),a2

1$:		move.l	(A2)+,a1
		SYSCALL	FreeMem
		dbf	d2,1$

		move.l	a0,a1
		SYSCALL	FreeMem

		movem.l	(sp)+,d0-d7/a0-a6
		rts

*****************************************************************************
* Function	: OpenScreen						
* Parameters	: A0 = NewScreenStructure
* Result	: D0 = ScreenStructure
*****************************************************************************

@OpenScreen:
OpenScreen:	movem.l	d1-d5/a0-a4,-(sp)

		move.l	a0,a4				* A4=NewScrenStructure
		move.l	#sc_SIZEOF,d0
		SYSCALL	AllocFastClearMem		* Screen Structure
		move.l	d0,a1				* A1=ScrStructure

		move.w	ns_LeftEdge(a4),sc_LeftEdge(A1)
		move.w	ns_TopEdge(a4),sc_TopEdge(A1)
		move.w	ns_Width(a4),sc_Width(A1)
		move.w	ns_Height(a4),sc_Height(A1)
		move.w	ns_ViewModes(a4),sc_ViewModes(A1)
		move.l	ns_Flags(a4),sc_Flags(a1)

		lea	ScrList,a0			* ScrList
		SYSCALL	AddTail

		move.l	a1,a0				* A0 = Screen

	******	Initiate ColorMap  ******

		lea	sc_ColorMap(A0),a1
		move.l	ns_ColorMap(A4),a3
		moveq.l	#32-1,d0

		move.l	a3,d1
		beq.s	.NoColMap
		
.CopyColMap:	move.w	(A3)+,(A1)+
		dbf	d0,.CopyColMap
		bra.s	.EndColMap

.NoColMap:	clr.w	(A1)+
		dbf	d0,.NoColMap

	******	Initiate Bitmap Structure  ******

.EndColMap:
		lea	sc_Bitmap(A0),a1		* A1=BitmStr
		move.l	ns_BitmStr(A4),a3
		move.l	a3,d0				* BitmStr vorhanden
		beq.s	.StdBitmStr			* Nein -->

		or.l	#SCF_CUSTOMBITMAP,sc_Flags(A0)	* CustomBitmapFlag	

		move.w	#bm_SIZEOF-1,d0
.CopyBitmStr:	move.b	(A3)+,(A1)+
		dbf	d0,.CopyBitmStr			* User's BitmapStructure
		bra	.EndBitmStr			* kopieren

.StdBitmStr:	move.w	sc_Width(a0),d0			* Width in Pixels
		lsr.w	#3,d0
		move.w	d0,bm_BytesPerRow(a1)		* Width in Bytes
		move.w	sc_Height(a0),d1
		move.w	d1,bm_Rows(a1)			* Height
		move.w	ns_Depth(a4),d2
		move.b	d2,bm_Depth(a1)			* Depth

		move.l	d1,d3				* D3=Height
		mulu	d0,d3				* D3=Width*Height
		mulu	d2,d0				* Depth*Widht
		mulu	d1,d0				* *Height=ScrSize
		add.w	#64+32,d0			* CHEAT for ColorMap und Reserve (PPDecrunch etc.)
		SYSCALL	AllocClearMem			* D0=ScreenBase

		lea	bm_Planes(a1),a1		* Ptr to planes
		move.w	d2,d1
		bra.s	.EndBitmPtr			* D1=ScrDepth-1	
.CopyBitmPtr:	move.l	d0,(A1)+			* Enter Plane
		add.l	d3,d0				* Add PlaneSize
.EndBitmPtr:	dbf	d1,.CopyBitmPtr

	******	CopperListe erstellen *******

.EndBitmStr:
		lea	sc_CopperList(a0),a1		* A1=CopperList
		move.w	#CWAIT,(A1)+			* First Wait
		move.w	#2,(A1)+			* Add 2 to YPos

		move.w	#bplcon0,(A1)+
		move.w	#$0200,(A1)+			* BitPlanes off

		lea	sc_Bitmap+bm_Planes(a0),a2
		move.w	#bplpt,d1			* Custom Address
		moveq	#6-1,d3				* 6 Planes
3$:		move.l	(A2)+,d0			* Plane
		bsr	SetLongValue			* Set Plane
		dbf	d3,3$				* Repeat -->

		moveq.l	#0,d0				* Sprites to 0
		move.w	#sprpt,d1			* Custom Address
		moveq	#8-1,d3				* 8 Sprites
2$:		bsr	SetLongValue			* Set Sprite
		dbf	d3,2$				* Repeat -->

		move.w	#bplcon1,(A1)+			* BPLCON1
		move.w	#$0000,(A1)+
		move.w	#bplcon2,(A1)+			* BPLCON2
		move.w	#$0024,(A1)+
		move.w	#bpl1mod,(A1)+			* BPL1MOD
		move.w	#$0000,(a1)+
		move.w	#bpl2mod,(A1)+			* BPL2MOD
		move.w	#$0000,(a1)+

		move.w	#diwstrt,(A1)+			* DIWSTRT
		clr.w	(A1)+
		move.w	#diwstop,(A1)+			* DIWSTOP
		clr.w	(A1)+

	*******	Calculate DDFSTRT DDFSTOP *******

		move.w	sc_ViewModes(a0),d0
		btst	#15,d0				* HIRES
		bne.s	.HiRes				* Yes -->

		move.w	#$0081-17,d0
		add.w	sc_LeftEdge(A0),d0		* LeftEdge
		asr.w	#1,d0				* DDFSTRT=($81-17+X)/2
		move.w	sc_Width(A0),d1
		asr.w	#4,d1				* Width in words
		subq.w	#1,d1
		asl.w	#3,d1
		add.w	d0,d1				* DDFSTOP=DDFSTRT+((W/2-1)*8)
		bra.s	.LoRes

.HiRes:		move.w	#$0081-9,d0
		add.w	sc_LeftEdge(A0),d0		* LeftEdge
		asr.w	#1,d0				* DDFSTRT=($81-9+X)/2
		move.w	sc_Width(A0),d1
		asr.w	#4,d1
		subq.w	#2,d1
		asl.l	#2,d1
		add.w	d0,d1				* DDFSTOP=DDFSTRT+((W/2-2)*4)

.LoRes:		and.w	#$00FC,d0
		and.w	#$00FC,d1			* Mask out FUTURE-EXPANSION-BITS

		move.w	#ddfstrt,(A1)+			* DDFSTRT
		move.w	d0,(A1)+
		move.w	#ddfstop,(A1)+			* DDFSTOP
		move.w	d1,(A1)+

	*******	Set ColorMap *******

		lea.l	sc_ColorMap(a0),a3		* Get ColorMap
		move.w	#color,d1			* Color00
		moveq	#32-1,d4			* NumCols-1

.CopyCols:	move.w	d1,(A1)+
		addq.w	#2,d1
		move.w	(A3)+,(A1)+
		dbf	d4,.CopyCols				* Repeat -->

		move.w	#CWAIT,(A1)+			* Wait
		move.w	sc_Height(A0),(a1)+		* Add ScrHeight to YPos

		moveq	#0,d2
		move.b	sc_Bitmap+bm_Depth(A0),d2
		ror.w	#4,d2				* Depth*$1000
		or.w	#$0200,d2			* Video Color
		or.w	sc_ViewModes(A0),d2		* Users ViewModes
;		or.w	SystemBplcon0,d2		* GenLock !!!

		move.w	#bplcon0,(A1)+			* BPLCON0
		move.w	d2,(A1)+			* ScrDepth*$1000+$200

		move.w	#CWAIT,(A1)+			* Wait
		clr.w	(A1)+				* Add nothing

		move.w	#bplcon0,(A1)+
		move.w	#$0200,(A1)+
		move.w	#CEND,(A1)+

		clr.l	sc_BitmapOffset(A0)

		moveq	#0,d0
		move.w	d0,d1
		bsr	MoveScreen
		move.l	a0,d0				* ScreenStructure

		movem.l	(sp)+,d1-d5/a0-a4
		rts

*****************************************************************************
* Function	: CloseScreen						
* Parameters	: A0 = Screen
* Result	: none
*****************************************************************************

@CloseScreen:
CloseScreen:	movem.l	d0/a0-a1,-(sp)

		move.l	sc_Flags(a0),d0
		btst	#SCB_CUSTOMBITMAP,d0		* CustomBitmapFlag	
		bne.s	.CustomBitmap

		move.l	sc_Bitmap+bm_Planes(a0),a1
		SYSCALL	FreeMem				* Free Planes

.CustomBitmap:	move.l	a0,a1
		SYSCALL	Remove				* Remove from ScrList
		SYSCALL	FreeMem				* Free ScreenStruct
		bsr	MergeCopper
		movem.l	(sp)+,d0/a0-a1
		rts


*****************************************************************************
* Function	: MoveScreen
* Parameters	: A0=Screen  D0=X  D1=Y
* Result	: none
*****************************************************************************

@MoveScreen:
MoveScreen:	movem.l	d0-d6/a0-a2,-(sp)
		lea	sc_CopperList(a0),a1		* This Screens CopperList
		lea	sc_Bitmap(a0),a2
		add.w	d1,sc_TopEdge(a0)
		move.w	sc_TopEdge(a0),d2

		moveq	#0,d6

.TopBorder:	cmp.w	#320,d2
		blt.s	.BottomBorder
		move.w	#320,d2				* unterer Rand
.BottomBorder:

	*******	Calculate DIWSTRT DIWSTOP *******

		move.w	sc_LeftEdge(A0),d2		* + LeftEdge
		move.w	sc_Width(A0),d3			* Width
		move.w	sc_ViewModes(A0),d4		* ScreenModes
		btst	#15,d4
		beq.s	.LoRes
		asr.w	#1,d2

.LoRes:		move.w	#$0581,d0
		move.w	#$4081,d1		
		add.b	d2,d0				* Add LeftEdge.b
		add.b	d2,d1				* Add LeftEdge.b
		add.b	d3,d1				* Add Width.b

		move.w	d0,cpr_DiwStrt+2(A1)		* DisplayWindowStart
		move.w	d1,cpr_DiwStop+2(A1)		* DisplayWindowStop

		lea	cpr_Plane1(a1),a1		* CopperList
		lea	bm_Planes(a2),a2		* Planes

		move.w	#bplpt,d1			* Custom Address
		moveq	#6-1,d2				* 6 Planes
.EnterBMap:	move.l	(A2)+,d0			* Plane
		add.l	d6,d0
		bsr	SetLongValue			* Set Plane
		dbf	d2,.EnterBMap			* Repeat -->

		bsr	MergeCopper			* Screens und CopperListen neu verhaengen
		movem.l	(sp)+,d0-d6/a0-a2
		rts

*****************************************************************************
* Function	: LoadRGB						
* Parameters	: A0 = Screen A1=ColorMap
* Result	: none
*****************************************************************************

@LoadRGB:
LoadRGB:	movem.l	d0/a0-a3,-(sp)
		lea	sc_CopperList+cpr_Colors+2(a0),a2
		lea	sc_ColorMap(a0),a3
		moveq	#32-1,d0
.CopyCols:	move.w	(a1),(a2)			* Copy Color
		move.w	(a1)+,(a3)+
		addq.w	#4,a2				* Next Color
		dbf	d0,.CopyCols			* Repeat -->
		bsr	MergeCopper
		movem.l	(sp)+,d0/a0-a3
		rts

*****************************************************************************
* Function	: FadeOut						
* Parameters	: A0 = Screen D0 = Speed
* Result	: none
*****************************************************************************

@FadeOut:
FadeOut:	movem.l	d0-d2/a0-a3,-(sp)
		move.w	d0,d2
		move.l	a0,a3				* A3=Screen

		lea	DestColorMap,a1			* DestColorMap
		move.l	a1,a2
		moveq	#32-1,d0
.ClearCMAP:	clr.w	(A2)+
		dbf	d0,.ClearCMAP			* = NULL

		moveq	#16-1,d1
.FadeOutLoop:	lea	sc_ColorMap(A3),a0		* SourceMap
		lea	DestColorMap,a1
		bsr	FadeColors			* Fade

		move.l	a0,a1				* ColorMap
		move.l	a3,a0				* Screen
		bsr	LoadRGB				* Set Color to Screen

		move.w	d2,d0				* Speed
		bsr	RasterDelay			* Delay a bit
		dbf	d1,.FadeOutLoop
		movem.l	(sp)+,d0-d2/a0-a3
		rts

*****************************************************************************
* Function	: FadeIn						
* Parameters	: A0 = Screen  A1 = ColorMap  D0 = Speed
* Result	: none
*****************************************************************************

@FadeIn:
FadeIn:		movem.l	d0-d2/a0-a3,-(sp)
		move.w	d0,d2
		move.l	a0,a3				* A3=Screen

		lea	DestColorMap,a0
		lea	sc_ColorMap(a3),a2
		moveq	#32-1,d0
.ClearCMAP:	move.w	(A1)+,(A0)+
		clr.w	(A2)+
		dbf	d0,.ClearCMAP

		moveq	#16-1,d1
.FadeInLoop:	lea	sc_ColorMap(A3),a0		* SourceMap
		lea	DestColorMap,a1			* DestinationMap
		bsr	FadeColors			* Fade

		move.l	a0,a1				* ColorMap
		move.l	a3,a0				* Screen
		bsr	LoadRGB				* Set Color to Screen

		move.w	d2,d0				* Speed
		bsr	RasterDelay			* Delay a bit
		dbf	d1,.FadeInLoop
		movem.l	(sp)+,d0-d2/a0-a3
		rts

********************************************************************************

FadeColors:	movem.l	d1-d7/a0-a6,-(SP)
		moveq.l	#32-1,d0		; 32 Farben
.FadeColor:	moveq.l	#0,d1			; ZielFarbe
		move.w	(a0)+,d2		; SourceFarbe
		move.w	(a1)+,d3		; Zielfarbe

		moveq.l	#3-1,d4			; je 3 Nibbles
.FadeLoop:	move.w	d2,d5
		move.w	d3,d6
		and.w	#$F,d5			; SourceNibble
		and.w	#$F,d6			; DestNibble
		bsr.s	NibbleFade
		ror.w	#4,d5
		or.w	d5,d1
		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d3
		dbf	d4,.FadeLoop
		move.w	d1,-2(A0)
		dbf	d0,.FadeColor
		movem.l	(SP)+,d1-d7/a0-a6
		rts

****************************************************************************

NibbleFade:	cmp.b	d5,d6
		beq.s	2$
		bhi.s	1$
		subq.b	#1,d5
		bra.s	2$
1$:		addq.b	#1,d5
2$:		rts

*****************************************************************************
* Function	: WaitRaster
* Parameters	: D0 = RasterLine to wait for
* Result	: none
*****************************************************************************

@WaitRaster:
WaitRaster:	movem.l	d0-d1/a5,-(sp)
		ext.l	d0
		lea	custom,a5
		lsl.l	#8,d0
1$:		move.l	vposr(a5),d1
		and.l	#$1FF00,d1
		cmp.l	d0,d1
		blt.s	1$
		movem.l	(sp)+,d0-d1/a5
		rts

*****************************************************************************
* Function	: RasterDelay
* Parameters	: D0 = RasterLines to wait
* Result	: none
*****************************************************************************

@RasterDelay:
RasterDelay:	movem.l	d1-d3/a5,-(sp)
		lea	custom,a5
		ext.l	d0
		moveq.l	#0,d3				* JAJA
2$:		move.l	vposr(a5),d1
		and.l	#$1FF00,d1

1$:		move.l	vposr(a5),d2
		and.l	#$1FF00,d2
		cmp.l	d1,d2
		beq.s	1$

		addq.w	#1,d3
		cmp.l	d0,d3
		bne.s	2$
		movem.l	(sp)+,d1-d3/a5
		rts

*****************************************************************************
* Function	: DelayVBlank
* Parameters	: none
* Result	: none
*****************************************************************************

@DelayVBlank:
DelayVBlank:	movem.l	d0/a5,-(sp)
		lea	custom,a5

1$:		move.l	vposr(a5),d0
		and.l	#$1FF00,d0
		tst.l	d0
		bne.s	1$

;2$:		move.l	vposr(a5),d0
;		and.l	#$1FF00,d0
;		cmp.l	#$00100,d0
;		bne.s	2$

		movem.l	(sp)+,d0/a5
		rts


****************************************************************************

@MergeCopper:
MergeCopper:	movem.l	d0-d7/a0-a5,-(sp)
		lea	custom,a5
		lea	GfxBase,a4
		clr.b	d5				* PalFlag
		move.l	gfx_DrawCpr(A4),a3		* CopperListe

	*** Vorab die Sprites des ersten Screens setzen ***

		lea	ScrList,a0
		move.l	(a0),a0
		move.l	(a0),d0
		beq	.End

		move.l	#$0221FFFE,(A3)+		* First Wait

		lea	sc_CopperList+cpr_Sprite0(a0),a0
		moveq	#16-1,d0
2$:		move.l	(a0)+,(A3)+			* Set 8 Sprites
		dbf	d0,2$

	*** Jetzt werden alle Screens durchsucht ***

		lea	ScrList,a0
.Next:		move.l	(A0),a0				* First Screen
		move.l	(A0),d0
		beq	.End				* No Screen -->
		move.l	(A0),a1
		move.l	(A1),d0
		bne.s	.LastScr

		move.w	#1024,d7			* Next YStart
		bra.s	.Default
.LastScr:	move.w	sc_TopEdge(A1),d7		* Next YStart
		add.w	#$002c-2,d7
.Default:	move.w	sc_TopEdge(a0),d6		* Actual YStart
		add.w	#$002c-2,d6
		lea	sc_CopperList(a0),a1		* CopperStructure

		cmp.w	d6,d7				* Screens equal
		beq.s	.Next

.Loop:		move.w	(A1)+,d0			* Get Command
		cmp.w	#CWAIT,d0			* CWAIT
		bne	.CEnd				* NO -->
		
	******	CopperWait ******

		cmp.w	#MAXSCRHEIGHT,d6		* Unterste Y-Position
		bls.s	.InScr				* kleiner -->

	****** Abschluss der Copperliste, weil nichts mehr kommt ******

		tst.b	d5
		bne.s	.UpperPal			* Pal already set

		cmp.w	#$FF,d6				* Below PalBorder
		blt.s	.UpperPal			* NO -->

		move.l	#$FFDFFFFE,(A3)+		* Insert a PALWAIT
		st.b	d5				* Set PALFlag
		addq.l	#2,a1

.UpperPal:	;;move.l	#$3621FFFE,(A3)+
		move.l	#$0121FFFE,(A3)+
		move.l	#$01000200,(A3)+
		bra	.End

.InScr:		cmp.w	d7,d6				* Kommt da noch'n Screen
		bge	.Next				* JAJA -->

		tst.w	d6				* Kleiner als 0
		bls.s	.Nothing			* Ja -->

		tst.b	d5				* Schon PAL
		bne.s	.Pal1				* ja -->
		cmp.w	#255,d6				* PAL
		beq.s	.Pal2				* Direkt auf PalGrenze
		blt.s	.Pal1				* Oberhalb
		move.l	#$FFDFFFFE,(A3)+		* PalWait einfügen
		st.b	d5				* PalFlag setzen

.Pal1:		moveq	#0,d1
		move.b	d6,d1
		asl.w	#8,d1
		or.b	#$21,d1
		move.w	d1,(A3)+			* CWAIT einfügen
		move.w	#$FFFE,(A3)+
.Nothing:	add.w	(a1)+,d6			* Increase YStart
		bra.s	.Loop		

.Pal2:		moveq	#0,d1
		move.b	d6,d1
		asl.w	#8,d1
		or.b	#$21,d1
		move.w	d1,(A3)+			* CWAIT einfügen
		move.w	#$FFFE,(A3)+
		add.w	(a1)+,d6			* Increase YStart

.Pal4:		move.w	(A1),d0				* Next Command
		btst	#0,d0				* CWAIT
		bne.s	.Pal3				* Yes -->

		move.l	(A1)+,(a3)+			* CMOVE kopieren
.Pal3:
		move.l	#$FFDFFFFE,(A3)+		* PalWait
		st.b	d5				* PalFlag
		bra	.Loop

	******	CopperEnd ******

.CEnd:		cmp.w	#CEND,d0			* CEND
		beq	.Next				* NO -->

	******	CopperMove ******

.CMove:		cmp.w	#sprpt,d0			* Filter out the
		blo	.NoSprite			* SpritePointers
		cmp.w	#sprpt+30,d0
		bhi	.NoSprite

		addq.l	#2,A1
		bra	.Loop

.NoSprite:	move.w	d0,(A3)+			* Copy Command
		move.w	(a1)+,(A3)+			* Copy Value
		bra	.Loop

.End:		move.l	#$FFFFFFFE,(A3)

	******	Double Buffered CopperList's ******

		move.l	gfx_DrawCpr(A4),d0		* Neue Copperliste
		move.l	gfx_ViewCpr(A4),gfx_DrawCpr(A4)	* Neue alte Copperliste
		move.l	d0,gfx_ViewCpr(A4)		* Aktuelle Copperliste
		move.l	d0,cop1lc(A5)
		movem.l	(sp)+,d0-d7/a0-a5
		rts

*****************************************************************************
* A1=CopperList D0=Value D1=Register

SetValue:	move.w	d1,(a1)+			* Custom Register
		move.w	d0,(a1)+			* Value
		addq.w	#2,d1				* Next Custom-Register
		rts

*****************************************************************************
* A1=CopperList D0=Addr D1=Register

SetLongValue:	move.w	d1,(a1)+			* Upper Custom-Address
		swap	d0
		move.w	d0,(a1)+			* Upper Value
		addq.w	#2,d1				* Next Custom-Register
		move.w	d1,(a1)+			* Lower Custom-Address
		swap	d0
		move.w	d0,(a1)+			* Lower Value
		addq.w	#2,d1				* Next Custom-Register
		rts


*****************************************************************************
* Function	: SetAPen						    *
* Parameters	: D0 = APen / A0 = Window				    *
* Result	: NONE							    *
*****************************************************************************

@SetAPen:
SetAPen:	move.b	d0,wn_APen(A0)			* Set FrontPen
		rts

*****************************************************************************
* Function	: SetBPen						
* Parameters	: D0 = BPen / A0 = Window
* Result	: NONE
*****************************************************************************

@SetBPen:
SetBPen:	move.b	d0,wn_BPen(A0)			* Set BackPen
		rts

*****************************************************************************
* Function	: SetAPen						
* Parameters	: D0 = APen / A0 = Window
* Result	: NONE
*****************************************************************************

@GetAPen:
GetAPen:	move.b	wn_APen(A0),d0			* Set FrontPen
		rts

*****************************************************************************
* Function	: SetBPen						
* Parameters	: D0 = BPen / A0 = Window
* Result	: NONE
*****************************************************************************

@GetBPen:
GetBPen:	move.b	wn_BPen(A0),d0			* Set BackPen
		rts

*****************************************************************************
* Function	: Move						
* Parameters	: D0 = XPos / D1 = YPOS / A0 = Window
* Result	: NONE
*****************************************************************************

@Move:
Move:		move.w	d0,wn_CursorX(A0)		* Set CrusorX
		move.w	d1,wn_CursorY(A0)		* Set CursorY
		rts

*****************************************************************************
* Function	: SetDrawMode
* Parameters	: D0 = DrawMode / A0 = Window
* Result	: NONE
*****************************************************************************

_SetDrawMode:
SetDrawMode:	move	d0,wn_DrawMode(A0)		* Set DrawMode
		rts


*****************************************************************************
* Function	: ReadPixel
* Parameters	: D0 = X / D1 = Y / A0 = Window
* Result	: D0 = COLOR
*****************************************************************************

ReadPixel:
	IFND	MINGFX
		movem.l	d1-d4/a0-a1,-(sp)
		add.w	wn_XOrigin(A0),d0		* XPosition
		add.w	wn_YOrigin(A0),d1		* YPosition
		move.l	wn_BitmStr(A0),a1		* BitmStr

		move.w	d0,d2
		mulu	bm_BytesPerRow(A1),d1
		lsr.w	#3,d0
		add.w	d0,d1				* D1 = Offset in BitMap

		and.w	#7,d2
		moveq	#7,d3
		sub.w	d2,d3				* D3 = PixelOffset		

		moveq	#0,d0				* Color
		moveq	#0,d2
		move.b	bm_Depth(A1),d2			* Number of Planes
		subq.b	#1,d2				* for DBF
		lea	bm_Planes(A1),a1		* Pointers to BitMaps

		moveq.l	#5-1,d2
		moveq.l	#0,d4
.GetPixel:	move.l	(A1)+,a0			* Plane
		btst	d3,(A0,d1.w)			* Set this Bit
		beq.s	.Clear
		bset	d4,d0
.Clear:		addq.w	#1,d4
		dbf	d2,.GetPixel
		movem.l	(sp)+,d1-d4/a0-a1
	ENDC
		rts

*****************************************************************************
* Function	: WritePixel
* Parameters	: D0 = X / D1 = Y / A0 = Window
* Result	: NONE
*****************************************************************************

WritePixel:

	IFND	MINGFX
		movem.l	d0-d3/a0-a1,-(sp)
		add	wn_XOrigin(A0),d0		* XPosition
		add	wn_YOrigin(A0),d1		* YPosition
		move.l	wn_BitmStr(A0),a1		* BitmStr

		move	d0,d2
		mulu	bm_BytesPerRow(A1),d1
		lsr	#3,d0
		add	d1,d0				* D0 = Offset in BitMap

		and	#7,d2
		moveq	#7,d3
		sub	d2,d3				* D3 = PixelOffset		

		move.b	wn_APen(A0),d1			* Color
		moveq.l	#0,d2
		move.b	bm_Depth(A1),d2			* Number of Planes
		subq.b	#1,d2
		lea	bm_Planes(A1),a1

.SetPixel:	move.l	(A1)+,a0			* Plane
		btst	#0,d1				* Clear/Set Bit
		beq.s	.Clear

		bset	d3,(A0,d0.w)			* Set this Bit
		bra.s	.End
.Clear:
		bclr	d3,(A0,d0.w)			* Clear this Bit
.End:		lsr	#1,d1
		dbf	d2,.SetPixel
		movem.l	(sp)+,d0-d3/a0-a1
	ENDC
		rts

*****************************************************************************
* Function	: RectFill
* Parameters	: D0 = X1 / D1 = Y1 / D2 = Width / D3 = Height / A0 = Window
* Result	: NONE
*****************************************************************************

_RectFill:
RectFill:	tst	d2
		bgt.s	5$
		tst	d3
		bgt.s	5$
		rts

5$:		movem.l	d0-d7/a0-a3/a5,-(sp)
		SYSCALL	OwnBlitter

		lea	custom,a5
		add	wn_XOrigin(A0),d0
		add	wn_YOrigin(A0),d1

		move	d3,-(sp)
		SYSCALL	WaitBlit

		move.l	wn_BitmStr(A0),a1		* BitmapStructure
		moveq	#0,d7
		move.b	bm_Depth(A1),d7
		subq.b	#1,d7				* Depth-1

		lea	ShiftTab(pc),a3			* ShiftTabelle

		add	d0,d2
		add	#15,d2
		move	d2,d3
		and	#15,d3
		lsl	#1,d3
		move	0(A3,d3.w),d3
		not	d3
		move	d3,bltalwm(A5)			* LastWordMask

		move	d0,d4
		and	#15,d4
		lsl	#1,d4
		move	0(A3,d4.w),bltafwm(A5)		* FirstWordMask

		lsr	#4,d2
		lsr	#4,d0
		move	bm_BytesPerRow(A1),d3		* Bytes/Row
		move	d1,d5
		mulu	d3,d1
		move	d0,d4
		lsl	#1,d4
		add	d1,d4				* D4=Offset

		sub	d0,d2				* D2=Breite in Words		
		move	d2,d5
		lsl	#1,d5
		sub	d5,d3				* D3=Modulo in Bytes
		move	d3,bltbmod(A5)			* Modulo
		move	d3,bltdmod(A5)			* Modulo
		move	#-1,bltadat(A5)			* Fill with $FFFF
		move	#0,bltcon1(A5)
		move	(sp)+,d3			* Höhe
		lsl	#6,d3				* Fuer BltSize
		or	d2,d3				* D3=BltSize

		move.b	wn_APen(A0),d5
		lea	bm_Planes(A1),a1		* Pointer to Planes
				
3$:		SYSCALL	WaitBlit
		move.l	(A1)+,a2
		move	#$050C,bltcon0(a5)		* USE BD / D=NOT(A) AND B (Löschen)
		lsr	#1,d5
		bcc.s	4$

		move	#$05FC,bltcon0(A5)		* USE BD / D=A OR B (Setzen)
4$:		add	d4,a2				* Destination
		move.l	a2,bltdpt(A5)
		move.l	a2,bltbpt(A5)
		move	d3,bltsize(A5)			* Start Blit
		dbf	d7,3$

		SYSCALL	DisownBlitter
		movem.l	(sp)+,d0-d7/a0-a3/a5
		rts		

*****************************************************************************
* Function	: GetData
* Parameters	: D0 = X / D1 = Y / D2 = Widht / D3 = Height
*               : A0 = Window / A1 = Buffer
* Result	: NONE
*****************************************************************************

_GetData:
GetData:
	IFND	MINGFX

		tst.w	d2				* Width = 0
		bgt.s	5$
		tst.w	d3				* Height = 0
		bgt.s	5$
		rts

5$:		movem.l	d0-d7/a0-a5,-(sp)
		SYSCALL	OwnBlitter

		lea	custom,a5
		move.l	a1,a4
		add	wn_XOrigin(A0),d0		* Left Border
		add	wn_YOrigin(A0),d1		* Top Border

		move	d3,-(sp)
		SYSCALL	WaitBlit

		move.l	wn_BitmStr(A0),a1		* BitmapStructure
		moveq	#0,d7
		move.b	bm_Depth(A1),d7
		subq.b	#1,d7				* Depth-1

		lea	ShiftTab(pc),a3			* ShiftTabelle

		add	d0,d2				* Right Border
		add	#16,d2
		move	d2,d3
		and	#15,d3
		lsl	#1,d3
		move	(A3,d3.w),d3
		not	d3
		move	d3,bltalwm(A5)			* LastWordMask

		move	d0,d4
		and	#15,d4
		lsl	#1,d4
		move	(A3,d4.w),bltafwm(A5)		* FirstWordMask

		lsr.w	#4,d2				* Right Border Words
		lsr.w	#4,d0				* Left Border Words
		move.w	bm_BytesPerRow(A1),d3		* Bytes/Row
		move.w	d1,d5				* D5=Top Border
		mulu	d3,d1
		move.w	d0,d4
		lsl.w	#1,d4
		add.w	d1,d4				* D4=Offset

		sub.w	d0,d2				* D2=Breite in Words		
		move.w	d2,d5
		lsl.w	#1,d5				* D5=Breite in Bytes
		move.w	d5,d6				* D6=Breite in Bytes

		sub.w	d5,d3				* D3=Modulo in Bytes
		move.w	d3,bltbmod(A5)			* Source Modulo
		move.w	#0,bltcon1(A5)
		move.w	#0,bltdmod(A5)			* Destination Modulo
		move.w	#-1,bltadat(A5)			* Fill with $FFFF

		move	(sp)+,d3			* Height
		mulu	d3,d6				* D6=Lenght (Height*Width)
		lsl	#6,d3				* for BltSize
		or.w	d2,d3				* D3=BltSize

		move.w	#$05C0,bltcon0(A5)		* USE BD / D=AB (A AND B)
		lea	bm_Planes(A1),a1		* Pointer to Planes
				
3$:		SYSCALL	WaitBlit
		move.l	(A1)+,a2			* Plane

		add.w	d4,a2				* Destination
		move.l	a2,bltbpt(A5)			* Set Source
		move.l	a4,bltdpt(A5)			* Set Destination
		move.w	d3,bltsize(A5)			* Start Blit
		add.w	d6,a4				* Add Length to Dest.
		dbf	d7,3$

		SYSCALL	DisownBlitter
		movem.l	(sp)+,d0-d7/a0-a5
	ENDC
		rts		


*****************************************************************************
* Function	: PutData
* Parameters	: D0 = X / D1 = Y / D2 = Widht / D3 = Height
*               : A0 = Window / A1 = Buffer
* Result	: NONE
*****************************************************************************

_PutData:
PutData:
	IFND	MINGFX

		tst.w	d2				* Width = 0
		bgt.s	5$
		tst.w	d3				* Height = 0
		bgt.s	5$
		rts

5$:		movem.l	d0-d7/a0-a5,-(sp)
		SYSCALL	OwnBlitter

		lea	custom,a5
		move.l	a1,a4
		add	wn_XOrigin(A0),d0		* Left Border
		add	wn_YOrigin(A0),d1		* Top Border

		move	d3,-(sp)
		SYSCALL	WaitBlit

		move.l	wn_BitmStr(A0),a1		* BitmapStructure
		moveq	#0,d7
		move.b	bm_Depth(A1),d7
		subq.b	#1,d7				* Depth-1

		lea	ShiftTab(pc),a3			* ShiftTabelle

		add	d0,d2				* Right Border
		add	#16,d2
		move	d2,d3
		and	#15,d3
		lsl	#1,d3
		move	(A3,d3.w),d3
		not	d3
		move	d3,bltalwm(A5)			* LastWordMask

		move	d0,d4
		and	#15,d4
		lsl	#1,d4
		move	(A3,d4.w),bltafwm(A5)		* FirstWordMask

		lsr	#4,d2				* Right Border Words
		lsr	#4,d0				* Left Border Words

		move	bm_BytesPerRow(A1),d3		* Bytes/Row
		move	d1,d5				* D5=Top Border
		mulu	d3,d1
		move	d0,d4
		lsl	#1,d4
		add	d1,d4				* D4=Offset

		sub	d0,d2				* D2=Breite in Words		
		move	d2,d5
		lsl	#1,d5				* D5=Breite in Bytes
		move	d5,d6				* D6=Breite in Bytes

		sub	d5,d3				* D3=Modulo in Bytes
		move	d3,bltdmod(A5)			* Destination Modulo
		move	d3,bltcmod(A5)			* SourceC Modulo
		move.w	#0,bltbmod(A5)			* SourceB Modulo

		move.w	#0,bltcon1(A5)
		move	#-1,bltadat(A5)			* Fill with $FFFF

		move	(sp)+,d3			* Height
		mulu	d3,d6				* D6=Lenght (Height*Width)
		lsl	#6,d3				* for BltSize
		or	d2,d3				* D3=BltSize

		move	#$07CA,bltcon0(A5)		* USE BCD / D=AB+(A)C (A AND B OR (NOT A AND C)
		lea	bm_Planes(A1),a1		* Pointer to Planes
				
3$:		SYSCALL	WaitBlit
		move.l	(A1)+,a2			* Plane

		add	d4,a2				* Destination Address
		move.l	a4,bltbpt(A5)			* Set SourceB
		move.l	a2,bltcpt(A5)			* Set SourceC
		move.l	a2,bltdpt(A5)			* Set Destination
		move	d3,bltsize(A5)			* Start Blit
		add	d6,a4				* Add Length to Source
		dbf	d7,3$

		SYSCALL	DisownBlitter
		movem.l	(sp)+,d0-d7/a0-a5
	ENDC
		rts		


*****************************************************************************
* Function	: BitBlit						    *
* Parameters	: A0=SourceBitmap  A1=DestBitmap  A2=Buffer (ignored)	    *
*               : D0=SourceX  D1=SourceY  D2=Width D3=Height 		    *
*               : D4=DestX  D5=DestY					    *
* Result	: NONE							    *
*****************************************************************************

_BitBlit:
BitBlit:
	IFND	MINGFX

		movem.l	d0-d7/a0-a6,-(SP)
		SYSCALL	OwnBlitter
		subq	#1,d2
		lea	BlitData,a6
		lea	custom,a5
			
		move.l	d0,-(SP)
		add.w	#15,d0
		and.w	#~15,d0
		lsr.l	#3,d0
		addq	#4,d0
		mulu	d1,d0
		move.l	d0,d7
		add.l	d0,d0
		SYSCALL	AllocClearMem
		move.l	d0,a2
		move.l	(SP)+,d0

		move.l	a2,a3
		add.l	d7,a3

; Maske bilden
		move	d0,(A6)			; breite
		move	d1,2(a6)		; hoehe
		add	#15,d0			; breite auf naechstes Word aufrunden
		and	#~15,d0	
		move	d0,d6			; aufgerundete breite retten
		lsr	#4,d0			; /2
		move	d0,4(A6)		; breite in words
		lsl	#6,d1
		or.w	d0,d1			; bltsize
		sub	(A6),d6			; aufgerundete-orig. breite
		moveq	#-1,d0			; alle bits gesetzt
		lsl	d6,d0			; von rechts nach links loeschen = lwm
		SYSCALL	WaitBlit
		move.l	a2,bltdpt(a5)		; Dest D
		clr	bltdmod(a5)		; Modulo D
		clr	bltcon1(a5)		; BltCon1
		move	#$1f0,bltcon0(a5)	; BltCon0
		move	#-1,bltafwm(a5)		; FirstWordMask
		move	d0,bltalwm(a5)		; LastWordMask
		move	#-1,bltadat(a5)		; Source A Data
		move	d1,bltsize(a5)		; Blitter starten
; Source Werte berechnen

		move.w	4(a6),d0		; breite in words
		add.w	d0,d0			; breite in bytes
		move.w	(A0),d6			; breite des bildschirms
		sub.w	d0,d6			; bild-auschnittbreite = modulo
		subq	#2,d6			; Modulo - 2
		move.w	d6,8(A6)		; retten

		move.w	4(a6),d0		; breite in words
		addq	#1,d0			; ein word mehr
		move	2(a6),d1		; hoehe
		lsl	#6,d1
		or.w	d0,d1			; bltsize
		move.w	d1,6(a6)		; retten

		move	d2,-(SP)		; x koordinate runden
		and	#~15,d2			; x koordinate abrunden
		asr	#3,d2			; x/8
		muls	(a0),d3			; y*breite
		add.w	d3,d2			; Y+x
		move	d2,10(a6)		; SourceOffset
		move	(SP)+,d0		; x koordinate holen
		and	#15,d0			; shift wert bilden	
		move	#$f,d1
		sub	d0,d1
		move	d1,d0
		move	#12,d1
		lsl	d1,d0			; shiftwert an die richtige bltcon
		move	d0,12(a6)		; position shiften


; DestWerte berechnen

		move.w	4(a6),d0		; Breite in Words
		add.w	d0,d0			; in bytes
		move	(A1),d1			; breite des schirmes
		sub.w	d0,d1			; bildbreite-auschnittbreite
		sub	#2,d1			; -2 = DestModulo
		move	d1,14(A6)		; Dest Modulo

		move	d4,-(SP)		; x2 retten	
		and	#~15,d4			; abrunden
		lsr	#3,d4			; x2/8
		muls	(A1),d5	
		add.l	d5,d4									
		move	d4,16(a6)		; DestOffset
		move	(SP)+,d0		; x2 holen
		and	#15,d0			; ShiftWert berechnen
		move	#12,d1
		lsl	d1,d0			; shiftwert an die richtige bltcon
		move	d0,18(a6)		; position shiften
		

		moveq	#0,d1
		move.b	5(a0),d1
		sub	#1,d1

		addq	#8,a0
		addq	#8,a1

RectLoop1:
		SYSCALL	WaitBlit
; source in zwischenbuffer

		move.l	(A0)+,a4		; SourceAdresse holen
		add	10(a6),a4		; SourceOffset addieren
		move.l	a4,bltapt(a5)		; Source A
		move.l	a3,bltdpt(a5)		; Dest D
		clr	bltcon1(a5)		; BltCon1
		move	#$09f0,d0		; Wert fuer BltCon0
		or.w	12(A6),d0		; SourceShiftWert dazuodern
		move	d0,bltcon0(a5)		; BltCon0
		move.l	#$ffffffff,bltafwm(a5)	; First/LastWordMask
		move	8(A6),bltamod(a5)	; SourceModulo
		clr	bltdmod(a5)		; DestModulo loeschen
		move	6(A6),bltsize(a5)	; BltSize
		
		SYSCALL	WaitBlit

; zwischenbuffer nach dest

		move.l	(A1)+,a4		; DestAdresse holen
		add.w	16(A6),a4		; DestOffset addieren
		move.l	a2,bltapt(a5)		; Source A
		add	#2,a3
		move.l	a3,bltbpt(a5)		; Source B
		sub	#2,a3
		move.l	a4,bltcpt(a5)		; Source C
		move.l	a4,bltdpt(a5)		; Dest D	
		
		move	#-2,bltamod(a5)		; Modulo A
		move	#0,bltbmod(a5)		; Modulo B
		move	14(a6),bltcmod(a5)	; Modulo C
		move	14(a6),bltdmod(a5)	; Modulo D
		
		move	18(A6),bltcon1(a5)	; Shift nach BltCon1
		move	#$0fca,d0		; Wert fuer BltCon0
		or	18(A6),d0		; ShiftWert dazuodern
		move	d0,bltcon0(a5)		; BltCon0
		move.l	#$ffff0000,bltafwm(a5)	; First/LastWordMask
		move	6(A6),bltsize(a5)
		dbf	d1,RectLoop1

		move.l	a2,a1
		SYSCALL	FreeMem
		SYSCALL	DisownBlitter
		movem.l	(SP)+,d0-d7/a0-a6
	ENDC
		rts

*****************************************************************************
* Function	: Draw
* Parameters	: D0 = X / D1 = Y / A0 = Window
* Result	: NONE
*****************************************************************************

@Draw:
Draw:
	IFND	MINGFX

		movem.l	d0-d7/a0-a1/a5,-(sp)
		SYSCALL	OwnBlitter
		lea	custom,a5
		move	wn_XOrigin(A0),d4
		move	wn_YOrigin(A0),d5
		move	d0,d2
		move	d1,d3		
		move	wn_CursorX(A0),d0
		move	wn_CursorY(A0),d1
		move	d2,wn_CursorX(A0)
		move	d3,wn_CursorY(A0)
		add	d4,d0
		add	d5,d1
		add	d4,d2
		add	d5,d3

		moveq	#0,d4
		move.b	wn_APen(A0),d4			* Farbe
		move.l	wn_BitmStr(A0),a0

		lea	OktTab(PC),a1
		move.w	bm_BytesPerRow(a0),d6
		cmp.w	d3,d1				* Y1 <= Y2 ?
		ble.s	1$				* ja
		exg	d3,d1				* sonst Y1 mit Y2 ...
		exg	d2,d0				* ... und X1 mit X2 tauschen
1$:		sub.w	d1,d3				* D3 := Delta Y
		muls.w	d6,d1				* D1 *= BytesPerRow
		move.w	d0,d5				* X1
		asr.w	#4,d5				* /16 : Word-Offset
		add.w	d5,d5				* *2  : Byte-Offset WORD-ali.
		ext.l	d5
		add.l	d5,d1				* D1 := Plane-Offset

		moveq	#0,d5
		sub.w	d0,d2				* D2 := Delta X (genannt X)
		bpl.s	2$				* ist >0
		neg.w	d2				* sonst negieren
		ori.w	#$0004,d5			* für Oktant-Bestimmung
2$:		andi.w	#$000f,d0			* Bit-Nr. im Wort von X1
		ror.w	#4,d0				* nach Bit 12-15 für bltcon0
		ori.w	#$bfa,d0			* $0B00 | minterm (08=Loeschen/48=EOR/FA=Setzen)

		cmp.w	d2,d3				* Delta X > Delta Y ?
		ble.s	3$				* ja
		exg	d3,d2				* sonst vertauschen
		ori.w	#$0002,d5			* für Oktant-Bestimmung
3$:		move.w	0(a1,d5.w),d5			* Oktant aus Tabelle
		asl.w	#2,d3				* D3 :  4Y
		SYSCALL	WaitBlit

		move.w	d0,-(SP)			* bltcon0
		moveq.l	#-1,d0				* FirstWordMask & LastWordMask
		move.l	d0,bltafwm(a5)			* Beide Masks auf einmal!
		move.w	d6,bltcmod(a5)
		move.w	d6,bltdmod(a5)
		move	d0,bltbdat(A5)

		move.w	d3,d6				* D6 :  4Y
		add.w	d2,d2				* D2 :  2X
		sub.w	d2,d3
		move.w	d3,d7				* D7 :  4Y-2X
		bpl.s	4$				* > 0
		bset	#6,d5				* sonst SIGN setzen (bplcon1)
4$:		move.w	d5,bltcon1(a5)
		sub.w	d2,d3				* D3 :  4Y-4X
		lsl.w	#5,d2				* nach Bits 6-15 (war ja 2X)
		addi.w	#64+2,d2			* D2 :  BltSize

		move.w	(SP)+,d5			* bltcon0
		moveq	#0,d0
		move.b	bm_Depth(A0),d0
		subq	#1,d0				* Depth 
		lea	bm_Planes(a0),a0		* bm_Planes-Array
5$:		move.l	(a0)+,a1			* Next plane

		move.b	#$08,d5				* 08
		lsr.w	#1,d4				* Plane-Bit == 1 ?
		bcc.s	6$				* nein ---> ignore

		move.b	#$FA,d5				* fa
6$:
		add.l	d1,a1				* + Plane-Offset
		SYSCALL	WaitBlit
		move.l	a1,bltcpt(a5)			* Line-Start nach Source C
		move.l	a1,bltdpt(a5)			* und Destination
		move.w	#$8000,bltadat(a5)		* Für Line-Draw
		move.w	d5,bltcon0(a5)
		move.w	d3,bltamod(a5)
		move.w	d6,bltbmod(a5)			* 4Y
		move.w	d7,bltapt+2(a5)			* 4Y-2X
		move.w	d2,bltsize(a5)			* BLIT STARTEN!
		dbf	d0,5$

99$:		SYSCALL	DisownBlitter
		movem.l	(SP)+,d0-d7/a0-a1/a5
	ENDC
		rts

	IFND	MINGFX
OktTab:		* Bits: 4:SUD, 3:SUL, 2:AUL, 1:SING, 0:LINE
		dc.w	%10001,%00001,%10101,%01001
	ENDC

*****************************************************************************
* Function	: CloseWindow
* Parameters	: A0 = Window
* Result	: NONE
*****************************************************************************

@CloseWindow:
CloseWindow:	movem.l	d0-d3/a0-a1,-(sp)
		bsr	CloseFont			* Close Font

		btst	#WNB_NOBACKSAVE,wn_Flags+1(A0)
		bne.s	.NoBackRestore			* Saved Background

		moveq	#0,d0
		moveq	#0,d1
		move	wn_Width(A0),d2
		move	wn_Height(A0),d3
		move.l	wn_SaveBack(A0),a1		* Buffer
		bsr	PutData				* Restore Background

		move.l	wn_SaveBack(A0),a1		* Buffer
		SYSCALL	FreeMem				* Free SaveBuffer	

.NoBackRestore:	move.l	a0,a1
		SYSCALL	FreeMem				* Free WindowStructure
		movem.l	(sp)+,d0-d3/a0-a1
		rts

*****************************************************************************
* Function	: OpenWindow
* Parameters	: A0 = NewWindow  A1=BitMapStr
* Result	: D0 = Pointer to WindowStructure
*****************************************************************************

@OpenWindow:
OpenWindow:	movem.l	d1-d5/a0-a3,-(sp)

		move.l	a0,a3				* A3=NewWindow
		move.l	#wn_SIZEOF,d0
		SYSCALL	AllocFastClearMem		* WindowStructure
		move.l	d0,a0				* A0=WindowStructure

		move.l	a1,wn_BitmStr(A0)		* BitmapStructure
		move.w	nw_LeftEdge(A3),wn_XOrigin(A0)
		move.w	nw_TopEdge(A3),wn_YOrigin(A0)
		move.w	nw_Width(A3),wn_Width(A0)
		move.w	nw_Height(A3),wn_Height(A0)
		move.b	nw_BPen(A3),wn_BPen(A0)
		move.w	nw_Flags(A3),wn_Flags(A0)
		move.w	nw_DrawMode(A3),wn_DrawMode(A0)
		move.l	nw_Font(A3),wn_Font(a0)

		btst	#WNB_NOBACKSAVE,wn_Flags+1(A0)	* Don't save Background
		bne.s	.NoBackSave

		move.w	wn_Width(A0),d0			* Window Widht
		add.w	#31,d0
		asr.w	#4,d0
		asl.w	#1,d0				* Widht in Bytes rounded
		mulu	wn_Height(A0),d0		* D0=Lenght for 1 Plane

		move.l	wn_BitmStr(A0),a1
		moveq	#0,d1
		move.b	bm_Depth(A1),d1			* Screen Depth
		;mulu	d1,d0
		mulu	#5,d0				* D0=Lenght for X Planes

		SYSCALL	AllocClearMem			* Allocate SaveBuffer
		move.l	d0,wn_SaveBack(a0)

		moveq	#0,d0
		move	#0,d1
		move	wn_Width(A0),d2
		move	wn_Height(A0),d3
		move.l	wn_SaveBack(A0),a1		* Buffer
		bsr	GetData				* Save Background

		btst	#WNB_BORDERLESS,wn_Flags+1(A0)
		bne.s	.NoBackSave			* Kein Rechteck bei BORDERLESS

		move.b	wn_BPen(A0),wn_APen(A0)
		moveq	#0,d0
		moveq	#0,d1
		move.w	wn_Width(A0),d2
		move.w	wn_Height(A0),d3		* Size of Window
		bsr	RectFill

.NoBackSave:	moveq	#0,d5				* FontDistance
		move.b	nw_APen(A3),wn_APen(A0)
		move.l	nw_Font(A3),a1			* FontStructure
		move.l	a1,d0				* nicht vorhanden
		beq.s	.NoFont				* -->

		bsr	OpenFont			* Open this Font
		tst.l	d0
		beq.s	.NoFont
		move.l	d0,wn_Font(A0)			* Zeiger auf FontStrucure

		move.w	nf_Height(A1),d5		* for TitleBar
		subq.w	#1,d5

.NoFont:	move.l	nw_Titel(A3),a1			* TitelText
		move.l	a1,d0
		beq.s	.NoTitel			* kein Titel -->

		bset	#WNB_TITEL,wn_Flags(A0)		* TitelFlag
		move.w	wn_Width(A0),d0			* Width of Window
		lsr.w	#1,d0				* Middle of Window
		moveq	#3,d1				* YPos
		add.w	d5,d1				* for ExtraFont
		bsr	Move				* SetCursor
		bsr	MidText				* Print WindowTitel

.NoTitel:
		btst	#WNB_BORDERLESS,wn_Flags+1(A0)
		bne.s	.NoBorder

		bsr.s	DrawWindowBorder

.NoBorder:
		move.b	nw_APen(A3),wn_APen(A0)
		move.l	a0,d0

		movem.l	(sp)+,d1-d5/a0-a3
		rts

DrawWindowBorder:
		move	wn_Width(A0),d2
		move	wn_Height(A0),d3
		subq	#1,d2
		subq	#1,d3
		move	d2,d4
		move	d3,d5
		subq	#1,d4
		subq	#1,d5

		move.b	#25,wn_APen(A0)
		MoveMcr	#0,d3
		DrawMcr	#0,#0

		DrawMcr	d2,#0
		MoveMcr	#1,d5
		DrawMcr	d4,d5
		DrawMcr	d4,#1

		move.b	#26,wn_APen(A0)
		MoveMcr	#1,d5
		DrawMcr	#1,#1
		DrawMcr	d4,#1
		MoveMcr	#0,d3
		DrawMcr	d2,d3
		DrawMcr	d2,#0

		move.l	nw_Titel(A3),a1			* TitelText
		move.l	a1,d0
		beq.s	.NoTitel			* kein Titel -->

		move.l	wn_Font(A0),a1			* Font
		move.l	a1,d0
		beq.s	.NoFont				* StandartFont

		moveq	#5,d5
		add.w	fo_Height(A1),d5
		bra.s	.ExtraFont

.NoFont:	moveq	#12,d5

.ExtraFont:	MoveMcr	#1,d5
		DrawMcr	d4,d5

		move.b	#25,wn_APen(A0)
		subq.w	#1,d5
		MoveMcr	#1,d5
		DrawMcr	d4,d5
.NoTitel:	rts

*****************************************************************************
* Function	: ClearWindow
* Parameters	: A0 = Window
* Result	: none
*****************************************************************************

_ClearWindow:
ClearWindow:

	IFND	MINGFX

		movem.l	d0-d6/a0-a1,-(sp)
		btst	#WNB_BORDERLESS,wn_Flags(A0)	* Borderless ?
		beq.s	.BorderWindow			* No -->

		moveq	#0,d0				* LeftEdge
		moveq	#0,d1				* TopEdge
		move.w	wn_Width(A0),d2			* Widht
		move.w	wn_Height(A0),d3		* Height
		bra.s	.ClearWindow

.BorderWindow:	moveq	#2,d0				* LeftEdge
		moveq	#2,d1				* TopEdge
		move.w	wn_Width(A0),d2
		move.w	wn_Height(A0),d3
		subq.w	#4,d2				* Widht
		subq.w	#4,d3				* Height	

.ClearWindow:	btst	#WNB_TITEL,wn_Flags(A0)
		beq.s	.NoTitel

		move.l	wn_Font(A0),a1			* StandartFont
		move.l	a1,d6
		beq.s	.StandartFont

		move.w	fo_Height(A1),d5
		addq.w	#6,d5
		bra.s	.ExtraFont

.StandartFont:	moveq	#11,d5

.ExtraFont:	add.w	d5,d1				* Don't clear Titelbar			
		sub.w	d5,d3				* Height

.NoTitel:	move.b	wn_APen(A0),d4			* Save APen
		move.b	wn_BPen(A0),wn_APen(A0)		* BPen = ClearPen

		bsr	RectFill			* ClearWindow Back Area

		move.b	d4,wn_APen(A0)			* Old APen
		movem.l	(sp)+,d0-d6/a0-a1
	ENDC
		rts

*****************************************************************************
* Function	: Text
* Parameters	: A0 = Window / A1 = Nullterminated String
* Result	: NONE
*****************************************************************************

@Text:
Text:		movem.l	d0-d7/a0-a6,-(sp)

		move.w	wn_CursorX(a0),d5		* StartXPos

		move.l	wn_Font(a0),a3			* FontStructure
		move.l	a3,d0

		beq	StandartFont

	******	Input: A3 = FontStrct / A1 = Text  ******

		SYSCALL	Disable

		move.l	a0,a5				* A5=Window
		move.l	a1,a4				* A4=Text

		move.w	fo_XDist(a3),d1			* Distanz
		move.w	wn_XOrigin(A5),d3		* Window Left Edge
		move.w	wn_YOrigin(A5),d4		* Window Top Edge
		move.l	wn_BitmStr(A5),a1		* BitmStr
		move.l	fo_Bob(a3),a0			* BobStructure
		move.l	fo_AsciiTab(a3),a6		* AsciiTab

.FontLoop:	moveq.l	#0,d0
		move.b	(a4)+,d0			* Char
		beq	.EndFont			* Last Letter

	;	cmp.b	#FIRSTCODE,d0			* Too Small for SpecialCode
	;	blo.s	5$				* Yes --->

		cmp.b	#LINEFEED,d0			* Got LineFeed-Code
		bne.s	4$				* No -->

		move.w	fo_Height(A3),d2
		add.w	d2,wn_CursorY(A5)
		lsr.w	#1,d2

	;;;	move.w	d2,wn_CursorX(A5)
		move.w	d5,wn_CursorX(a0)

		bra.s	.FontLoop			* Next Char

4$:		cmp.b	#SETCURSOR,d0
		bne.s	6$

		moveq	#0,d0
		move.b	(A4)+,d0
		move.w	d0,wn_CursorX(A5)
		move.b	(A4)+,d0
		move.w	d0,wn_CursorY(A5)
		bra.s	.FontLoop			* Next Char
6$:
		lea	1(a4),a4			* Dummy
		bra.s	.FontLoop

5$:		cmp.b	#' ',d0
		bne.s	8$
		move.w	fo_SpaceWidth(A3),d2
		beq.s	8$
		move.w	d2,d0
		bra.s	.NoPropFont				
8$:		sub.b	#' ',d0
		move.b	(a6,d0.w),d0
		move.w	d0,bob_Image(A0)

		move.w	wn_CursorX(A5),d0		* XPos
		add.w	d3,d0
		move.w	d0,bob_X(a0)
		move.w	wn_CursorY(A5),d0		* YPos
		add.w	d4,d0
		move.w	d0,bob_Y(a0)

		move.l	a5,d2
		lea	custom,a5
		SYSCALL	DrawOneBob
		move.l	d2,a5

7$:		btst	#FOB_NOPROP,fo_Flags+1(a3)
		beq.s	.PropFont
		move.w	fo_Width(A3),d0
		bra.s	.NoPropFont

.PropFont:	SYSCALL	GetBobData
		move.w	bod_Width(a2),d0

.NoPropFont:	add.w	d1,d0
		add.w	d0,wn_CursorX(a5)
		bra	.FontLoop
.EndFont:	movem.l	(SP)+,d0-d7/a0-a6
		SYSCALL	Enable
		rts


StandartFont:	move.b	wn_APen(A0),d4			* Color
		move.l	wn_BitmStr(A0),a2		* BitmStr
		moveq	#0,d3
		move.b	bm_Depth(A2),d3
		sub.b	#1,d3				* Depth-1
		lea	bm_Planes(A2),a3		* Planes

.FontLoop:	moveq	#0,d2
		move.b	(A1)+,d2			* Character
		beq.s	1$				* End --->

	;	cmp.b	#FIRSTCODE,d2			* Too Small for SpecialCode
	;	blo.s	6$				* Yes --->

		cmp.b	#LINEFEED,d2			* Got LineFeed-Code
		bne.s	4$				* No -->

		addq	#8,wn_CursorY(A0)
		move.w	d5,wn_CursorX(A0)
		bra.s	.FontLoop			* Next Char

4$:		cmp.b	#SETCURSOR,d2
		bne.s	5$

		moveq	#0,d0
		move.b	(A1)+,d0
		move.w	d0,wn_CursorX(a0)
		move.b	(A1)+,d0
		move.w	d0,wn_CursorY(a0)
		bra.s	.FontLoop			* Next Char

5$:		cmp.b	#SETCOLOR,d2
		bne.s	6$

		move.b	(a1)+,d4
		move.b	d4,wn_APen(A0)
		bra.s	.FontLoop

6$:		move	wn_CursorX(A0),d0		* XPos
		add	wn_XOrigin(A0),d0
		move	wn_CursorY(A0),d1		* YPos
		add	wn_YOrigin(A0),d1
		
		bsr	PrintChar
		add	#8,wn_CursorX(A0)		* Next Position
		bra.s	.FontLoop

1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

*****************************************************************************
* Function	: RightText
* Parameters	: A0 = Window / A1 = Nullterminated String
* Result	: NONE
*****************************************************************************

RightText:	move.l	d2,-(sp)
		movem.l	d0-d1/a0,-(sp)
		move.l	a1,a0
		bsr	StrLen				* Length of String
		lsl.w	#3,d0				* PixelLength
		move.w	d0,d2				* to D2
		movem.l	(sp)+,d0-d1/a0
		sub.w	d2,wn_CursorX(A0)
		move.l	(sp)+,d2
		bra	Text


*****************************************************************************
* Function	: MidText
* Parameters	: A0 = Window / A1 = Nullterminated String
* Result	: NONE
*****************************************************************************

MidText:	move.l	d2,-(sp)
		movem.l	d0-d1/a0,-(sp)
		move.l	a1,a0
		bsr	StrLen				* Length of String
		lsl	#3,d0				* PixelLength
		lsr	#1,d0				* Half Length
		move	d0,d2				* to D2
		movem.l	(sp)+,d0-d1/a0
		sub	d2,wn_CursorX(A0)
		move.l	(sp)+,d2
		bra	Text

*****************************************************************************
* Function	: Print
* Parameters	: A0 = Window / A1 = Nullterminated String / A2 = Stack
* Result	: NONE
*****************************************************************************

@Print:
Print:		move.l	a1,-(sp)
		movem.l	d0-d2/a0-a3,-(sp)		* Save Window
		move.l	a1,a0				* Text for RawDoFmt
		move.l	a2,a1				* Stack for RawDoFmt
		lea	RawPrint(pc),a2			* My Routine
		lea	RawBuffer,a3			* My Buffer
		SYSCALL	RawDoFmt			* Convert Text

		movem.l	(sp)+,d0-d2/a0-a3		* Window
		lea	RawBuffer,a1			* Text
		bsr	Text
		move.l	(sp)+,a1
		rts

RawPrint:	move.b	d0,(A3)+
		cmp.l	#EndBuffer,a3
		bne.s	1$

		MSG	<"RawBuffer OverFlow">

1$:		rts

*****************************************************************************

PrintChar:	movem.l	d0-d7/a1-a6,-(sp)
		sub	#32,d2
		lsl	#3,d2
		lea	ZeichenSatz(pc),a1
		add	d2,a1				* Character-Address

		mulu	bm_BytesPerRow(A2),d1
		move	d0,d2
		lsr	#3,d0
		add	d1,d0				* D1 = Offset

		and	#7,d2
		moveq	#7,d5
		sub	d2,d5				* D5 = Shift

		move.b	d5,d2
		lsl.b	#1,d2
		lea	ClearTab(pc),a4
		move	(A4,d2.w),d2
		move	d2,d6
		lsr	#8,d2				* D2/D6 = Löschmaske

		move.l	a1,a6
		cmp	#DM_JAM,wn_DrawMode(A0)		* HinterGrund löschen
		beq.s	5$				* Ja -->		

*** Zeichen schreiben ohne Hintergrund löschen **************************************

4$:		move.l	a6,a1				* Character
		move.l	(A3)+,a4			* Bitmap
		add.w	d0,a4				* A4 = Offset in Bitmap
		
		moveq	#8-1,d7				* 8-1 Rows

		lsr.b	#1,d4
		bcc.s	2$				* Clear/Set

1$:		moveq	#0,d1
		move.b	(A1)+,d1
		lsl	d5,d1				* Shiften
		or.b	d1,1(A4)
		lsr	#8,d1
		or.b	d1,(A4)
		add	bm_BytesPerRow(A2),a4		* Next Row
		dbf	d7,1$
		bra.s	3$

2$:		moveq	#0,d1
		move.b	(A1)+,d1
		lsl	d5,d1				* Shiften
		not	d1
		and.b	d1,1(A4)
		lsr	#8,d1
		and.b	d1,(A4)
		add	bm_BytesPerRow(A2),a4		* Next Row
		dbf	d7,2$
3$:
		move	wn_Flags(a0),d7
		btst	#WNB_FASTTEXT,d7		* FastText
		bne.s	9$				* ja -->
		dbf	d3,4$
		movem.l	(sp)+,d0-d7/a1-a6
		rts

*** Zeichen schreiben mit Hintergrund löschen **************************************

5$:		move.l	a6,a1				* Character
		move.l	(A3)+,a4			* Bitmap
		add	d0,a4				* A4 = Offset in Bitmap
		
		moveq	#8-1,d7				* 8-1 Rows

		lsr.b	#1,d4
		bcc	7$				* Clear/Set

6$:		moveq	#0,d1
		move.b	(A1)+,d1
		lsl	d5,d1				* Shiften
		and.b	d6,1(A4)
		or.b	d1,1(A4)
		lsr	#8,d1
		and.b	d2,(A4)
		or.b	d1,(A4)
		add	bm_BytesPerRow(A2),a4		* Next Row
		dbf	d7,6$
		bra.s	8$

7$:		moveq	#0,d1
		move.b	(A1)+,d1
		lsl	d5,d1				* Shiften
		not	d1
		and.b	d6,1(A4)
		and.b	d1,1(A4)
		lsr	#8,d1
		and.b	d2,(A4)
		and.b	d1,(A4)
		add	bm_BytesPerRow(A2),a4		* Next Row
		dbf	d7,7$
8$:
		move	wn_Flags(a0),d7
		btst	#WNB_FASTTEXT,d7		* FastText
		bne.s	9$				* ja -->
		dbf	d3,5$

9$:		movem.l	(sp)+,d0-d7/a1-a6
		rts

*****************************************************************************
* Function	: OpenFont
* Parameters	: A0 = Window / A1 = NewFontStructure
* Result	: D0 = Font
*****************************************************************************

OpenFont:
	IFND	MINGFX
		movem.l	d1-d2/a0-a3,-(SP)
		move.l	nf_Bob(a1),d0
		beq.s	.NoFont

;		bsr	CloseFont

		move.l	#fo_SIZEOF,d0
		SYSCALL	AllocFastClearMem
		move.l	d0,a2				* A2=FontStructure
		move.w	nf_Width(A1),fo_Width(A2)
		move.w	nf_Height(A1),fo_Height(A2)
		move.w	nf_XDist(A1),fo_XDist(A2)
		move.w	nf_Flags(A1),fo_Flags(A2)
		move.w	nf_SpaceWidth(A1),fo_SpaceWidth(A2)
		move.l	nf_AsciiTab(A1),a3
		move.l	a3,d0				* AsciiTab
		bne.s	.NormTab
		lea	NormAsciiTab(pc),a3

.NormTab:	move.l	a3,fo_AsciiTab(a2)		* AsciiTab
		move.l	nf_Bob(A1),d0
		lea	FontNewBob(pc),a1
		move.l	d0,2(a1)
		SYSCALL	AddBob

		move.l	d0,fo_Bob(a2)			* FontBob

		move.l	a2,wn_Font(A0)
		move.l	a2,d0
.NoFont:	movem.l	(SP)+,d1-d2/a0-a3
	ENDC
		rts

*****************************************************************************
* Function	: CloseFont
* Parameters	: A0 = Window
* Result	: none
*****************************************************************************

CloseFont:
	IFND	MINGFX
		movem.l	d0/a0-a2,-(SP)
		move.l	a0,a2
		move.l	wn_Font(a0),a0
		move.l	a0,d0
		beq.s	.NoFont

		clr.l	wn_Font(A2)

		move.l	fo_Bob(a0),a1
		SYSCALL	FreeMem				* Free BobStructure
		move.l	a0,a1
		SYSCALL	FreeMem				* Free FontStructure

.NoFont:	movem.l	(SP)+,d0/a0-a2
	ENDC
		rts

*****************************************************************************
* Function	: StrLen
* Parameters	: A0 = Nullterminated String
* Result	: D0 = Length
*****************************************************************************

StrLen:		move.l	a0,-(sp)
		moveq	#0,d0
2$:		tst.b	(A0)+
		beq.s	1$
		addq	#1,d0
		bra.s	2$
1$:		move.l	(sp)+,a0
		rts

*****************************************************************************
* Function	: PrintAt
* Parameters	: Window, XPos, YPos, String, ......
* Result	: none
*****************************************************************************

_PrintAt:	movem.l	d0-d1/a0-a4,-(sp)

		move.l	32(A7),a0			* Window
		move.l	a0,a4
		move.l	4+32(A7),d0			* XPos
		move.l	8+32(A7),d1			* YPos
		bsr	Move				* Set Cursor

		move.l	12+32(A7),a0			* FormatString
		lea	16+32(A7),a1			* Buffer
		lea	RawPrint(pc),a2
		lea	RawBuffer,a3
		SYSCALL	RawDoFmt

		move.l	a4,a0
		lea	RawBuffer,a1			* Buffer
		bsr	Text

		movem.l	(sp)+,d0-d1/a0-a4
		rts

*****************************************************************************
* Function	: GetCustom
* Parameters	: none
* Result	: A5 = Custom
*****************************************************************************

@GetCustom:	lea	custom,a5
		rts

*****************************************************************************

* Bitmap to Font-Converter V0.1 (28.12.1989 rs)

ZeichenSatz:	dc.b	0,0,0,0,0,0,0,0				; Space (32)
		dc.b	$18,$18,$18,$18,$00,$18,$00,$00		; !
		dc.b	$36,$36,$12,$00,$00,$00,$00,$00		; "
		dc.b	$36,$7F,$36,$36,$7F,$36,$00,$00		; #
		dc.b	$36,$36,$12,$00,$00,$00,$00,$00		; $
		dc.b	$36,$36,$12,$00,$00,$00,$00,$00		; %
		dc.b	$36,$36,$12,$00,$00,$00,$00,$00		; &
		dc.b	$0C,$0C,$04,$00,$00,$00,$00,$00		; '
		dc.b	$0C,$18,$18,$18,$18,$0C,$00,$00		; (
		dc.b	$18,$0C,$0C,$0C,$0C,$18,$00,$00		; )
		dc.b	$08,$2A,$1C,$1C,$2A,$08,$00,$00		; *
		dc.b	$00,$0C,$0C,$3F,$0C,$0C,$00,$00		; +
		dc.b	$00,$00,$00,$00,$1C,$1C,$38,$00		; ,
		dc.b	$00,$00,$00,$3E,$00,$00,$00,$00		; -
		dc.b	$00,$00,$00,$00,$18,$18,$00,$00		; .
		dc.b	$03,$06,$0C,$18,$30,$60,$00,$00		; /
		dc.b	$1E,$33,$33,$33,$33,$1E,$00,$00		; 0 (48)
		dc.b	$04,$0c,$1c,$0c,$0c,$1e,$00,$00		; 1
		dc.b	$1e,$33,$03,$06,$18,$3F,$00,$00		; 2
		dc.b	$3F,$02,$06,$03,$23,$1E,$00,$00		; 3
		dc.b	$06,$0E,$16,$26,$7F,$06,$00,$00		; 4
		dc.b	$3F,$30,$3E,$07,$07,$3E,$00,$00		; 5
		dc.b	$1E,$30,$3E,$33,$33,$1E,$00,$00		; 6
		dc.b	$3F,$03,$06,$0C,$0C,$0C,$00,$00		; 7
		dc.b	$1E,$33,$1E,$33,$33,$1E,$00,$00		; 8
		dc.b	$1E,$33,$33,$1F,$03,$1E,$00,$00		; 9
		dc.b	$00,$0C,$0C,$00,$0C,$0C,$00,$00
		dc.b	$00,$0C,$0C,$00,$0C,$0C,$00,$00
		dc.b	$02,$06,$0C,$18,$0C,$06,$02,$00
		dc.b	$00,$00,$1F,$00,$1F,$00,$00,$00
		dc.b	$08,$0C,$06,$03,$06,$0C,$08,$00
		dc.b	$1E,$27,$06,$0C,$00,$0C,$00,$00
		dc.b	$1E,$27,$06,$0C,$00,$0C,$00,$00		; (64)
		dc.b	$1E,$31,$31,$3F,$31,$31,$00,$00
		dc.b	$3E,$31,$36,$31,$31,$3E,$00,$00
		dc.b	$1E,$31,$30,$30,$31,$1E,$00,$00
		dc.b	$3E,$31,$31,$31,$31,$3E,$00,$00
		dc.b	$3F,$30,$3E,$30,$30,$3F,$00,$00
		dc.b	$3F,$30,$3E,$30,$30,$30,$00,$00
		dc.b	$1E,$31,$30,$33,$31,$1E,$00,$00
		dc.b	$31,$31,$3F,$31,$31,$31,$00,$00
		dc.b	$1E,$0C,$0C,$0C,$0C,$1E,$00,$00
		dc.b	$3F,$23,$03,$03,$23,$1E,$00,$00
		dc.b	$31,$32,$3C,$32,$31,$31,$00,$00
		dc.b	$30,$30,$30,$30,$30,$3F,$00,$00
		dc.b	$31,$3B,$35,$31,$31,$31,$00,$00
		dc.b	$31,$39,$35,$33,$31,$31,$00,$00
		dc.b	$1E,$31,$31,$31,$31,$1E,$00,$00
		dc.b	$3E,$31,$31,$3E,$30,$30,$00,$00		; (80)
		dc.b	$3C,$62,$62,$66,$62,$3D,$00,$00
		dc.b	$3E,$31,$31,$3E,$31,$31,$00,$00
		dc.b	$1E,$39,$1C,$0E,$27,$1E,$00,$00
		dc.b	$3F,$0C,$0C,$0C,$0C,$0C,$00,$00
		dc.b	$31,$31,$31,$31,$31,$1E,$00,$00
		dc.b	$31,$31,$1A,$1A,$0C,$0C,$00,$00
		dc.b	$35,$35,$35,$35,$35,$1A,$00,$00
		dc.b	$31,$1A,$0C,$0C,$1A,$31,$00,$00
		dc.b	$31,$31,$1A,$0C,$0C,$0C,$00,$00
		dc.b	$3F,$07,$0E,$1C,$38,$3F,$00,$00
		dc.b	$3E,$30,$30,$30,$30,$3E,$00,$00
		dc.b	$60,$30,$18,$0C,$06,$03,$00,$00
		dc.b	$3E,$06,$06,$06,$06,$3E,$00,$00
		dc.b	$1C,$36,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$FE,$00
		dc.b	$0C,$0C,$04,$00,$00,$00,$00,$00		; (96)
		dc.b	$00,$7C,$06,$3E,$46,$3D,$00,$00
		dc.b	$30,$3E,$31,$31,$31,$3E,$00,$00
		dc.b	$00,$1E,$31,$30,$31,$1E,$00,$00
		dc.b	$03,$1F,$23,$23,$23,$1F,$00,$00
		dc.b	$00,$1E,$31,$3F,$30,$1F,$00,$00
		dc.b	$0E,$19,$18,$3C,$18,$18,$18,$00
		dc.b	$00,$1F,$23,$23,$1F,$23,$1E,$00
		dc.b	$30,$3E,$31,$31,$31,$31,$00,$00

		dc.b	$08,$1E,$0C,$0C,$0C,$1E,$00,$00		; 'i'
		dc.b	$08,$1E,$0C,$0C,$0C,$0C,$38,$00		; 'j'

		dc.b	$30,$31,$32,$3C,$32,$31,$00,$00
		dc.b	$18,$18,$18,$18,$18,$0C,$00,$00
		dc.b	$00,$3A,$35,$35,$35,$35,$00,$00
		dc.b	$00,$3E,$31,$31,$31,$31,$00,$00
		dc.b	$00,$1E,$31,$31,$31,$1E,$00,$00
		dc.b	$00,$3E,$31,$31,$31,$3E,$30,$00		; (112)
		dc.b	$00,$1F,$23,$23,$23,$1F,$03,$00
		dc.b	$00,$36,$39,$30,$30,$30,$00,$00
		dc.b	$00,$1F,$38,$1E,$07,$3E,$00,$00
		dc.b	$18,$3C,$18,$18,$1A,$0C,$00,$00
		dc.b	$00,$31,$31,$31,$31,$1E,$00,$00
		dc.b	$00,$61,$61,$32,$1C,$08,$00,$00
		dc.b	$00,$35,$35,$35,$35,$1A,$00,$00
		dc.b	$00,$31,$1A,$0C,$1A,$31,$00,$00
		dc.b	$00,$61,$61,$73,$3E,$0C,$38,$00
		dc.b	$00,$3F,$06,$0C,$18,$3F,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00


;ZeichenSatz:	dc.l	$00000000,$00000000,$18181818,$00001800	; 32
;		dc.l	$66666600,$00000000,$6666FF66,$FF666600
;		dc.l	$183E603C,$067C1800,$62660C18,$30664600
;		dc.l	$3C663C38,$67663F00,$060C1800,$00000000
;		dc.l	$0C183030,$30180C00,$30180C0C,$0C183000
;		dc.l	$00663CFF,$3C660000,$0018187E,$18180000
;		dc.l	$00000000,$00181830,$0000007E,$00000000
;		dc.l	$00000000,$00181800,$03060C18,$3060C000
;		dc.l	$3C666E76,$66663C00,$18183818,$18187E00	; 48
;		dc.l	$3C66060C,$30607E00,$3C66061C,$06663C00
;		dc.l	$060E1E66,$7F060600,$7E607C06,$06663C00
;		dc.l	$3C66607C,$66663C00,$7E660C18,$18181800
;		dc.l	$3C66663C,$66663C00,$3C66663E,$06663C00
;		dc.l	$00001800,$00180000,$00001800,$00181830
;		dc.l	$0E183060,$30180E00,$00007E00,$7E000000
;		dc.l	$70180C06,$0C187000,$3C66060C,$18001800
;		dc.l	$3C666E6E,$60623C00,$183C667E,$66666600	; 64
;		dc.l	$7C66667C,$66667C00,$3C666060,$60663C00
;		dc.l	$786C6666,$666C7800,$7E606078,$60607E00
;		dc.l	$7E606078,$60606000,$3C66606E,$66663C00
;		dc.l	$6666667E,$66666600,$3C181818,$18183C00
;		dc.l	$1E0C0C0C,$0C6C3800,$666C7870,$786C6600
;		dc.l	$60606060,$60607E00,$63777F6B,$63636300
;		dc.l	$66767E7E,$6E666600,$3C666666,$66663C00
;		dc.l	$7C66667C,$60606000,$3C666666,$663C0E00	; 80
;		dc.l	$7C66667C,$786C6600,$3C66603C,$06663C00
;		dc.l	$7E181818,$18181800,$66666666,$66663C00
;		dc.l	$66666666,$663C1800,$6363636B,$7F776300
;		dc.l	$66663C18,$3C666600,$6666663C,$18181800
;		dc.l	$7E060C18,$30607E00,$3C303030,$30303C00
;		dc.l	$c0603018,$0c060300,$3C0C0C0C,$0C0C3C00
;		dc.l	$00183C7E,$18181818,$0010307F,$7F301000
;		dc.l	$18180c00,$00000000,$00003C06,$3E663E00	; 96
;		dc.l	$0060607C,$66667C00,$00003C60,$60603C00
;		dc.l	$0006063E,$66663E00,$00003C66,$7E603C00
;		dc.l	$000E183E,$18181800,$00003E66,$663E067C
;		dc.l	$0060607C,$66666600,$00180038,$18183C00
;		dc.l	$00060006,$0606063C,$0060606C,$786C6600
;		dc.l	$00381818,$18183C00,$0000667F,$7F6B6300
;		dc.l	$00007C66,$66666600,$00003C66,$66663C00
;		dc.l	$00007C66,$667C6060,$00003E66,$663E0606	; 112
;		dc.l	$00007C66,$60606000,$00003E60,$3C067C00
;		dc.l	$00187E18,$18180E00,$00006666,$66663E00
;		dc.l	$00006666,$663C1800,$0000636B,$7F3E3600
;		dc.l	$0000663C,$183C6600,$00006666,$663E0C78
;		dc.l	$00007E0C,$18307E00,$0e181870,$18180e00
;		dc.l	$18181800,$18181800,$7018180e,$18187000
;		dc.l	$738c0000,$00000000,$aa55aa55,$aa55aa55
;		dc.l	$007e4242,$42427e00			; 128 (Quadr.)


ShiftTab:	dc.w	%1111111111111111
		dc.w	%0111111111111111
		dc.w	%0011111111111111
		dc.w	%0001111111111111
		dc.w	%0000111111111111
		dc.w	%0000011111111111
		dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
		dc.w	%0000000001111111
		dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
		dc.w	%0000000000000011
		dc.w	%0000000000000001

ClearTab:	dc.w	%1111111100000000
		dc.w	%1111111000000001
		dc.w	%1111110000000011
		dc.w	%1111100000000111
		dc.w	%1111000000001111
		dc.w	%1110000000011111
		dc.w	%1100000000111111
		dc.w	%1000000001111111
		dc.w	%0000000011111111

FontNewBob:	SETDATA	0
		SETFLAGS	BOBF_NOLIST|BOBF_NORESTORE|BOBF_NODOUBLE
		ENDE

NormAsciiTab:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		;	  ! " # $ % & ' ( ) * + , - . /
		dc.b	1,2,3,4,5,6,7,8,9,10,0,0,0,0,0,0
		;	0 1 2 3 4 5 6 7 8 9  : ; < = > ?
		dc.b	0,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
		;	@ A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
		dc.b	26,27,28,29,30,31,32,33,34,35,36
		;	P  Q  R  S  T  U  V  W  X  Y  Z	

		SECTION	MyBSS,BSS_C

DestColorMap:	DS.W	32

RawBuffer:	DS.B	250
EndBuffer:
Shift:		DS.B	2
	IFND	MINGFX
BlitData:	DS.W	16
	ENDC

Copper1:	DS.W	500
Copper2:	DS.W	500

GfxBase:	DS.B	gfx_SIZEOF
ScrList:	DS.B	lh_SIZEOF
