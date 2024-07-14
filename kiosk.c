#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "select.h"
#include "show.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

static struct SelectObject KioskSelect1;

static void KioskRoutine(struct Screen *scr)
{
	struct	BitMap	*lastbm;
	short	oldxpos;

	oldxpos	   = MyBob->bob_X;
	MyBob->bob_X = 0;

	lastbm		= ActBitmap;
	ActBitmap	= &(scr->sc_Bitmap);

	Select(&KioskSelect1,NULL);

	MyBob->bob_X = oldxpos;
	ActBitmap	 = lastbm;
}


void __regargs Kiosk(struct Bob *bob)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		ShowIFF("Kiosk",&KioskRoutine,0);
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

static struct SelectObject KioskSelect2 =
{
	0,0,
	120,60,

	"Kaufen Sie doch 'mal\n"
	"das Bi-Fi Roll 3er\n"
	"Pack. Ihm liegen Tips\n"
	"zum Spielverlauf und\n"
	"der Stadtplan bei."
};

static struct SelectObject KioskSelect1 =
{
	-40,-10,
	180,80,

	"Moechten Sie die\n"
	"Nummer Eins unter\n"
	"den Snacks, oder\n"
	"lieber einen\n"
	"anderen ?",

	0,0,"Bi-fi Minisalami (1)",&KioskSelect2,&Kauf1,
	0,0,"Bi-fi Roll       (3)",&KioskSelect2,&Kauf3,
	0,0,"Bi-fi light      (1)",&KioskSelect2,&Kauf1,
	0,0,"Bi-fi Peperami   (2)",&KioskSelect2,&Kauf2,
	0,0,"Bi-fi Jumbo      (2)",&KioskSelect2,&Kauf2,
	0,0,"Sneakers Schoko  (1)",&KioskSelect2,&Kauf1,
	0,0,"Venus Schoko     (1)",&KioskSelect2,&Kauf1,
	0,0,"Blaupause        (1)",&KioskSelect2,&Kauf1,
	0,0,"Danke - nichts",NULL,NULL
};

