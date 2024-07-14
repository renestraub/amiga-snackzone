#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "iff.h"
#include "level.h"
#include "main.h"
#include "panel.h"
#include "copper.h"
#include "ubahn.h"
#include "sound.h"

#define	WAITCNT			200

#define	SEGTOP			18
#define	SEGLEFT			203
#define	SEGWIDTH		32
#define	SEGHEIGHT		23

#define	COPYSEGTOP		160
#define	COPYSEGLEFT		0

extern void __regargs DelayBlank(void);

static struct NewScreen ubahnns	  = { 0,10,320,178,5,0,0,0,0 };
static struct NewScreen automatns = { -16,15,320,160,5,0,0,0,0 };
static struct NewWindow automatwn =
{
	0,0,320,210,
	17,0,
	WNF_NOBACKSAVE+WNF_BORDERLESS,
	DM_OR,
	0,
	0
};

static struct Subway gegenwartsubwayinfo[] =
{
	1110,956,&Level3Tab,			// Königsalle
	130,0,&Level1Tab,				// 5th Avenue
	52,0,&Level6Tab,				// SnackStreet
	562,290,&Level8Tab,				// Eyberstrasse
	1746,1546,&Level4Tab,			// Baker Street
	52,0,&Level16Tab,				// SnackStreet FUTURE
};

static struct Subway futuresubwayinfo[] =
{
	1110,956,&Level13Tab,			// Königsalle
	148,0,&Level11Tab,				// 5th Avenue
	52,0,&Level16Tab,				// SnackStreet
	562,286,&Level18Tab,			// Eyberstrasse
	1846,1567,&Level14Tab,			// Baker Street
};

UWORD FutureColorMap[] =
{
   0x000,0xFFF,0xDDE,0xAAC,0x88B,0x669,0x448,0x336,
   0xF88,0xF66,0x833,0x500,0x007,0x00F,0x3E0,0xACF,
   0x8AC,0x996,0xDDA,0xFF0,0xAA0,0x909,0xF99,0xF04,
   0x698,0x6B8,0x688,0x688,0x355,0x008,0x055,0x222
}; 


static struct	Screen *myscreen;
static WORD	cmap[32];
static short SpeedTab1[] = {
	-2,13,		// Start FX Anfahr
	4,7,
	6,6,
	8,5,
	10,4,		// 10 * 4 VBlank speed
	15,3,
	20,2,
	50,1,
	20,2,
	15,3,
	-2,14,		// Start FX Brems
	10,4,
	8,5,
	6,6,
	4,7,
	-1
};

static short SpeedTab2[] = {
	-2,13,		// Start FX Anfahr
	4,7,
	6,6,
	8,5,
	10,4,		// 10 * 4 VBlank speed
	15,3,
	20,2,
	50,1,
	-1
};

static short SpeedTab3[] = {
	50,1,
	20,2,
	15,3,
	-2,14,		// Start FX Brems
	10,4,
	8,5,
	6,6,
	4,7,
	-1
};

static short PointTab[] = {
	227,92,
	220,106,
	213,120,
	206,134,
	199,148,
	280,COPYSEGTOP
};

// flag = 0 kein Zeitwechsel
// flag = 1 Wechsel Zukunft 1
// flag = 2 Wechsel Zukunft 2

void ColorCycle(short flag)
{
	WORD cnt,spd,len,swap,i,j,k;
	short *SpeedTab;

	switch(flag)
	{
		case 0:
			SpeedTab = SpeedTab1;
			break;

		case 1:
			SpeedTab = SpeedTab2;
			break;

		case 2:
			SpeedTab = SpeedTab3;
			break;
	}
	
	cnt = 0;

	do
	{
		len = SpeedTab[cnt++];
		spd = SpeedTab[cnt++];

		if(len == -1)	break;
		if(len == -2)
		{
			StartFX(spd);
			continue;
		}
	
		for(i=0;i<len;i++)
		{
			for(j=0;j<spd;j++)
			{
				GetKey();
				DelayBlank();
			}

			swap = cmap[31];
			for(k=31;k>8;k--)	cmap[k] = cmap[k-1];
			cmap[8] = swap;

			LoadRGB(myscreen,cmap);

			if( !flag && !CheckJoy())	break;
		}
		if( !flag && !CheckJoy() )	break;
	}
	while( 1 );
}

// flag = 0 kein Zeitwechsel
// flag = 1 Zeitwechsel

void __regargs ShowUBahn(short flag)
{
	struct	BitMap	bitmap1,
				  	bitmap2;
	IFFFILE			picture;
	short			cmap_l[32],
					cmap2[32],
					i;

	if(!flag)
	{
	 	InitBitmap(&bitmap1,PictureBase,320,178,5 );
		ubahnns.ns_BitmStr = &bitmap1;
		myscreen = OpenScreen(&ubahnns);

		if(TimeZone == GEGENWART)	picture = LoadFastFile("UBahn");
		else						picture = LoadFastFile("UBahn2");
		GetColorTab(cmap,picture);
		DecodePic(&bitmap1,picture);
		FreeMem(picture);

		FadeIn(myscreen,cmap,125);
		ColorCycle(flag);

		FadeOut(myscreen,125);
		CloseScreen(myscreen);
	}
	else
	{
	 	InitBitmap(&bitmap1,PictureBase,320,178,5 );
	 	InitBitmap(&bitmap2,&PictureBase[40000],320,178,5 );

		picture = LoadFastFile("UBahn");
		DecodePic(&bitmap1,picture);
		GetColorTab(cmap,picture);
		FreeMem(picture);

		picture = LoadFastFile("UBahn2");
		DecodePic(&bitmap2,picture);
		GetColorTab(cmap2,picture);
		FreeMem(picture);

		ubahnns.ns_BitmStr = &bitmap1;
		myscreen = OpenScreen(&ubahnns);
		FadeIn(myscreen,cmap,125);

		ColorCycle(1);

		for(i=0;i<32;i++)	cmap_l[i] = 0xFFF;
		FadeIn(myscreen,cmap_l,125);
		CloseScreen(myscreen);
		
		for(i=0;i<32;i++)	cmap[i] = cmap2[i];
		FadeIn(myscreen,cmap,250);
		ubahnns.ns_BitmStr = &bitmap2;
		myscreen = OpenScreen(&ubahnns);

		ColorCycle(2);

		FadeOut(myscreen,125);
		CloseScreen(myscreen);
	}
}

void __regargs Fahrkarte(void)
{
	struct	Screen *myscreen;
	struct	Window *mywindow;
	struct	BitMap bitmap;
	struct	Subway *subinfo;
	struct	JoyInfo joy;
	IFFFILE	picture;
	WORD	cmap[32];
	short	line,
			lastline,
			ownline;
	char	key,
			key1,
			key2,
			abort;
			
	NoInt++;

	FadeOutCopper();

	InitBitmap( &bitmap,PictureBase,320,184,5 );
	ClearMem( PictureBase,40*184*5 );
	automatns.ns_BitmStr = &bitmap;
	myscreen = OpenScreen( &automatns );
	mywindow = OpenWindow( &automatwn,&bitmap );

	picture  = LoadFastFile("Fahrkarte");
	GetColorTab(cmap,picture);
	DecodePic(&bitmap,picture);
	FreeMem(picture);

	if( TimeZone == GEGENWART )
		FadeIn( myscreen,cmap,125 );
	else
		FadeIn( myscreen,FutureColorMap,125 );

	RasterDelay( 1000 );

	line	 = -1;
	lastline = -1;
	ownline  = ActLevelPtr->UBahnLinie;

	key1     = 0;
	key2     = 0;
	abort    = FALSE;

	do
	{
		RasterDelay(1000);
	
		key = GetKey();
		if(key)
		{
			key1 = key2;
			key2 = key;
		}

		if(key1 == '1' && key2 == '0')	line = 0;
		if(key1 == '1' && key2 == '3')	line = 1;
		if(key1 == '1' && key2 == '7')	line = 2;
		if(key1 == '2' && key2 == '3')	line = 3;
		if(key1 == '2' && key2 == '4')	line = 4;
	
		if(TimeZone == GEGENWART && ElementList[el_Ticket].flag == Solved)
		{
			if(key1 == '9' && key2 == '6')	line = 5;
		}

		GetJoy(&joy);

		if(joy.ydir == JOY_DOWN && line < 4)
		{
			while(joy.ydir == JOY_DOWN)	GetJoy(&joy);
			line++;
		}

		if(joy.ydir == JOY_UP   && line > 0)
		{
			while(joy.ydir == JOY_UP)	GetJoy(&joy);
			line--;
		}

		if(line != lastline)
		{
			/* Draw 7 Digit Display */

			BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT+SEGWIDTH*line,COPYSEGTOP,
				    SEGWIDTH,SEGHEIGHT,SEGLEFT,SEGTOP);

			/* Draw Red Point indicating destination */

			SetAPen(mywindow,0);
			RectFill(mywindow,PointTab[lastline*2],PointTab[lastline*2+1],4,3);
			BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT+1+6*SEGWIDTH,COPYSEGTOP,
				    3,3,PointTab[line*2],PointTab[line*2+1]);

			lastline = line;
			key1 = key2 = 0;
		}

		if((line >= 0) && (!CheckJoy() || key=='\n'))	abort = TRUE;
	}
	while(!abort);

	FadeOut(myscreen,125);
	CloseScreen(myscreen);

	if(line >= 0 && line < 6)
	{
		if(TimeZone == GEGENWART)	subinfo = gegenwartsubwayinfo;
		else						subinfo = futuresubwayinfo;

		NextLevelPtr 		 = subinfo[line].NewLevel;
		NextLevelPtr->LevelX = subinfo[line].LevelX;
		NextLevelPtr->RonnyX = subinfo[line].BobX;

		if(line != ownline)
		{
			StartSong(7);

			if(line==5)	
			{
				TimeZone = ZUKUNFT;
				ShowUBahn(1);
				RemoveGadget(Ticket);
			}	
			else
				ShowUBahn(0);

			if(TimeZone == ZUKUNFT)
				StartSong(0);
			else
				StartSong(2);
		}
	}

	SetCopperList(&CopperList);

	NoInt--;
}
