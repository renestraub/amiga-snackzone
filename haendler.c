#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "main.h"
#include "select.h"
#include "panel.h"
#include "sound.h"

static char Text1[] = { "Ich nehme die\n"
						"Ohrringe." };
static char Text2[] = { "Den Siegelring\n"
						"bitte." };
static char Text3[] = { "Ich moechte\n"
						"die Halskette." };
static char Text4[] = { "Nichts.\n" };

static struct SelectObject HaendlerSelect1 =
{
	0,0,
	0,-50,

	"Mein Angebot\n\n"
	"Ohrringe...1 Taler\n"
	"Siegelring.2 Taler\n"
	"Halskette..5 Taler",

	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL
};


static void KaufOhrring(struct Bob *bob)
{
	AddGadget(Ohrring);
	ChangeMoney(-1);

	ElementList[el_Ohrring].flag = Taken;
	StartFX(3);
	ShowMoney();
}

static void KaufSiegelring(struct Bob *bob)
{
	AddGadget(Ring);
	ChangeMoney(-2);

	ElementList[el_Siegelring].flag = Taken;
	StartFX(3);
	ShowMoney();
}

static void KaufHalskette(struct Bob *bob)
{
	AddGadget(Halskette);
	ChangeMoney(-5);

	ElementList[el_Halskette].flag = Taken;
	StartFX(3);
	ShowMoney();
}

static void InitHaendler(void)
{
	short i;

	i = 0;

	if(ElementList[el_Ohrring].flag == 0)
	{
		HaendlerSelect1.SelectText[i].text		= Text1;
		HaendlerSelect1.SelectText[i++].handler	= &KaufOhrring;
	}

	if(ElementList[el_Siegelring].flag == 0)
	{
		HaendlerSelect1.SelectText[i].text		= Text2;
		HaendlerSelect1.SelectText[i++].handler	= &KaufSiegelring;
	}

	if(ElementList[el_Halskette].flag == 0)
	{
		HaendlerSelect1.SelectText[i].text		= Text3;
		HaendlerSelect1.SelectText[i++].handler	= &KaufHalskette;
	}

	HaendlerSelect1.SelectText[i].text		= Text4;
	HaendlerSelect1.SelectText[i++].handler	= NULL;

	HaendlerSelect1.SelectText[i].text		= NULL;
}

void __regargs HaendlerCollision(struct Bob *bob)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		if(ElementList[el_Ohrring].flag != 0 &&
		   ElementList[el_Siegelring].flag != 0 &&
		   ElementList[el_Halskette].flag != 0)		return;

		ClearPfeil();
		
		InitHaendler();
		Select(&HaendlerSelect1,bob);
	}
}

