
/** CopperList ******************************************************************/

#define	CWAIT				1
#define	CEND				0xFFFE

/** Window Bits *****************************************************************/

#define	FOB_NOPROP			0
#define	FOF_NOPROP			1

#define	WNB_BORDERLESS		0
#define	WNB_NOBACKSAVE		1
#define	WNB_FASTTEXT		2
#define	WNB_TITEL			3

#define	WNF_BORDERLESS		1
#define	WNF_NOBACKSAVE		2
#define	WNF_FASTTEXT		4
#define	WNF_TITEL			8

#define DM_OR				0		/* DrawMode JAM (Clears Background) */
#define	DM_JAM				1		/* DrawMode OR */

/** Screen **********************************************************************/

#define	MAXSCRHEIGHT		261

#define SCB_CUSTOMBITMAP	0
#define SCF_CUSTOMBITMAP	1


/** ExtraCodes for 'Text' *******************************************************/

#define	FIRSTCODE	192
#define	LINEFEED	10		/* Insert LineFeed */
#define	SETCURSOR	194		/* Place Cursor */
#define	SETCOLOR	195		/* Set Color */
#define	LASTCODE	196		/* Last Code */

/** STRUCTUREs ******************************************************************/

typedef UBYTE *PLANEPTR;

struct BitMap
{
    UWORD   BytesPerRow;
    UWORD   Rows;
    UBYTE   Flags;
    UBYTE   Depth;
    UWORD   pad;
    PLANEPTR Planes[8];
};

struct GfxBase
{
	APTR	gfx_ScrList;
	APTR	gfx_ViewCpr;
	APTR	gfx_DrawCpr;
};

struct	Copper
{
	LONG	cpr_Wait1;
	LONG	cpr_OFF1;

	WORD	cpr_Plane1[8];
	WORD	cpr_Plane2[8];
	WORD	cpr_Plane3[8];
	WORD	cpr_Plane4[8];
	WORD	cpr_Plane5[8];
	WORD	cpr_Plane6[8];			/* BitPlanes */
	
	WORD	cpr_Sprite0[8];
	WORD	cpr_Sprite1[8];
	WORD	cpr_Sprite2[8];
	WORD	cpr_Sprite3[8];
	WORD	cpr_Sprite4[8];
	WORD	cpr_Sprite5[8];
	WORD	cpr_Sprite6[8];
	WORD	cpr_Sprite7[8];			/* Sprites */

	LONG	cpr_BplCon1;
	LONG	cpr_BplCon2;
	LONG	cpr_Bpl1Mod;
	LONG	cpr_Bpl2Mod;
	LONG	cpr_DiwStrt;
	LONG	cpr_DiwStop;
	LONG	cpr_DdfStrt;
	LONG	cpr_DdfStop;
	WORD	cpr_Colors[64];
	LONG	cpr_Wait2;
	LONG	cpr_ON;
	LONG	cpr_Wait3;
	LONG	cpr_OFF2;
	LONG	cpr_End;
};

struct	NewWindow
{
	WORD	nw_LeftEdge;		/* Left Edge */
	WORD	nw_TopEdge;			/* Top Edge */
	WORD	nw_Width;			/* Width in Pixels */			
	WORD	nw_Height;			/* Height in Pixels */
	BYTE	nw_APen;			/* APen */
	BYTE	nw_BPen;			/* BPen */
	WORD	nw_Flags;			/* WindowFlags */
	WORD	nw_DrawMode;		/* DrawMode */
	APTR	nw_Titel;			/* This Windows Titel */
	struct	NewFont *nw_Font;	/* The Font */
};

struct	NewScreen
{
	WORD	ns_LeftEdge;		/* LeftEdge */
	WORD	ns_TopEdge;			/* TopEdge */
	WORD	ns_Width;			/* Width in Pixels */
	WORD	ns_Height;			/* Height in Pixels */
	WORD	ns_Depth;			/* Depth */
	WORD	ns_ViewModes;		/* ViewModes (BPLCON0) */
	LONG	ns_Flags;			/* Flags */
	APTR	ns_BitmStr;
	APTR	ns_ColorMap;
};

struct Screen
{
	APTR	sc_NextScr;
	APTR	sc_LastScr;
	BYTE	sc_Type;
	BYTE	sc_Pri;
	APTR	sc_Name;

	WORD	sc_LeftEdge;				/* LeftEdge */
	WORD	sc_TopEdge;					/* TopEdge */
	WORD	sc_Width;					/* Width in Pixels */
	WORD	sc_Height;					/* Height in Pixels */
	WORD	sc_ViewModes;				/* ViewModes */
	LONG	sc_Flags;					/* Flags */

	LONG	sc_BitmapOffset;			/* Offset für Screen mit neg. YPos */
	struct	BitMap	sc_Bitmap;			/* BitmapStructure */
	WORD	sc_ColorMap[32];			/* ColorMap */
	struct	Copper	sc_CopperList;	/* CopperList */
};

struct Window
{
	APTR	wn_BitmStr;				/* This Windows BitMapSTRUCTURE */
	WORD	wn_XOrigin;				/* This Windows LeftEdge */
	WORD	wn_YOrigin;				/* This Windows TopEdge */
	WORD	wn_Width;				/* This Windows Width */
	WORD	wn_Height;				/* This Windows Height */
	WORD	wn_Flags;				/* Window Flags */
	WORD	wn_CursorX;				/* Actual CursorX (Pixels) */
	WORD	wn_CursorY;				/* Actual CursorY (Pixels) */
	BYTE	wn_APen;				/* Actual APen */
	BYTE	wn_BPen;				/* Actual BPen */
	WORD	wn_DrawMode;			/* Actual DrawMode */
	APTR	wn_SaveBack;			/* Buffer for Background */
	APTR	wn_Font;				/* This Windows Font */
};

struct NewFont
{
	WORD	nf_Width;			/* FontWidth (NonProportional Print) */
	WORD	nf_Height;			/* FontHeight */
	WORD	nf_SpaceWidth;		/* SpaceWidth */
	WORD	nf_XDist;			/* Distance beetwen Chars */
	WORD	nf_Flags;			/* FontFlags (NOPROP) */
	APTR	nf_Bob;				/* FontBob */
	APTR	nf_AsciiTab;		/* AsciiTab */
};

struct Font
{
	APTR	fo_Bob;				/* CharBob */
	APTR	fo_AsciiTab;		/* AsciiTab */
	WORD	fo_Width;			/* FontWidth */
	WORD	fo_Height;			/* FontHeight */
	WORD	fo_SpaceWidth;		/* SpaceWidth */
	WORD	fo_XDist;			/* Distance */
	WORD	fo_Flags;			/* FontFlags */
};

/** Prototypes ******************************************************************/

struct Screen * __regargs OpenScreen(struct NewScreen *);
void __regargs CloseScreen(struct Screen *);
void __regargs MoveScreen(struct Screen *, WORD, WORD);
void __regargs LoadRGB(struct Screen *, APTR);
void __regargs FadeIn(struct Screen *, APTR, WORD);
void __regargs FadeOut(struct Screen *,WORD);
void __regargs MergeCopper(void);

struct Window * __regargs OpenWindow(struct NewWindow *, struct BitMap *);
void __regargs CloseWindow(struct Window *);
void __regargs Move(struct Window *, WORD, WORD);
void __regargs Draw(struct Window *, WORD, WORD);
void __regargs Text(struct Window *, char *);
void __regargs Print(struct Window *, char *, APTR);
void __stdargs PrintAt(struct Window *, LONG, LONG, char *, ...);
void __regargs SetAPen(struct Window *,BYTE);
void __regargs SetBPen(struct Window *,BYTE);
BYTE __regargs GetAPen(struct Window *);
BYTE __regargs GetBPen(struct Window *);

void __asm SetDrawMode(register __a0 struct Window *,
					   register __d0 LONG );

void __asm ClrScr(register __a0 struct Window *);
void __asm RectFill(register __a0 struct Window *,
		    register __d0 WORD,
		    register __d1 WORD,
		    register __d2 WORD,
		    register __d3 WORD);

void __regargs DelayVBlank(void);
void __regargs RasterDelay(WORD);
void __regargs WaitRaster(WORD);

struct BitMap * __asm CreateBitmap(register __d0 WORD,
				   register __d1 WORD,
				   register __d2 WORD );

__asm InitBitmap(register __a0 struct BitMap *,
				 register __a1 APTR,
				 register __d0 WORD,
			 	 register __d1 WORD,
			 	 register __d2 WORD );

void __asm DeleteBitmap(register __a0 struct BitMap *);

void __asm BitBlit(register __a0 struct BitMap *,
		   register __a1 struct BitMap *,
		   register __a2 APTR,
		   register __d2 LONG,			// sx
		   register __d3 LONG,			// sy
		   register __d0 LONG,			// w
		   register __d1 LONG,			// h
		   register __d4 LONG,			// dx
		   register __d5 LONG );		// dy

void __asm GetData(register __a0 struct Window *,
		   register __a1 APTR,
		   register __d0 WORD,
		   register __d1 WORD,
		   register __d2 WORD,
		   register __d3 WORD );

void __asm PutData(register __a0 struct Window *,
		   register __a1 APTR,
		   register __d0 WORD,
		   register __d1 WORD,
		   register __d2 WORD,
		   register __d3 WORD );
		

void __regargs GetCustom(void);
void __asm InitGfx(void);
