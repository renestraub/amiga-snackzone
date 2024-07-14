#include "myexec.h"
#include "gfx.h"
#include "definitions.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "panel.h"
#include "iff.h"
#include "select.h"
#include "level.h"
#include "enemy.h"
#include "sound.h"
#include "drawbob.h"
#include "show.h"

static struct SelectObject	WaerterSelect1,
							WaerterSelect3,
							WaerterSelect10,
							WaerterSelect12,
							WaerterSelect20;

static	struct	NewScreen 	museumns = { 0,30,320,142,5,0,0,0,0 };
static	struct	NewScreen 	waerterns = { 0,15,320,160,5,0,0,0,0 };
static	struct	NewScreen 	zeitns = { 0,5,320,175,5,0,0,0,0 };

static	struct	Screen		*myscreen;
static	struct	BitMap		bitmap,
							*lastbitmap;
static	short				cmap[32];
static	char				abortflag;

#define SEGLEFT		162
#define SEGTOP		93
#define SEGWIDTH	16
#define SEGHEIGHT	14

#define COPYSEGLEFT	108
#define COPYSEGTOP	145
#define SEGABSTAND	17

void GoBack(void)
{
	struct	Screen	*zscr;
	struct	BitMap	bitmap;
	IFFFILE			picture;
	short			cmap_l[32],
					i;

	InitBitmap( &bitmap,PictureBase,320,200,5 );
	ClearMem(PictureBase,40000);

	zeitns.ns_BitmStr = &bitmap;
	zscr = OpenScreen( &zeitns );

	picture = LoadFastFile( "Zeitmaschine" );
	GetColorTab( cmap_l,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	FadeIn(zscr,cmap_l,125);
	for(i=0;i<32;i++)	cmap_l[i] = 0xFFF;

	StartFX(17);

	for(i=0;i<130;i++)
	{
		RasterDelay(Random(300)+1);
		MoveScreen(zscr,0,-5);
		MoveScreen(zscr,0,-5);
		MoveScreen(zscr,0,-5);
		MoveScreen(zscr,0,-5);
		RasterDelay(Random(300)+1);
		MoveScreen(zscr,0,5);
		MoveScreen(zscr,0,5);
		MoveScreen(zscr,0,5);
		MoveScreen(zscr,0,5);
	}
	StartFX(16);		// FX Off

	FadeIn(zscr,cmap_l,1000);
	FadeOut(zscr,125);

	CloseScreen(zscr);
}


// Falscher Sound bei Rueckkehr

void Waerter(void)
{
	struct	Screen	*wscr;
	struct	BitMap	bitmap,
					*lastbm;
	
	IFFFILE			picture;
	short			cmap_l[32];

	FadeOut(myscreen,125);
	lastbm = ActBitmap;
	ActBitmap = &bitmap;

	InitBitmap( &bitmap,PictureBase,320,200,5 );
	ClearMem(PictureBase,40000);

	waerterns.ns_BitmStr = &bitmap;
	wscr = OpenScreen( &waerterns );

	picture = LoadFastFile( "Mann" );
	GetColorTab( cmap_l,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	FadeIn(wscr,cmap_l,125);

	if(ElementList[el_Sokoban].flag == 5)
	{
		if(ElementList[el_Bedienteil].flag == Taken)
		{
			Select(&WaerterSelect10,NULL);

			FadeOut(wscr,125);
			GoBack();
				
			NextLevelPtr	 	 = &Level6Tab;
			NextLevelPtr->LevelX = 0;
			NextLevelPtr->RonnyX = 100;

			EndFlag = CHANGE_LEVEL;
			TimeZone = GEGENWART;

			abortflag = TRUE;
		} else {
			Select(&WaerterSelect20,NULL);
		}		
	}
	else
	{
		if(ElementList[el_Waerter].flag == Solved)
		{
			Select(&WaerterSelect3,NULL);
		} else {
			Select(&WaerterSelect1,NULL);
			ElementList[el_Waerter].flag = Solved;
		}
	}

	FadeOut(wscr,125);
	CloseScreen(wscr);

	if(EndFlag != CHANGE_LEVEL)
	{
		FadeIn(myscreen,cmap,125);
	}

	ActBitmap	 = lastbm;
}

void StartSokoban(int level)
{
	IFFFILE	picture;
	int		result;
	int  	(*sokoban)(  int,
						 APTR,
						 APTR,
						 APTR,
						 APTR);

	FadeOut(myscreen,125);
	StartSong(4);

	sokoban = LoadSeg("Sokoban");
	result = sokoban(level,PictureBase,&PictureBase[42000],&StartFX,MyExecBase);
	UnLoadSeg(sokoban);

	ClearMem(&PictureBase[42000],40000);
	picture = LoadFastFile( "Lift" );
	GetColorTab( cmap,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	FadeIn(myscreen,cmap,125);
	StartSong(7);

	if((result & 2) == 2)
	{
		level++;

		if(level > ElementList[el_Sokoban].flag)
			ElementList[el_Sokoban].flag = level;

	}
	if((result & 4) == 4)
		AddGadget(Patent);
}

void __regargs Museum(struct Bob *bob, struct Bob *enemybob)
{
	struct	JoyInfo joy;
	IFFFILE	picture;
	short	oldxpos,
			etage,
			maxetage,
			lastetage;
	char	abort;	

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	NoInt++;

	lastbitmap = ActBitmap;
	oldxpos	= MyBob->bob_X;
	MyBob->bob_X = 0;

	FadeOutCopper();
	StartSong(7);

	ActBitmap = &bitmap;
	InitBitmap( &bitmap,&PictureBase[42000],320,162,5 );
	ClearMem(&PictureBase[42000],40000);

	museumns.ns_BitmStr = &bitmap;
	myscreen = OpenScreen( &museumns );

	picture = LoadFastFile( "Lift" );
	GetColorTab( cmap,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT+1*SEGABSTAND,COPYSEGTOP,
			SEGWIDTH,SEGHEIGHT,SEGLEFT,SEGTOP);

	FadeIn(myscreen,cmap,125);

	abortflag = FALSE;

	do
	{
		abort = FALSE;
		lastetage  = -1;		/* Undef */
		etage = 1;

		if(ElementList[el_Waerter].flag != Solved)
			maxetage = 1;
		else
		{
			maxetage = ElementList[el_Sokoban].flag + 2;
			etage = maxetage-1;
		}

		if(maxetage > 6)	maxetage = 6;

		do
		{
			if(etage != lastetage)	// Display ändern
			{
				if(lastetage != -1)
				{
					StartFX(11);
					RasterDelay(300*10);
				}
				BitBlit(&bitmap,&bitmap,NULL,COPYSEGLEFT+etage*SEGABSTAND,COPYSEGTOP,
						SEGWIDTH,SEGHEIGHT,SEGLEFT,SEGTOP);
				StartFX(12);

				lastetage = etage;
			}

			GetKey();
			GetJoy(&joy);
	
			if( joy.ydir == JOY_UP && etage < maxetage )
			{
				while(joy.ydir == JOY_UP)	GetJoy(&joy);
				etage++;
			}
	
			if(joy.ydir == JOY_DOWN && etage > 0 )
			{
				while(joy.ydir == JOY_DOWN)	GetJoy(&joy);
				etage--;
			}
			if(!CheckJoy())	abort = TRUE;
		}
		while(!abort);

		switch(etage)
		{
			case 0:						// U1
				Waerter();
				break;
		
			case 1:						// EG
				abortflag = TRUE;
				break;

			case 2:						// O1
				StartSokoban(0);
				break;

			case 3:						// O2
				StartSokoban(1);
				break;

			case 4:						// O3
				StartSokoban(2);
				break;

			case 5:						// O4
				StartSokoban(3);
				break;

			case 6:						// O5
				StartSokoban(4);
				break;
		}
	}
	while(!abortflag);

	FadeOut( myscreen,125 );
	CloseScreen( myscreen );

	if(EndFlag != CHANGE_LEVEL)
	{
		MyBob->bob_X = oldxpos;
		ActBitmap = lastbitmap;

		SetUpLevel();
		UpDateBobs();

		StartSong(0);
		SetCopperList( &CopperList );
		FadeInCopper();
	}
	else
		StartSong(2);

	NoInt--;
}


static struct SelectObject WaerterSelect20 =
{
	80,-40,
	120,100,

	"Vielen Dank fuer Ihre\n"
	"Hilfe. Die alte Zeit-\n"
	"maschine steht Ihnen\n"
	"zur Verfuegung. Leider\n"
	"fehlt ein Teil am\n"
	"Armaturenbrett. Haben\n"
	"Sie es schon gefunden?",

	0,0,"Nein leider\n"
		"nicht.",&WaerterSelect12,NULL
};


static struct SelectObject WaerterSelect12 =
{
	0,0,
	120,100,

	"Suchen Sie in der\n"
	"Stadt. Es muss sich\n"
	"irgendwo dort be-\n"
	"finden."
};

static struct SelectObject WaerterSelect11 =
{
	0,0,
	120,100,

	"Dann wuensche ich\n"
	"Ihnen eine angenehme\n"
	"Zeitreise."
};

static struct SelectObject WaerterSelect10 =
{
	80,-40,
	120,80,

	"Vielen Dank fuer Ihre\n"
	"Hilfe. Die alte Zeit-\n"
	"maschine steht Ihnen\n"
	"zur Verfuegung. Leider\n"
	"fehlt ein Teil am\n"
	"Armaturenbrett. Haben\n"
	"Sie es schon gefunden?",

	0,0,"Ja, hier\n"
		"ist es",&WaerterSelect11,NULL,
};

static struct SelectObject WaerterSelect3 =
{
	0,0,
	120,90,

	"Geben Sie nicht auf,\n"
	"versuchen Sie es\n"
	"weiter."
};

static struct SelectObject WaerterSelect2 =
{
	0,0,
	120,90,

	"Schieben Sie die\n"
	"Vitrinen wieder an\n"
	"die richtigen Stellen\n"
	"und ich ueberlasse\n"
	"Ihnen meine antike\n"
	"Zeitmaschine fuer die\n"
	"Rueckkehr. Beginnen\n"
	"Sie im 1. Stock."
};

static struct SelectObject WaerterSelect1 =
{
	-5,-25,
	130,95,

	"Aah endlich wieder ein\n"
	"Gast. Unsere letzten\n"
	"Besucher haben uns vor\n"
	"3 Jahren das ganze\n"
	"Haus durcheinander\n"
	"gebracht. So wie sie\n"
	"gekleidet sind,muessen\n"
	"Sie ein Zeitreisender\n"
	"sein.",

	0,0,"Wer? ich? Nein",NULL,NULL,
	0,0,"Ja stimmt, ich\n"
		"suche die\n"
		"Produktions-\n"
		"unterlagen der\n"
		"Bi-fi Roll",&WaerterSelect2,NULL
};
