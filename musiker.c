#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"

static struct SelectObject MusikerSelect1;
static struct SelectObject MusikerSelect2;
static struct SelectObject MusikerSelect3;


// Wird bei Kollision aufgerufen

void __regargs MusikerCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Musiker].flag != Solved)
	{
		Select(&MusikerSelect1,enemybob);
	}
	enemybob->bob_CollHandler = NULL;
}


static void MusikerSolved(struct Bob *bob)
{
	ElementList[el_Musiker].flag = Solved;

	RemoveGadget(Magnet);
	ChangeEmotion(7);
	ChangeMoney(17);
//	ShowMoney();
}

static void SelectMusiker(struct Bob *bob)
{
	short	oldmoney;

	if(ElementList[el_Magnet].flag == Taken)
	{
		oldmoney = MoneyObject.value;

		Select(&MusikerSelect2,bob);

		if(oldmoney != MoneyObject.value)
			ShowMoney();
	}
	else
	{
		Select(&MusikerSelect3,bob);
	}
}

static struct SelectObject MusikerSelect4 =
{
	0,5,
	-4,-24,

	"Danke lieber\n"
	"Freund. Nimm\n"
	"meine Tages-\n"
	"einnahmen.",NULL,NULL,
};

static struct SelectObject MusikerSelect3 =
{
	0,5,
	-4,-24,

	"..habe.. Mund-\n"
	"harmonika ...-\n"
	"schluckt.",

	0,0,"Tja da kann man\n"
		"nichts machen",NULL,NULL,
};

static struct SelectObject MusikerSelect2 =
{
	0,5,
	-4,-24,

	"..habe.. Mund-\n"
	"harmonika ...-\n"
	"schluckt",

	0,0,"Tja da kann man\n"
		"nichts machen",NULL,NULL,
	0,0,"Nehmen Sie diesen\n"
		"Magneten um sie\n"
		"hervorzuholen.\n",&MusikerSelect4,&MusikerSolved,
};

static struct SelectObject MusikerSelect1 =
{
	0,5,
	-4,-24,
	NULL,

	0,0,"Weiter",NULL,NULL,
	0,0,"Guten Tag\n"
		"fehlt Ihnen\n"
		"etwas ?\n",NULL,&SelectMusiker,
};
