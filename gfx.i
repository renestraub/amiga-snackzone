

	IFD GFX_S
	 XDEF	InitGfx,GfxBase
	 XDEF	SetAPen,SetBPen,SetDrawMode,Move
	 XDEF	ReadPixel,WritePixel,Draw,RectFill
	 XDEF	PutData,GetData
	 XDEF	Text,MidText,RightText,Print,StrLen
	 XDEF	OpenWindow,CloseWindow,ClearWindow
	 XDEF	OpenScreen,CloseScreen,LoadRGB,MoveScreen,MergeCopper
	 XDEF	OpenFont,CloseFont
	 XDEF	FadeOut,FadeIn
	 XDEF	RasterDelay,WaitRaster,DelayVBlank
	 XDEF	CreateBitmap,DeleteBitmap,InitBitmap
	 XDEF	BitBlit
	 XDEF	SetValue,SetLongValue

	 XDEF	@OpenScreen,@OpenWindow,@CloseScreen,@MoveScreen,@RasterDelay
	 XDEF	@LoadRGB,@DelayVBlank,@CloseWindow,@Move,@Print,@Text
	 XDEF	@WaitRaster,@FadeIn,@FadeOut
	 XDEF	_RectFill,@SetAPen,@SetBPen,@GetAPen,@GetBPen
	 XDEF	@Draw,@GetCustom
	 XDEF	@MergeCopper
	 XDEF	_CreateBitmap,_DeleteBitmap,_InitBitmap,_ClearWindow
	 XDEF	_PrintAt
	 XDEF	_GetData,_PutData
	 XDEF	_BitBlit
	 XDEF	_InitGfx
	 XDEF	_SetDrawMode
	ENDC

	IFND GFX_S
	 XREF	InitGfx,GfxBase
	 XREF	SetAPen,SetBPen,SetDrawMode,Move
	 XREF	ReadPixel,WritePixel,Draw,RectFill
	 XREF	PutData,GetData
	 XREF	Text,MidText,RightText,Print,StrLen
	 XREF	OpenWindow,CloseWindow,ClearWindow
	 XREF	OpenScreen,CloseScreen,LoadRGB,MoveScreen,MergeCopper
	 XREF	OpenFont,CloseFont
	 XREF	FadeOut,FadeIn
	 XREF	RasterDelay,WaitRaster
	 XREF	CreateBitmap,DeleteBitmap,InitBitmap
	 XREF	SetValue,SetLongValue
	ENDC


*** CopperList ******************************************************************

CWAIT:	EQU	1
CEND:	EQU	$FFFE

*** Window Bits *****************************************************************

	BITDEF	FO,NOPROP,0			* No Proportional Text

	BITDEF	WN,BORDERLESS,0			* Windows with no border
	BITDEF	WN,NOBACKSAVE,1			* Don't save Background
	BITDEF	WN,FASTTEXT,2			* FastPrint (1 Bitmap)
	BITDEF	WN,TITEL,3			* Window has Titel

DM_OR:	EQU	0			* DrawMode JAM (Clears Background)
DM_JAM:	EQU	1			* DrawMode OR

*** Screen **********************************************************************

MAXSCRHEIGHT:		EQU	261

SCB_CUSTOMBITMAP:	EQU	0
SCF_CUSTOMBITMAP:	EQU	1

*** ExtraCodes for 'Text' ***************************************************** 

FIRSTCODE:	EQU	192
LINEFEED:	EQU	10		* Insert LineFeed
SETCURSOR:	EQU	194		* Place Cursor
SETCOLOR:	EQU	195		* Set Color
LASTCODE:	EQU	196		* Last Code

*** STRUCTUREs ******************************************************************
	
  STRUCTURE StrctGfxBase,0
	LONG	gfx_ScrList
	LONG	gfx_ViewCpr
	LONG	gfx_DrawCpr
	LABEL	gfx_SIZEOF

  STRUCTURE StrctCopper,0
	LONG	cpr_Wait1
	LONG	cpr_OFF1
	STRUCT	cpr_Plane1,8
	STRUCT	cpr_Plane2,8
	STRUCT	cpr_Plane3,8
	STRUCT	cpr_Plane4,8
	STRUCT	cpr_Plane5,8
	STRUCT	cpr_Plane6,8			* BitPlanes
	STRUCT	cpr_Sprite0,8
	STRUCT	cpr_Sprite1,8
	STRUCT	cpr_Sprite2,8
	STRUCT	cpr_Sprite3,8
	STRUCT	cpr_Sprite4,8
	STRUCT	cpr_Sprite5,8
	STRUCT	cpr_Sprite6,8
	STRUCT	cpr_Sprite7,8			* Sprites
	LONG	cpr_BplCon1
	LONG	cpr_BplCon2
	LONG	cpr_Bpl1Mod
	LONG	cpr_Bpl2Mod
	LONG	cpr_DiwStrt
	LONG	cpr_DiwStop
	LONG	cpr_DdfStrt
	LONG	cpr_DdfStop
	STRUCT	cpr_Colors,128
	LONG	cpr_Wait2
	LONG	cpr_ON
	LONG	cpr_Wait3
	LONG	cpr_OFF2
	LONG	cpr_End
	LABEL	cpr_SIZEOF

  STRUCTURE StrctNewWindow,0			* NewWindow STRUCTURE
	WORD	nw_LeftEdge			* Left Edge	
	WORD	nw_TopEdge			* Top Edge
	WORD	nw_Width			* Width in Pixels				
	WORD	nw_Height			* Height in Pixels
	BYTE	nw_APen				* APen
	BYTE	nw_BPen				* BPen
	WORD	nw_Flags			* WindowFlags
	WORD	nw_DrawMode			* DrawMode
	APTR	nw_Titel			* This Windows Titel
	APTR	nw_Font
	LABEL	nw_SIZEOF

  STRUCTURE StrctNewScreen,0			* NewScreen STRUCTURE
	WORD	ns_LeftEdge			* LeftEdge
	WORD	ns_TopEdge			* TopEdge
	WORD	ns_Width			* Width in Pixels
	WORD	ns_Height			* Height in Pixels
	WORD	ns_Depth			* Depth
	WORD	ns_ViewModes			* ViewModes (BPLCON0)
	LONG	ns_Flags			* The Flags
	APTR	ns_BitmStr
	APTR	ns_ColorMap
	LABEL	ns_SIZEOF

  STRUCTURE StrctScreen,0			* NewScreen STRUCTURE
	APTR	sc_NextScr
	APTR	sc_LastScr
	BYTE	sc_Type
	BYTE	sc_Pri
	APTR	sc_Name

	WORD	sc_LeftEdge			* LeftEdge
	WORD	sc_TopEdge			* TopEdge
	WORD	sc_Width			* Width in Pixels
	WORD	sc_Height			* Height in Pixels
	WORD	sc_ViewModes			* ViewModes
	LONG	sc_Flags			* Flags

	LONG	sc_BitmapOffset			* Offset für Screen mit neg. YPos
	STRUCT	sc_Bitmap,bm_SIZEOF		* BitmapStructure
	STRUCT	sc_ColorMap,64			* ColorMap
	STRUCT	sc_CopperList,cpr_SIZEOF	* CopperList
	LABEL	sc_SIZEOF

  STRUCTURE StrctWindow,0
	APTR	wn_BitmStr			* This Windows BitMapSTRUCTURE
	WORD	wn_XOrigin			* This Windows LeftEdge
	WORD	wn_YOrigin			* This Windows TopEdge
	WORD	wn_Width			* This Windows Width
	WORD	wn_Height			* This Windows Height
	WORD	wn_Flags			* Window Flags
	WORD	wn_CursorX			* Actual CursorX (Pixels)
	WORD	wn_CursorY			* Actual CursorY (Pixels)
	BYTE	wn_APen				* Actual APen
	BYTE	wn_BPen				* Actual BPen
	WORD	wn_DrawMode			* Actual DrawMode
	APTR	wn_SaveBack			* Buffer for Background
	APTR	wn_Font				* This Windows Font
	LABEL	wn_SIZEOF

  STRUCTURE StrctNewFont,0
	WORD	nf_Width			* FontWidth (NonProportional Print)
	WORD	nf_Height			* FontHeight
	WORD	nf_SpaceWidth			* SpaceWidth
	WORD	nf_XDist			* Distance beetwen Chars
	WORD	nf_Flags			* FontFlags (NOPROP)
	APTR	nf_Bob				* FontBob
	APTR	nf_AsciiTab			* AsciiTab
	LABEL	nf_SIZEOF

  STRUCTURE StrctFont,0
	APTR	fo_Bob				* CharBob
	APTR	fo_AsciiTab			* AsciiTab
	WORD	fo_Width			* FontWidth
	WORD	fo_Height			* FontHeight
	WORD	fo_SpaceWidth			* SpaceWidth
	WORD	fo_XDist			* Distance
	WORD	fo_Flags			* FontFlags
	LABEL	fo_SIZEOF

*******************************************************************************
