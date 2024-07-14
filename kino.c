#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "panel.h"
#include "iff.h"
#include "bigsprite.h"
#include "drawbob.h"
#include "select.h"
#include "level.h"
#include "enemy.h"
#include "sound.h"

extern APTR BigRonny;
extern APTR	BigRonnyLeftAnim,BigRonnyLeftMove;
extern APTR	BigRonnyRightAnim,BigRonnyRightMove;

BYTE	MoveFlag;
APTR	BigHeroBase;

static struct SelectObject KinoSelect1;

static struct NewScreen kinons = { 0,0,320,176,5,0,0,0,0 };
static struct NewScreen automatns = { 0,55,320,86,5,0,0,0,0 };

static struct NewWindow kinown =
{
	0,0,320,200,
	17,0,
	WNF_NOBACKSAVE+WNF_BORDERLESS,
	DM_OR,
	0,
	0
};

#define SEGLEFT		79
#define SEGTOP		48
#define SEGWIDTH	19
#define SEGHEIGHT	34
#define COPYSEGLEFT	64
#define COPYSEGTOP	90
#define	SAVELEFT	20
#define	SAVETOP		40

#define SEGABSTAND	37
#define MAX_ITEMS	5

static void __regargs Automat(void)
{
	struct	Screen *myscreen;
	struct	Window *mywindow;
	struct	BitMap bitmap;
	struct	JoyInfo joy;
	IFFFILE	picture;
	WORD	cmap[32];
	short	lastpos,
			pos;
	char	abort;


	InitBitmap( &bitmap,&PictureBase[42000],320,125,5 );
	automatns.ns_BitmStr = &bitmap;
	myscreen = OpenScreen(&automatns);
	mywindow = OpenWindow(&kinown, &bitmap);
	SetAPen(mywindow,0);
	RectFill(mywindow,0,0,321,125);

	picture    = LoadFastFile("Automat");
	GetColorTab(cmap,picture);
	DecodePic(&bitmap,picture);
	FreeMem(picture);

	FadeIn(myscreen,cmap,125);

	abort      = FALSE;
	pos		   = 0;
	lastpos	   = -1;

	do
	{
		DelayBlank();
		GetKey();

		GetJoy(&joy);

		if(joy.xdir == JOY_LEFT && pos > 0)
		{
			while(joy.xdir == JOY_LEFT)	GetJoy(&joy);
			pos--;
		}

		if(joy.xdir == JOY_RIGHT && pos < (MAX_ITEMS-1))
		{
			while(joy.xdir == JOY_RIGHT)	GetJoy(&joy);
			pos++;
		}

		if(joy.ydir == JOY_UP || joy.ydir == JOY_DOWN)	abort = TRUE;


		if(!CheckJoy())
		{
			BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT+20,COPYSEGTOP,
					SEGWIDTH,SEGHEIGHT,SEGLEFT+pos*SEGABSTAND,SEGTOP);

			while(!CheckJoy());

			switch(pos)
			{
				case 0:
					if(ElementList[el_Kaugummi].flag != Solved)
					{
						StartFX(2);
						ChangeMoney(-1);
						AddGadget(Kaugummi);
						ElementList[el_Kaugummi].flag = Solved;
						abort = TRUE;
					}	
					break;

				case 1:
					if(ElementList[el_Eistee].flag != Solved)
					{
						StartFX(2);
						ChangeMoney(-2);
						AddGadget(Lipton);
						ElementList[el_Eistee].flag = Solved;
						abort = TRUE;
					}
					break;

				case 2:
					if(!ElementList[el_Kondom].flag)
					{
						StartFX(2);
						ChangeMoney(-1);
						AddGadget(Kondom);
						ElementList[el_Kondom].flag = Taken;
						abort = TRUE;
					}
					break;

				case 3:
					if(!ElementList[el_Strumpfhose].flag)
					{
						StartFX(2);
						ChangeMoney(-3);
						AddGadget(Strumpfhose);
						ElementList[el_Strumpfhose].flag = Taken;
						abort = TRUE;
					}					
					break;

				case 4:
					if(ElementList[el_Bifiroll].flag != Solved)
					{
						StartFX(2);
						ChangeMoney(-2);
						ChangeEnergy(10);
						ElementList[el_Bifiroll].flag = Solved;
						abort = TRUE;
					}
					break;
			}

			BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT,COPYSEGTOP,
					SEGWIDTH,SEGHEIGHT,SEGLEFT+pos*SEGABSTAND,SEGTOP);
		}

		if(lastpos != pos)
		{
			if(lastpos != -1)
			{
				// Clear Background (if saved)

				SetAPen(mywindow,0);
				RectFill(mywindow,SEGLEFT+lastpos*SEGABSTAND,SEGTOP,SEGWIDTH+1,SEGHEIGHT);
			}

			// Draw Hand

			BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT,COPYSEGTOP,
					SEGWIDTH,SEGHEIGHT,SEGLEFT+pos*SEGABSTAND,SEGTOP);

			lastpos = pos;
		}
	}
	while(!abort);

	FadeOut(myscreen,125);
	CloseScreen(myscreen);
}

void __regargs Kino(struct Bob *bob, struct Bob *enemybob)
{
	struct	Screen *myscreen;
	struct	BitMap bitmap,
				   *lastbitmap;
	struct	JoyInfo joy;
	struct	Bob *herobob;
	IFFFILE	picture;
	WORD	cmap[32];
	short	xpos,
			oldxpos;
	char	abort;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	NoInt++;

	lastbitmap = ActBitmap;
	oldxpos	   = MyBob->bob_X;
	MyBob->bob_X = 0;

	FadeOutCopper();

	StartSong(4);

	ActBitmap  = &bitmap;
	InitBitmap( &bitmap,PictureBase,320,176,5 );

	kinons.ns_BitmStr = &bitmap;
	myscreen   = OpenScreen( &kinons );

	picture    = LoadFastFile( "Kino" );
	GetColorTab( cmap,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	BigHeroBase = LoadFastFile("HeroBig");
	herobob    = AddBob(&BigRonny);
	herobob->bob_X = 260;

	InitBigSprite(myscreen);
	BigSpriteHandler(herobob);
	FadeIn(myscreen,cmap,125);

	abort      = FALSE;

	MoveFlag = TRUE;
	SetAnimPrg(herobob,&BigRonnyLeftAnim,8);
	SetMovePrg(herobob,&BigRonnyLeftMove,1,34);

	do
	{
		DelayBlank();
		WaitRaster(215);
		WaitRaster(216);

		BigSpriteHandler(herobob);

		if( !MoveFlag )
		{
			GetJoy( &joy );

			if( joy.xdir == JOY_LEFT && herobob->bob_X > 0)
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyLeftAnim,8);
				SetMovePrg(herobob,&BigRonnyLeftMove,1,34);

				herobob->bob_X--;
			}		

			if( joy.xdir == JOY_RIGHT )
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyRightAnim,8);
				SetMovePrg(herobob,&BigRonnyRightMove,1,34);

				herobob->bob_X++;
			}		

			xpos = herobob->bob_X;

			if(xpos > 0 && xpos < 80 && joy.ydir == JOY_UP)
			{
				FadeOut( myscreen,125 );
				ClearBigSprite( myscreen );
				Automat();
				InitBigSprite( myscreen );
				BigSpriteHandler( herobob );
				FadeIn( myscreen,cmap,125 );
			}
		
			if(xpos > 200 && xpos < 280 && joy.ydir == JOY_UP && ElementList[el_Kino].flag != Solved)
			{
				Select( &KinoSelect1,NULL );
			}

			if(xpos > 280)	abort = TRUE;
		}
		GetKey();
	}
	while(!abort);

	RemBob( herobob );
	FreeMem( BigHeroBase );

	FadeOut( myscreen,125 );
	CloseScreen( myscreen );

	MyBob->bob_X = oldxpos;
	ActBitmap = lastbitmap;

	SetUpLevel();
	UpDateBobs();

	StartSong(2);

	SetCopperList( &CopperList );
	FadeInCopper();

	NoInt--;
}


static void GetKarte(void)
{
	ElementList[el_Kino].flag = Taken;
	AddGadget(Kinokarte);
}

static void Kauf1(struct Bob *bob)
{
	ChangeMoney(-4);
	GetKarte();
}

static void Kauf2(struct Bob *bob)
{
	ChangeMoney(-5);
	GetKarte();
}

static void Kauf3(struct Bob *bob)
{
	ChangeMoney(-6);
	GetKarte();
}


static struct SelectObject KinoSelect3 =
{
	0,0,
	150,92,

	"Vor einer Woche hat\n"
	"schon einmal jemand\n"
	"versucht die Pro-\n"
	"duktionsunterlagen\n"
	"zu finden, ohne ins\n"
	"Kino zu gehen.\n"
	"Man hat nie wieder\n"
	"etwas von ihm ge-\n"
	"sehen oder gehoert."
};

static struct SelectObject KinoSelect2 =
{
	0,0,
	150,75,

	"Hier bitte.Hebe\n"
	"die Karte gut auf,\n"
	"vielleicht triffst\n"
	"Du 'mal einen\n"
	"Sammler."
};

static struct SelectObject KinoSelect1 =
{
	245,-45,
	0,0,

	NULL,

	0,0,"Film 1",&KinoSelect2,&Kauf1,
	0,0,"Film 2",&KinoSelect2,&Kauf2,
	0,0,"Film 3",&KinoSelect2,&Kauf3,
	0,0,"Nichts",&KinoSelect3,NULL
};
