#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "select.h"
#include "show.h"
#include "panel.h"
#include "iff.h"
#include "drawbob.h"
#include "sound.h"

static struct SelectObject TankSelect1;

static void TankstelleRoutine(struct Screen *scr)
{
	struct	BitMap	*lastbm;
	short	oldxpos;

	oldxpos	   = MyBob->bob_X;
	MyBob->bob_X = 0;

	lastbm		= ActBitmap;
	ActBitmap	= &(scr->sc_Bitmap);

	Select(&TankSelect1,NULL);

	MyBob->bob_X = oldxpos;
	ActBitmap	 = lastbm;
}

void __regargs Tankstelle(struct Bob *bob)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		ShowIFF("Tankstelle",&TankstelleRoutine,0);
	}
}

static void Kauf1(struct Bob *bob)
{
	ChangeEnergy(4);
	ChangeMoney(-1);
	StartFX(3);
	ShowMoney();
}

static void Kauf2(struct Bob *bob)
{
	ChangeEnergy(8);
	ChangeMoney(-2);
	StartFX(3);
	ShowMoney();
}

static void Kauf3(struct Bob *bob)
{
	ChangeEnergy(12);
	ChangeMoney(-3);
	StartFX(3);
	ShowMoney();
}

static struct SelectObject TankSelect1 =
{
	0,0,
	140,80,

	"Moechten Sie die\n"
	"Nummer Eins unter\n"
	"den Snacks, oder\n"
	"lieber einen\n"
	"anderen ?",

	0,0,"Bi-fi Minisalami (1)",NULL,&Kauf1,
	0,0,"Bi-fi Roll       (3)",NULL,&Kauf3,
	0,0,"Bi-fi light      (1)",NULL,&Kauf1,
	0,0,"Bi-fi Peperami   (2)",NULL,&Kauf2,
	0,0,"Bi-fi Jumbo      (2)",NULL,&Kauf2,
	0,0,"Sneakers Schoko  (1)",NULL,&Kauf1,
	0,0,"Venus Schoko     (1)",NULL,&Kauf1,
	0,0,"Blaupause        (1)",NULL,&Kauf1,
	0,0,"Danke - nichts",NULL,NULL
};

