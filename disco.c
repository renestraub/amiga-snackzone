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
#include "show.h"

extern	void	__regargs DelayBlank(void);
extern	APTR	BigRonny,
				BigRonnyLeftAnim,
				BigRonnyLeftMove,
				BigRonnyRightAnim,
				BigRonnyRightMove;

extern	BYTE	MoveFlag;
extern	APTR	BigHeroBase;
extern	short	SpriteXPos;

static struct SelectObject	NightSelect1,
							SammlerSelect1,
							BarkeeperSelect1,
							ProfessorSelect1,
							ProfessorSelect2;


static struct NewScreen		discons = { 0,0,320,176,5,0,0,0,0 };

void NightInfo(struct Screen *scr)
{
	struct	BitMap	*lastbm;
	short	oldxpos;

	oldxpos	   = MyBob->bob_X;
	MyBob->bob_X = 0;

	lastbm		= ActBitmap;
	ActBitmap	= &(scr->sc_Bitmap);

	Select(&NightSelect1,NULL);

	MyBob->bob_X = oldxpos;
	ActBitmap	 = lastbm;
}


void __regargs DiscoGegenwart(void)
{
	ShowIFF("Disco",&NightInfo,0);

	if(ElementList[el_DiscoGegenwart].flag != Solved)
	{
		ChangeEnergy(10);
		ChangeEmotion(15);
		ElementList[el_DiscoGegenwart].flag = Solved;
	}
}


void __regargs DiscoFuture(struct Bob *bob, struct Bob *enemybob)
{
	struct	Screen	*myscreen;
	struct	BitMap	bitmap,
					bitmap2,
					*lastbitmap;
	struct	JoyInfo	joy;
	struct	Bob		*herobob;
	IFFFILE			picture;
	WORD			cmap[32];
	short			x_pos,
					oldx_pos;
	char			abort_flag,
					back_cnt,
					backpic_cnt;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	NoInt++;

	lastbitmap	= ActBitmap;
	oldx_pos	= MyBob->bob_X;
	MyBob->bob_X = 0;

	FadeOutCopper();

//	StartSong(0);

	ActBitmap  = &bitmap;
	InitBitmap( &bitmap,PictureBase,320,200,5 );
	InitBitmap( &bitmap2,&PictureBase[42000],320,130,5 );

	discons.ns_BitmStr = &bitmap;
	myscreen   = OpenScreen( &discons );

	picture    = LoadFastFile( "Disco" );
	GetColorTab( cmap,picture );
	DecodePic( &bitmap,picture );
	FreeMem( picture );

	picture	   = LoadFastFile( "DiscoBack" );
	DecodePic( &bitmap2,picture );
	FreeMem( picture );

	BigHeroBase = LoadFastFile("HeroBig");
	herobob     = AddBob(&BigRonny);
	herobob->bob_X = -28;
	herobob->bob_Y = 160;
	herobob->bob_Image = 0;

	InitBigSprite(myscreen);
	BigSpriteHandler(herobob);
	BigSpriteHandler(herobob);

	MoveFlag = TRUE;
	SetAnimPrg(herobob,&BigRonnyRightAnim,8);
	SetMovePrg(herobob,&BigRonnyRightMove,1,34);

	FadeIn(myscreen,cmap,125);

	abort_flag = FALSE;
	back_cnt = 0;
	backpic_cnt = 0;

	do
	{
		DelayBlank();
		WaitRaster(215);
		WaitRaster(216);

		BigSpriteHandler(herobob);

		if(back_cnt++ == 5)
		{
			back_cnt = 0;

			if(backpic_cnt++ == 4)	backpic_cnt = 0;

			BitBlit(&bitmap2,&bitmap,NULL,0,2+backpic_cnt*26,320,24,0,57);
		}

		if( !MoveFlag )
		{
			GetJoy( &joy );

			x_pos = SpriteXPos;

			if( joy.xdir == JOY_LEFT && herobob->bob_X)
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyLeftAnim,8);
				SetMovePrg(herobob,&BigRonnyLeftMove,1,34);

				herobob->bob_X--;
			}		

			if( joy.xdir == JOY_RIGHT && herobob->bob_X < 250 )
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyRightAnim,8);
				SetMovePrg(herobob,&BigRonnyRightMove,1,34);

				herobob->bob_X++;
			}		

			if(joy.ydir == JOY_UP)
			{
				if(x_pos > 270 && x_pos < 290)
				{
					Select(&BarkeeperSelect1,NULL);
				}

				if(x_pos > 210 && x_pos < 260)
				{
					if(	ElementList[el_Bedienteil].flag != Taken && ElementList[el_Kino].flag == Taken )
					{
						Select(&SammlerSelect1,NULL);
					}
				}

				if(x_pos > 150 && x_pos < 200)
				{
					if(ElementList[el_Sokoban].flag > 0)
					{
						Select(&ProfessorSelect1,NULL);
					} else {
						Select(&ProfessorSelect2,NULL);
					}
				}
			}
			if(x_pos < -10)	abort_flag = TRUE;
		}
		GetKey();
	}
	while(!abort_flag);

	RemBob( herobob );
	FreeMem( BigHeroBase );

	FadeOut( myscreen,125 );
	CloseScreen( myscreen );

	MyBob->bob_X = oldx_pos;
	ActBitmap = lastbitmap;

	SetUpLevel();
	UpDateBobs();

//	StartSong(4);

	SetCopperList( &CopperList );
	FadeInCopper();

	NoInt--;
}


// Wasser
void Drink1(struct Bob *bob)
{
	ChangeEnergy(7);
	ChangeMoney(-2);
	StartFX(3);
	ShowMoney();
}

// Spirit of Space
void Drink2(struct Bob *bob)
{
	ChangeEnergy(7);
	ChangeMoney(-3);
	StartFX(3);
	ShowMoney();
}

// Galaxy Cocktail
void Drink3(struct Bob *bob)
{
	ChangeEnergy(7);
	ChangeMoney(-4);
	StartFX(3);
	ShowMoney();
}

// Moon Mix
void Drink4(struct Bob *bob)
{
	ChangeEnergy(7);
	ChangeMoney(-5);
	StartFX(3);
	ShowMoney();
}

void SolvedSammler(struct Bob *bob)
{
	AddGadget(Zeitmaschine);
	ElementList[el_Bedienteil].flag = Taken;

	RemoveGadget(Kinokarte);
	ElementList[el_Kino].flag = Solved;
}

static struct SelectObject SammlerSelect5 =
{
	170,-45,
	165,75,

	"WAHNSINN!\n"
	"Eine Kinokarte von\n"
	"1993! Die ist un-\n"
	"bezhlbar. Tauschen\n"
	"Sie sie gegen ein\n"
	"Teil einer alten\n"
	"Zeitmaschine ?",

	0,0,"Okay",NULL,&SolvedSammler,
	0,0,"Nein, ich nehme\n"
		"nur Cash\n",NULL,NULL
};

static struct SelectObject SammlerSelect4 =
{
	165,-45,
	170,60,

	"Sie wollen mich\n"
	"verkohlen, dieser\n"
	"Film laeuft schon\n"
	"lange nicht mehr.\n",

	0,0,"Ich habe mir einen\n"
		"kleinen Scherz\n"
		"erlaubt",NULL,NULL,
	0,0,"Wenn Sie mir nicht\n"
		"glauben wollen,\n"
		"hier ist die Karte",&SammlerSelect5,NULL
};

static struct SelectObject SammlerSelect3 =
{
	165,-45,
	180,60,

	"Interesannt,ich\n"
	"sammle Kino-\n"
	"karten. Welchen\n"
	"Film haben Sie\n"
	"gesehen ?",

	0,0,"Das Schreien der\n"
		"Schafe",&SammlerSelect4,NULL,
	0,0,"Club der lebenden\n"
		"Poeten",&SammlerSelect4,NULL,
	0,0,"Das unbkleidete\n"
		"Geschuetz 3 1/2",&SammlerSelect4,NULL
};

static struct SelectObject SammlerSelect2 =
{
	0,0,
	210,50,

	"Schade, ich\n"
	"sammle Kino-\n"
	"karten",NULL,NULL
};

static struct SelectObject SammlerSelect1 =
{
	250,-55,
	220,60,

	"Hallo!\n"
	"Waren Sie\n"
	"in letzter\n"
	"Zeit im\n"
	"Kino ?",

	0,0,"Nein",&SammlerSelect2,NULL,
	0,0,"Ja",&SammlerSelect3,NULL
};


static struct SelectObject ProfessorSelect9 =
{
	0,0,
	0,80,

	"Bi-Fi Roll etwas nach rechts\n"
	"Venus nach mitte rechts\n"
	"Minisalami neben Bi-Fi Roll\n"
	"Peperami ein Feld nach oben\n"
	"und der Rest ist ein\n"
	"Kinderspiel\n"
};

static struct SelectObject ProfessorSelect8 =
{
	175,-50,
	0,90,

	"Nun.. verschieben Sie\n"
	"Sneakers nach miite unten\n"
	"Dubletto nach rechts\n"
	"neben Sneakers\n"
	"Peperami in die 2.Reihe\n"
	"nahe Minisalami\n"
	"Blaupause nach rechts\n"
	"neben Dubletto\n",

	0,0,"\nWeiter",&ProfessorSelect9,NULL
};

static struct SelectObject ProfessorSelect7 =
{
	0,0,
	0,90,

	"Nun.. verschieben Sie\n"
	"Aqua nach oben links\n"
	"Thai 1 Feld nach oben\n"
	"Plant nach links\n"
	"Ozeat 1 Feld links\n"
	"Thai nach oben rechts\n"
	"Ozeat nach unten links\n"
	"und der Rest ist\n"
	"einfach"
};

static struct SelectObject ProfessorSelect6 =
{
	0,0,
	0,90,

	"Nun.. verschieben Sie\n"
	"Dust nach unten links\n"
	"Silizi nach links\n"
	"Slimee nach unten rechts\n"
	"Dropiletten nach unten\n"
	"Powd nach unten links\n"
	"und schliesslich\n"
	"Gili nach rechts."
};

static struct SelectObject ProfessorSelect5 =
{
	0,0,
	160,75,

	"Dieses Raetsel ist\n"
	"wirklich einfach,\n"
	"versuchen Sie es\n"
	"selbst zu loesen.",NULL,NULL
};

static struct SelectObject ProfessorSelect4 =
{
	175,-50,
	150,75,

	"Klar,ich habe mich\n"
	"schon lange mit dem\n"
	"Museumswaerter unter-\n"
	"halten. In welchem\n"
	"Stockwerk haben Sie\n"
	"Probleme ?",

	0,0,"Im 1.Stock",&ProfessorSelect5,NULL,
	0,0,"Im 2.Stock",&ProfessorSelect5,NULL,
	0,0,"Im 3.Stock",&ProfessorSelect6,NULL,
	0,0,"Im 4.Stock",&ProfessorSelect7,NULL,
	0,0,"Im 5.Stock",&ProfessorSelect8,NULL,
};

static struct SelectObject ProfessorSelect3 =
{
	0,0,
	175,65,

	"Nein ich kenne\n"
	"kein Produktions-\n"
	"geheimnis.",NULL,NULL
};

static struct SelectObject ProfessorSelect2 =
{
	175,-43,
	185,65,

	"\nGuten Tag",

	0,0,"Ich suche das\n"
		"Bi-Fi Roll\n"
		"Produktions-\n"
		"geheimnis!\n"
		"Koennen Sie\n"
		"mir helfen ?",&ProfessorSelect3,NULL
};

static struct SelectObject ProfessorSelect1 =
{
	115,-40,
	185,65,

	"\nGuten Tag",

	0,0,"Ich suche das Bi-Fi Roll\n"
		"Produktionsgeheimnis!\n"
		"Koennen Sie mir helfen",&ProfessorSelect3,NULL,
	0,0,"Ich habe ein Problem\n"
		"im Snack-Museum. Sind\n"
		"Sie schon einmal dort\n"
		"gewesen ?\n",&ProfessorSelect4,NULL
};

static struct SelectObject BarkeeperSelect1 =
{
	145,-45,
	215,75,

	"Was moechten\n"
	"Sie trinken?\n",

	0,0,"Wasser..........2 ECU",0,&Drink1,
	0,0,"Spirit of Space.3 ECU",0,&Drink2,
	0,0,"Galaxy Cocktail.4 ECU",0,&Drink3,
	0,0,"Moon-Mix........5 ECU",0,&Drink4,
	0,0,"Danke nichts",NULL,NULL
};

static struct SelectObject NightSelect1 =
{
	0,0,
	190,70,

	"Was fuer eine\n"
	"Nacht !!"
};

