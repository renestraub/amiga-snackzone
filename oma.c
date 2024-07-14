#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

static	struct	SelectObject OmaSelect1,OmaSelect2;
static	LONG	timer;

extern	APTR	OmaMove;
extern	APTR	OmaAnim;

void __regargs OmaHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Oma].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

void __regargs OmaCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Oma].flag == Talked)
	{
		timer++;
		return;
	}
	if(ElementList[el_Oma].flag != Solved)
	{
		Select(&OmaSelect1,enemybob);
	}
}

void __regargs OmaCheck(struct Bob *bob, LONG l)
{
	if(timer > 300)
	{
		Select(&OmaSelect2,bob);
		ChangeMoney(3);
		ChangeEmotion(5);
	
		StartFX(2);
		ShowMoney();

		ElementList[el_Oma].flag = Solved;
	}
	else
	{
		ElementList[el_Oma].flag = 0;
	}
	bob->bob_CollHandler = NULL;
}

static void HelpOma(struct Bob *bob)
{
	ElementList[el_Oma].flag = Talked;

	SetMovePrg(bob,&OmaMove,1,3);
	SetAnimPrg(bob,&OmaAnim,3);

	timer = 0;
}

static void NoHelpOma(struct Bob *bob)
{
	bob->bob_CollHandler = NULL;
}

static struct SelectObject OmaSelect2 =
{
	0,0,
	0,-48,
	"Tausend Dank,\n"
	"junger Mann.\n"
	"Hier nehmen Sie\n"
	"3 Taler - sparen\n"
	"Sie sie auf, und\n"
	"verprassen Sie\n"
	"sie nicht gleich."
};

static struct SelectObject OmaSelect1 =
{
	0,0,
	0,-48,
	"Junger Mann,\n"
	"waeren Sie so\n"
	"freundlich,\n"
	"mir ueber die\n"
	"Strasse zu\n"
	"helfen ?",

	0,0,"Tut mir leid. Ich\n"
		"habe keine Zeit.",NULL,&NoHelpOma,
	0,0,"Selbstverstaendlich\n"
		"gerne.\n",NULL,&HelpOma
};
