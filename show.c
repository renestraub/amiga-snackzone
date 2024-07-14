#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "iff.h"
#include "level.h"
#include "enemy.h"

extern	void __regargs DelayBlank(void);
		void CyclePosition(struct Screen *scr);

static	struct	NewScreen	ns = { 0,0,320,200,5,0,0,0,0 };

UWORD	futuremap[] =
{
   0x111,0xBCE,0x055,0x204,0x400,0x215,0x334,0x088,
   0x720,0xFFF,0x357,0x518,0x711,0x0BB,0x567,0x419,
   0x48A,0x349,0x17B,0x0DD,0xA10,0x679,0x52B,0x13B,
   0x46B,0xC10,0x79B,0xA89,0x22C,0x54D,0x89C,0xABD
}; 

void __regargs ShowIFF(char *FileName, void (*Handler)(struct Screen *), LONG l)
{
	struct	Screen *scr;
	struct	BitMap bitmap;
	IFFFILE	picture;
	UWORD	cmap[32],
			i;

	if(!l)
	{
		NoInt++;
		FadeOutCopper();
	}

	ClearMem( PictureBase,40000 );
	InitBitmap( &bitmap,PictureBase,320,200,5 );
	ns.ns_BitmStr = &bitmap;
	scr = OpenScreen( &ns );

	if( FileName )
	{
		picture = LoadFastFile( FileName );

		if( Handler == &CyclePosition && TimeZone == ZUKUNFT)
		{
			for(i=0;i<32;i++)	cmap[i] = futuremap[i];
		} else {
			GetColorTab( cmap,picture );
		}
		DecodePic( &bitmap,picture );
		FreeMem( picture );
	}

	FadeIn( scr,cmap,200 );

	if(Handler)
	{
		Handler(scr);
	}
	else
	{
		while(CheckJoy()) 
		{
			DelayBlank();
			GetKey();
		}
	}

	FadeOut( scr,125 );
	CloseScreen( scr );

	if(!l)
	{
		SetUpLevel();
		UpDateBobs();
	
		NoInt--;
		SetCopperList(&CopperList);
		FadeInCopper();
	}
}

void CyclePosition(struct Screen *scr)
{
	WORD	cmap[32];
	WORD	*Color;
	short	i,
			dir;

	for(i=0;i<32;i++)	cmap[i] = scr->sc_ColorMap[i];

	Color   = &(scr->sc_ColorMap[9]);
	dir		= 0;

	do
	{
		DelayBlank();
		GetKey();

		if( dir == 1 )
		{
			cmap[9] += 0x111;
			if(cmap[9] == 0xFFF)	dir = 0;
		} else {
			cmap[9] -= 0x111;
			if(cmap[9] == 0x000)	dir = 1;
		}
	
		LoadRGB(scr,cmap);
	}
	while(CheckJoy());
}

void __regargs ShowKarte(void)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		ShowIFF("Karte",&CyclePosition,0);
	}
}

void __regargs ShowSupermarkt(void)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		ShowIFF("Supermarkt",NULL,0);
	}
}
