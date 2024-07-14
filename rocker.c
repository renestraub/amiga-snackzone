#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"

#define ROCKERGRENZE 440

extern	APTR	RockerMove,
				RockerAnim;

static	struct	SelectObject RockerSelect1,
							 RockerSelect10,
							 RockerSelect20,
							 RockerSelect30;

static	struct	Bob	*Rocker2_Bob;


void __regargs StoreRocker2(struct Bob *bob, LONG l)
{
	Rocker2_Bob = bob;
}

void __regargs RockerHandler(struct Bob *bob, LONG value)
{
	if((ElementList[el_Rocker].flag != Solved) && (MyBob->bob_X < ROCKERGRENZE))
		LeftLock = TRUE;
	else
		LeftLock = FALSE;

	if(ElementList[el_Rocker].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

void __regargs RockerCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Rocker].flag == Solved)		return;

	if(ElementList[el_Rocker].flag != Talked)
	{
		Select(&RockerSelect1,enemybob);
	}
	else
	{
		if(ElementList[el_FederInfo].flag == 1)		// Verchromt
		{
			Select(&RockerSelect10,enemybob);
			RemoveGadget(Feder);
			ElementList[el_FederInfo].flag = 0;
		}

		if(ElementList[el_FederInfo].flag == 2)		// Silber nicht 19"
		{
			Select(&RockerSelect20,enemybob);
			RemoveGadget(Feder);
			ElementList[el_FederInfo].flag = 0;
		}

		if(ElementList[el_FederInfo].flag == 3)		// Richtige Feder
		{
			Select(&RockerSelect30,enemybob);
			ElementList[el_Rocker].flag = Solved;

			SetMovePrg(enemybob,&RockerMove,1,2);
			SetAnimPrg(enemybob,&RockerAnim,1);

			RemoveGadget(Feder);
	
			RemBob(Rocker2_Bob);
		}
	}
	enemybob->bob_CollHandler = NULL;
}


void TalkedRocker(struct Bob *bob)
{
	ElementList[el_Rocker].flag = Talked;
}

// Versilbert 19"
static struct SelectObject RockerSelect30 =
{
	0,0,
	0,-28,

	"Gut gemacht Kleiner\n"
	"Die neue Feder\n"
	"bringt uns in 3\n"
	"Sekunden auf 200.\n"
};

// Versilbert != 19"
static struct SelectObject RockerSelect20 =
{
	0,0,
	0,-28,

	"\nOh Mann wir haben\n"
	"doch gesagt\n"
	"NEUNZEHN ZOLL !\n"
};

// Verchromt
static struct SelectObject RockerSelect10 =
{
	0,0,
	0,-28,

	"Du Schussel! Schleppst\n"
	"uns 'ne verchromte\n"
	"Feder an. Sollen wir\n"
	"uns die an 'nen Aus-\n"
	"puff schweissen ?"
};

static struct SelectObject RockerSelect4 =
{
	0,0,
	0,-28,

	"Du Depp! Das\n"
	"weiss doch jedes\n"
	"Kind. Nun schwirr\n"
	"ab und mach hin."
};

static struct SelectObject RockerSelect3 =
{
	0,0,
	0,-28,

	"Du organisierst\n"
	"uns eine 19 Zoll\n"
	"Kolbenrueckhol-\n"
	"feder",

	0,0,"Verchromt ?",&RockerSelect4,NULL,
	0,0,"Vesilbert ?",&RockerSelect4,NULL
};

static struct SelectObject RockerSelect2 =
{
	0,0,
	0,-28,

	"HA! HA! HA!\n"
	"Da haben wir\n"
	"aber Angst!"
};

static struct SelectObject RockerSelect1 =
{
	0,0,
	0,-28,

	"Halt Kleiner !\n"
	"Wenn Du hier vor-\n"
	"bei willst,musst\n"
	"Du uns erst eine\n"
	"Gefaelligkeit\n"
	"erweisen.",

	0,0,"Was fuer eine\n"
		"Gefaelligkeit?",&RockerSelect3,&TalkedRocker,
	0,0,"Verzieht euch\n"
		"oder ich hole\n"
		"die Bullen\n",&RockerSelect2,NULL
};
