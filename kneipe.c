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

extern void __regargs DelayBlank(void);

extern APTR BigRonny;
extern APTR	BigRonnyLeftAnim,BigRonnyLeftMove;
extern APTR	BigRonnyRightAnim,BigRonnyRightMove;

extern BYTE	MoveFlag;
extern APTR	BigHeroBase;

static struct SelectObject KneipeSelect1,
						   KneipeSelect2,
						   KneipeSelect5;

static struct NewScreen Kneipens = { 0,20,320,156,5,0,0,0,0 };

void __regargs Kneipe(struct Bob *bob, struct Bob *enemybob)
{
	struct	Screen		 *myscreen;
	struct	BitMap		 bitmap,
				  		 *lastbitmap;
	struct	JoyInfo		joy;
	struct	Bob *herobob;
	int  (*Paintgame)(	int,
						int,
						APTR,
						APTR,
						APTR,
						APTR);

	IFFFILE				picture;
	WORD				cmap[32];
	short				xpos,
						oldxpos,
						result;
	char				abort;


	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	NoInt++;

	lastbitmap = ActBitmap;
	oldxpos	   = MyBob->bob_X;
	MyBob->bob_X = 0;

	FadeOutCopper();

	InitBitmap( &bitmap, PictureBase, 320,156,5);
	ActBitmap  = &bitmap;

	picture    = LoadFastFile("Kneipe");
	GetColorTab(cmap,picture);
	DecodePic(&bitmap,picture);
	FreeMem(picture);

	Kneipens.ns_BitmStr = &bitmap;
	myscreen   = OpenScreen(&Kneipens);

	BigHeroBase = LoadFastFile("HeroBig");
	herobob    = AddBob(&BigRonny);
	herobob->bob_X = 240;

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

			if( joy.xdir == JOY_LEFT && herobob->bob_X > 50)
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyLeftAnim,8);
				SetMovePrg(herobob,&BigRonnyLeftMove,1,34);
			}		

			if( joy.xdir == JOY_RIGHT )
			{
				MoveFlag = TRUE;
				SetAnimPrg(herobob,&BigRonnyRightAnim,8);
				SetMovePrg(herobob,&BigRonnyRightMove,1,34);
			}		

			xpos = herobob->bob_X;

			if(xpos > 20 && xpos < 80 && joy.ydir == JOY_UP && ElementList[el_Videogamemuenze].flag == Taken)
			{
				FadeOut( myscreen,125 );
				ClearBigSprite( myscreen );

				StartSong(6);

				Paintgame = LoadSeg("PaintPrg");
				result = Paintgame(1,Processor,PictureBase,&PictureBase[42000],&StartFX,MyExecBase);
				UnLoadSeg(Paintgame);

				if(result==2)
				{
					ElementList[el_PaintSpiel].flag = Solved;
					ChangeEmotion(8);
				}

				InitBigSprite( myscreen );
				BigSpriteHandler( herobob );
				FadeIn( myscreen,cmap,125 );

				StartSong(2);
			}

			if(xpos > 160 && xpos < 260 && joy.ydir == JOY_UP)
			{
				if(ElementList[el_Ticket].flag != Solved)
				{
					if(ElementList[el_PaintSpiel].flag == Solved)
					{
						Select( &KneipeSelect2,NULL );
					} else {
						Select( &KneipeSelect1,NULL );
					}
				} else {
					Select( &KneipeSelect5,NULL );
				}
			}

			if(xpos > 260)	abort = TRUE;
		}
		GetKey();
	}
	while(!abort);

	RemBob(herobob);
	FreeMem(BigHeroBase);

	FadeOut(myscreen,125);
	CloseScreen(myscreen);

	MyBob->bob_X = oldxpos;
	ActBitmap = lastbitmap;

	SetUpLevel();
	UpDateBobs();

	SetCopperList(&CopperList);
	FadeInCopper();

	NoInt--;
}

void GetTicket(struct Bob *bob)
{
	ElementList[el_Ticket].flag = Solved;
	AddGadget(Ticket);
}

void KaufLimo(struct Bob *bob)
{
	ChangeEnergy(2);
	ChangeMoney(-1);
	StartFX(3);
	ShowMoney();
}

static struct SelectObject KneipeSelect5 =
{
	0,0,
	170,60,

	"Ich kann Dir\n"
	"leider nicht\n"
	"weiter helfen,\n"
	"Lukas."
};

static struct SelectObject KneipeSelect4 =
{
	185,-45,
	150,75,

	"Alle Achtung ! Hier\n"
	"nimm dieses Ticket.\n"
	"Es ist der Schluessel\n"
	"in die Zukunft. Tippe\n"
	"96 am Automaten,\n"
	"um es zu benutzen."
};

static struct SelectObject KneipeSelect3 =
{
	185,-45,
	150,75,

	"Wenn du meinen\n"
	"Highscore beim\n"
	"Painting Spiel\n"
	"schlaegst,\n"
	"werde ich\n"
	"Dir helfen."
};

// HighScore geschlagen

static struct SelectObject KneipeSelect2 =
{
	185,-45,
	0,0,

	NULL,

	0,0,"Hallo Joe, hast\n"
		"du einen Tip\n"
		"fuer mich ?",&KneipeSelect4,&GetTicket,
	0,0,"Eine Limonade\n"
		"Joe.\n",NULL,&KaufLimo
};

// Highscore nicht geschlagen

static struct SelectObject KneipeSelect1 =
{
	185,-45,
	0,0,

	NULL,

	0,0,"Hallo Joe, hast\n"
		"du einen Tip\n"
		"fuer mich ?",&KneipeSelect3,NULL,

	0,0,"Eine Limonade\n"
		"Joe.\n",NULL,&KaufLimo
};
