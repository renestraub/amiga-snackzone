#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"

static struct SelectObject RoboterSelect1;

void __regargs RoboterCollision(struct Bob *mybob, struct Bob *enemybob)
{
	Select(&RoboterSelect1,enemybob);

	enemybob->bob_CollHandler = NULL;
}

static void Buy1(struct Bob *bob)
{
	ElementList[el_Faden].flag = Taken;
	AddGadget(Faden);
}

static void Buy2(struct Bob *bob)
{
	ElementList[el_Magnet].flag = Taken;
	AddGadget(Magnet);
}

static void Buy3(struct Bob *bob)
{
	ElementList[el_Roentgen].flag = Taken;
	AddGadget(Roentgengeraet);
}



static struct SelectObject RoboterSelect2 =
{
	0,5,
	0,-58,
	"Null Problemo\n"
	"Bitte sehr."
};

static struct SelectObject RoboterSelect1 =
{
	0,5,
	0,-58,
	"Technischer\n"
	"Hilfsroboter QX42\n"
	"Was kann ich\n"
	"Ihnen anbieten ?\n",

	0,0,"Nichts",NULL,NULL,
	0,0,"Messer,Nadel+Faden",&RoboterSelect2,&Buy1,
	0,0,"Den Magneten",NULL,&Buy2,
	0,0,"Das Roentgengeraet",NULL,&Buy3,
};
